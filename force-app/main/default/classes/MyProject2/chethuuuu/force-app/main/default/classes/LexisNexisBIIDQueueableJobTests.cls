@isTest
private class LexisNexisBIIDQueueableJobTests {

    @isTest
    private static void requestLexisNexisBIID() {
        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        LexisNexisBIIDQueueableJob lexisNexisBIIDInstance = new LexisNexisBIIDQueueableJob(applicationList);

        Test.startTest();
            Id jobId = System.enqueueJob(lexisNexisBIIDInstance);
        Test.stopTest();

        System.assert(jobId != null);
    }
}