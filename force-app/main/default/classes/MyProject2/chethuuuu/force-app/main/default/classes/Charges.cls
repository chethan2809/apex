public class Charges extends DBManager {
    public static final Decimal LATE_FEE_AMOUNT = 50;
    public static final Decimal BLOCKED_ACCOUNT_FEE_AMOUNT = 250;
    public static final Decimal MAXIMUM_CHARGEABLE_AMOUNT = 30;

    public static loan__Charge__c createCharge(Id loanAccountId, Id feeId, Date chargeDate, Decimal originalAmount){
        loan__Charge__c charge = new loan__Charge__c();
        charge.loan__Loan_Account__c = loanAccountId;
        charge.loan__Fee__c = feeId;
        charge.loan__Date__c = chargeDate;
        charge.loan__Original_Amount__c = originalAmount;
        return charge;
    }
}