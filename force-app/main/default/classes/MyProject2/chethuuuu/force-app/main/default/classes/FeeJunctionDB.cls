public class FeeJunctionDB extends DBManager {
    public List<loan__Fee_Junction__c> getAllActiveFeesAndFeeSets() {
        return [
            SELECT Id, loan__Fee_Set__c, loan__Fee__c
            FROM loan__Fee_Junction__c
            WHERE loan__Fee__r.loan__State__c = 'Active'
        ];
    }
}