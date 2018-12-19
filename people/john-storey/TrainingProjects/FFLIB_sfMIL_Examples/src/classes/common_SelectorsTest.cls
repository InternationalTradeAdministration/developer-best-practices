@isTest
private class common_SelectorsTest
{
    @isTest
    static void AccountsSelector()
    {
        List<Account> result = common_AccountsSelector.newInstance().selectById(new Set<Id> {});
        System.assert(result != null);
        System.assertEquals(0, result.size());
    }
}