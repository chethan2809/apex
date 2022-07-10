@isTest
private class TestPartnerAPIHelpers {


    @isTest
    static void genericPartnerAPIValidation() {
        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
         '{ "Name" : "APP-0000000678"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        PartnerAPIHelpers.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        User user = (User) JSON.deserialize(
         '{ "AccountId" : "01p02000000EXrQ"}' , User.class
        );
        user.Id = TestUtility.getFakeId(User.getSObjectType());
        user.Email = 'test@gmail.com';
        user.ContactId = TestUtility.getFakeId(Contact.getSObjectType());

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User>{user};
        PartnerAPIHelpers.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        Account account = (Account) JSON.deserialize(
            '{ "Id" : "01p02000000EXrQ"}' , Account.class
        );
        account.Name = 'TestPartnerPAIHelper';
        account.Partner_API_Key__c = GeneralHelper.generateUniqueReferenceId(account.Id);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{account};
        PartnerAPIHelpers.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Test.startTest();
            Map<String, Object> partnerAPIValidation =  PartnerAPIHelpers.genericPartnerAPIValidation(user.Email, null, account.Partner_API_Key__c);
        Test.stopTest();
    }

    @isTest
    static void constructResponseMap() {
        Map<String,String> argumentsMap = new Map<String,String> {'Name' => 'Name'};
        sObject sobj;
        Account acc = new Account();
        acc.Name = 'testname';

        Test.startTest();
            Map<String, Object> constResponseMap =  PartnerAPIHelpers.constructResponseMap(acc, argumentsMap);
        Test.stopTest();

        System.assertEquals(acc.Name, constResponseMap.get('Name'));
    }

    @isTest
    static void constructMapResponse() {
        Map<String,String> argumentsMap = new Map<String,String> {'Name' => 'Name'};
        Map<String,String> record = new Map<String,String> {'Name' => 'Name'};

        Test.startTest();
            Map<String, Object> constResponseMap =  PartnerAPIHelpers.constructResponseMap(record, argumentsMap);
        Test.stopTest();

        System.assertEquals(record.get('Name'), constResponseMap.get('Name'));
    }

    @isTest
    static void generateErrorLog() {
        String request = '{"application":"APP-0000000664","consentAccepted":true,"partnerDetails":{"partnerEmail":"test_acc@mailinator.com"}}';
        String error = 'something went wrong';
        String apiName = 'PartnerDocumentUploadAPI';
        String origin = 'PartnerAPIHelpers';
        String partnerAPIKey = GeneralHelper.generateUniqueReferenceId('partnerAPIKey');

        Test.startTest();
            PartnerAPIHelpers.generateErrorLog(origin, request, error, apiName, partnerAPIKey);
        Test.stopTest();
    }
}