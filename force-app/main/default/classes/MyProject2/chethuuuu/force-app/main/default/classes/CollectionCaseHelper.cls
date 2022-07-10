public class CollectionCaseHelper {

    @TestVisible
    private static GroupMemberDB groupMemberDBInstance = new GroupMemberDB();
    @TestVisible
    private static CollectionCaseDB collectionCaseDBInstance = new CollectionCaseDB();

    public static Map<Id, Collection_Case__c> getAllCollectionCasesMap {
        get {
            if(getAllCollectionCasesMap == null) {
                getAllCollectionCasesMap = new Map<Id, Collection_Case__c>();
                for(Collection_Case__c collectionCase : collectionCaseDBInstance.getCollectionCases()) {
                    getAllCollectionCasesMap.put(collectionCase.CL_Contract_Id__c, collectionCase);
                }
            }
            return getAllCollectionCasesMap;
        }
        set;
    }

    public static List<GroupMember> lowBalanceQueueUsersList {
        get {
            if(lowBalanceQueueUsersList == null) {
                lowBalanceQueueUsersList = new List<GroupMember>();
                lowBalanceQueueUsersList = groupMemberDBInstance.getAllLowBalanceQueueUsers();
            }
            return lowBalanceQueueUsersList;
        }
        set;
    }

    public static List<GroupMember> highBalanceQueueUsersList {
        get {
            if(highBalanceQueueUsersList == null) {
                highBalanceQueueUsersList = new List<GroupMember>();
                highBalanceQueueUsersList = groupMemberDBInstance.getAllHighBalanceQueueUsers();
            }
            return highBalanceQueueUsersList;
        }
        set;
    }

    @AuraEnabled(cacheable=true)
    public static loan__Office_Name__c getCurrentSystemDate() {
        return [
            SELECT Id, loan__Current_System_Date__c FROM loan__Office_Name__c LIMIT 1
        ];
    }
}