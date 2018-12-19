public interface core_IEventsConsumer
    extends Queueable
{
    void setEvents( List<SObject> events );
}