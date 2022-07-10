public class InvestmentOrderDB {

    public List<loan__Investor_Loan__c> getInvestmentOrderListByDisbursalTxnIds (Set<Id> disbursalIds) {
        return [
            SELECT  Id, Loan_Disbursal_Transaction__c, loan__Principal_Amount_Paid__c, loan__Remaining_Investment_Amount__c,
                loan__Total_Amount_Paid__c, loan__Inv_Accrued_Interest_Amt__c
            FROM loan__Investor_Loan__c
            WHERE Loan_Disbursal_Transaction__c IN: disbursalIds
        ];
    }
}