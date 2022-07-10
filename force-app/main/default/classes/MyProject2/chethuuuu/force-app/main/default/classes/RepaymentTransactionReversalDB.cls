public class RepaymentTransactionReversalDB extends DBManager{
    public static List<loan__Repayment_Transaction_Adjustment__c> getReversalTransactionListByIds(Set<Id> reversalTransactionIds) {
        return [
            SELECT Id, loan__Adjustment_Txn_Date__c, loan__Loan_Payment_Transaction__r.loan__Transaction_Amount__c,
            loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.loan__Contact__r.Email,
            loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.loan__Contact__r.Name,
            loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Application__r.Owner.Email,
            loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Application__r.Owner.FirstName,
            loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Application__r.Owner.LastName,
            loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Application__r.Owner.Title,
            loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Application__r.Owner.Phone
            FROM loan__Repayment_Transaction_Adjustment__c
            WHERE Id IN :reversalTransactionIds
        ];
    }
}