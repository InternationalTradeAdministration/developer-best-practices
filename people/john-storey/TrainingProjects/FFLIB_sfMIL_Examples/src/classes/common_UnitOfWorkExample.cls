@isTest
private class common_UnitOfWorkExample
{
    @isTest
    static void basicTest()
    {
        Account acct = new Account();
        acct.Name = 'Bob\'s Bagel Shop';

        fflib_ISObjectUnitOfWork uow = fflibext_Application.UnitOfWork.newInstance();
        uow.registerNew(acct);
        uow.commitWork();

        acct = [select Id, Name from Account where Id = :acct.Id].get(0);
        System.debug(acct);
    }
}