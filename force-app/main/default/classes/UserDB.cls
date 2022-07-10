public class UserDB extends DBManager {

    public List<User> getUsersByUserNames(Set<String> userNames) {
        return [
            SELECT Id, AccountId, contactId, Username FROM User
            WHERE IsActive = true
                AND Username IN :userNames
        ];
    }

    public List<User> getUserByAccountIds(Set<Id> accountIds) {
        return [
            SELECT Id, AccountId, contactId, Username, Partner_Account_Manager__c
            FROM User
            WHERE AccountId  IN :accountIds
        ];
    }

    public List<User> getUsersByContactIds(Set<Id> contactIds) {
        return [
            SELECT Id, AccountId, ContactId, Username,Partner_Account_Manager__c
            FROM User
            WHERE IsActive = true
            AND contactId  IN :contactIds
        ];
    }

    public List<User> getBrokerUserDetailsByLoggedInId(){
        return [
            SELECT Id, AccountId, ContactId, Email, Username, Phone , Partner_Account_Manager__c
            FROM User
            WHERE Id =:UserInfo.getUserId()
        ];
    }



    public List<User> getUserDetailsByUnderWriterIds(Set<Id> underWriterIds){
        return [
            SELECT Id, Name, Email, Username, Phone
            FROM User
            WHERE Id IN :underWriterIds
        ];
    }

    public List<User> getDefaultPortalOwnerByEmail(Set<String> ownerEmails){
        return [
            SELECT Id, Name, Email, Username, Phone, AccountId, ContactId, Partner_Account_Manager__c
            FROM User
            WHERE Email IN :ownerEmails
        ];
    }

    public List<User> getUserDetailsByIds(Set<Id> brokerIds){
        return [
            SELECT Id, Name, Email, Username, Phone, AccountId, ContactId
            FROM User
            WHERE Id IN :brokerIds
        ];
    }

    public List<User> getUserDetailsByProfileIds(Set<Id> profileIds){
        return [
            SELECT Id, Name, Email, Username, Phone, AccountId, ContactId
            FROM User
            WHERE ProfileId IN :profileIds
        ];
    }

    public List<User> getDerronHardyDetailsByEmailAddress() {
        Origination_Settings__mdt defaultEmailSetting = CustomMetaDataHelper.defaultOriginationSetting;
        return [
            SELECT Id, FirstName, LastName, Email, Phone, Title
            FROM User
            WHERE Email = :defaultEmailSetting.Derron_Hardy_Email__c
        ];
    }

    public List<User> getUsersByBrokerContactIds(Set<Id> contactIds) {
        return [
            SELECT Id, AccountId, IsActive, ContactId, Username,Partner_Account_Manager__c
            FROM User
            WHERE contactId  IN :contactIds
        ];
    }
}