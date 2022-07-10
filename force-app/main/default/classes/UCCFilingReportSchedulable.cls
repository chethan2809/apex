public class UCCFilingReportSchedulable implements Schedulable {

    List<UCC_Filing_Detail__c> uccFilingList = new List<UCC_Filing_Detail__c>();

    public UCCFilingReportSchedulable(List<UCC_Filing_Detail__c> uccFilingList) {
        this.uccFilingList = uccFilingList;
    }

    public void execute(SchedulableContext sc) {
        System.enqueueJob(new UCCFilingReportQueueableJob(uccFilingList));
        System.abortJob(sc.getTriggerId());
    }
}