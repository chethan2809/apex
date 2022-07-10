public class CANOcrolusReportTriggerHandler {

    @TestVisible
    private static ApplicationDB applicationDBInstance = new ApplicationDB();

    public void beforeUpdate(Map<Id, CAN_Ocrolus_Report__c> newMap, Map<Id, CAN_Ocrolus_Report__c> oldMap) {
        Set<Id> verificationCompletedOcrolusReportsIds = new Set<Id>();

        for(CAN_Ocrolus_Report__c ocrolusReport : newMap.values()) {
            CAN_Ocrolus_Report__c oldOcrolusReport = oldMap.get(ocrolusReport.Id);
            if(Ocrolus.isCANVerificationCompleted(ocrolusReport, oldOcrolusReport)) {
                ocrolusReport.Document_Status__c = Ocrolus.OCROLUS_DOC_STATUS_COMPLETE;
                verificationCompletedOcrolusReportsIds.add(ocrolusReport.Id);
            }
        }

        if(!verificationCompletedOcrolusReportsIds.isEmpty()) {
            OcrolusManager.getOcrolusAnalyticsExcel(verificationCompletedOcrolusReportsIds);
        }
    }

    public void afterUpdate(Map<Id, CAN_Ocrolus_Report__c> newMap, Map<Id, CAN_Ocrolus_Report__c> oldMap) {
        Map<Id, CAN_Ocrolus_Report__c> ocrolusReportByApplicationId = new Map<Id, CAN_Ocrolus_Report__c>();
        for(CAN_Ocrolus_Report__c ocrolusReport : newMap.values()) {
            CAN_Ocrolus_Report__c oldOcrolusReport = oldMap.get(ocrolusReport.Id);
            if(Ocrolus.isCANVerificationCompleted(ocrolusReport, oldOcrolusReport)) {
                ocrolusReportByApplicationId.put(ocrolusReport.Application__c, ocrolusReport);
            }
        }

        if(!ocrolusReportByApplicationId.isEmpty()) {
            Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>(applicationDBInstance.getApplicationsByIds(ocrolusReportByApplicationId.keySet()));
            for(CAN_Ocrolus_Report__c ocrolusReport : ocrolusReportByApplicationId.values()) {
                genesis__Applications__c application = applicationMap.get(ocrolusReport.Application__c);
                application.genesis__Status__c = Applications.STATUS_PRICING_GENERATION;

                CAN_Ocrolus_Report__c oldOcrolusReport = oldMap.get(ocrolusReport.Id);
                if(application.Annual_Volume__c <= 0) {
                    application.Annual_Volume__c = (ocrolusReport.Offer_GAV_Amount__c).setScale(2);
                }
                if(oldOcrolusReport.Offer_GAV_Amount__c == null && ocrolusReport.Offer_GAV_Amount__c != null) {
                    application.Annual_Volume__c = (ocrolusReport.Offer_GAV_Amount__c).setScale(2);
                } else if(oldOcrolusReport.Offer_GAV_Amount__c != null && ocrolusReport.Offer_GAV_Amount__c != oldOcrolusReport.Offer_GAV_Amount__c){
                    application.Annual_Volume__c = CANOcrolusReports.calculateGAV(application, ocrolusReport);
                }
            }
            BusinessRuleManager.runOcrolusDeclineRules(applicationMap, ocrolusReportByApplicationId.values());
            applicationDBInstance.addUpdates(applicationMap.values()).executeUpdates();
            getBookDocumentStatusAsync(ocrolusReportByApplicationId.keySet());
        }
    }

    @future (callout=true)
    public static void getBookDocumentStatusAsync(Set<Id> applicationIds) {
        OcrolusManager.getBookDocumentStatus(applicationIds);
    }
}