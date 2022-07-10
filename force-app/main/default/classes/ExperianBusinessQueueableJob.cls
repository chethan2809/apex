public class ExperianBusinessQueueableJob  implements Queueable, Database.AllowsCallouts {
    private List<genesis__Applications__c> listOfApplications = new List<genesis__Applications__c>();

    public ExperianBusinessQueueableJob(List<genesis__Applications__c> listOfApplications) {
        this.listOfApplications = listOfApplications;
    }

    public void execute(QueueableContext context) {
        ExperianManager.requestBusinessCreditCheck(listOfApplications);
    }
}