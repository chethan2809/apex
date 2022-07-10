@isTest(isParallel=true)
private class TestPartnerGetApplicationStatusManager {

    @isTest
    private static void validateRequest() {
        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());
        account.Name = 'TestPartnerCal';
        account.Partner_API_Key__c = GeneralHelper.generateUniqueReferenceId(account.Id);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{account};
        PartnerAPIHelpers.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Contact contact = new Contact();
        contact.LastName = 'test';
        contact.AccountId = account.Id;
        contact.Id = TestUtility.getFakeId(Contact.getSObjectType());

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact>{contact};
        PartnerAPIHelpers.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        Map<String, String> testUserMap = new Map<String, String>();
        testUserMap.put('Id', TestUtility.getFakeId(User.getSObjectType()));
        testUserMap.put('ContactId', contact.Id);
        testUserMap.put('AccountId', contact.AccountId);
        testUserMap.put('Email', 'no@email.com');
        String strUser = JSON.serialize(testUserMap);
        User testUser = (User) JSON.deserialize(strUser, User.class);

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User>{testUser};
        PartnerAPIHelpers.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        Map<String, String> applicationMap = new Map<String, String>();
        applicationMap.put('Id', TestUtility.getFakeId(genesis__Applications__c.getSObjectType()));
        applicationMap.put('Name', 'APP-0000000678');
        applicationMap.put('Broker_Contact__c', testUser.ContactId);
        applicationMap.put('genesis__Status__c', Applications.STATUS_APPROVED);
        applicationMap.put('Overall_Status__c', Applications.STATUS_APPROVED);
        String jsonString = JSON.serialize(applicationMap);
        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(jsonString, genesis__Applications__c.class);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        PartnerAPIHelpers.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        RestRequest request = new RestRequest();

        request.addHeader('httpMethod', 'GET');
        request.requestUri = '/services/apexrest/v1/partner/applicationstatus/';
        request.addParameter('application', application.Name);
        request.addParameter('partnerEmail', testUser.Email);
        request.addParameter('partnerAPIKey', account.Partner_API_Key__c);

        Test.startTest();
            Map<String, Object> responseMap = PartnerGetApplicationStatusManager.getApplicationStatus(request);
        Test.stopTest();

        System.assert(responseMap != null);
    }
}