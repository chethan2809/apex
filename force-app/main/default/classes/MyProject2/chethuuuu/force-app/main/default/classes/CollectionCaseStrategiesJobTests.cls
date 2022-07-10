@isTest
private class CollectionCaseStrategiesJobTests
{
    @TestSetup
    static void makeData(){
        TestUtility.runSetupData();
        loan__Loan_Account__c  clContract = TestUtility.createContract();
    }

    @isTest
    private static void collectionCaseStrategiesJobTest()
    {
        loan__Loan_Account__c loanContract = [
            SELECT Id, loan__Loan_Balance__c, loan__Account__r.Legacy_Current_Balance__c,
            Total_Outstanding_Repayment_Amount__c, loan__Frequency_of_Loan_Payment__c,
            Return_Reason_Code__c, loan__Loan_Status__c
            FROM loan__Loan_Account__c LIMIT 1
        ];

        loan__Loan_Account__c clContract = (loan__Loan_Account__c) JSON.deserialize(
            '{"Total_Outstanding_Repayment_Amount__c" : "2000"}', loan__Loan_Account__c.class
        );
        clContract.Id = loanContract.Id;
        clContract.loan__Loan_Status__c = 'Active - Bad Standing';
        clContract.loan__Frequency_of_Loan_Payment__c = CollectionCaseConstants.FREQUENCY_DAILY;
        clContract.Return_Reason_Code__c = 'R02';
        update clContract;

        Collection_Criteria__c collectionCriteria = new Collection_Criteria__c();
        collectionCriteria.Queue_Value__c = 1;
        collectionCriteria.Active__c = true;
        collectionCriteria.Evaluation_Criteria__c = 'SELECT Id FROM loan__Loan_Account__c';
        insert collectionCriteria;

        Exception ex;

        System.Test.startTest();
            try {
                CollectionCaseStrategiesJob.execute();
            }
            catch(Exception e) {
                ex = e;
            }
        System.Test.stopTest();

        System.assertEquals(clContract.Total_Outstanding_Repayment_Amount__c, 2000);
    }

    @isTest
    private static void collectionCaseStrategiesJobSizeCheck()
    {
        Origination_Settings__mdt originationSettings = new Origination_Settings__mdt();
        originationSettings.Collection_Case_Strategy_Batch_Size__c = null;
        CustomMetaDataHelper.defaultOriginationSetting = originationSettings;

        Exception ex;

        System.Test.startTest();
            try {
                CollectionCaseStrategiesJob.execute();
            }
            catch(Exception e) {
                ex = e;
            }
        System.Test.stopTest();

        TestUtility.assertException(ex);
        System.assertEquals(ex.getMessage(), 'Collection_Case_Strategy_Batch_Size__c is null');
    }
}