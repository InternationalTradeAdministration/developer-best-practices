public class common_MockUsageInTest_TargetClass
{
    public List<Account> getAllAccounts()
    {
        return common_AccountsSelector.newInstance().selectAll();
    }

    public List<Account> getAccountsById(Set<Id> idSet)
    {
        return common_AccountsSelector.newInstance().selectById(idSet);
    }
}