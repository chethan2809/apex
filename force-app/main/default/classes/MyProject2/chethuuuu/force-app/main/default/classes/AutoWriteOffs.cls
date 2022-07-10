public class AutoWriteOffs {

    public static loan__Charge__c createChargesOnWrittenOff(loan__Loan_Account__c loanAccount) {
        loan__Fee__c preClosureFee =
            ServicingHelper.feeSetIdToFeesByName.get(loanAccount.loan__Fee_Set__c).get(GeneralConstants.PRE_CLOSURE_FEE);
        loan__Charge__c preClosureCharge =  Charges.createCharge (
            loanAccount.Id, preClosureFee.Id, GeneralHelper.currentSystemDate, loanAccount.Future_Payable_Interest_Amount__c
        );
        return preClosureCharge;
    }
}