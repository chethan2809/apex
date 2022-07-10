public class CollectorAssignmentManager
{
    @TestVisible
    private static CollectionCaseDB collectionCaseDBInstance = new CollectionCaseDB();
    @TestVisible
    private static AccountDB accountDBInstance = new AccountDB();

    public static void collectorAssignment(List<loan__Loan_Account__c> delinquentAllCLContracts) {
        Integer lowBalanceQueueUserIndex = 0;
        Integer highBalanceQueueUserIndex = 0;
        Integer defaultCollectionQueueUserIndex = 0;
        List<Collection_Case__c> collectionCaseList = collectionCaseDBInstance.getActiveCollectionCases();
        Set<Id> collectionCaseIdsToInActive = getCollectionCaseIdsForActiveFalse(collectionCaseList, delinquentAllCLContracts);

        for (Collection_Case__c collectionCase : collectionCaseList) {

            if(collectionCaseIdsToInActive.contains(collectionCase.CL_Contract_Id__c)) {
                collectionCase.Is_Active__c = false;
                accountDBInstance.addUpdate(Accounts.setAccountFieldsFromCollectionsAfterInsert(collectionCase, collectionCase.Is_Active__c));
                collectionCase.Collections_status__c = CollectionCaseConstants.COLLECTION_CASE_STATUS_BAD_STANDING;
                collectionCase.Collections_sub_status__c = null;
            }

            Map<String, GroupMember> workLoadOfCollectors = getCollectorWorkLoad(collectionCaseList);
            if(!workLoadOfCollectors.isEmpty()) {
                lowBalanceQueueUserIndex = CollectionCaseHelper.lowBalanceQueueUsersList.indexOf(
                    workLoadOfCollectors.get(CollectionCaseConstants.LOW_BALANCE_QUEUE)
                );
                highBalanceQueueUserIndex = CollectionCaseHelper.highBalanceQueueUsersList.indexOf(
                    workLoadOfCollectors.get(CollectionCaseConstants.HIGH_BALANCE_QUEUE)
                );
            }

            if(!collectionCase.Manual_Collector_Assigned__c && !collectionCase.Is_Same_Queue__c) {
                if(collectionCase.Case_Queue__c == CollectionCaseConstants.LOW_BALANCE_QUEUE &&
                    !CollectionCaseHelper.lowBalanceQueueUsersList.isEmpty()
                ) {
                    collectionCase.OwnerId = CollectionCaseHelper.lowBalanceQueueUsersList.get(Math.mod(lowBalanceQueueUserIndex,
                    CollectionCaseHelper.lowBalanceQueueUsersList.size())).UserOrGroupId;
                    lowBalanceQueueUserIndex++;
                } else if(collectionCase.Case_Queue__c == CollectionCaseConstants.HIGH_BALANCE_QUEUE &&
                    !CollectionCaseHelper.highBalanceQueueUsersList.isEmpty()
                ) {
                    collectionCase.OwnerId = CollectionCaseHelper.highBalanceQueueUsersList.get(Math.mod(highBalanceQueueUserIndex,
                    CollectionCaseHelper.highBalanceQueueUsersList.size())).UserOrGroupId;
                    highBalanceQueueUserIndex++;
                }
            }
            collectionCaseDBInstance.addUpdate(collectionCase);
        }
        collectionCaseDBInstance.executeUpdates();
        accountDBInstance.executeUpdates();
    }

    public static Set<Id> getCollectionCaseIdsForActiveFalse(List<Collection_Case__c> collectionCaseList,
        List<loan__Loan_Account__c> delinquentAllCLContracts
    ) {
        Set<Id> loanContractIds = new Set<Id>();
        Set<Id> collectionCaseIds = new Set<Id>();
        for (loan__Loan_Account__c loanContract : delinquentAllCLContracts) {
            loanContractIds.add(loanContract.Id);
        }
        for (Collection_Case__c collectionCase : collectionCaseList) {
            collectionCaseIds.add(collectionCase.CL_Contract_Id__c);
        }
        for (Id caseId : collectionCaseIds) {
            if(loanContractIds.contains(caseId)) {
                collectionCaseIds.remove(caseId);
            }
        }

        return collectionCaseIds;
    }

    public static Map<String, GroupMember> getCollectorWorkLoad(List<Collection_Case__c> oldCollectionCases) {
        Map<String, GroupMember> loadOfCollectors = new Map<String, GroupMember>();
        Integer lowBalanceQueueTemp = oldCollectionCases.size();
        GroupMember lowBalanceQueueLessLoadOwner;
        for (GroupMember owner : CollectionCaseHelper.lowBalanceQueueUsersList) {
            Integer temp = 0;
            for (Collection_Case__c collCase : oldCollectionCases) {
                if(collCase.ownerId == owner.UserOrGroupId) {
                    temp++;
                }
            }
            if(lowBalanceQueueTemp >= temp) {
                lowBalanceQueueTemp = temp;
                lowBalanceQueueLessLoadOwner = owner;
            }
        }
        loadOfCollectors.put(CollectionCaseConstants.LOW_BALANCE_QUEUE, lowBalanceQueueLessLoadOwner);

        Integer highBalanceQueueTemp = oldCollectionCases.size();
        GroupMember highBalanceQueueLessLoadOwner;
        for (GroupMember owner : CollectionCaseHelper.highBalanceQueueUsersList) {
            Integer temp = 0;
            for (Collection_Case__c collCase : oldCollectionCases) {
                if(collCase.ownerId == owner.UserOrGroupId) {
                    temp++;
                }
            }
            if(highBalanceQueueTemp >= temp) {
                highBalanceQueueTemp = temp;
                highBalanceQueueLessLoadOwner = owner;
            }
        }
        loadOfCollectors.put(CollectionCaseConstants.HIGH_BALANCE_QUEUE, highBalanceQueueLessLoadOwner);

        return loadOfCollectors;
    }

    @AuraEnabled
    public static void manualCollectorAssignment(Id collectionCaseId, String selectedQueue, Id selectedCollectorId) {
        Collection_Case__c collectionCase = new Collection_Case__c(Id = collectionCaseId);
        collectionCase.Case_Queue__c = selectedQueue;
        collectionCase.OwnerId = selectedCollectorId;
        collectionCase.Manual_Collector_Assigned__c = true;
        collectionCaseDBInstance.addUpdate(collectionCase).executeUpdates();
    }
}