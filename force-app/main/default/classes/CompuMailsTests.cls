@isTest
private class CompuMailsTests {
    @isTest
    private static void buildCompuMailWrapperTest() {
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
        application.AAN_Letter_Sent__c = true;
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
            List<String> csvRowValuesForExperian = CompuMails.buildCompuMailWrapperForExperian(partyList, accountMap, applicationMap, applicationIdToLastEnquiryDateMap);
            List<String> csvRowValuesForAAN = CompuMails.buildCompuMailWrapperForAAN(partyList, accountMap, applicationMap);
            List<String> csvRowValuesForAbandonApplication = CompuMails.buildCompuMailWrapperForAbandonApplication(partyList, accountMap, applicationMap);
        Test.stopTest();

        System.assertEquals(1, csvRowValuesForExperian.size());
        System.assertEquals(1, csvRowValuesForAAN.size());
        System.assertEquals(1, csvRowValuesForAbandonApplication.size());
    }

    @isTest
    private static void buildAANCompuMailWrapperForDefaultFicoScore() {
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
        contact.FICO_MKT__c = 9001;
        contact.Reasons_for_Credit_Score__c = 'Time in Business';

        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>();
        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-00000102", "Business_Type__c" : "Sole Proprietorship"}' ,
            genesis__Applications__c.class
        );
        application.Primary_Guarantor__c = contact.Id;
        application.Primary_Guarantor__r = contact;
        application.Underwriter__c = TestUtility.getFakeId(User.getSObjectType());
        application.Annual_Volume__c = 20000;
        application.OwnerId = TestUtility.getFakeId(User.getSObjectType());
        application.Type__c = 'New';
        application.Sales_Rep__c = TestUtility.getFakeId(User.getSObjectType());
        application.genesis__Account__c = account.Id;
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.AAN_Letter_Sent__c = true;
        application.Last_Status_Update_Date__c = Date.newInstance(2020, 01, 02);
        applicationMap.put(application.Id, application);

        List<clcommon__Party__c> partyList = new List<clcommon__Party__c>();
        clcommon__Party__c party = new clcommon__Party__c();
        party.clcommon__Contact__r = contact;
        party.genesis__Application__c = application.Id;
        party.genesis__Application__r = application;
        partyList.add(party);

        Test.startTest();
            List<String> csvRowValuesForAAN = CompuMails.buildCompuMailWrapperForAAN(partyList, accountMap, applicationMap);
        Test.stopTest();

        System.assertEquals(1, csvRowValuesForAAN.size());
    }

    @isTest
    private static void getBusinessDBAName() {
        Map<Id, Account> accountMap = new Map<Id, Account>();
        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());
        account.Merchant_ID__c = 'AVDGO234';
        account.Name = 'DUMMY';
        account.Legal_Name__c = 'Test';
        accountMap.put(account.Id, account);

        String businessDBAName;
        Test.startTest();
            businessDBAName = CompuMails.getBusinessDBAName(account.Id, accountMap);
        Test.stopTest();

        System.assertEquals(account.Legal_Name__c, businessDBAName);
    }
}