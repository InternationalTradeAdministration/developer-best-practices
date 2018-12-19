public interface common_IAccountsSelector
    extends fflib_ISObjectSelector
{
    List<Account> selectAll();
    List<Account> selectById(Set<Id> idSet);
    List<Account> selectByAccountNumber(Set<String> accountNumberSet);
}