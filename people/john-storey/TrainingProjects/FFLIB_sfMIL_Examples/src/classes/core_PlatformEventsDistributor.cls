public class core_PlatformEventsDistributor
{
    public enum MatcherRules
    {
        MatchPlatformEventBusAndEventCategoryAndEventName,
        MatchPlatformEventBusAndEventCategory,
        MatchPlatformEventBusAndEventName,
        MatchPlatformEventBus
    }

    private static string EVENT_CATEGORY_FIELD_NAME = 'EventCategory__c'.toLowerCase();
    private static string EVENT_NAME_FIELD_NAME = 'EventName__c'.toLowerCase();

    // hide the default constructor
    private core_PlatformEventsDistributor() { }

    public static void triggerHandler()
    {
        //from this method we can gain access to the incoming Event__e records
        //  via the Trigger.new context variable
        if (Trigger.isExecuting
            && Trigger.isAfter
            && Trigger.isInsert)
        {
            triggerHandler( trigger.new );
        }
    }

    @TestVisible
    private static void triggerHandler( List<SObject> events )
    {
        System.debug('<ojs> events:\n' + events);

        // the platform events come in.
        if ( events != null && ! events.isEmpty() )
        {
            // extract the event payloads
            Set<String> eventNameSet = core_Utils.generateStringSetFromField( events, core_Event__e.EventName__c );
            Set<String> eventCategorySet = core_Utils.generateStringSetFromField( events, core_Event__e.EventCategory__c );

            Schema.DescribeSObjectResult platformEventBusDescribe = events.getSobjectType().getDescribe();

            // need to read all available core_EventConsumerSubscription__mdt records for this event SObjectType
            // SOQL targeting custom MDT tables does not support the OR operator.  Manually filter.
            // https://help.salesforce.com/articleView?id=custommetadatatypes_limitations.htm
            List<core_EventConsumerSubscription__mdt> subscriptionRecords = new List<core_EventConsumerSubscription__mdt>();
            for
            (
                core_EventConsumerSubscription__mdt ecs :
                [
                    select
                        Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, 
                        Consumer__c, 
                        EventBus__c,
                        EventCategory__c, 
                        EventName__c, 
                        IsActive__c, 
                        MatcherRule__c
                    from core_EventConsumerSubscription__mdt
                    where IsActive__c = true and EventBus__c = :platformEventBusDescribe.getName()
                ]
            )
            {
                if (eventCategorySet.contains(ecs.EventCategory__c) || eventNameSet.contains(ecs.EventName__c))
                {
                    subscriptionRecords.add(ecs);
                }
            }

            System.debug('<ojs> subscriptionRecords:\n' + subscriptionRecords);

            core_IEventsConsumer consumer = null;

            List<SObject> eventBatchForSubscriber = new List<SObject>();

            Set<String> platformEventBusAvailableFieldsSet = platformEventBusDescribe.fields.getMap().keyset();

            // for each core_EventConsumerSubscription__mdt record, instantiate the Apex class found in the Consumer field
            for ( core_EventConsumerSubscription__mdt subscriptionRecord : subscriptionRecords )
            {
                eventBatchForSubscriber.clear();

                // sort through the events and only select the ones that this subscriber is interested.
                for ( SObject event : events )
                {
                    System.debug(
                        '<ojs> Comparing ...\n' +
                        'platformEventBusDescribe:\n\t' + platformEventBusDescribe + '\n' +
                        'platformEventBusDescribe.getName():\n\t' + platformEventBusDescribe.getName() + '\n' +
                        'subscriptionRecord:\n\t' + subscriptionRecord + '\n' +
                        'event:\n\t' + event);

                    // Match on EventCategory__c and EventName__c
                    if ( platformEventBusDescribe.getName().equalsIgnoreCase( subscriptionRecord.EventBus__c )
                        && MatcherRules.MatchPlatformEventBusAndEventCategoryAndEventName.name().equalsIgnoreCase( subscriptionRecord.MatcherRule__c )
                        && platformEventBusAvailableFieldsSet.contains( EVENT_CATEGORY_FIELD_NAME )
                        && platformEventBusAvailableFieldsSet.contains( EVENT_NAME_FIELD_NAME )
                        && subscriptionRecord.EventCategory__c.equalsIgnoreCase( (String)event.get( EVENT_CATEGORY_FIELD_NAME ) )
                        && subscriptionRecord.EventName__c.equalsIgnoreCase( (String)event.get( EVENT_NAME_FIELD_NAME ) ) )
                    {
                        System.debug('<ojs> match #1');
                        eventBatchForSubscriber.add( event );
                    }
                    // Match on EventCategory__c
                    else if ( platformEventBusDescribe.getName().equalsIgnoreCase( subscriptionRecord.EventBus__c )
                        && MatcherRules.MatchPlatformEventBusAndEventCategory.name().equalsIgnoreCase( subscriptionRecord.MatcherRule__c )
                        && platformEventBusAvailableFieldsSet.contains( EVENT_CATEGORY_FIELD_NAME )
                        && subscriptionRecord.EventCategory__c.equalsIgnoreCase( (String)event.get( EVENT_CATEGORY_FIELD_NAME ) ) )
                    {
                        System.debug('<ojs> match #2');
                        eventBatchForSubscriber.add( event );
                    }
                    // Match on EventName__c
                    else if ( platformEventBusDescribe.getName().equalsIgnoreCase( subscriptionRecord.EventBus__c )
                        && MatcherRules.MatchPlatformEventBusandEventName.name().equalsIgnoreCase( subscriptionRecord.MatcherRule__c )
                        && platformEventBusAvailableFieldsSet.contains( EVENT_NAME_FIELD_NAME )
                        && subscriptionRecord.EventName__c.equalsIgnoreCase( (String)event.get( EVENT_NAME_FIELD_NAME ) ) )
                    {
                        System.debug('<ojs> match #3');
                        eventBatchForSubscriber.add( event );
                    }
                    // Match sole because it is an event on this specific platform event bus
                    else if ( platformEventBusDescribe.getName().equalsIgnoreCase( subscriptionRecord.EventBus__c )
                        && MatcherRules.MatchPlatformEventBus.name().equalsIgnoreCase( subscriptionRecord.MatcherRule__c ) )
                    {
                        System.debug('<ojs> match #4');
                        eventBatchForSubscriber.add( event );
                    }
                    else
                    {
                        System.debug('<ojs> no match');
                    }
                }

                System.debug('<ojs> eventBatchForSubscriber:\n' + eventBatchForSubscriber);

                if ( ! eventBatchForSubscriber.isEmpty() )
                {
                    // now that the events have been sorted for this specific subscription, distribute them to that subscriber
                    try 
                    {
                        System.debug('<ojs> attempting to construct the consumer');
                        System.debug('<ojs> subscriptionRecord.Consumer__c:\n' + subscriptionRecord.Consumer__c);

                        // verify that the class exists and that class implements the core_IEventsConsumer interface
                        consumer = (core_IEventsConsumer)(Type.forName( subscriptionRecord.Consumer__c ).newInstance());

                        System.debug('<ojs> successfully constructed');

                        // use the setEvents() method to set the payload
                        consumer.setEvents( eventBatchForSubscriber );

                        //  and then enqueue the consumer class 
                        Id jobId = System.enqueueJob( consumer );

                        System.debug('<ojs> job enqueued: ' + jobId);
                    }
                    catch (Exception e)
                    {
                        system.debug( e );
                        System.debug( subscriptionRecord );
                        System.debug( eventBatchForSubscriber );
                    }
                }
            }
        }
    }
}