public class UCCValidateFilingSchedulable implements Schedulable {

    List<UCC_Filing_Detail__c> uccFilingList = new List<UCC_Filing_Detail__c>();

    public UCCValidateFilingSchedulable(List<UCC_Filing_Detail__c> uccFilingList) {
        this.uccFilingList = uccFilingList;
    }

    public void execute(SchedulableContext sc) {
        System.enqueueJob(new UCCValidateFilingQueueableJob(uccFilingList));
        System.abortJob(sc.getTriggerId());
    }
}