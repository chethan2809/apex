@isTest
private class FinCenContactMatchJobTests {
    @isTest
    private static void finCenReportContactMatchJob() {
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

        Contact contactRecord = TestUtility.generateContact();
        contactRecord.LastName = 'Troiano';
        contactRecord.FirstName = 'Andy';
        contactRecord.MailingBuildingNumber__c = '540';
        contactRecord.MailingStreet = '340 Westover Drive';
        contactRecord.MailingCity = 'Woodstock';
        contactRecord.MailingState = 'GA';
        contactRecord.MailingPostalCode = '30188';
        contactRecord.genesis__SSN__c = '123121234';
        contactRecord.AccountId = accountRecord.Id;

        insert contactRecord;

        Origination_Settings__mdt originationSettings = new Origination_Settings__mdt();
        originationSettings.FinCen_Contact_Match_Batch_Size__c = 10;
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
            FinCenContactMatchJob.execute();
        Test.stopTest();

        List<AccountContactRelation> contactList =
            [SELECT Id, Contact.Name, Contact.FirstName, Contact.LastName, Contact.MailingBuildingNumber__c, Contact.MailingStreet,
                Contact.MailingCity, Contact.MailingState, Contact.MailingCountry, Contact.MailingPostalCode, Contact.Birthdate,
                Contact.genesis__SSN__c
            FROM AccountContactRelation];

        System.assertEquals(1, contactList.size());
        System.assertEquals('Andy', contactList.get(0).Contact.FirstName);
    }

    @isTest
    private static void finCenReportXContactMatchJobException() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        GeneralHelper.currentSystemDateTime = DateTime.newInstance(GeneralHelper.currentSystemDate, DateTime.Now().Time());
        CAN_General_Settings__c generalSetting = new CAN_General_Settings__c();
        generalSetting.Id = TestUtility.getFakeId(CAN_General_Settings__c.getSObjectType());
        generalSetting.FinCen_Threshold_Value__c = 85;
        CustomSettingsHelper.generalSettings = generalSetting;

        Origination_Settings__mdt originationSettings = new Origination_Settings__mdt();
        CustomMetaDataHelper.defaultOriginationSetting = originationSettings;

        DBManagerTestsStub documentDBStubInstance = new DBManagerTestsStub();
        FinCenRecordMatchManager.documentDBInstance = (DocumentDB) Test.createStub(DocumentDB.class, documentDBStubInstance);
        Exception ex;

        Test.startTest();
            try {
                FinCenContactMatchJob.execute();
            } catch (Exception e) {
                ex = e;
            }
        Test.stopTest();

        System.assertEquals('FinCen_Contact_Match_Batch_Size__c is null', ex.getMessage());
    }
}