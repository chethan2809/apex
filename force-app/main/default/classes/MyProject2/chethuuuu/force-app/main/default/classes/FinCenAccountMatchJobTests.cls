@isTest
private class FinCenAccountMatchJobTests {
    @isTest
    private static void finCenReportAccountMatchJob() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        GeneralHelper.currentSystemDateTime = DateTime.newInstance(GeneralHelper.currentSystemDate, DateTime.Now().Time());
        Account accountRecord = TestUtility.generateAccount();
        accountRecord.BillingBuildingNumber__c = '340';
        accountRecord.BillingStreet = '663 BRYANT BLVD';
        accountRecord.BillingCity = 'Rock Hill';
        accountRecord.BillingState = 'NC';
        accountRecord.BillingPostalCode = '29732';
        accountRecord.Doing_Business_As_Name__c = 'SURGERY CENTER';
        accountRecord.Legal_Name__c = 'SURGERY CENTER';
        accountRecord.Business_Name__c = 'SURGERY CENTER';
        accountRecord.Name = 'SURGERY CENTER';
        accountRecord.Business_Tax_ID__c = '783960579';
        accountRecord.Type = Accounts.BORROWER;
        accountRecord.CLS_Active_Contract__c = true;
        accountRecord.Last_Date_of_Activity__c = GeneralHelper.currentSystemDate.addDays(-60);
        accountRecord.Product_Type__c = GeneralConstants.PRODUCT_TYPE_FLEXIBLE_AMZ_LOAN;

        insert accountRecord;

        Origination_Settings__mdt originationSettings = new Origination_Settings__mdt();
        originationSettings.FinCen_Account_Match_Batch_Size__c = 10;
        CustomMetaDataHelper.defaultOriginationSetting = originationSettings;

        CAN_General_Settings__c canGeneralSetting = new CAN_General_Settings__c();
        canGeneralSetting.Active_Days_For_FinCen_Record__c = 90;
        canGeneralSetting.Id = TestUtility.getFakeId(CAN_General_Settings__c.getSObjectType());
        canGeneralSetting.FinCen_Threshold_Value__c = 85;
        canGeneralSetting.FinCen_Eligible_Last_Funded_Date__c = GeneralHelper.currentSystemDate.addDays(-60);
        canGeneralSetting.FinCen_Days_Since_Last_Funded_Date__c = 100;
        CustomSettingsHelper.generalSettings = canGeneralSetting;

        DBManagerTestsStub documentDBStubInstance = new DBManagerTestsStub();
        FinCenRecordMatchManager.documentDBInstance = (DocumentDB) Test.createStub(DocumentDB.class, documentDBStubInstance);

        Test.startTest();
            FinCenAccountMatchJob.execute();
        Test.stopTest();

        List<Account> accountList = [
            SELECT Id, Name, Legal_Name__c, Business_Name__c, Doing_Business_As_Name__c, Merchant_ID__c, Business_Tax_ID__c
            FROM Account
            WHERE Id = :accountRecord.Id
        ];

        System.assertEquals(1, accountList.size());
        System.assertEquals('SURGERY CENTER', accountList.get(0).Legal_Name__c);
    }

    @isTest
    private static void finCenReportAccountMatchJobException() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        GeneralHelper.currentSystemDateTime = DateTime.newInstance(GeneralHelper.currentSystemDate, DateTime.Now().Time());
        CAN_General_Settings__c canGeneralSetting = new CAN_General_Settings__c();
        canGeneralSetting.Active_Days_For_FinCen_Record__c = 90;
        canGeneralSetting.Id = TestUtility.getFakeId(CAN_General_Settings__c.getSObjectType());
        canGeneralSetting.FinCen_Threshold_Value__c = 85;
        canGeneralSetting.FinCen_Eligible_Last_Funded_Date__c = GeneralHelper.currentSystemDate.addDays(-60);
        canGeneralSetting.FinCen_Days_Since_Last_Funded_Date__c = 100;
        CustomSettingsHelper.generalSettings = canGeneralSetting;

        Origination_Settings__mdt originationSettings = new Origination_Settings__mdt();
        CustomMetaDataHelper.defaultOriginationSetting = originationSettings;

        DBManagerTestsStub documentDBStubInstance = new DBManagerTestsStub();
        FinCenRecordMatchManager.documentDBInstance = (DocumentDB) Test.createStub(DocumentDB.class, documentDBStubInstance);
        Exception ex;

        Test.startTest();
            try {
                FinCenAccountMatchJob.execute();
            } catch (Exception e) {
                ex = e;
            }
        Test.stopTest();

        System.assertEquals('FinCen_Account_Match_Batch_Size__c is null', ex.getMessage());
    }
}