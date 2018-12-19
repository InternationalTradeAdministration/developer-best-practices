@isTest
private class common_AccountsTest
{
    @isTest
    static void basicTest()
    {
        List<Account> accountList = new List<Account>();
        accountList.add(new Account());
        common_IAccounts dom = (common_IAccounts) fflibext_Application.Domain.newInstance(accountList);
    }
}