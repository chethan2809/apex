public class OcrolusQueueableJob implements Queueable, Database.AllowsCallouts {

    private List<genesis__Applications__c> listOfApplications = new List<genesis__Applications__c>();

    public OcrolusQueueableJob(List<genesis__Applications__c> listOfApplications) {
        this.listOfApplications = listOfApplications;
    }

    public void execute(QueueableContext context) {
        OcrolusManager.requestOcrolusFileUpload(listOfApplications);
    }
}