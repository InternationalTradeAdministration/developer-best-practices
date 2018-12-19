public class common_AccountsSelector
    extends fflibext_SObjectSelector
    implements common_IAccountsSelector
{
    public static common_IAccountsSelector newInstance()
    {
        return (common_IAccountsSelector) fflibext_Application.Selector.newInstance( Account.SObjectType );
    }

    private Schema.sObjectType getSObjectType()
    {
        return Account.SObjectType;
    }

    private List<Schema.SObjectField> getAdditionalSObjectFieldList()
    {
        return new List<Schema.SObjectField> {};
    }

    public List<Account> selectAll()
    {
        return Database.query(newQueryFactory().toSOQL());
    }

    public List<Account> selectById(Set<Id> idSet)
    {
        return (List<Account>) selectSObjectsById(idSet);
    }

    public List<Account> selectByAccountNumber(Set<String> accountNumberSet)
    {
        fflib_QueryFactory qf = newQueryFactory();
        qf.selectField('CreatedBy.Name');
        qf.subselectQuery(Contact.SObjectType, true)
            .selectField('Contact.Id')
            .selectField('Contact.Name');
        qf.setCondition(Account.AccountNumber + ' in :accountNumberSet');
        qf.setOrdering(Account.Name, SortOrder.DESCENDING);
        qf.setLimit(5);

        return Database.query(qf.toSOQL());
    }
}