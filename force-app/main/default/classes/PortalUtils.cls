public with sharing class PortalUtils {
    
    public static Boolean validateSession() {
        try {
            User contextUser = [SELECT id, username FROM User WHERE username =: UserInfo.getUserName() AND IsActive = true];
        } catch(Exception e) {
            //throw new IllegalUserException('Invalid User!', e);
        }
        return true;
    }
    
    public static Boolean validateRequest(Map<String,Object> params, List<String> keysToCheck) {
      
        if(keysToCheck != null && !keysToCheck.isEmpty()) {
            for(String key : keysToCheck) {
                if( !params.containsKey(key) || params.get(key) == null || String.isBlank(String.valueOf(params.get(key))) ) {
                  /* Either key is not present in req map OR value is null OR value is blank */
                    //throw new IllegalInputException('Validation Error -> ' + key);
                }
            }
        }
        
        return true;
    }
    
    public static clcommon.Response setResponse(String status, String errorCode, String errorMessage) {
        clcommon.Response response = new clcommon.Response();
        response.status = status;
        response.errorCode = errorCode;
        response.errorMessage = errorMessage;
        return response;  
    }
    
    public static clcommon.Response setResponse(String errorMessage) {
        clcommon.Response response = new clcommon.Response();
        response.status = clcommon.Constants.ERROR;
        response.errorCode = clcommon.Constants.API_EXCEPTION;
        response.errorMessage = errorMessage;
        return response;  
    }
    
    public static clcommon.Response setResponse(String key, Map<String, Object> dataMap) {
        clcommon.Response response = new clcommon.Response();
        List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
        respList.add(new clcommon.PortalCustomRemoteActionRecord(key, dataMap));
        response = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
        response.status = clcommon.Constants.SUCCESS;
        return response;
    }
    
    //To store the Portal error log to clcommon__Type__c
    public static void insertPortalLog(Exception e, String errorType) {
        clcommon__Log__c portalLog = new clcommon__Log__c();
        //portalLog.Category__c = PortalConstants.PARAM_PORTAL;
        portalLog.clcommon__Message__c = e.getMessage() + ' ## ' + e.getStackTraceString();
        portalLog.clcommon__Time__c = DateTime.now();
        portalLog.clcommon__Type__c = errorType;
        //portalLog.User_Details__c = userInfo.getUserId();
        insert portalLog;
    }
    
    public static void insertPortalLog(String message, String errorType) {
        clcommon__Log__c portalLog = new clcommon__Log__c();
        //portalLog.Category__c = PortalConstants.PARAM_PORTAL;
        portalLog.clcommon__Message__c = message;
        portalLog.clcommon__Time__c = DateTime.now();
        portalLog.clcommon__Type__c = errorType;
        //portalLog.User_Details__c = userInfo.getUserId();
        insert portalLog;
    }

    public static Boolean validateAccount(Id accountId){
        Account account = [SELECT Id FROM Account WHERE Id = : accountId];
        if(account != null){
            return true;
        }
        else{
            return false;
        }
    }

    public static Boolean validateContact(Id contactId){
        Contact contact = [SELECT Id FROM Contact WHERE Id = : contactId];
        if(contact != null){
            return true;
        }
        else{
            return false;
        }
    }

    public static Boolean validaterRelatedContact(Id contactId, Id accountId){
        Contact contact = [SELECT AccountId FROM Contact WHERE Id = : contactId];
        if(contact != null && contact.AccountId == accountId){
            return true;
        }
        else{
            return false;
        }
    }
}