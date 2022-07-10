public class FeeDB extends DBManager {
     public List<loan__Fee__c> getAllActiveFees() {
        return [
            SELECT Id, Name, loan__Amount__c, loan__Time_of_charge__c
            FROM loan__Fee__c
            WHERE loan__State__c = 'Active'
        ];
    }
}