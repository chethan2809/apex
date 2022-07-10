public class UCCValidateFilingQueueableJob implements Queueable, Database.AllowsCallouts {

    List<UCC_Filing_Detail__c> uccFilingList = new List<UCC_Filing_Detail__c>();

    public UCCValidateFilingQueueableJob(List<UCC_Filing_Detail__c> uccFilingList) {
        this.uccFilingList = uccFilingList;
    }

    public void execute(QueueableContext context) {
        UCCFilingManager.UCCValidateFiling(uccFilingList);
    }
}