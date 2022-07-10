public class CollectionCaseStrategies
{
    @TestVisible
    private static CollectionCriteriaDB collectionCriteriaDBInstance = new CollectionCriteriaDB();

    public static Collection_Case__c setCollectionCaseFields(loan__Loan_Account__c clContract, Collection_Case__c collectionCase)
    {
        collectionCase.CL_Contract_Id__c = clContract.Id;
        collectionCase.Contract_Number__c = clContract.Name;
        collectionCase.Bank_Account__c = clContract.Bank_Account__r.Name;
        collectionCase.Contract_Application_Id__c = clContract.Application__c;
        collectionCase.No_missed_payments__c = clContract.Latest_Number_Of_Missed_Payments__c;
        collectionCase.Account__c = clContract.loan__Account__c;
        collectionCase.Contact__c = clContract.Primary_Contact__c;
        collectionCase.Total_Unpaid_Due_Amount_To_Current__c = clContract.Total_Unpaid_Due_Amount_To_Current__c;
        collectionCase.Delinquent_amount__c = clContract.loan__Delinquent_Amount__c;
        collectionCase.Original_Funded_Amount__c = clContract.loan__Disbursed_Amount__c;
        collectionCase.Loan_Balance__c = clContract.loan__Loan_Balance__c;
        collectionCase.Last_Disbursal_Date__c = clContract.loan__Last_Disbursal_Date__c;
        collectionCase.Last_Disbursal_Amount__c = clContract.loan__Last_Disbursal_Amount__c;
        collectionCase.Current_Payoff_Amount__c = clContract.Current_Payoff_Amount__c;
        collectionCase.Pmt_Amt_Cur__c = clContract.loan__Pmt_Amt_Cur__c;
        collectionCase.Payment_Amount__c = clContract.loan__Payment_Amount__c;
        collectionCase.Frequency__c = clContract.loan__Frequency_of_Loan_Payment__c;
        collectionCase.Principal_Remaining__c = clContract.loan__Principal_Remaining__c;
        collectionCase.Previous_Installment_Date__c = clContract.loan__Previous_Installment_Date__c;
        collectionCase.Total_Outstanding_Repayment_Amount__c = clContract.Total_Outstanding_Repayment_Amount__c;
        collectionCase.Number_of_Days_Overdue__c = clContract.loan__Number_of_Days_Overdue__c;
        collectionCase.Last_Payment_Date__c = clContract.loan__Last_Payment_Date__c;
        collectionCase.Last_Payment_Amount__c = clContract.loan__Last_Payment_Amount__c;
        collectionCase.CL_Contract_Status__c = clContract.loan__Loan_Status__c;
        collectionCase.Contract_Application_Name__c = clContract.Application__r.Name;
        collectionCase.Original_Repayment_Amount__c = clContract.Outstanding_Repayment_Amount__c;
        collectionCase.SCRA__c = clContract.loan__Account__r.SCRA__c;
        collectionCase.Confirmed_fraud__c = clContract.loan__Account__r.Confirmed_Fraud_Flag__c;
        collectionCase.Deceased_owner__c = clContract.loan__Account__r.Deceased__c;
        collectionCase.Cease_and_Desist__c = clContract.loan__Account__r.Cease_and_Desist__c;
        collectionCase.Amount_To_Current__c = clContract.loan__Amount_to_Current__c;
        collectionCase.Maturity_Date__c = clContract.loan__Last_Installment_Date__c;
        collectionCase.Type__c = clContract.Type__c;
        collectionCase.Latest_Missed_Payment_Date__c = clContract.Latest_Missed_Payment_Date__c;
        collectionCase.Doing_Business_As_Name__c = clContract.loan__Account__r.Doing_Business_As_Name__c;
        collectionCase.Excess__c = clContract.loan__Excess__c;
        collectionCase.Amount_Due_Till_Current__c = clContract.loan__Amount_Due_Till_Current__c;
        if(!clContract.loan__Automated_Payment_Setup__r.isEmpty() && clContract.loan__Automated_Payment_Setup__r.size() > 0) {
            collectionCase.Active_APS__c = true;
        } else {
            collectionCase.Active_APS__c = false;
        }

        collectionCase.Case_Queue__c = collectionQueue(clContract);

        return collectionCase;
    }

    public static String collectionQueue(loan__Loan_Account__c clContract)
    {
        String queueName;
        List<Collection_Criteria__c> collectionCriteriaList = collectionCriteriaDBInstance.getCollectionCriteriaAndQueueValue();

        if(!collectionCriteriaList.isEmpty()){
            Decimal queueValue = collectionCriteriaList[0].Queue_Value__c;

            if(clContract.Total_Outstanding_Repayment_Amount__c < queueValue) {
                queueName = CollectionCaseConstants.LOW_BALANCE_QUEUE;
            } else {
                queueName = CollectionCaseConstants.HIGH_BALANCE_QUEUE;
            }
        }
        return queueName;
    }
}