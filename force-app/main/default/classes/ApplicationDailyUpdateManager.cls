public class ApplicationDailyUpdateManager {
    @TestVisible
    private static CANPricingDetailDB canPricingDetailDBInstance = new CANPricingDetailDB();
    @TestVisible
    private static ApplicationDB applicationDBInstance = new ApplicationDB();
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    private static String errorMessage;

    public static String updateApplicationAndPricingByApplicationId(Id applicationId) {
        genesis__Applications__c application = applicationDBInstance.getApplicationsByIds(new Set<Id> {applicationId}).get(0);
        updateApplicationAndPricing(new List<genesis__Applications__c> { application });
        if(errorMessage != null) {
            return errorMessage;
        } else {
            return 'Updated successfully';
        }
    }

    public static void updateApplicationAndPricing(list<genesis__Applications__c> applicationList) {
        Date currentDate = GeneralHelper.currentSystemDate;
        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>(applicationList);
        Set<Id> processedApplicationIds = new Set<Id>();

        try {
            for(CAN_Pricing_Detail__c pricingDetail :
                canPricingDetailDBInstance.getCANPricingListByApplicationIdsAndStatuses(
                    applicationMap.keySet(), ApplicationDailyUpdates.ELIGIBLE_PRICING_STATUS
                )
            ) {
                if(processedApplicationIds.contains(pricingDetail.Application__c)) {
                    continue;
                }
                processedApplicationIds.add(pricingDetail.Application__c);
                CANPricingDetails.calculatePaymentAmount(pricingDetail);

                genesis__Applications__c application = applicationMap.get(pricingDetail.Application__c);
                Applications.setApplicationFieldsFromPricingForApplicationFrequency(application, pricingDetail);
                applicationMap.remove(pricingDetail.Application__c);
                canPricingDetailDBInstance.addUpdate(pricingDetail);

                ApplicationDailyUpdates.expireDeclineRule(application);
                applicationDBInstance.addUpdate(application);

                if(application.genesis__Status__c == Applications.STATUS_DECLINED) {
                    applicationMap.remove(pricingDetail.Application__c);
                }
            }

            canPricingDetailDBInstance.executeUpdates();

        } catch(Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'Application Daily Update Job', 'Failed on update Pricing ' + e.getMessage() + e.getStackTraceString(), null,
                null, ErrorLogs.ERROR, applicationList.get(0).Id, false
            );
            errorMessage = e.getMessage() + e.getStackTraceString();
            errorLogDBInstance.addInsert(errorLog);
        }

        for(genesis__Applications__c application :applicationMap.values()) {
            application.genesis__Expected_Start_Date__c = GeneralHelper.getBusinessDate(currentDate);
            application.genesis__Expected_First_Payment_Date__c = Applications.getFirstPaymentDateByFrequency(
                application.genesis__Expected_Start_Date__c, application.genesis__Payment_Frequency__c
            );
            if(application.genesis__Expected_Start_Date__c > application.genesis__Expected_Close_Date__c) {
                application.genesis__Expected_Close_Date__c = application.genesis__Expected_Start_Date__c.addDays(1);
            }

            ApplicationDailyUpdates.expireDeclineRule(application);

            applicationDBInstance.addUpdate(application);
        }

        DBManager.PartialResult partialInsertSaveResults = applicationDBInstance.executePartialUpdates();

        for (Database.SaveResult insertSaveResult : partialInsertSaveResults.saveResults) {
            if (!insertSaveResult.isSuccess()) {
                Integer resultIndex = partialInsertSaveResults.saveResults.indexOf(insertSaveResult);
                genesis__Applications__c application = (genesis__Applications__c) partialInsertSaveResults.sObjectList.get(resultIndex);

                List<Database.Error> errors = insertSaveResult.getErrors();
                errorMessage = ErrorLogs.constructErrorMessageFromDatabaseResult(
                    insertSaveResult.getErrors()
                );

                Error_Log__c errorLog = ErrorLogs.createErrorLog(
                    'Application Daily Update Job', 'Failed on update Application ' + errorMessage, null, null, ErrorLogs.ERROR,
                    application.Id, false
                );
                errorLogDBInstance.addInsert(errorLog);
            }
        }

        errorLogDBInstance.executeInserts();
    }
}