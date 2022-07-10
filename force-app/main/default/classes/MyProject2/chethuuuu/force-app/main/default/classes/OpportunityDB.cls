public class OpportunityDB extends DBManager {
    public List<Opportunity> getOpportunityByAccountIds (Set<Id> accountIds) {
        return [
            SELECT Id, AccountId, Refinanced_CL_Contract__c
            FROM Opportunity
            WHERE AccountId IN :accountIds
        ];
    }

    public List<Opportunity> getOpportunityByIds (Set<Id> opportunityIds) {
        return [
            SELECT Id, Name, AccountId, Refinanced_CL_Contract__c, StageName, Sub_Status__c
            FROM Opportunity
            WHERE Id IN :opportunityIds
        ];
    }
}