public class ContractConditions {

    public static loan__Contract_Condition__c createContractCondition(Id loanAccountId) {
        loan__Contract_Condition__c contractCondition  = new loan__Contract_Condition__c();
        contractCondition.loan__Loan_Account__c = loanAccountId;
        contractCondition.loan__Condition_Spread__c = ServicingHelper.conditionsOnSpreadId;
        contractCondition.loan__Loan_Payment_Spread__c = ServicingHelper.defaultPaymentSpreadId;
        return contractCondition;
    }
}