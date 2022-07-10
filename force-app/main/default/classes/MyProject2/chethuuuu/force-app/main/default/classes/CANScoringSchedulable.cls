public class CANScoringSchedulable implements Schedulable {
    private List<genesis__Applications__c> listOfApplications = new List<genesis__Applications__c>();

    public CANScoringSchedulable(List<genesis__Applications__c> listOfApplications) {
        this.listOfApplications = listOfApplications;
    }

    public void execute(SchedulableContext sc) {
        System.enqueueJob(new CANScoringQueueableJob(listOfApplications));
        System.abortJob(sc.getTriggerId());
    }
}