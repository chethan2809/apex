public without sharing class PartnerPricingSecureLinkController {
    @TestVisible
    private static ApplicationDB applicationDBInstance = new ApplicationDB();
    @TestVisible
    private static CANPricingDetailDB canPricingDetailDBInstance = new CANPricingDetailDB();

    @AuraEnabled(cacheable=false)
    public static Id getApplicationId(String encryptedString) {
        String key = CustomSettingsHelper.generalSettings.Partner_Pricing_Secure_Link_Key__c;
        Blob decrypted = Crypto.decryptWithManagedIV(
            'AES128', EncodingUtil.base64Decode(key), (Blob) EncodingUtil.convertFromHex(encryptedString)
        );
        String decryptedString = decrypted.toString();
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(decryptedString);

        return (Id) resultMap.get('applicationId');
    }

    @AuraEnabled(cacheable=true)
    public static CAN_General_Settings__c getCANGeneralSetting() {
        return CustomSettingsHelper.generalSettings;
    }

    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getApplicationDetails(Id applicationId) {
        List<genesis__Applications__c> applicationList = applicationDBInstance.getApplicationsByIds(
            new Set<Id> {applicationId}
        );

        if(applicationList.isEmpty()) {
            throw new PartnerPricingException('There was no Application found for this request');
        }

        Map<String, Object> applicationMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(applicationList.get(0)));

        System.debug('applicationMap:' + applicationMap);
        return applicationMap;
    }

    @AuraEnabled(cacheable=false)
    public static Boolean validateApplication(Map<String, Object> application) {
        genesis__Applications__c applicationObj = (genesis__Applications__c) JSON.deserialize(JSON.serialize(application) , genesis__Applications__c.class);
        return (applicationObj.Broker_Account__r.Is_Broker_Active__c && applicationObj.Broker_Account__r.Enable_Secure_Partner_Links__c
            && Applications.PARTNER_PRICING_ELIGIBLE_STATUSES.contains(applicationObj.genesis__Status__c)
        );
    }

    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getPricingDetails(Id applicationId) {
        List<CAN_Pricing_Detail__c> pricingList = canPricingDetailDBInstance.getCANPricingListByApplicationIdsAndStatuses(
            new Set<Id> {applicationId}, CANPricingDetails.ACTIVE_PRICING_STATUSES
        );

        if(pricingList.isEmpty()){
            throw new PartnerPricingException('There was no Pricing Detail record found');
        }

        Map<String, Object> pricingDetailMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(pricingList.get(0)));
        pricingDetailMap.put('sObject', 'CAN_Pricing_Detail__c');
        return pricingDetailMap;
    }

    @AuraEnabled(cacheable=false)
    public static Map<String, Object> calculatePricing(Map<String, Object> pricingDetail) {
        CAN_Pricing_Detail__c pricingDetailObj = (CAN_Pricing_Detail__c) JSON.deserialize(JSON.serialize(pricingDetail) , CAN_Pricing_Detail__c.class);
        pricingDetailObj = CANPricingDetails.calculateCANPricing(pricingDetailObj);
        return (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(pricingDetailObj));
    }

    @AuraEnabled
    public static String acceptPricingOffer(Map<String, Object> pricingDetail) {
        CAN_Pricing_Detail__c pricingDetailObj = (CAN_Pricing_Detail__c) JSON.deserialize(JSON.serialize(pricingDetail) , CAN_Pricing_Detail__c.class);
        CAN_Pricing_Detail__c finalPricing = CCAcceptOfferFromPortalAPI.createAcceptedPricingRecordFromBrokerPortal(
            pricingDetailObj, pricingDetailObj.Application__c
        );
        canPricingDetailDBInstance.addInsert(finalPricing);

        try {
            canPricingDetailDBInstance.executeInserts();
            return 'Success';
        } catch(Exception e) {
            throw e;
        }
    }

    @AuraEnabled
    public static String generateDocument(Id applicationId) {

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String jsonBody = '{"parentId":"' + applicationId +'","sendForESign":true,"templateType":"Loan Agreement"}';
        req.setEndpoint('callout:Portal_Conga_API/services/apexrest/v1/congaautomation');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setBody(jsonBody);
        req.setTimeout(60000);

        HttpResponse response = http.send(req);
        if(response.getStatusCode() == 200){
            genesis__Applications__c application = applicationDBInstance.getApplicationsByIds(
                new Set<Id> {applicationId}
            ).get(0);
            Decimal generateDocCount = application.Partner_Pricing_Generate_Doc_Count__c;
            application.Partner_Pricing_Generate_Doc_Count__c = generateDocCount == null? 1 : generateDocCount + 1;
            applicationDBInstance.addUpdate(application).executeUpdates();
            return 'Success';
        } else {
            return response.getStatus();
        }
    }

    private class PartnerPricingException extends Exception {}
}