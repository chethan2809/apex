public class CANPricingDetailManager {

    @TestVisible
    private static ApplicationDB applicationDBInstance = new ApplicationDB();
    @TestVisible
    private static CANPricingDetailDB canPricingDetailDBInstance = new CANPricingDetailDB();
    @TestVisible
    private static OcrolusReportDB canOcrolusReportDBInstance = new OcrolusReportDB();
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

    public static void createInitialCANPricingDetail(Set<Id> applicationIds) {

        Map<Id, Decimal> ocrolusMaxDailyPaymentByApplicationId = new Map<Id, Decimal>();

        for(CAN_Ocrolus_Report__c ocrolusReport : canOcrolusReportDBInstance.getCANOcrolusReportByApplicationIDs(applicationIds)){
            ocrolusMaxDailyPaymentByApplicationId.put(ocrolusReport.Application__c, ocrolusReport.Max_Daily_Payment__c);
        }

        Map<Id, genesis__Applications__c> applicationMap = new  Map<Id, genesis__Applications__c> (applicationDBInstance.getApplicationsByIds(applicationIds));

        for(genesis__Applications__c application : applicationMap.values()) {
            try {
                if(application.genesis__Status__c != Applications.STATUS_DECLINED) {
                    Decimal maxDailyPayment = ocrolusMaxDailyPaymentByApplicationId.get(application.Id);
                    CAN_Pricing_Detail__c pricingDetail = CANPricingDetails.createPricingDetail(application, null, maxDailyPayment);
                    pricingDetail.Status__c = CANPricingDetails.STATUS_SENT_TO_CUSTOMER;
                    pricingDetail.Offer_Type__c = CANPricingDetails.OFFER_TYPE_INITIAL_OFFER;
                    CANPricingDetails.calculateCANPricing(pricingDetail);
                    canPricingDetailDBInstance.addInsert(pricingDetail);

                    Applications.setApplicationFieldsFromPricing(application, pricingDetail);
                    application.genesis__Status__c = Applications.STATUS_OFFER_SENT;

                    BusinessRules.pricingGenerationDeclineRules(application, pricingDetail);
                    applicationDBInstance.addUpdate(application);
                }
            } catch (Exception e) {
                application.genesis__Status__c = Applications.STATUS_PRICING_GENERATION_FAILED;
                applicationDBInstance.addUpdate(application);
                Error_Log__c errorLog = ErrorLogs.createErrorLog(
                    'Initial CAN Pricing Generation', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                    application.Id, false
                );
                errorLogDBInstance.addInsert(errorLog);
            }
        }

        errorLogDBInstance.executeInserts();
        canPricingDetailDBInstance.executeInserts();
        applicationDBInstance.executeUpdates();
    }

    public static void archiveExistingCANPricingDetails(Map<Id, Id> applicationIdToPricingIdForArchive) {
        for(CAN_Pricing_Detail__c pricingDetail :
            canPricingDetailDBInstance.getUnArchivedPricingDetailsByApplicationIds(applicationIdToPricingIdForArchive.keySet())
        ) {
            if(applicationIdToPricingIdForArchive.get(pricingDetail.Application__c) != pricingDetail.Id) {
                pricingDetail.Status__c = CANPricingDetails.STATUS_ARCHIVED;
                canPricingDetailDBInstance.addUpdate(pricingDetail);
            }
        }

        canPricingDetailDBInstance.executeUpdates();
    }

    public static void handleBeforeInsertExceptionAndManualPricing(
        List<CAN_Pricing_Detail__c> newList, Set<Id> applicationIdsForSettingInitialPricingValues
    ) {
        Map<Id, Decimal> ocrolusMaxDailyPaymentByApplicationId = new Map<Id, Decimal>();

        for(CAN_Ocrolus_Report__c ocrolusReport : canOcrolusReportDBInstance.getCANOcrolusReportByApplicationIds(applicationIdsForSettingInitialPricingValues)){
            ocrolusMaxDailyPaymentByApplicationId.put(ocrolusReport.Application__c, ocrolusReport.Max_Daily_Payment__c);
        }

        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>(
            applicationDBInstance.getApplicationsByIds(applicationIdsForSettingInitialPricingValues)
        );

        for(CAN_Pricing_Detail__c pricingDetail : newList) {
            if(applicationMap.containsKey(pricingDetail.Application__c)) {
                Decimal maxDailyPayment = ocrolusMaxDailyPaymentByApplicationId.get(pricingDetail.Application__c);
                pricingDetail = CANPricingDetails.createPricingDetail(
                    applicationMap.get(pricingDetail.Application__c), pricingDetail, maxDailyPayment
                );
                CANPricingDetails.calculateCANPricing(pricingDetail);
            }
        }
    }
}