trigger core_PlatformEvents on core_Event__e
(after insert)
{
    core_PlatformEventsDistributor.triggerHandler();
}