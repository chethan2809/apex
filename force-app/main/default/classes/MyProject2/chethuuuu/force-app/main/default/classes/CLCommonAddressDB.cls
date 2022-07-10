public class CLCommonAddressDB extends DBManager {
    public List<clcommon__Address__c> getAddresses(Set<Id> addressIds){
        return [
            SELECT Id,clcommon__Address_Line_2__c, clcommon__Street_Address__c, clcommon__City__c, clcommon__State_Province__c, clcommon__Country__c, clcommon__Zip_Code__c
            FROM clcommon__Address__c
            WHERE Id in :addressIds
            AND genesis__Active__c = true
        ];
    }
}