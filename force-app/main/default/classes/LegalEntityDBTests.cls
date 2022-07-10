@isTest(isParallel=true)
private class LegalEntityDBTests {

    private static LegalEntityDB legalEntityDBInstance = new LegalEntityDB();

    @isTest
    private static void getLegalEntity() {
        Test.startTest();
            List<clcommon__Legal_Entity__c> legalEntityList = legalEntityDBInstance.getLegalEntity();
        Test.stopTest();

        System.assert(legalEntityList != null);
        System.assert(legalEntityList.isEmpty());
    }
}