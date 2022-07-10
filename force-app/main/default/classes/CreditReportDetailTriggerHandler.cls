public class CreditReportDetailTriggerHandler {

    public void beforeInsert(List<Credit_Report_Detail__c> newCreditReportDetailList) {
        for(Credit_Report_Detail__c  creditReportDetail : newCreditReportDetailList ) {
            if(creditReportDetail.Type__c != null) {
                creditReportDetail.RecordTypeId =
                    Schema.SObjectType.Credit_Report_Detail__c.getRecordTypeInfosByName().get(creditReportDetail.Type__c).getRecordTypeId();
            }
            if(creditReportDetail.SIC_Code__c != null) {
                creditReportDetail.SIC_4_Digit_Description__c = IndustryRatingProfileManager.getIndustryRatingDescriptionBySICCode(
                    creditReportDetail.SIC_Code__c
                );
            }
        }
    }

    public void beforeUpdate(Map<Id, Credit_Report_Detail__c> newCreditReportDetailMap, Map<Id, Credit_Report_Detail__c> oldCreditReportDetailMap) {
        for (Credit_Report_Detail__c newCreditReportDetail : newCreditReportDetailMap.values()) {
            Credit_Report_Detail__c oldCreditReportDetail = oldCreditReportDetailMap.get(newCreditReportDetail.Id);
            if(newCreditReportDetail.SIC_Code__c != oldCreditReportDetail.SIC_Code__c) {
                newCreditReportDetail.SIC_4_Digit_Description__c = IndustryRatingProfileManager.getIndustryRatingDescriptionBySICCode(newCreditReportDetail.SIC_Code__c);
            }
        }
    }
}