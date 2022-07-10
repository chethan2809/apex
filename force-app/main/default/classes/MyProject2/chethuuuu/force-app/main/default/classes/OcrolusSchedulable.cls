public class OcrolusSchedulable implements Schedulable {
    private List<genesis__Applications__c> listOfApplications = new List<genesis__Applications__c>();

    public OcrolusSchedulable(List<genesis__Applications__c> listOfApplications) {
        this.listOfApplications = listOfApplications;
    }

    public void execute(SchedulableContext sc) {
        System.enqueueJob(new OcrolusQueueableJob(listOfApplications));
        System.abortJob(sc.getTriggerId());
    }
}