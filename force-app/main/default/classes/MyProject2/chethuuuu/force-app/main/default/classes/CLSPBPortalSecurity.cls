public class CLSPBPortalSecurity {
    public static ApplicationDB applicationDBInstance = new ApplicationDB();
    public static AccountDB accountDBInstance = new AccountDB();
    public static UserDB userDBInstance = new UserDB();
    public static ContactDB contactDBInstance = new ContactDB();
    public static CLCommonRelationshipDB clCommonRelationshipDBInstance = new CLCommonRelationshipDB();
    public static Boolean validApplication(Id applicationId){
        Boolean isValidApplication = false;
        Set<Id> brokerUserIds = new Set<Id>();
        brokerUserIds = CCBPBrokerHierarchyManager.getBrokerUserIds();
        List<genesis__Applications__c> applicationList = applicationDBInstance.getApplicationsByIdsAndBrokerIds(new Set<Id> {applicationId}, brokerUserIds);
        if(!applicationList.isEmpty()){
            isValidApplication = true;
        }else{
             isValidApplication = false;
        }
        return isValidApplication;
    }

    public static Boolean validateUserByBorrowerAccountId(Id borrowerId){
        Boolean isValidUser = false;
        Set<Id> brokerUserIds = new Set<Id>();
        brokerUserIds = CCBPBrokerHierarchyManager.getBrokerUserIds();
        List<User> brokerAccountsList = userDBInstance.getUserDetailsByIds(brokerUserIds);
        if(!brokerAccountsList.isEmpty()){
            Set<Id> brokerAccountIds = new Set<Id>();
            for(User brokerUserAccount: brokerAccountsList){
                brokerAccountIds.add(brokerUserAccount.AccountId);
            }
            List<clcommon__Relationship__c> brokersBorrowerAccountList = clCommonRelationshipDBInstance.getAllRelatedBorrowersByBrokerIds(brokerAccountIds, new Set<Id> {borrowerId});
            if(!brokersBorrowerAccountList.isEmpty()) {
                isValidUser = true;
            } else {
                isValidUser = false;
            }
        }
        else{
            isValidUser = false;
        }
        return isValidUser;
    }

    public static Boolean validLoggedInBrokerUser(Id brokerContactId){
        Boolean isValidLoggedInUser = false;
        List<User> userList = userDBInstance.getUsersByContactIds(new Set<Id> {brokerContactId});
        if(!userList.isEmpty()){
            isValidLoggedInUser = true;
        }else{
            isValidLoggedInUser = false;
        }
        return isValidLoggedInUser;
    }
}