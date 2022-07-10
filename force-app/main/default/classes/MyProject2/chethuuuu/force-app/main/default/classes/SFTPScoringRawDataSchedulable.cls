public class SFTPScoringRawDataSchedulable implements Schedulable {

    List<Credit_Report_Detail__c> reportList = new List<Credit_Report_Detail__c>();
    Map<Id, Map<String, String>> responseMapByCreditReportDetail = new Map<Id, Map<String, String>>();
    Map<Id, Id> contactIdAccountIdToApplicationId = new Map<Id, Id>();

    public SFTPScoringRawDataSchedulable(List<Credit_Report_Detail__c> reportList, Map<Id, Map<String, String>> responseMapByCreditReportDetail, Map<Id, Id> contactIdAccountIdToApplicationId) {
        this.reportList = reportList;
        this.responseMapByCreditReportDetail = responseMapByCreditReportDetail;
        this.contactIdAccountIdToApplicationId = contactIdAccountIdToApplicationId;
    }

    public void execute(SchedulableContext sc) {
        System.enqueueJob(new SFTPScoringRawDataQueueableJob(reportList, responseMapByCreditReportDetail, contactIdAccountIdToApplicationId));
        System.abortJob(sc.getTriggerId());
    }
}