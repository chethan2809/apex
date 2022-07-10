public  with sharing class WaiveInterest {
     @AuraEnabled(cacheable = true)
    public static List<loan__Loan_Account__c> getloans(string recordId)
    {
        return [SELECT loan__Interest_Accrued_Not_Due__c,loan__Interest_Remaining__c from loan__Loan_Account__c where id=:recordId];
    }
    

}