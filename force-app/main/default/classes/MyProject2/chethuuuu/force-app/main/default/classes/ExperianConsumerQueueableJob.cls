public class ExperianConsumerQueueableJob implements Queueable, Database.AllowsCallouts  {
    private List<genesis__Applications__c> listOfApplications = new List<genesis__Applications__c>();

    public ExperianConsumerQueueableJob(List<genesis__Applications__c> listOfApplications) {
        this.listOfApplications = listOfApplications;
    }

    public void execute(QueueableContext context) {
        ExperianManager.requestConsumerCreditCheck(listOfApplications);
    }
}