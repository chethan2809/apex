public class PartnerAPIHelpers {
    @TestVisible
    private static AccountDB accountDBInstance = new AccountDB();
    @TestVisible
    private static ContactDB contactDBInstance = new ContactDB();
    @TestVisible
    private static ApplicationDB applicationDBInstance = new ApplicationDB();
    @TestVisible
    private static UserDB userDBInstance = new UserDB();
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

    public static Map<String, Object> genericPartnerAPIValidation(String partnerEmail, String applicationName, String partnerAPIKey) {
        Map<String, Object> result = new Map<String, Object>();
        List<User> partnerUsersList = userDBInstance.getDefaultPortalOwnerByEmail(new Set<String>{ partnerEmail });
        User partnerDetails = new User();

        if(!partnerUsersList.isEmpty()){
            partnerDetails = partnerUsersList.get(0);
            result.put(PartnerAPIConstants.PARTNER_DETAIL, partnerDetails);
        }

        if(partnerDetails == null || partnerDetails.AccountId == null || partnerDetails.ContactId == null) {
            throw new PartnerAPIHelperException(PartnerAPIConstants.PARTNER_USER_DOES_NOT_EXIST);
        }

        if(partnerDetails.AccountId != null) {
            List<Account> brokerAccountList = accountDBInstance.getAccountByIds(new set<Id> {partnerDetails.AccountId});
            if(!brokerAccountList.isEmpty() && brokerAccountList[0].Partner_API_Key__c != partnerAPIKey) {
                throw new PartnerAPIHelperException(PartnerAPIConstants.PARTNER_API_KEY_DOES_NOT_MATCH);
            }
        }

        if(applicationName != null){
            List<genesis__Applications__c> partnerApplications = applicationDBInstance.getPartnerApplicationByName(new Set<String>{ applicationName });
            if(partnerApplications.isEmpty()){
                throw new PartnerAPIHelperException(PartnerAPIConstants.INVALID_APPLICATION);
            }
            genesis__Applications__c application = partnerApplications.get(0);
            result.put(PartnerAPIConstants.APPLICATION_DETAILS, application);
            Account partnerAccount;
            if(application.Broker_Contact__c != null) {
                List<Contact> contactsList = contactDBInstance.getContactsByIds(new Set<Id>{application.Broker_Contact__c});
                Contact partnerContact = contactsList.get(0);
                if(partnerContact != null) {
                    List<Account> accountsList = accountDBInstance.getAccountByIds(new Set<Id>{partnerContact.AccountId});
                    partnerAccount = accountsList.get(0);
                }
            }
            if(partnerAccount == null) {
                throw new PartnerAPIHelperException(PartnerAPIConstants.PARTNER_USER_DOES_NOT_HAVE_ACCESS);
            }
            if(partnerAccount.Partner_API_Key__c != partnerAPIKey) {
                throw new PartnerAPIHelperException(PartnerAPIConstants.PARTNER_USER_DOES_NOT_HAVE_ACCESS);
            }
        }
        return result;
    }

    public static Map<String, Object> constructResponseMap(sObject sObjectRecord, Map<String, String> mapData){

        Map<String, Object> response = new Map<String, Object>();
        String fieldAPI;
        for(String key: mapData.keySet()){
            fieldAPI = mapData.get(key);
            response.put(key, sObjectRecord.get(fieldAPI));
        }
        return response;
    }

    public static Map<String, Object> constructResponseMap(Map<String, String> objectRecord, Map<String, String> mapData){

        Map<String, Object> response = new Map<String, Object>();
        String fieldAPI;
        for(String key: mapData.keySet()){
            fieldAPI = mapData.get(key);
            response.put(key, objectRecord.get(fieldAPI));
        }
        return response;
    }

    public static void generateErrorLog(String origin, String request, String error, String partnerEmail, String partnerAPIKey){
        Id referenceId;
        List<Account> brokerAccountList = new List<Account>();
        if(partnerAPIKey != null) {
            List<User> loggedInBrokerUsersList = userDBInstance.getDefaultPortalOwnerByEmail(new Set<String> { partnerEmail });
            if(!loggedInBrokerUsersList.isEmpty()) {
                brokerAccountList = accountDBInstance.getAccountByIds(new set<Id> {loggedInBrokerUsersList[0].AccountId});
            }
            if(!brokerAccountList.isEmpty() && brokerAccountList[0].Partner_API_Key__c != partnerAPIKey) {
                referenceId = brokerAccountList.get(0).Id;
            }
        }

        if(partnerEmail != null) {
            List<User> loggedInBrokerUsersList = userDBInstance.getDefaultPortalOwnerByEmail(new Set<String> { partnerEmail });
            if(!loggedInBrokerUsersList.isEmpty()){
                referenceId = loggedInBrokerUsersList.get(0).ContactId;
            }
        }

        Error_Log__c errorLog = ErrorLogs.createErrorLog(
            origin, error, request, null, ErrorLogs.ERROR, referenceId, false
        );
        errorLogDBInstance.addInsert(errorLog);
        errorLogDBInstance.executeInserts();
    }

    private class PartnerAPIHelperException extends Exception {}
}