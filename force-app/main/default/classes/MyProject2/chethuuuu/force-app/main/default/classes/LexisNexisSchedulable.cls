public class LexisNexisSchedulable implements Schedulable {
    private List<genesis__Applications__c> listOfApplications = new List<genesis__Applications__c>();

    public LexisNexisSchedulable(List<genesis__Applications__c> listOfApplications) {
        this.listOfApplications = listOfApplications;
    }

    public void execute(SchedulableContext sc) {
        System.enqueueJob(new LexisNexisQueueableJob(listOfApplications));
        System.abortJob(sc.getTriggerId());
    }
}