public class SFTPScoringRawDataQueueableJob implements Queueable, Database.AllowsCallouts {

    List<Credit_Report_Detail__c> reportList = new List<Credit_Report_Detail__c>();
    Map<Id, Map<String, String>> responseMapByCreditReportDetail = new Map<Id, Map<String, String>>();
    Map<Id, Id> contactIdAccountIdToApplicationId = new Map<Id, Id>();

    public SFTPScoringRawDataQueueableJob(List<Credit_Report_Detail__c> reportList, Map<Id, Map<String, String>> responseMapByCreditReportDetail, Map<Id, Id> contactIdAccountIdToApplicationId) {
        this.reportList = reportList;
        this.responseMapByCreditReportDetail = responseMapByCreditReportDetail;
        this.contactIdAccountIdToApplicationId = contactIdAccountIdToApplicationId;
    }

    public void execute(QueueableContext context) {
        SFTPScoringRawDataManager.SFTPSendRawData(reportList, responseMapByCreditReportDetail, contactIdAccountIdToApplicationId);
    }
}