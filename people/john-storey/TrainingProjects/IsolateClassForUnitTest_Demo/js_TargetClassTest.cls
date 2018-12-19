@IsTest
private class js_TargetClassTest
{
    @IsTest
    static void contactCountPerAccount_WithoutClassFactory()
    {
        createMockData();
    
        // ----- Supply the mock data to the class being tested.
        js_TargetClass.mock_contactByAccountIdMap = contactByAccountIdMap;

        Test.startTest();
        Map<Id, Integer> testRestultMap = new js_TargetClass().numberOfContacts(accountList);
        Test.stopTest();

        // ----- Assert that everything is proper.
        System.assertNotEquals(null, testRestultMap);
        System.assertEquals(accountList.size(), testRestultMap.size());
        System.assertEquals(contactByAccountIdMap.get(accountList.get(0).Id).size(), testRestultMap.get(accountList.get(0).Id));
        System.assertEquals(contactByAccountIdMap.get(accountList.get(1).Id).size(), testRestultMap.get(accountList.get(1).Id));
        System.assertEquals(contactByAccountIdMap.get(accountList.get(2).Id).size(), testRestultMap.get(accountList.get(2).Id));
    }

    @IsTest
    static void contactCountPerAccount_UsingInterface()
    {
        createMockData();

        // Create the mock class and give to the Factory.
        // Requires the existence of a codified class; see mock_js_OtherClass below.
        js_IOtherClass mockOtherClass = new mock_js_OtherClass();
        mockOtherClass.setMockDataMap = mockContactByAccountIdMap;
        js_TargetClass.mock_jsOtherClass = mockOtherClass;

        Test.startTest();
        Map<Id, Integer> testRestultMap = new js_TargetClass().numberOfContacts(accountList);
        Test.stopTest();

        // ----- Assert that everything is proper.
        System.assertNotEquals(null, testRestultMap);
        System.assertEquals(accountList.size(), testRestultMap.size());
        System.assertEquals(contactByAccountIdMap.get(accountList.get(0).Id).size(), testRestultMap.get(accountList.get(0).Id));
        System.assertEquals(contactByAccountIdMap.get(accountList.get(1).Id).size(), testRestultMap.get(accountList.get(1).Id));
        System.assertEquals(contactByAccountIdMap.get(accountList.get(2).Id).size(), testRestultMap.get(accountList.get(2).Id));
    }

    @IsTest
    static void contactCountPerAccount_WithClassFactory()
    {
        createMockData();

        // Create the mock class and give to the Factory.
        // Requires the existence of a codified class; see mock_js_OtherClass below.
        js_IOtherClass mockOtherClass = new mock_js_OtherClass();
        mockOtherClass.setMockDataMap = mockContactByAccountIdMap;
        js_ClassFactory.setMock(js_IOtherClass.class, mockOtherClass);

        Test.startTest();
        Map<Id, Integer> testRestultMap = new js_TargetClass().numberOfContacts(accountList);
        Test.stopTest();

        // ----- Assert that everything is proper.
        System.assertNotEquals(null, testRestultMap);
        System.assertEquals(accountList.size(), testRestultMap.size());
        System.assertEquals(contactByAccountIdMap.get(accountList.get(0).Id).size(), testRestultMap.get(accountList.get(0).Id));
        System.assertEquals(contactByAccountIdMap.get(accountList.get(1).Id).size(), testRestultMap.get(accountList.get(1).Id));
        System.assertEquals(contactByAccountIdMap.get(accountList.get(2).Id).size(), testRestultMap.get(accountList.get(2).Id));
    }

