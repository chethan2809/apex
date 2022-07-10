public class RepaymentTxnAdjustmentDB extends DBManager{
    public List<loan__Repayment_Transaction_Adjustment__c> getReversalTransactionListByIds(Set<Id> reversalTransactionIds) {
        return [
            SELECT Id, loan__Adjustment_Txn_Date__c, loan__Loan_Payment_Transaction__r.loan__Transaction_Amount__c,
                loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.loan__Contact__r.Email,
                loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.loan__Contact__r.Name,
                loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Primary_Contact__r.Name,
                loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Primary_Contact__r.Email,
                loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Application__r.Sales_Rep__r.Email,
                loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Application__r.Sales_Rep__r.FirstName,
                loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Application__r.Sales_Rep__r.LastName,
                loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Application__r.Sales_Rep__r.Title,
                loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Application__r.Sales_Rep__r.Phone,
                loan__Loan_Payment_Transaction__r.loan__Loan_Account__c,
                loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Name,
                loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Application__r.Sales_Rep__c,
                loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Primary_Contact__c,
            	loan__Reason_Code__c, loan__Transaction_Creation_Date__c, loan__Reference__c
            FROM loan__Repayment_Transaction_Adjustment__c
            WHERE Id IN :reversalTransactionIds
        ];
    }

    public List<loan__Repayment_Transaction_Adjustment__c> getReversalTransactionListByIdsAndReversalReasonCodes(Set<Id> reversalTransactionIds, Set<String> reversalReasonCodes) {
        return [
            SELECT Id, loan__Adjustment_Txn_Date__c, loan__Loan_Payment_Transaction__r.loan__Transaction_Amount__c,
                loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.loan__Contact__r.Email,
                loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.loan__Contact__r.Name,
                loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Primary_Contact__r.Name,
                loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Primary_Contact__r.Email,
                loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Application__r.Sales_Rep__r.Email,
                loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Application__r.Sales_Rep__r.FirstName,
                loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Application__r.Sales_Rep__r.LastName,
                loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Application__r.Sales_Rep__r.Title,
                loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Application__r.Sales_Rep__r.Phone,
                loan__Loan_Payment_Transaction__r.loan__Loan_Account__c,
                loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Name,
                loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Application__r.Sales_Rep__c,
                loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Primary_Contact__c,
            	loan__Reason_Code__c, loan__Transaction_Creation_Date__c
            FROM loan__Repayment_Transaction_Adjustment__c
            WHERE Id IN :reversalTransactionIds
                AND loan__Reason_Code__c IN :reversalReasonCodes
        ];
    }
}