public class BankAccountDB extends DBManager {

    public List<loan__Bank_Account__c> getAllActiveBankAccountsByContactIds(Set<Id> contactIds) {
        return [SELECT Id, loan__Active__c, loan__Contact__c FROM loan__Bank_Account__c WHERE Id = :contactIds];
    }

    public List<loan__Bank_Account__c> getAllActiveBankAccountsByAccountIds(List<Id> accountIds) {
        return [
            SELECT Id, loan__Active__c, loan__Account__c
            FROM loan__Bank_Account__c
            WHERE loan__Account__c = :accountIds
            AND loan__Active__c = true
        ];
    }

    public List<loan__Bank_Account__c> getAllBankAccountsByAccountIds(Set<Id> accountIds) {
        return [
            SELECT Id, Name, loan__Bank_Account_Number__c, loan__Bank_Name__c, loan__Account_Usage__c,
                loan__Account__c, loan__Active__c, loan__Contact__c, loan__Account_Type__c, loan__ACH_Code__c,
                loan__Archived__c, loan__Routing_Number__c
            FROM loan__Bank_Account__c
            WHERE loan__Account__c = :accountIds
        ];
    }

    public List<loan__Bank_Account__c> getBankAccountsById(Set<Id> accountIds){
        return[
            SELECT Id, loan__Active__c, loan__Account__c
            FROM loan__Bank_Account__c
            WHERE Id = :accountIds
        ];
    }

    public List<loan__Bank_Account__c> getActiveCANBankAccount() {
        return[
            SELECT Id, loan__Active__c, loan__Account__c
            FROM loan__Bank_Account__c
            WHERE loan__Account__r.Name = 'CAN Capital'
            AND loan__Active__c = true
        ];
    }
}