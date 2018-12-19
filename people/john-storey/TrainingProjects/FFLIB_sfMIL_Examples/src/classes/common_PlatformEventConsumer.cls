public class common_PlatformEventConsumer
    implements core_IEventsConsumer
{
    private List<SObject> eventSobjects = new List<SObject>();

    public void setEvents(List<SObject> eventSobjects)
    {
        System.debug('<ojs> common_PlatformEventConsumer.setEvents:\n' + eventSobjects);
        this.eventSobjects = eventSobjects;
    }

    public void execute(QueueableContext ctx)
    {
        System.debug('<ojs> common_PlatformEventConsumer.execute');
        System.debug('<ojs> eventSobjects:\n' + eventSobjects);

        for (SObject sobj : eventSobjects)
        {
            core_Event__e evt = (core_Event__e) sobj;

            // extract the data from the events.
        }

        // do something with the data.
    }
}