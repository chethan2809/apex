@isTest
private class ApplicationDailyUpdatesTests {

    @isTest
    private static void expireDeclineRuleTests() {
        Origination_Settings__mdt originationSetting = new Origination_Settings__mdt();
        originationSetting.Pricing_Expire_Days__c = 3;
        CustomMetaDataHelper.defaultOriginationSetting = originationSetting;

        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Status__c =  'OFFER SENT';
        application.Last_Status_Update_Date__c = system.today().addDays(-5);
        GeneralHelper.currentSystemDate = system.today();

        Test.startTest();
            ApplicationDailyUpdates.expireDeclineRule(application);
        Test.stopTest();

        System.assert(application!=null);
    }

    @isTest
    private static void expireDeclineRuleWithNullUpdate() {
        Origination_Settings__mdt originationSetting = new Origination_Settings__mdt();
        originationSetting.Pricing_Expire_Days__c = 3;
        CustomMetaDataHelper.defaultOriginationSetting = originationSetting;

        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Status__c = 'OFFER SENT';
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        Test.startTest();
            ApplicationDailyUpdates.expireDeclineRule(application);
        Test.stopTest();

        System.assert(application!=null);
    }

    @isTest
    private static void expireDeclineRuleWithConcurrrentExpireDays() {
        Origination_Settings__mdt originationSetting = new Origination_Settings__mdt();
        originationSetting.Concurrent_Expire_Days__c = 3;
        CustomMetaDataHelper.defaultOriginationSetting = originationSetting;

        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Status__c = 'NEW ENTERED';
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Last_Status_Update_Date__c = system.today().addDays(-5);
        GeneralHelper.currentSystemDate = system.today();

        Test.startTest();
            ApplicationDailyUpdates.expireDeclineRule(application);
        Test.stopTest();

        System.assert(application!=null);
    }

    @isTest
    private static void expireDeclineRuleOutsideExclusivityWithBroker() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountRecord.Name = 'Maher Industries LLC';
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '375043024';
        accountRecord.Biz_Start_Date__c = TestUtility.currentSystemDate.addYears(-10);
        accountRecord.Type = 'Borrower';
        accountRecord.Broker_Account__c = TestUtility.getFakeId(Account.getSObjectType());

        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Status__c = Applications.STATUS_CAN_SCORING;
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Last_Status_Update_Date__c = GeneralHelper.currentSystemDate.addDays(-5);
        application.genesis__Account__r = accountRecord;
        application.Auto_Renewed__c = true;
        application.Broker_Contact__c = TestUtility.getFakeId(Contact.getSObjectType());

        Test.startTest();
            ApplicationDailyUpdates.expireDeclineRule(application);
        Test.stopTest();

        System.assertEquals(Applications.STATUS_DECLINED, application.genesis__Status__c);
    }

    @isTest
    private static void expireDeclineRuleAutoRenewedWithCANDirect() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        CAN_General_Settings__c canGeneralSettings = new CAN_General_Settings__c();
        canGeneralSettings.Id = TestUtility.getFakeId(CAN_General_Settings__c.getSObjectType());
        canGeneralSettings.CAN_Renewal_expiration_days_after_payoff__c = 30;
        CustomSettingsHelper.generalSettings = canGeneralSettings;

        Account accountRecord = (Account) JSON.deserialize('{"Days_Since_Zero_Balance_Date__c" : 40}', Account.class);
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountRecord.Name = 'Maher Industries LLC';
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '375043024';
        accountRecord.Biz_Start_Date__c = TestUtility.currentSystemDate.addYears(-10);
        accountRecord.Type = 'Borrower';

        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Status__c = Applications.STATUS_CAN_SCORING;
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Last_Status_Update_Date__c = GeneralHelper.currentSystemDate.addDays(-5);
        application.genesis__Account__r = accountRecord;
        application.Auto_Renewed__c = true;

        Test.startTest();
            ApplicationDailyUpdates.expireDeclineRule(application);
        Test.stopTest();

        System.assertEquals(Applications.STATUS_DECLINED, application.genesis__Status__c);
    }
}