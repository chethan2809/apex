public class FinCenResultDB extends DBManager {

    public List<FinCen_Result__c> getFinCenResult(Set<Id> finCenResultIds) {
        return [SELECT Id, Name FROM FinCen_Result__c WHERE Id = :finCenResultIds];
    }
}