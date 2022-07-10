public class CANPricingDetailTriggerHandler {

    @TestVisible
    private static ApplicationDB applicationDBInstance = new ApplicationDB();
    @TestVisible
    private static OcrolusReportDB canOcrolusReportDBInstance = new OcrolusReportDB();

    public void beforeInsert(List<CAN_Pricing_Detail__c> newList) {
        Set<Id> applicationIdsForSettingInitialPricingValues = new Set<Id>();

        for(CAN_Pricing_Detail__c pricingDetail : newList) {
            if(pricingDetail.Status__c != CANPricingDetails.STATUS_SENT_TO_CUSTOMER
                && pricingDetail.Status__c != CANPricingDetails.STATUS_ACCEPTED
            ) {
                applicationIdsForSettingInitialPricingValues.add(pricingDetail.Application__c);
            } else if(pricingDetail.Status__c == CANPricingDetails.STATUS_ACCEPTED) {
                pricingDetail.Offer_Type__c = CANPricingDetails.OFFER_TYPE_ACCEPTED_OFFER;
            }
        }

        if(!applicationIdsForSettingInitialPricingValues.isEmpty()) {
            CANPricingDetailManager.handleBeforeInsertExceptionAndManualPricing(newList, applicationIdsForSettingInitialPricingValues);
        }
    }

    public void afterInsert(Map<Id, CAN_Pricing_Detail__c> newMap) {
        Map<Id, Id> applicationIdToPricingIdForArchive = new Map<Id, Id>();

        for(CAN_Pricing_Detail__c pricingDetail : newMap.values()) {
            if(pricingDetail.Status__c == CANPricingDetails.STATUS_SENT_TO_CUSTOMER) {
                applicationIdToPricingIdForArchive.put(pricingDetail.Application__c, pricingDetail.Id);
            } else if(pricingDetail.Status__c == CANPricingDetails.STATUS_ACCEPTED) {
                genesis__Applications__c application = new genesis__Applications__c(Id = pricingDetail.Application__c);
                applicationIdToPricingIdForArchive.put(pricingDetail.Application__c, pricingDetail.Id);
                Applications.setApplicationFieldsFromPricing(application, pricingDetail);
                application.genesis__Status__c = Applications.STATUS_OFFER_ACCEPTED;
                applicationDBInstance.addUpdate(application);
            }
        }

        if(!applicationIdToPricingIdForArchive.isEmpty()) {
            CANPricingDetailManager.archiveExistingCANPricingDetails(applicationIdToPricingIdForArchive);
        }

        applicationDBInstance.executeUpdates();
    }

    public void beforeUpdate(Map<Id, CAN_Pricing_Detail__c> newMap, Map<Id, CAN_Pricing_Detail__c> oldMap) {
        Map<Id, Id> applicationIdToPricingIdForArchive = new Map<Id, Id>();
        for(CAN_Pricing_Detail__c pricingDetail : newMap.values()) {
            genesis__Applications__c application = new genesis__Applications__c(Id = pricingDetail.Application__c);
            CANPricingDetails.validatePricing(pricingDetail);
            CAN_Pricing_Detail__c oldPricingDetail = oldMap.get(pricingDetail.Id);
            if(CANPricingDetails.isPolicyParameterModified(pricingDetail, oldPricingDetail)) {
                CANPricingDetails.setGAVAndPricingFactorFromPolicyExhibit(pricingDetail);
            }
            if(CANPricingDetails.isPricingModified(pricingDetail, oldPricingDetail)) {
                CANPricingDetails.calculateCANPricingWithoutPolicyUpdate(pricingDetail);
            }

            if(oldPricingDetail.Status__c != pricingDetail.Status__c
                && pricingDetail.Status__c == CANPricingDetails.STATUS_SENT_TO_CUSTOMER
            ) {
                if(pricingDetail.Offer_Type__c != CANPricingDetails.OFFER_TYPE_MANUAL_OFFER) {
                    Applications.setApplicationFieldsFromPricing(application, pricingDetail);
                }
                if(pricingDetail.Offer_Type__c == CANPricingDetails.OFFER_TYPE_MANUAL_OFFER
                    && pricingDetail.Maximum_Exception_Amount__c != null
                    && pricingDetail.Maximum_Exception_Amount__c > 250000
                ) {
                    pricingDetail.Status__c = CANPricingDetails.STATUS_REVIEW_REQUIRED;
                    pricingDetail.Offer_Type__c = CANPricingDetails.OFFER_TYPE_EXCEPTION_OFFER;
                    application.genesis__Status__c = Applications.STATUS_UW_EXCEPTION_REVIEW;
                } else {
                    applicationIdToPricingIdForArchive.put(pricingDetail.Application__c, pricingDetail.Id);
                    application.genesis__Status__c = Applications.STATUS_OFFER_SENT;
                }

                applicationDBInstance.addUpdate(application);
            }
        }

        if(!applicationIdToPricingIdForArchive.isEmpty()) {
            CANPricingDetailManager.archiveExistingCANPricingDetails(applicationIdToPricingIdForArchive);
        }

        applicationDBInstance.executeUpdates();
    }

    private class CANPricingDetailTriggerHandlerException extends Exception {}
}