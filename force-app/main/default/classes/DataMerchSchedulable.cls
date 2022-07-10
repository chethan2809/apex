public class DataMerchSchedulable implements Schedulable {
    private List<genesis__Applications__c> listOfApplications = new List<genesis__Applications__c>();

    public DataMerchSchedulable(List<genesis__Applications__c> listOfApplications) {
        this.listOfApplications = listOfApplications;
    }

    public void execute(SchedulableContext sc) {
        System.enqueueJob(new DataMerchQueueableJob(listOfApplications));
        System.abortJob(sc.getTriggerId());
    }
}