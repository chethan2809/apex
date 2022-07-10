public class CCBPBrokerHierarchyManager {
    public static UserDB userDBInstance = new UserDB();
    public static AccountDB accountDBInstance = new AccountDB();
    public static CLCommonRelationshipDB clCommonRelationshipDBInstance = new CLCommonRelationshipDB();

    public static Set<Id> getBrokerUserIds() {
        Set<Id> brokerUserIds = new Set<Id>();
        List<User> loggedInBrokerUserList = userDBInstance.getBrokerUserDetailsByLoggedInId();
        Set<Id> accountIdsSet = new Set<Id>();
        Set<Id> relatedEntityIdsSet = new Set<Id>();
        accountIdsSet.add(loggedInBrokerUserList[0].AccountId);

        List<clcommon__Relationship__c> relatedEntityBrokersList = clCommonRelationshipDBInstance.getAllRelatedBrokersByParentBrokerId(accountIdsSet);
        for(clcommon__Relationship__c relatedEntityBroker : relatedEntityBrokersList){
            relatedEntityIdsSet.add(relatedEntityBroker.clcommon__Related_Entity__c);
        }
        List<User> allLayersBrokersList = userDBInstance.getUserByAccountIds(relatedEntityIdsSet);
        for(User brokers : allLayersBrokersList){
            brokerUserIds.add(brokers.Id);
        }
        return brokerUserIds;
    }
}