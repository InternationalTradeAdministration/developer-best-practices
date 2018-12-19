public class common_Accounts
    extends fflib_SObjectDomain
    implements common_IAccounts
{
    private ValidationException validationException = null;

    public static common_IAccounts newInstance(List<Account> records)
    {
        return (common_IAccounts) fflibext_Application.Domain.newInstance(records);
    }

    public static common_IAccounts newInstance(Set<Id> recordIds)
    {
        return (common_IAccounts) fflibext_Application.Domain.newInstance(recordIds);
    }

    public common_Accounts()
    {
        super(new List<Account>());
    }

    public common_Accounts(List<Account> records)
    {
        super(records);
    }

    private ValidationException getValidationException()
    {
        if ( validationException == null )
        {
            validationException = new ValidationException();
        }

        return validationException;
    }

    private boolean isValidationExceptionsPresent()
    {
        return validationException != null;
    }

    public override void onBeforeInsert()
    {
    }

    public override void onBeforeUpdate(Map<Id,SObject> existingRecords)
    {
    }

    public override void onAfterInsert()
    {
    }

    public override void onAfterUpdate(Map<Id,SObject> existingRecords)
    {
    }

    public override void onAfterDelete()
    {
    }
    public class ValidationException
        extends Exception
    {
    }

    public class Constructor
        implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct()
        {
            return new common_Accounts();
        }

        public fflib_SObjectDomain construct(List<Account> sObjectList)
        {
            return new common_Accounts(sObjectList);
        }
    }
}