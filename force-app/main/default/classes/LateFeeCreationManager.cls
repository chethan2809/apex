public class LateFeeCreationManager {
    @TestVisible
    private static CLContractDB contractDBInstance = new CLContractDB();
    @TestVisible
    private static ChargeDB chargeDBInstance = new ChargeDB();

    public static void processLateFeeCreation(List<loan__Loan_Account__c> loanAccountList) {

        for(loan__Loan_Account__c loanAccount : loanAccountList) {
            Date currentSystemDate = GeneralHelper.currentSystemDate;
            if(loanAccount.Late_fee_Applied_Date__c == null || loanAccount.Late_fee_Applied_Date__c.monthsBetween(currentSystemDate) != 0){
                loan__Fee__c lateFee = ServicingHelper.feeSetIdToFeesByName.get(loanAccount.loan__Fee_Set__c).get(GeneralConstants.LATE_FEE);
                loan__Charge__c lateCharge = Charges.createCharge(
                    loanAccount.Id, lateFee.Id, GeneralHelper.currentSystemDate, Charges.LATE_FEE_AMOUNT
                );
                chargeDBInstance.addInsert(lateCharge);

                loanAccount.Late_fee_Applied_Date__c = GeneralHelper.currentSystemDate;
                contractDBInstance.addUpdate(loanAccount);
            }
        }

        chargeDBInstance.executeInserts();
        contractDBInstance.executeUpdates();
    }
}