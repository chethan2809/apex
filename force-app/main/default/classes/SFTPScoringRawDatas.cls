public class SFTPScoringRawDatas {


    public static Id buildResponseAttachment(Credit_Report_Detail__c creditReport, Map<Id, Map<String, String>> responseMapByCreditReportDetail, List<Attachment> attachmentList, Map<Id, Id> contactIdAccountIdToApplicationId) {

        Id applicationId;
        Blob fileBlob;
        String currentDate = String.ValueOf(GeneralHelper.currentSystemDateTime);
        if(creditReport.Contact__c != null && responseMapByCreditReportDetail.get(creditReport.Contact__c) != null) {
            Attachment attachmentRecord = new Attachment();
            Map<String, String> responseMap = responseMapByCreditReportDetail.get(creditReport.Contact__c);
            fileBlob = Blob.valueOf(responseMap.get('consumerReport'));
            attachmentRecord.Name = 'ExperianConsumerCreditReport_' + currentDate;
            applicationId = contactIdAccountIdToApplicationId.get(creditReport.Contact__c);
            attachmentRecord.Body = fileBlob;
            attachmentRecord.parentId = creditReport.Id;
            attachmentRecord.ContentType = 'text/plain';
            attachmentList.add(attachmentRecord);
        } else if(creditReport.Account__c != null && responseMapByCreditReportDetail.get(creditReport.Account__c) != null) {
            Map<String, String> responseMap = responseMapByCreditReportDetail.get(creditReport.Account__c);
            for(String reportType : responseMap.KeySet()){
                Attachment attachmentRecord = new Attachment();
                fileBlob = Blob.valueOf(responseMap.get(reportType));
                attachmentRecord.Name = reportType + '_' + currentDate;
                applicationId = contactIdAccountIdToApplicationId.get(creditReport.Account__c);
                attachmentRecord.Body = fileBlob;
                attachmentRecord.parentId = creditReport.Id;
                attachmentRecord.ContentType = 'text/plain';
                attachmentList.add(attachmentRecord);
            }
        } else if(creditReport.Application__c != null && responseMapByCreditReportDetail.get(creditReport.Application__c) != null) {
            Attachment attachmentRecord = new Attachment();
            Map<String, String> responseMap = responseMapByCreditReportDetail.get(creditReport.Application__c);
            for(String reportType : responseMap.KeySet()){
                fileBlob = Blob.valueOf(responseMap.get(reportType));
                if(reportType == 'lexisNexisReport'){
                    attachmentRecord.Name = 'LexisNexisBIID_' + currentDate;
                } else if (reportType == 'fraudScoreReport'){
                    attachmentRecord.Name = 'LexisNexisSBA_' + currentDate;
                }
                applicationId = creditReport.Application__c;
                attachmentRecord.Body = fileBlob;
                attachmentRecord.parentId = creditReport.Id;
                attachmentRecord.ContentType = 'text/plain';
                attachmentList.add(attachmentRecord);
            }
        }

        return applicationId;
    }
}