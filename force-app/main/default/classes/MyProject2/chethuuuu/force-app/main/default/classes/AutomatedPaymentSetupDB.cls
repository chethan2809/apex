public class AutomatedPaymentSetupDB extends DBManager {
      public List<loan__Automated_Payment_Setup__c> getAPSRecordsByContractIds(Set<Id> contractIds){
        return[
            SELECT Id, Name, loan__Amount_Type__c, loan__Active__c, loan__Debit_Date__c, loan__CL_Contract__c,
                loan__Recurring_ACH_Start_Date__c, loan__Recurring_ACH_End_Date__c, loan__CL_Contract__r.loan__Loan_Status__c,
                loan__CL_Contract__r.loan__Disbursal_Date__c, loan__Transaction_Amount__c, loan__Frequency__c, loan__Setup_Date__c,
                loan__CL_Contract__r.loan__Maturity_Date_Current__c, loan__CL_Contract__r.loan__la_matured_flag__c,
                loan__CL_Contract__r.loan__Last_Installment_Date__c, loan__CL_Contract__r.loan__Next_Installment_Date__c
            FROM loan__Automated_Payment_Setup__c
            WHERE loan__CL_Contract__c IN :contractIds
        ];
    }
}