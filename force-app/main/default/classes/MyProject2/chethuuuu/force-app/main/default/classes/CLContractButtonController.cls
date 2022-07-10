global class CLContractButtonController {
    @TestVisible
    private static ChargeDB chargeDBInstance = new ChargeDB();

    webService static String createPreClosureCharge(loan__Loan_Account__c loanAccount) {
        try {
            loan__Fee__c preClosureFee =
                    ServicingHelper.feeSetIdToFeesByName.get(loanAccount.loan__Fee_Set__c).get(GeneralConstants.PRE_CLOSURE_FEE);
            loan__Charge__c preClosureCharge =  Charges.createCharge(
                loanAccount.Id, preClosureFee.Id, GeneralHelper.currentSystemDate, loanAccount.Pre_Closure_Penalty_Amount__c
            );
            chargeDBInstance.addInsert(preClosureCharge).executeInserts();

            return 'Success';
        }
        catch (Exception e) {
            return e.getMessage();
        }
    }
}