public class js_TargetClass
{

    public Map<Id, Integer> numberOfContacts(List<Account> accountList)
    {
        Map<Id, Integer> resultMap = new Map<Id, Integer>();

        Map<Id, List<Contact>> contactsByAccountIdMap = null;

        if (!isTest())
        {
            contactsByAccountIdMap = js_OtherClass.getContactsForAccounts(accountList);
        }
        else
        {
            contactsByAccountIdMap = mock_contactByAccountIdMap;
        }

        for (Id acctId : contactsByAccountIdMap.keySet())
        {
            resultMap.put(acctId, contactsByAccountIdMap.get(acctId).size());
        }

        return resultMap;
    }

    public Map<Id, Integer> numberOfContacts_usingInterfaceInjection(List<Account> accountList)
    {
        Map<Id, Integer> resultMap = new Map<Id, Integer>();

        Map<Id, List<Contact>> contactsByAccountIdMap = null;

        if (!isTest())
        {
            otherClassInstance = new js_OtherClass();
        }
        else
        {
            otherClassInstance = mock_jsOtherClass;
        }

        contactsByAccountIdMap = otherClassInstance.getContactsForAccounts(accountList);

        for (Id acctId : contactsByAccountIdMap.keySet())
        {
            resultMap.put(acctId, contactsByAccountIdMap.get(acctId).size());
        }

        return resultMap;
    }

    public Map<Id, Integer> numberOfContacts_usingClassFactory(List<Account> accountList)
    {
        Map<Id, Integer> resultMap = new Map<Id, Integer>();

        Map<Id, List<Contact>> contactsByAccountIdMap = null;

        js_IOtherClass oc = (js_IOtherClass) js_ClassFactory.newInstance(js_IOtherClass.class);
        contactsByAccountIdMap = oc.getContactsForAccounts(accountList);

        for (Id acctId : contactsByAccountIdMap.keySet())
        {
            resultMap.put(acctId, contactsByAccountIdMap.get(acctId).size());
        }

        return resultMap;
    }

    public void methodCreatingNewData(List<Contact> contactList)
    {
        List<Account> accountList = new List<Account>();

        for (Contact ctc : contactList)
        {
            accountList.add(
                new Account(
                    Name = ctc.FirstName + ' ' + ctc.LastName));
        }

        test_AccountList = accountList;
        if (!isTest()) insert accountList;  // Doing so with mock data may cause DML exception.

        // Certainly we'd want to connect the Contact to the new Account
        // but I'm skipping that to keep the demo simple.
    }

    // ------- Test Context -----------------------------

    @TestVisible
    private static Boolean forceTestStatus = false;

    @TestVisible
    private static Map<Id, List<Contact>> mock_contactByAccountIdMap = null;

    @TestVisible
    private static List<Account> test_AccountList = null;

    @TestVisible
    private static js_IOtherClass mock_jsOtherClass = null;

    private static Boolean isTest()
    {
        return
            forceTestStatus ||
            mock_contactByAccountIdMap != null ||
            mock_jsOtherClass != null
    }
}