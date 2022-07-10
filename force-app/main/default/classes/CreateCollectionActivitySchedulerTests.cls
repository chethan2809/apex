@isTest
public class CreateCollectionActivitySchedulerTests {

    @isTest
    private static void createCollectionActivityScheduler() {
        String cronExp = '0 0 12 1 1 ? *';
        Test.startTest();
            String jobId = System.schedule('CreateCollectionActivityScheduler', cronExp, new CreateCollectionActivityScheduler());
            System.assert(jobId != null);
        Test.stopTest();
    }
}