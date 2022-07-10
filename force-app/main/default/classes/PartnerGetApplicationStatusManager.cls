public class PartnerGetApplicationStatusManager {
    @TestVisible
    private static CANPricingDetailDB canPricingDetailDBInstance = new CANPricingDetailDB();
    @TestVisible
    private static CLContractDB clContractDBInstance = new CLContractDB();
    @TestVisible
    private static STIPSChecklistDB stipsChecklistDBInstance = new STIPSChecklistDB();

    public static Map<String, Object> getApplicationStatus(RestRequest request){
        genesis__Applications__c application = PartnerGetApplicationStatus.validateRequest(request);
        Id applicationId = application.Id;
        String applicationStatus = application.Overall_Status__c;
        application.Overall_Status__c = PartnerAPIConstants.applicationOverAllStatusToApplicationPartnerAPIStatus.get(applicationStatus);
        if(application.Overall_Status__c == Applications.STATUS_APPROVED) {
            applicationStatus = application.Overall_Status__c;
            List<loan__Loan_Account__c> clContractList = clContractDBInstance.getLoanAccountsByApplicationIds(new Set<Id> {applicationId});
            if(!clContractList.isEmpty() && PartnerAPIConstants.clContractStatusToApplicationStatus.containsKey(clContractList[0].loan__Loan_Status__c)) {
                applicationStatus = clContractList[0].loan__Loan_Status__c;
            }
            application.Overall_Status__c = PartnerAPIConstants.clContractStatusToApplicationStatus.get(applicationStatus);
        }

        List<CAN_Pricing_Detail__c> canPricingDetails = canPricingDetailDBInstance.getCANPricingListByApplicationIdsAndStatuses(new Set<Id> { applicationId }, new Set<String>{ CANPricingDetails.STATUS_SENT_TO_CUSTOMER });
        List<STIPS_Checklist__c> stipsChecklist = stipsChecklistDBInstance.getSTIPSCheckListByApplicationIds(new Set<Id> { applicationId });

        Map<String, Object> responseMap = PartnerGetApplicationStatus.buildResponse(canPricingDetails, stipsChecklist, application);
        return responseMap;
    }
}