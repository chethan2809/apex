@isTest
private class LoanDisbursalTxnDistTriggerHandlerTests {

    @isTest
    static void beforeInsert() {
        String loanName = 'LAI00000000';

        loan__Loan_Account__c loanAccount = (loan__Loan_Account__c) JSON.deserialize(
            '{"Disbursement_Count__c" : 2, "Name" : "' + loanName + '" }', loan__Loan_Account__c.class
        );
        loanAccount.Bank_Account__c = TestUtility.getFakeId(loan__Bank_Account__c.getSObjectType());
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{ loanAccount };
        LoanDisbursalTxnDistTriggerHandler.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        Map<String, Id> paymentModeIdByName = new Map<String, Id>();
        paymentModeIdByName.put(GeneralConstants.PAYMENT_MODE_ACH, TestUtility.getFakeId(loan__Payment_Mode__c.getSObjectType()));
        ServicingHelper.paymentModeIdByName = paymentModeIdByName;

        loan__Disbursal_Txn_Distribution__c newDisbursalTxnDistribution = new loan__Disbursal_Txn_Distribution__c();
        newDisbursalTxnDistribution.loan__Name_of_Entity__c = loanName;

        LoanDisbursalTxnDistTriggerHandler disbursalTxnDistTriggerHandlerInstance = new LoanDisbursalTxnDistTriggerHandler();

        Test.startTest();
        disbursalTxnDistTriggerHandlerInstance.beforeInsert(new List<loan__Disbursal_Txn_Distribution__c> {newDisbursalTxnDistribution});
        Test.stopTest();

        System.assertEquals(loanAccount.Bank_Account__c, newDisbursalTxnDistribution.loan__Bank_Account__c);
        System.assertEquals(LoanDisbursalTxnDistributions.FUNDED_SOURCE_MERCHANT, newDisbursalTxnDistribution.Funded_Source__c);
    }
}