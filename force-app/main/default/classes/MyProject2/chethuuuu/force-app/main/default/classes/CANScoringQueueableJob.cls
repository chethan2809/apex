public class CANScoringQueueableJob implements Queueable, Database.AllowsCallouts {

    private List<genesis__Applications__c> listOfApplications = new List<genesis__Applications__c>();

    public CANScoringQueueableJob(List<genesis__Applications__c> listOfApplications) {
        this.listOfApplications = listOfApplications;
    }

    public void execute(QueueableContext context) {
        CANScoringManager.requestCANScoring(listOfApplications);
    }
}