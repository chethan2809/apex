public with sharing class WaiveOffInterest {
        @AuraEnabled(cacheable = true)
    public static List<loan__Loan_Account__c> getloans(string recordId)
    {
        return [SELECT  loan__Interest_Accrued_Not_Due__c,loan__Interest_Remaining__c from loan__Loan_Account__c
        where id=:recordId WITH SECURITY_ENFORCED];
    }
    @AuraEnabled
    public static Boolean updateRecord(String accId){
        System.debug('@@@@ContractId@@@'+accId);
        loan__Loan_Account__c acc=[select loan__Interest_Waived__c,loan__Interest_Accrued_Not_Due__c,loan__Interest_Remaining__c from loan__Loan_Account__c
        where Id=:accId WITH SECURITY_ENFORCED];
       // acc.loan__Interest_Waived__c=acc.loan__Interest_Remaining__c  + acc.loan__Interest_Accrued_Not_Due__c;
       
        try{
         acc.loan__Interest_Waived__c=acc.loan__Interest_Remaining__c  + acc.loan__Interest_Accrued_Not_Due__c;
         acc.loan__Interest_Remaining__c=0;
         acc.loan__Interest_Accrued_Not_Due__c=0;
            update acc;
        }
        catch (Exception e) {
            System.debug('unable to update the record due to'+e.getMessage());
        }
        return false;
    }
}