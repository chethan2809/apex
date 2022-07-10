public class ExperianBusinessSchedulable implements Schedulable {

    private List<genesis__Applications__c> listOfApplications = new List<genesis__Applications__c>();

    public ExperianBusinessSchedulable(List<genesis__Applications__c> listOfApplications) {
        this.listOfApplications = listOfApplications;
    }

    public void execute(SchedulableContext sc) {
        System.enqueueJob(new ExperianBusinessQueueableJob(listOfApplications));
        System.abortJob(sc.getTriggerId());
    }
}