@isTest
private class STIPSChecklistsTests {

    @isTest
    private static void createSTIPSChecklist() {
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        Test.startTest();
            STIPS_Checklist__c stipsChecklist = STIPSChecklists.createSTIPSChecklist(applicationId);
        Test.stopTest();

        System.assert(stipsChecklist != null);
        System.assertEquals(applicationId, stipsChecklist.Application__c);
    }
}