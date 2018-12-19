@isTest
private class common_ServiceExampleTest
{
    @isTest
    static void useTheService()
    {
        Account acct = new Account();
        acct.Name = 'Bob\'s Soda Shop';
        insert acct;

        System.debug('Service result is:\n' + common_ServiceExampleImpl.AServiceMethod(acct));
    }
}