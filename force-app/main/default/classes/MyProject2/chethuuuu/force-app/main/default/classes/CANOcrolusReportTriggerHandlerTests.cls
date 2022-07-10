@isTest
private class CANOcrolusReportTriggerHandlerTests {

    @isTest
    private static void beforeUpdateTests() {
        CAN_Ocrolus_Report__c  oldOcrolusReport = new CAN_Ocrolus_Report__c();
        oldOcrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());

        Map<Id, CAN_Ocrolus_Report__c> oldMap = new Map<Id, CAN_Ocrolus_Report__c>();
        oldMap.put(oldOcrolusReport.Id, oldOcrolusReport);

        CAN_Ocrolus_Report__c newOcrolusReport = new CAN_Ocrolus_Report__c();
        newOcrolusReport.Id = oldOcrolusReport.Id;
        newOcrolusReport.Max_Daily_Payment__c = 2000;
        newOcrolusReport.Offer_GAV_Amount__c = 100;

        Map<Id, CAN_Ocrolus_Report__c> newMap = new Map<Id, CAN_Ocrolus_Report__c>();
        newMap.put(newOcrolusReport.Id, newOcrolusReport);

        CANOcrolusReportTriggerHandler ocrolusReportTriggerHandlerInstance = new CANOcrolusReportTriggerHandler();

        Test.startTest();
            ocrolusReportTriggerHandlerInstance.beforeUpdate(newMap, oldMap);
        Test.stopTest();

        System.assertEquals(Ocrolus.OCROLUS_DOC_STATUS_COMPLETE, newOcrolusReport.Document_Status__c);
    }

    @isTest
    private static void afterUpdateTests() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        application.Opportunity__c = TestUtility.getFakeId(Opportunity.getSObjectType());
        application.Industry_Rating__c = 'A+ Medical';
        application.SC4_Tier__c = 'TIER 1';
        application.Type__c = 'New';
        application.Origination_Fee_Percentage__c = 1;
        application.genesis__Payment_Frequency__c = 'DAILY';

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        CANOcrolusReportTriggerHandler.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        CAN_Ocrolus_Report__c  oldOcrolusReport = new CAN_Ocrolus_Report__c();
        oldOcrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        oldOcrolusReport.Application__c = application.Id;

        Map<Id, CAN_Ocrolus_Report__c> oldMap = new Map<Id, CAN_Ocrolus_Report__c>();
        oldMap.put(oldOcrolusReport.Id, oldOcrolusReport);

        CAN_Ocrolus_Report__c newOcrolusReport = new CAN_Ocrolus_Report__c();
        newOcrolusReport.Id = oldOcrolusReport.Id;
        newOcrolusReport.Application__c = application.Id;
        newOcrolusReport.Max_Daily_Payment__c = 2000;
        newOcrolusReport.Offer_GAV_Amount__c = 100;

        Map<Id, CAN_Ocrolus_Report__c> newMap = new Map<Id, CAN_Ocrolus_Report__c>();
        newMap.put(newOcrolusReport.Id, newOcrolusReport);

        CANOcrolusReportTriggerHandler ocrolusReportTriggerHandlerInstance = new CANOcrolusReportTriggerHandler();

        Test.startTest();
            ocrolusReportTriggerHandlerInstance.afterUpdate(newMap, oldMap);
        Test.stopTest();

        System.assertEquals(1, applicationDBStubInstance.forUpdateSObjects.size());

        genesis__Applications__c actualApplication = (genesis__Applications__c) applicationDBStubInstance.forUpdateSObjects.get(0);
        System.assertEquals(Applications.STATUS_PRICING_GENERATION, actualApplication.genesis__Status__c);
        System.assertEquals(newOcrolusReport.Offer_GAV_Amount__c,  actualApplication.Annual_Volume__c);
    }
}