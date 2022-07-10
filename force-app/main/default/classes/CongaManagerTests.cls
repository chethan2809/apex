@isTest
private class CongaManagerTests {
    @isTest
    private static void processApplicationCongaDocuments() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Total_Competitors_Amount__c = 1000;
        application.Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;

        APXTConga4__Conga_Merge_Query__c congaQuery = new APXTConga4__Conga_Merge_Query__c();
        congaQuery.Id = TestUtility.getFakeId(APXTConga4__Conga_Merge_Query__c.getSObjectType());

        APXTConga4__Conga_Template__c congaTemplate = new APXTConga4__Conga_Template__c();
        congaTemplate.Id = TestUtility.getFakeId(APXTConga4__Conga_Template__c.getSObjectType());

        clcommon__Party__c party = new clcommon__Party__c();
        party.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        party.clcommon__Contact__c = TestUtility.getFakeId(Contact.getSObjectType());

        Map<String, Object> requestRecord = new Map<String, Object>();
        requestRecord.put('parentId', application.Id);
        requestRecord.put('templateType', 'Loan Agreement-A Application');
        requestRecord.put('sendForESign', true);

        CAN_Conga_Settings__c congaSettings = new CAN_Conga_Settings__c();
        congaSettings.Id = TestUtility.getFakeId(CAN_Conga_Settings__c.getSObjectType());
        congaSettings.Conga_Sign_BLA_Subject__c = 'Please sign your document';
        CustomSettingsHelper.congaSettings = congaSettings;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        CongaManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub congaQueryDBStubInstance = new DBManagerTestsStub();
        congaQueryDBStubInstance.genericReturnObject = new List<APXTConga4__Conga_Merge_Query__c> {congaQuery};
        CongaManager.congaQueryDBInstance = (CongaQueryDB) Test.createStub(CongaQueryDB.class, congaQueryDBStubInstance);

        DBManagerTestsStub congaTemplateDBStubInstance = new DBManagerTestsStub();
        congaTemplateDBStubInstance.genericReturnObject = new List<APXTConga4__Conga_Template__c> {congaTemplate};
        CongaManager.congaTemplateDBInstance = (CongaTemplateDB) Test.createStub(CongaTemplateDB.class, congaTemplateDBStubInstance);

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = new List<clcommon__Party__c> {party};
        CongaManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        System.Test.setMock(HttpCalloutMock.class, new CongaCalloutMock.CongaCalloutSuccessResponse());

        Test.startTest();
            CongaManager.processApplicationCongaDocuments(requestRecord);
        Test.stopTest();

        System.assertEquals('Please sign your document', CustomSettingsHelper.congaSettings.Conga_Sign_BLA_Subject__c);
    }

    @isTest
    private static void processApplicationCongaDocumentsException() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Total_Competitors_Amount__c = 1000;
        application.Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;

        Map<String, Object> requestRecord = new Map<String, Object>();
        requestRecord.put('parentId', application.Id);
        requestRecord.put('templateType', 'Loan Agreement-A Application');
        requestRecord.put('sendForESign', true);
        Exception ex;
        Test.startTest();
        try {
            CongaManager.processApplicationCongaDocuments(requestRecord);
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

        System.assertEquals('No Application found with Id ' + application.Id, ex.getMessage());
    }
}