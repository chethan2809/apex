public class PartnerCreateApplicationManager {
    @TestVisible
    private static ApplicationDB applicationDBInstance = new ApplicationDB();
    @TestVisible
    private static partyDB partyDBInstance = new partyDB();

    public static Map<String, Object> createPartnerApplication(Map<String, Object> requestMap) {
        Map<String, Object> partnerDetailsMap = (Map<String, object>) requestMap.get(PartnerAPIConstants.PARTNER_DETAILS);
        Map<String, Object> validationResult =  PartnerAPIHelpers.genericPartnerAPIValidation(String.valueOf(partnerDetailsMap.get(PartnerAPIConstants.PARTNER_EMAIL)), null,
            String.valueOf(partnerDetailsMap.get(PartnerAPIConstants.PARTNER_API_KEY)));
        Map<String, Object> request = PartnerCreateApplications.buildRequest(requestMap);
        Id applicationId = PartnerCreateApplications.createApplication(request);
        User userDetail = (User) validationResult.get(PartnerAPIConstants.PARTNER_DETAIL);
        applicationDBInstance.addUpdate(new genesis__Applications__c(Id = applicationId, OwnerId = userDetail.Id));
        applicationDBInstance.executeUpdates();
        List<genesis__Applications__c> applications = applicationDBInstance.getApplicationsByIds(new Set<Id>{ applicationId });
        List<clcommon__Party__c> parties = partyDBInstance.getBorrowerAndGuarantorsByApplicationIds(new Set<Id>{ applicationId });

        Map<String, Object> resultMap = PartnerCreateApplications.buildResponse(applications, parties);
        return resultMap;
    }
}