public class UCCValidateApproveFilingSchedulable implements Schedulable {

    List<UCC_Filing_Detail__c> uccFilingList = new List<UCC_Filing_Detail__c>();

    public UCCValidateApproveFilingSchedulable(List<UCC_Filing_Detail__c> uccFilingList) {
        this.uccFilingList = uccFilingList;
    }

    public void execute(SchedulableContext sc) {
        System.enqueueJob(new UCCValidateApproveFilingQueueableJob(uccFilingList));
        System.abortJob(sc.getTriggerId());
    }
}