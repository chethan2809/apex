public class LexisNexisFraudScoreSchedulable implements Schedulable{
    private List<genesis__Applications__c> listOfApplications = new List<genesis__Applications__c>();

    public LexisNexisFraudScoreSchedulable(List<genesis__Applications__c> listOfApplications) {
        this.listOfApplications = listOfApplications;
    }

    public void execute(SchedulableContext sc) {
        System.enqueueJob(new LexisNexisFraudScoreQueueableJob(listOfApplications));
        System.abortJob(sc.getTriggerId());
    }
}