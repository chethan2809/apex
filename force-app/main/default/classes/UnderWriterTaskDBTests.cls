@isTest(isParallel=true)
private class UnderWriterTaskDBTests {

    private static UnderWriterTaskDB underWriterTaskDBInstance = new UnderWriterTaskDB();

    @isTest
    private static void getUnderWriterTaskByApplicationIdsAndTaskNames() {
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(applicationId);

        Test.startTest();
            List<UnderWriter_Task__c> underWriterTaskList = underWriterTaskDBInstance.getUnderWriterTaskByApplicationIdsAndTaskNames(applicationIds, new Set<String>{'taskNames'});
        Test.stopTest();

        System.assert(underWriterTaskList != null);
        System.assert(underWriterTaskList.isEmpty());
    }
}