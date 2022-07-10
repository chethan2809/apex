@isTest
private class AutoWriteOffsTests {
    @isTest
    private static void createChargesOnWrittenOff() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        loan__Charge__c preClosureCharge;

        loan__Fee_Junction__c feeJunction = new loan__Fee_Junction__c();
        feeJunction.Id = TestUtility.getFakeId(loan__Fee_Junction__c.getSObjectType());

        loan__Fee__c loanFee = new loan__Fee__c();
        loanFee.Name = GeneralConstants.PRE_CLOSURE_FEE;
        loanFee.Id = TestUtility.getFakeId(loan__Fee__c.getSObjectType());

        loan__Loan_Account__c loanAccount = (loan__Loan_Account__c) JSON.deserialize(
            '{"Future_Payable_Interest_Amount__c" :' + 1000 + ' }', loan__Loan_Account__c.class
        );
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loanAccount.loan__Fee_Set__c = loanFee.Id;

        Map<String, loan__Fee__c> loanFeeNameToLoanFee = new Map<String, loan__Fee__c>();
        loanFeeNameToLoanFee.put(loanFee.Name, loanFee);

        ServicingHelper.feeSetIdToFeesByName.put(loanFee.Id, loanFeeNameToLoanFee);

        Test.startTest();
            preClosureCharge = AutoWriteOffs.createChargesOnWrittenOff(loanAccount);
        Test.stopTest();

        System.assertEquals(GeneralHelper.currentSystemDate, preClosureCharge.loan__Date__c);
    }
}