public class SuspendedFees {
    public static loan__Frozen_Fees_Config__c createSuspendedFee(Id loanAccountId, Id feeId){
        loan__Frozen_Fees_Config__c suspendedFee = new loan__Frozen_Fees_Config__c();
        suspendedFee.loan__Loan_Account__c = loanAccountId;
        suspendedFee.loan__Fee__c = feeId;
        suspendedFee.loan__Start_Date__c = GeneralHelper.currentSystemDate;
        suspendedFee.loan__End_Date__c = GeneralHelper.currentSystemDate.addYears(100);
        suspendedFee.loan__Active__c = True;
        return suspendedFee;
    }
}