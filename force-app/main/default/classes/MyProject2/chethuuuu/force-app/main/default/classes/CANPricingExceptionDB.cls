public class CANPricingExceptionDB extends DBManager {

    public list<CAN_Pricing_Exception__c> getPricingExceptionByApplicationId(Set<Id> applicationIds) {
        return [
            SELECT Id, Name, Account__c, Application__c, Approved_Exceptions__c, CreatedById, CreatedDate, Created_Date_Time__c,
            Credit_Decision__c, Credit_Review_Status__c, Exception_Requested__c, Exception_Types__c, IsDeleted,
            Justification_Notes__c, LastActivityDate, LastModifiedById, LastModifiedDate, OwnerId, Request_Detail__c,
            SystemModstamp, webbank_approval_required__c, WebBank_Approved__c
            FROM CAN_Pricing_Exception__c
            WHERE Application__c IN :applicationIds
        ];
    }

}