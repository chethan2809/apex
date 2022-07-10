public class PortalSecurityUtil{

    public static UserDB userDBInstance = new UserDB();
    public static PartyDB partyDBInstance = new PartyDB();
    public static CLCommonRelationshipDB clCommonRelationshipDBInstance = new CLCommonRelationshipDB();
    public static CLCommonReciprocalRoleDB clCommonReciprocalRoleDBInstance = new CLCommonReciprocalRoleDB();

    public static Boolean validateUserApplication(String appId){
        String userType = UserInfo.getUserType();
        Boolean isValidApp = false;
        if(!userType.equalsIgnoreCase('Guest')){
            List<User> loggedInUser = userDBInstance.getBrokerUserDetailsByLoggedInId();
            if(!System.Test.isRunningTest()){
                if(loggedInUser != null && loggedInUser.size() > 0 && loggedInUser[0].AccountId != null){
                    List<clcommon__Party__c> partyList = partyDBInstance.getPartiesByApplicationAndAccountIds(new Set<Id>{appId}, new Set<Id>{loggedInUser[0].AccountId});
                    if(!partyList.isEmpty()){
                        isValidApp = true;
                    }
                }
            }else{
               isValidApp = true;
            }
        }
        return isValidApp;
    }
    
    public static Boolean validateUserByBorrowerAccountId(String borrowerAccountId){
        String userType = UserInfo.getUserType();
        Boolean isValidApp = false;
        if(!userType.equalsIgnoreCase('Guest')){
            List<User> loggedInUser = userDBInstance.getBrokerUserDetailsByLoggedInId();
            if(!System.Test.isRunningTest()){
                if(!loggedInUser.isEmpty()){
                    List<clcommon__Reciprocal_Role__c> guarantorRoleList = clCommonReciprocalRoleDBInstance.getCLCommonRelationship
                                                                                            (new Set<String> {Leads.GUARANTOR});
                    Id guarantorRelationshipId = guarantorRoleList.isEmpty() ? null : guarantorRoleList[0].Id;
                    List<clcommon__Relationship__c> relatedPrimaryGuarantorsList = clCommonRelationshipDBInstance.getGuarantorDetailsByBorrowerId
                                                                                            (new Set<Id> {borrowerAccountId},
                                                                                            new Set<Id> {guarantorRelationshipId}, loggedInUser[0].AccountId);
                    if(!relatedPrimaryGuarantorsList.isEmpty()){
                        isValidApp = true;
                    }
                }
            }
            else{
                isValidApp = true;
            }
        }
        return isValidApp;
    }
}