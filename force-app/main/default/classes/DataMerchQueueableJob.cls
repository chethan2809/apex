public class DataMerchQueueableJob implements Queueable, Database.AllowsCallouts {

    private List<genesis__Applications__c> listOfApplications = new List<genesis__Applications__c>();

    public DataMerchQueueableJob(List<genesis__Applications__c> listOfApplications) {
        this.listOfApplications = listOfApplications;
    }

    public void execute(QueueableContext context) {
        DataMerchManager.requestDataMerchMerchants(listOfApplications);
    }
}