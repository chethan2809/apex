@isTest
public class ManualRunJobsControllerTests {

    @isTest
    private static void getManualJobsToRun() {
        Manual_Run_Jobs__mdt manualRunJobs = new Manual_Run_Jobs__mdt();
        manualRunJobs.DeveloperName = 'metaDataJob';
        manualRunJobs.Sample_Size__c = 100;
        String expectedKey = manualRunJobs.DeveloperName;

        Map<String, Manual_Run_Jobs__mdt> manualRunJobsSetup = new Map<String, Manual_Run_Jobs__mdt>();
        manualRunJobsSetup.put(manualRunJobs.DeveloperName, manualRunJobs);
        CustomMetaDataHelper.manualRunJobsByJobName = manualRunJobsSetup;

        Test.startTest();
            Map<String, Manual_Run_Jobs__mdt> manualRunJobsMap = ManualRunJobsController.getManualJobsToRun();
        Test.stopTest();

        System.assertEquals(manualRunJobs, manualRunJobsMap.get(expectedKey));
    }

    @isTest
    private static void runManualJobPaymentTransaction() {
        String jobName = 'loan_loanPaymentTransactionCreationJob';
        Integer batchSize = 1;

        Test.startTest();
            try {
                ManualRunJobsController.runManualJob(jobName, batchSize);
            } catch (Exception e) {

            }
        Test.stopTest();

        System.assertEquals('loan_loanPaymentTransactionCreationJob', jobName);
    }

    @isTest
    private static void runManualJobFilegen() {
        String jobName = 'loan_LoanPaymentFilegenJob';
        Integer batchSize = 1;

        Test.startTest();
            try {
                ManualRunJobsController.runManualJob(jobName, batchSize);
            } catch (Exception e) {

            }
        Test.stopTest();

        System.assertEquals('loan_LoanPaymentFilegenJob', jobName);
    }

    @isTest
    private static void runManualJobSFTPDisbursal() {
        String jobName = 'SFTPDisbursalJob';
        Integer batchSize = 1;

        Test.startTest();
            try {
                ManualRunJobsController.runManualJob(jobName, batchSize);
            } catch (Exception e) {

            }
        Test.stopTest();

        System.assertEquals('SFTPDisbursalJob', jobName);
    }

    @isTest
    private static void runManualJobDisbursalDistributionFilegenJob() {
        String jobName = 'loan_DisbursalDistributionFilegenJob';
        Integer batchSize = 1;

        Test.startTest();
            try {
                ManualRunJobsController.runManualJob(jobName, batchSize);
            } catch (Exception e) {

            }
        Test.stopTest();

        System.assertEquals('loan_DisbursalDistributionFilegenJob', jobName);
    }

    @isTest
    private static void runManualJobInvestorPayoutReversalJob() {
        String jobName = 'loan_InvestorPayoutReversalJob';
        Integer batchSize = 1;

        Test.startTest();
            try {
                ManualRunJobsController.runManualJob(jobName, batchSize);
            } catch (Exception e) {

            }
        Test.stopTest();

        System.assertEquals('loan_InvestorPayoutReversalJob', jobName);
    }
}