@isTest
private class CompuMailManagerTests {

    private class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    private class RestMockFail implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Failure Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(404);
            return res;
        }
    }

    @isTest
    private static void uploadCompuMailTest() {
        Test.setMock(HttpCalloutMock.class, new CompuMailCalloutMock());
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);

        Map<Id, Account> accountMap = new Map<Id, Account>();
        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());
        account.Merchant_ID__c = 'AVDGO234';
        account.Name = 'DUMMY';
        account.Doing_Business_As_Name__c = 'Test';
        account.Merchant_ID__c = 'Test';
        accountMap.put(account.Id, account);

        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.MailingCity = 'TEST';
        contact.MailingState = 'CA';
        contact.MailingStreet = 'Test Address';
        contact.MailingPostalCode = '22222';
        contact.MailingCountry = 'USA';
        contact.Last_Consumer_Credit_Pull__c = Date.newInstance(2020, 01, 02);
        contact.Last_Date_of_Inquiry__c = Date.newInstance(2020, 01, 02);
        contact.FICO_MKT__c = 22;
        contact.Reasons_for_Credit_Score__c = 'Time in Business';

        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>();
        genesis__Applications__c application = new genesis__Applications__c();
        application.Primary_Guarantor__c = contact.Id;
        application.Primary_Guarantor__r = contact;
        application.Underwriter__c = TestUtility.getFakeId(User.getSObjectType());
        application.Annual_Volume__c = 20000;
        application.OwnerId = TestUtility.getFakeId(User.getSObjectType());
        application.Type__c = 'New';
        application.Sales_Rep__c = TestUtility.getFakeId(User.getSObjectType());
        application.genesis__Account__c = account.Id;
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.AAN_Letter_Sent__c = false;
        application.Last_Status_Update_Date__c = Date.newInstance(2020, 01, 02);
        applicationMap.put(application.Id, application);

        List<clcommon__Party__c> partyList = new List<clcommon__Party__c>();
        clcommon__Party__c party = new clcommon__Party__c();
        party.clcommon__Contact__r = contact;
        party.genesis__Application__c = application.Id;
        party.genesis__Application__r = application;
        partyList.add(party);

        DateTime lastInquiryDate = GeneralHelper.currentSystemDateTime;
        Map<Id, DateTime> applicationIdToLastEnquiryDateMap = new Map<Id, DateTime>();
        applicationIdToLastEnquiryDateMap.put(application.Id, lastInquiryDate);

        Test.startTest();
            CompuMailManager.sendCompuMailForExperian(partyList, accountMap, applicationMap, applicationIdToLastEnquiryDateMap);
            CompuMailManager.sendCompuMailForAAN(partyList, accountMap, applicationMap);
            CompuMailManager.sendCompuMailForAbandonApplication(partyList, accountMap, applicationMap);
        Test.stopTest();

        System.assertEquals(22, party.clcommon__Contact__r.FICO_MKT__c);
    }

    @isTest
    private static void uploadExperianCompuMailException() {
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Map<Id, Account> accountMap = new Map<Id, Account>();
        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());
        account.Merchant_ID__c = 'AVDGO234';
        account.Name = 'DUMMY';
        account.Doing_Business_As_Name__c = 'Test';
        account.Merchant_ID__c = 'Test';
        accountMap.put(account.Id, account);

        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.MailingCity = 'TEST';
        contact.MailingState = 'CA';
        contact.MailingStreet = 'Test Address';
        contact.MailingPostalCode = '22222';
        contact.MailingCountry = 'USA';
        contact.Last_Consumer_Credit_Pull__c = Date.newInstance(2020, 01, 02);
        contact.Last_Date_of_Inquiry__c = Date.newInstance(2020, 01, 02);
        contact.FICO_MKT__c = 22;
        contact.Reasons_for_Credit_Score__c = 'Time in Business';

        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>();
        genesis__Applications__c application = new genesis__Applications__c();
        application.Primary_Guarantor__c = contact.Id;
        application.Primary_Guarantor__r = contact;
        application.Underwriter__c = TestUtility.getFakeId(User.getSObjectType());
        application.Annual_Volume__c = 20000;
        application.OwnerId = TestUtility.getFakeId(User.getSObjectType());
        application.Type__c = 'New';
        application.Sales_Rep__c = TestUtility.getFakeId(User.getSObjectType());
        application.genesis__Account__c = account.Id;
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.AAN_Letter_Sent__c = false;
        application.Last_Status_Update_Date__c = Date.newInstance(2020, 01, 02);
        applicationMap.put(application.Id, application);

        List<clcommon__Party__c> partyList = new List<clcommon__Party__c>();
        clcommon__Party__c party = new clcommon__Party__c();
        party.clcommon__Contact__r = contact;
        party.genesis__Application__c = application.Id;
        party.genesis__Application__r = application;
        partyList.add(party);

        DateTime lastInquiryDate = GeneralHelper.currentSystemDateTime;
        Map<Id, DateTime> applicationIdToLastEnquiryDateMap = new Map<Id, DateTime>();
        applicationIdToLastEnquiryDateMap.put(application.Id, lastInquiryDate);


        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        CompuMailManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Exception ex;
        Test.startTest();
            CompuMailManager.sendCompuMailForExperian(partyList, accountMap, applicationMap, applicationIdToLastEnquiryDateMap);
        Test.stopTest();

        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void uploadDeclineAANCompuMailException() {
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Map<Id, Account> accountMap = new Map<Id, Account>();
        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());
        account.Merchant_ID__c = 'AVDGO234';
        account.Name = 'DUMMY';
        account.Doing_Business_As_Name__c = 'Test';
        account.Merchant_ID__c = 'Test';
        accountMap.put(account.Id, account);

        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.MailingCity = 'TEST';
        contact.MailingState = 'CA';
        contact.MailingStreet = 'Test Address';
        contact.MailingPostalCode = '22222';
        contact.MailingCountry = 'USA';
        contact.Last_Consumer_Credit_Pull__c = Date.newInstance(2020, 01, 02);
        contact.Last_Date_of_Inquiry__c = Date.newInstance(2020, 01, 02);
        contact.FICO_MKT__c = 22;
        contact.Reasons_for_Credit_Score__c = 'Time in Business';

        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>();
        genesis__Applications__c application = new genesis__Applications__c();
        application.Primary_Guarantor__c = contact.Id;
        application.Primary_Guarantor__r = contact;
        application.Underwriter__c = TestUtility.getFakeId(User.getSObjectType());
        application.Annual_Volume__c = 20000;
        application.OwnerId = TestUtility.getFakeId(User.getSObjectType());
        application.Type__c = 'New';
        application.Sales_Rep__c = TestUtility.getFakeId(User.getSObjectType());
        application.genesis__Account__c = account.Id;
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.AAN_Letter_Sent__c = false;
        application.Last_Status_Update_Date__c = Date.newInstance(2020, 01, 02);
        applicationMap.put(application.Id, application);

        List<clcommon__Party__c> partyList = new List<clcommon__Party__c>();
        clcommon__Party__c party = new clcommon__Party__c();
        party.clcommon__Contact__r = contact;
        party.genesis__Application__c = application.Id;
        party.genesis__Application__r = application;
        partyList.add(party);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        CompuMailManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Exception ex;
        Test.startTest();
            CompuMailManager.sendCompuMailForAAN(partyList, accountMap, applicationMap);
        Test.stopTest();

        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void uploadAbandonApplicationCompuMailException() {
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Map<Id, Account> accountMap = new Map<Id, Account>();
        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());
        account.Merchant_ID__c = 'AVDGO234';
        account.Name = 'DUMMY';
        account.Doing_Business_As_Name__c = 'Test';
        account.Merchant_ID__c = 'Test';
        accountMap.put(account.Id, account);

        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.MailingCity = 'TEST';
        contact.MailingState = 'CA';
        contact.MailingStreet = 'Test Address';
        contact.MailingPostalCode = '22222';
        contact.MailingCountry = 'USA';
        contact.Last_Consumer_Credit_Pull__c = Date.newInstance(2020, 01, 02);
        contact.Last_Date_of_Inquiry__c = Date.newInstance(2020, 01, 02);
        contact.FICO_MKT__c = 22;
        contact.Reasons_for_Credit_Score__c = 'Time in Business';

        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>();
        genesis__Applications__c application = new genesis__Applications__c();
        application.Primary_Guarantor__c = contact.Id;
        application.Primary_Guarantor__r = contact;
        application.Underwriter__c = TestUtility.getFakeId(User.getSObjectType());
        application.Annual_Volume__c = 20000;
        application.OwnerId = TestUtility.getFakeId(User.getSObjectType());
        application.Type__c = 'New';
        application.Sales_Rep__c = TestUtility.getFakeId(User.getSObjectType());
        application.genesis__Account__c = account.Id;
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.AAN_Letter_Sent__c = false;
        application.Last_Status_Update_Date__c = Date.newInstance(2020, 01, 02);
        applicationMap.put(application.Id, application);

        List<clcommon__Party__c> partyList = new List<clcommon__Party__c>();
        clcommon__Party__c party = new clcommon__Party__c();
        party.clcommon__Contact__r = contact;
        party.genesis__Application__c = application.Id;
        party.genesis__Application__r = application;
        partyList.add(party);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        CompuMailManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Exception ex;
        Test.startTest();
            CompuMailManager.sendCompuMailForAbandonApplication(partyList, accountMap, applicationMap);
        Test.stopTest();

        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
    }
}