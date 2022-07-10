public class LexisNexisFraudScoreQueueableJob  implements Queueable, Database.AllowsCallouts  {
    private List<genesis__Applications__c> listOfApplications = new List<genesis__Applications__c>();

    public LexisNexisFraudScoreQueueableJob(List<genesis__Applications__c> listOfApplications) {
        this.listOfApplications = listOfApplications;
    }

    public void execute(QueueableContext context) {
        LexisNexisManager.requestLexisNexisFraudScoreCheck(listOfApplications);
    }
}