@isTest
private class CongaTemplateDBTests {
    private static CongaTemplateDB congaTemplateDBInstance = new CongaTemplateDB();
    @isTest
    private static void getCongaTemplatesByGroupNames() {
        Set<String> groupNames = new Set<String>();

        Test.startTest();
            List<APXTConga4__Conga_Template__c> congaTemplateList = congaTemplateDBInstance.getCongaTemplatesByGroupNames(groupNames);
        Test.stopTest();

        System.assert(congaTemplateList != null);
        System.assert(congaTemplateList.isEmpty());
    }
}