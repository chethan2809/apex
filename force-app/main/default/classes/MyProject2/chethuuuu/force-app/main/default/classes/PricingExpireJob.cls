public class PricingExpireJob implements Schedulable, Database.Batchable<SObject>  {

    @TestVisible
    private static Origination_Settings__mdt defaultPricingExpireSetting = CustomMetaDataHelper.defaultOriginationSetting;
    @TestVisible
    private static final String PRICING_STATUS_SENT_TO_CUSTOMER = 'Sent To Customer';
    @TestVisible
    private static ApplicationDB applicationDBInstance = new ApplicationDB();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date notificationDate = GeneralHelper.currentSystemDate.addDays(- Integer.ValueOf(defaultPricingExpireSetting.Pricing_Expire_Days__c));

        return Database.getQueryLocator([
            SELECT Id, Application__c, Start_Date__c
            FROM CAN_Pricing_Detail__c
            WHERE Status__c = :PRICING_STATUS_SENT_TO_CUSTOMER
                AND Start_Date__c >= :notificationDate
                AND Application__r.genesis__Status__c != :Applications.STATUS_DECLINED
        ]);
    }

    public void execute(Database.BatchableContext bc, List<CAN_Pricing_Detail__c> pricingDetailList) {
        for (CAN_Pricing_Detail__c pricingDetail : pricingDetailList) {
            genesis__Applications__c application = new genesis__Applications__c(Id = pricingDetail.Application__c);
            Applications.setDenialReasons(application, BusinessRules.DENIAL_REASON_PRICING_EXPIRED);
            applicationDBInstance.addUpdate(application);
        }

        applicationDBInstance.executeUpdates();
    }

    public void execute(SchedulableContext sc) {
        if (defaultPricingExpireSetting.Pricing_Expire_Batch_Size__c == null) {
            throw new PricingExpireJobException('Pricing_Expire_Batch_Size__c is null');
        }
        Database.executeBatch(this, Integer.ValueOf(defaultPricingExpireSetting.Pricing_Expire_Batch_Size__c));
    }

    public static void execute() {
        PricingExpireJob pricingExpireJobInstance = new PricingExpireJob();
        pricingExpireJobInstance.execute(null);
    }

    public void finish(Database.BatchableContext bc) {

    }

    private class PricingExpireJobException extends Exception {}
}