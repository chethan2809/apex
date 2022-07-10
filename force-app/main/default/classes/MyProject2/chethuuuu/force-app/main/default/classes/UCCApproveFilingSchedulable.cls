public class UCCApproveFilingSchedulable implements Schedulable {

    List<UCC_Filing_Detail__c> uccFilingList = new List<UCC_Filing_Detail__c>();

    public UCCApproveFilingSchedulable(List<UCC_Filing_Detail__c> uccFilingList) {
        this.uccFilingList = uccFilingList;
    }

    public void execute(SchedulableContext sc) {
        System.enqueueJob(new UCCApproveFilingQueueableJob(uccFilingList));
        System.abortJob(sc.getTriggerId());
    }
}