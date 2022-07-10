public class LoanPaymentSpreadDB {

    public List<loan__Loan_Payment_Spread__c> getDefaultCANPaymentSpread() {
        return [SELECT Id FROM loan__Loan_Payment_Spread__c WHERE Name = 'CAN Payment Spread' LIMIT 1];
    }
}