@isTest
private class SnapShotBatchJobTests
{
    @TestSetup
    static void makeData(){
        TestUtility.runSetupData();
        loan__Loan_Account__c  clContract = TestUtility.createContract();
    }

    @isTest
    private static void snapShotBatch()
    {
        loan__Loan_Account__c clContract = [
            SELECT Id, loan__Loan_Balance__c,loan__Invalid_Data__c, loan__Account__r.Legacy_Current_Balance__c FROM loan__Loan_Account__c
        ];

        clContract.loan__Loan_Status__c = 'Active - Good Standing';
        clContract.loan__Loan_Balance__c = 2000.00;
        clContract.loan__Invalid_Data__c = false;
        update clContract;

        Exception ex;

        System.Test.startTest();
            try {
                SnapShotBatchJob.execute();
            }
            catch(Exception e) {
                ex = e;
            }
        System.Test.stopTest();

        System.assertEquals(clContract.loan__Loan_Balance__c, 2000.00);
    }

    @isTest
    private static void snapShotBatchBatchSizeCheck()
    {
        Origination_Settings__mdt originationSettings = new Origination_Settings__mdt();
        originationSettings.Snapshot_Job_Size__c = null;
        CustomMetaDataHelper.defaultOriginationSetting = originationSettings;

        Exception ex;

        System.Test.startTest();
            try {
                SnapShotBatchJob.execute();
            }
            catch(Exception e) {
                ex = e;
            }
        System.Test.stopTest();

        TestUtility.assertException(ex);
        System.assertEquals(ex.getMessage(), 'Snapshot_Job_Size__c is null');
    }
}