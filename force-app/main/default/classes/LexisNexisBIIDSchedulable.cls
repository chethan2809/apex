public class LexisNexisBIIDSchedulable implements Schedulable {
    private List<genesis__Applications__c> listOfApplications = new List<genesis__Applications__c>();

    public LexisNexisBIIDSchedulable(List<genesis__Applications__c> listOfApplications) {
        this.listOfApplications = listOfApplications;
    }

    public void execute(SchedulableContext sc) {
        System.enqueueJob(new LexisNexisBIIDQueueableJob(listOfApplications));
        System.abortJob(sc.getTriggerId());
    }
}