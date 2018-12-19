@isTest
private class common_MockUsageInTest
{
    @isTest
    static void basicExample()
    {
        // ----- Create some mock Accounts.  These DO NOT exist in the org.
        Account acct1 = new Account();
        acct1.Id = fflib_IdGenerator.generate(Account.SObjectType);
        acct1.Name = 'Bob\'s Bagel Shop';

        Account acct2 = new Account();
        acct2.Id = fflib_IdGenerator.generate(Account.SObjectType);
        acct2.Name = 'Eat at Joe\'s';

        List<Account> mockAccountList = new List<Account> {acct1, acct2};

        // NOTE: The Accounts ARE NOT being inserted to the org.

        // ----- Prove that the org DOES NOT have any Accounts.
        List<Account> accountList = new common_MockUsageInTest_TargetClass().getAllAccounts();
        System.assertEquals(0, accountList.size());

        // ----- Create a mock Account selector with 2 pertinent methods.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        common_IAccountsSelector mockAccountsSelector = (common_IAccountsSelector) mocks.mock(common_IAccountsSelector.class);

        mocks.startStubbing();

        // This impertinent method is required by the Factory in order 
        // to determine which SObject it's associated to.
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);

        mocks.when(mockAccountsSelector.selectAll()).thenReturn(mockAccountList);
        mocks.when(mockAccountsSelector.selectById(new Set<Id> {acct2.Id})).thenReturn(new List<Account> {acct2});

        mocks.stopStubbing();

        fflibext_Application.Selector.setMock(mockAccountsSelector);

        // ----- Prove that calling the same class method yields Accounts.
        accountList = new common_MockUsageInTest_TargetClass().getAllAccounts();
        System.assertEquals(mockAccountList.size(), accountList.size());

        // ----- Furthermore, prove that the SelectById method works as expected.
        accountList = new common_MockUsageInTest_TargetClass().getAccountsById(new Set<Id> {acct2.Id});
        System.assertEquals(1, accountList.size());
    }
}