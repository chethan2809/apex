public class ApplicationDailyUpdates {
    public static final Set<String> ELIGIBLE_PRICING_STATUS = new Set<String> {
        CANPricingDetails.STATUS_ACCEPTED, CANPricingDetails.STATUS_SENT_TO_CUSTOMER
    };

    public static void expireDeclineRule(genesis__Applications__c application) {
        if(application.Last_Status_Update_Date__c == null) {
            return;
        }
        DateTime statusDate = application.Last_Status_Update_Date__c;
        Date lastStatusUpdatedDate = Date.newInstance(statusDate.year(), statusDate.month(), statusDate.day());
        Integer renewalExpirationDays = CustomSettingsHelper.generalSettings != null
            && CustomSettingsHelper.generalSettings.CAN_Renewal_expiration_days_after_payoff__c != null ?
            Integer.ValueOf(CustomSettingsHelper.generalSettings.CAN_Renewal_expiration_days_after_payoff__c) : null;

        if(application.genesis__Status__c == Applications.STATUS_OFFER_SENT
            && (lastStatusUpdatedDate.daysBetween(GeneralHelper.currentSystemDate) > CustomMetaDataHelper.defaultOriginationSetting.Pricing_Expire_Days__c)
        ) {
            Applications.setDenialReasons(application, BusinessRules.DENIAL_REASON_OFFERS_EXPIRED);
        } else if(application.genesis__Status__c == Applications.STATUS_NEW_ENTERED
            && (lastStatusUpdatedDate.daysBetween(GeneralHelper.currentSystemDate) > CustomMetaDataHelper.defaultOriginationSetting.Concurrent_Expire_Days__c)
        ) {
            Applications.setDenialReasons(application, BusinessRules.DENIAL_REASON_CLOSED_EXPIRED);
        } else if(Applications.APP_ACTIVE_STATUSES.contains(application.genesis__Status__c) && application.Auto_Renewed__c
            && ((application.Broker_Contact__c != null && !application.genesis__Account__r.Is_Exclusivity__c)
                ||
                (application.Broker_Contact__c == null && application.genesis__Account__r.Days_Since_Zero_Balance_Date__c != null
                    && renewalExpirationDays != null && application.genesis__Account__r.Days_Since_Zero_Balance_Date__c > renewalExpirationDays
                )
            )
        ) {
            Applications.setDenialReasons(application, BusinessRules.DENIAL_REASON_OFFERS_EXPIRED);
        }
    }
}