    @IsTest
    static void contactCountPerAccount_WithFflibMockPattern()
    {
        createMockData();

        // Create the mock class and give to the Factory.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        js_IOtherClass mockOtherClass = (js_IOtherClass) mocks.mock(js_IOtherClass.class);

        // With this process, the mock class is dynamic; doesn't really exist in code.
        mocks.startStubbing();
        mocks
            .when(mockOtherClass.getContactsForAccounts(accountList))
            .thenReturn(mockContactByAccountIdMap);
        mocks.stopStubbing();
        js_ClassFactory.setMock(js_IOtherClass.class, mockOtherClass);

        Test.startTest();
        Map<Id, Integer> testRestultMap = new js_TargetClass().numberOfContacts(accountList);
        Test.stopTest();

        // ----- Assert that everything is proper.
        System.assertNotEquals(null, testRestultMap);
        System.assertEquals(accountList.size(), testRestultMap.size());
        System.assertEquals(contactByAccountIdMap.get(accountList.get(0).Id).size(), testRestultMap.get(accountList.get(0).Id));
        System.assertEquals(contactByAccountIdMap.get(accountList.get(1).Id).size(), testRestultMap.get(accountList.get(1).Id));
        System.assertEquals(contactByAccountIdMap.get(accountList.get(2).Id).size(), testRestultMap.get(accountList.get(2).Id));
    }

    @IsTest
    static void createAccountsForContacts()
    {
        List<Contact> contactList = new List<Contact>();

        contactList.add(
            new Contact(
                FirstName = 'Joe',
                LastName = 'Smith'));

        contactList.add(
            new Contact(
                FirstName = 'George',
                LastName = 'Wilson'));

        contactList.add(
            new Contact(
                FirstName = 'Irma',
                LastName = 'Morris'));

        js_TargetClass.forceTestStatus = true;

        Test.startTest()
        new js_TargetClass().methodCreatingNewData(contactList);
        Test.stopTest();

        List<Account> newAccountList = js_TargetClass.test_AccountList;

        System.assertNotEquals(null, newAccountList);
        System.assertEquals(contactList.size(), newAccountList.size());
    }

    private class mock_js_OtherClass
        implements js_IOtherClass
    {
        private Map<Id, List<Contact>> mockDataMap = null;

        public void setMockDataMap(Map<Id, List<Contact>> mock)
        {
            mockDataMap = mock;
        }

        public Map<Id, List<Contact>> getContactsForAccounts(List<Account> accountList)
        {
            return mockDataMap;
        }
    }

    static List<Account> mockAccountList = null;
    static Map<Id, List<Contact>> mockContactByAccountIdMap = null;

    static void createMockData()
    {
        // ----- Create some Accounts
        mockAccountList = new List<Account>();

        mockAccountList.add(
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Smith Company'
            )
        );

        mockAccountList.add(
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType)
            )
        );

        mockAccountList.add(
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType)
            )
        );

        // ----- While creating the Contact-Account map, create some related Contacts.
        mockContactByAccountIdMap = new Map<Id, List<Contact>>();

        mockContactByAccountIdMap.put(mockAccountList.get(0).Id, new List<Contact>());
        mockContactByAccountIdMap.get(mockAccountList.get(0).Id).add(
            new Contact(
                Id = fflib_IDGenerator.generate(Contact.SObjectType),
                AccountId = mockAccountList.get(0).Id
            )
        );
        mockContactByAccountIdMap.get(mockAccountList.get(0).Id).add(
            new Contact(
                Id = fflib_IDGenerator.generate(Contact.SObjectType),
                AccountId = mockAccountList.get(0).Id
            )
        );

        mockContactByAccountIdMap.put(mockAccountList.get(1).Id, new List<Contact>());
        mockContactByAccountIdMap.get(mockAccountList.get(1).Id).add(
            new Contact(
                Id = fflib_IDGenerator.generate(Contact.SObjectType),
                AccountId = mockAccountList.get(1).Id
            )
        );

        mockContactByAccountIdMap.put(mockAccountList.get(2).Id, new List<Contact>());
        mockContactByAccountIdMap.get(mockAccountList.get(2).Id).add(
            new Contact(
                Id = fflib_IDGenerator.generate(Contact.SObjectType),
                AccountId = mockAccountList.get(2).Id
            )
        );
    }
}