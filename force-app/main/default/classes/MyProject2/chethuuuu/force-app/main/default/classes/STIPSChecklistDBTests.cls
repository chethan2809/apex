@isTest(isParallel=true)
public class STIPSChecklistDBTests {

    private static STIPSChecklistDB stipsChecklistDBInstance = new STIPSChecklistDB();

    @isTest
    private static void gettingSTIPSCheckListByApplicationIds() {
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(applicationId);

        Test.startTest();
            List<STIPS_Checklist__c> stipsChecklist = stipsChecklistDBInstance.getSTIPSCheckListByApplicationIds(applicationIds);
        Test.stopTest();

        System.assert(stipsChecklist != null);
        System.assert(stipsChecklist.isEmpty());
    }
}