public class QueueContractDB extends DBManager {
    public List<collect__Queue_Contract__c> getCollectorsByLoanAccounts(Set<String> loanAccountNames) {
        return [
            SELECT Id, collect__Collector__c, collect__Loan_Account_Id__c, collect__User__r.Email, collect__User__r.Title, collect__User__r.Phone
            FROM collect__Queue_Contract__c
            WHERE Name IN :loanAccountNames
        ];
    }
}