@isTest
private class WirePaymentTransactionJobTests {

    @TestSetup
    static void makeData(){
        TestUtility.runSetupData();
        loan__Loan_Account__c loanAccount = TestUtility.createContract();
        loan__Payment_Mode__c paymentMode = TestUtility.createPaymentMode('Wire');
        Wire_Payment_Transaction__c wirePaymentTransaction = new Wire_Payment_Transaction__c();
        wirePaymentTransaction.Status__c = 'In Progress';
        wirePaymentTransaction.Transaction_Amount__c = 5000;
        wirePaymentTransaction.Transaction_Date__c = GeneralHelper.currentSystemDate;
        wirePaymentTransaction.Loan_Account__c = loanAccount.Id;
        insert wirePaymentTransaction;
    }

    @isTest
    private static void wirePaymentTransactionJob() {
        Wire_Payment_Transaction__c wirePaymentTransaction = [
            SELECT Id FROM Wire_Payment_Transaction__c
        ];

        Exception ex;

        System.Test.startTest();
            try {
                WirePaymentTransactionJob.execute();
            }
            catch(Exception e) {
                ex = e;
            }
        System.Test.stopTest();

        TestUtility.assertNullException(ex);

        List<Wire_Payment_Transaction__c> actualWirePaymentTransaction = [
            SELECT Id, Status__c
            FROM Wire_Payment_Transaction__c
            WHERE Id = :wirePaymentTransaction.Id
        ];

        System.assertEquals(1, actualWirePaymentTransaction.size());
    }

    @isTest
    private static void wirePaymentTransactionJobCheckBatchSizeException() {

        Origination_Settings__mdt originationSettings = new Origination_Settings__mdt();
        originationSettings.Wire_Payment_Transaction_Job_Size__c = null;
        CustomMetaDataHelper.defaultOriginationSetting = originationSettings;
        Exception ex;

        System.Test.startTest();
            try {
                WirePaymentTransactionJob.execute();
            }
            catch(Exception e){
                ex = e;
            }
        System.Test.stopTest();

        TestUtility.assertException(ex);
        System.assertEquals(ex.getMessage(), 'Wire Payment Transaction Job Size is null in Default Origination Setting');

    }

    @isTest
    private static void wirePaymentTransactionJobCheckDMLException() {

        Wire_Payment_Transaction__c wirePaymentTransaction = [
            SELECT Id, Loan_Account__c FROM Wire_Payment_Transaction__c
        ];

        wirePaymentTransaction.Loan_Account__c = null;
        update wirePaymentTransaction;
        Exception ex;

        System.Test.startTest();
            try {
                WirePaymentTransactionJob.execute();
            }
            catch(Exception e){
                ex = e;
            }
        System.Test.stopTest();

        TestUtility.assertNullException(ex);

        List<Wire_Payment_Transaction__c> actualWirePaymentTransaction = [
            SELECT Id, Status__c, Failed_Reason__c
            FROM Wire_Payment_Transaction__c
            WHERE Id = :wirePaymentTransaction.Id
        ];

        System.assertEquals(1, actualWirePaymentTransaction.size());
        System.assertEquals(actualWirePaymentTransaction.get(0).Status__c, 'Failed');
        System.assert(actualWirePaymentTransaction.get(0).Failed_Reason__c.contains('System.NullPointerException: Attempt to de-reference a null object'));

    }

}