public class ExperianConsumerSchedulable implements Schedulable {
    private List<genesis__Applications__c> listOfApplications = new List<genesis__Applications__c>();

    public ExperianConsumerSchedulable(List<genesis__Applications__c> listOfApplications) {
        this.listOfApplications = listOfApplications;
    }

    public void execute(SchedulableContext sc) {
        System.enqueueJob(new ExperianConsumerQueueableJob(listOfApplications));
        System.abortJob(sc.getTriggerId());
    }
}