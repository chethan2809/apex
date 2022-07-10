@isTest
private class PurchaseStatementJobTests {

    @TestSetup
    private static void makeData(){
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        TestUtility.runSetupData();
        Contact contact = TestUtility.createContact();
        loan__Loan_Disbursal_Transaction__c disbursalTransaction = TestUtility.createLoanDisbursalTransaction();
    }

    @isTest
    private static void purchaseStatementJob() {
        loan__Loan_Disbursal_Transaction__c disbursalTransaction = [
            SELECT Id, loan__Loan_Account__c
            FROM loan__Loan_Disbursal_Transaction__c
        ];

        Test.startTest();
            PurchaseStatementJob.execute();
        Test.stopTest();

           List<loan__Loan_Disbursal_Transaction__c> updatedDisbursalTransactionList = [
            SELECT Id, loan__Loan_Account__c
            FROM loan__Loan_Disbursal_Transaction__c
            WHERE Id = :disbursalTransaction.Id
        ];

        System.assertEquals(1, updatedDisbursalTransactionList.size());
        System.assertEquals(disbursalTransaction.loan__Loan_Account__c, updatedDisbursalTransactionList.get(0).loan__Loan_Account__c);
    }

    @isTest
    private static void purchaseStatementJobCheckBatchSizeException() {

        Origination_Settings__mdt defaultPurchaseStatementSetting = new Origination_Settings__mdt();
        defaultPurchaseStatementSetting.Purchase_Statement_Batch_Size__c = null;
        CustomMetaDataHelper.defaultOriginationSetting = defaultPurchaseStatementSetting;
        Exception ex;

        Test.startTest();
            try {
                PurchaseStatementJob.execute();
            }
            catch(Exception e){
                ex = e;
            }
        Test.stopTest();

        TestUtility.assertException(ex);
        System.assertEquals('Purchase_Statement_Batch_Size__c is null', ex.getMessage());
    }
}