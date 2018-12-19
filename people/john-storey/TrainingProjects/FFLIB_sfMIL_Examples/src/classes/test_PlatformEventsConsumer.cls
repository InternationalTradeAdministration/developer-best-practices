public class test_PlatformEventsConsumer
    implements core_IEventsConsumer
{
    public void setEvents( List<SObject> events )
    {
        System.debug('Event received:\n' + JSON.serializePretty(events.get(0), true));
    }

    public void execute(QueueableContext context)
    {
        // Not implemented.
    }
}