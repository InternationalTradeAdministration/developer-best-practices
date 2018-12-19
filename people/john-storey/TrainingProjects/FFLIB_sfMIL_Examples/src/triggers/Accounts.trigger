trigger Accounts on Account
(after insert)
{
    fflib_SObjectDomain.triggerHandler(common_Accounts.class);
}