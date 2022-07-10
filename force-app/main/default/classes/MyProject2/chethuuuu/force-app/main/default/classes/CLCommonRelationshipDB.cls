public class CLCommonRelationshipDB extends DBManager{

    public List<clcommon__Relationship__c> getPrimaryGuarantorDetailsByBorrowerId(Set<Id> borrowerAccIds, Set<Id> relationshipIds){
        return [
            SELECT Id, clcommon__Entity__c, clcommon__Related_Entity__c, clcommon__Relationship__c, clcommon__Ownership_Percentage__c
            FROM clcommon__Relationship__c
            WHERE clcommon__Entity__c IN :borrowerAccIds
                AND clcommon__Relationship__c IN :relationshipIds
                AND clcommon__Ownership_Percentage__c = 100
            ORDER BY LastModifiedDate DESC LIMIT 1
        ];
    }

    public List<clcommon__Relationship__c> getGuarantorDetailsByBorrowerId(Set<Id> borrowerAccIds, Set<Id> relationshipIds, Id guarantorAccountId){
        return [
            SELECT Id, clcommon__Entity__c, clcommon__Related_Entity__c, clcommon__Relationship__c, clcommon__Ownership_Percentage__c
            FROM clcommon__Relationship__c
            WHERE clcommon__Entity__c IN :borrowerAccIds
                AND clcommon__Related_Entity__c = :guarantorAccountId
                AND clcommon__Relationship__c IN :relationshipIds
        ];
    }

    public List<clcommon__Relationship__c> getBrokerDetailsByBorrowerId(Set<Id> borrowerAccIds, Set<Id> relationshipIds){
        return [
            SELECT Id, clcommon__Entity__c, clcommon__Related_Entity__c, clcommon__Relationship__c
            FROM clcommon__Relationship__c
            WHERE clcommon__Entity__c IN :borrowerAccIds
                AND clcommon__Relationship__c IN :relationshipIds
            ORDER BY CreatedDate DESC LIMIT 1
        ];
    }

    public List<clcommon__Relationship__c> getBorrowerDetailsByBrokerDetails(Set<Id> brokerAccIds, Set<Id> relationshipIds){
        return [
            SELECT Id, clcommon__Entity__c, clcommon__Related_Entity__c, clcommon__Relationship__c
            FROM clcommon__Relationship__c
            WHERE clcommon__Related_Entity__c IN :brokerAccIds
                AND clcommon__Relationship__c IN :relationshipIds
            ORDER BY CreatedDate DESC
        ];
    }

    public List<clcommon__Relationship__c> getGuarantorsByBorrowerIds(Set<Id> borrowerAccIds, Set<Id> relationshipIds){
        return [
            SELECT Id, clcommon__Entity__c, clcommon__Related_Entity__c, clcommon__Relationship__c, clcommon__Ownership_Percentage__c
            FROM clcommon__Relationship__c
            WHERE clcommon__Entity__c IN :borrowerAccIds
                AND clcommon__Relationship__c IN :relationshipIds
            ORDER BY LastModifiedDate DESC
        ];
    }

    public List<clcommon__Relationship__c> getAllRelatedBrokersByParentBrokerId(Set<Id> brokerAccountIds){
        return [
            SELECT Id, clcommon__Entity__c, clcommon__Related_Entity__c, clcommon__Relationship__c
            FROM clcommon__Relationship__c
            WHERE clcommon__Entity__c IN :brokerAccountIds
        ];
    }

    public List<clcommon__Relationship__c> getAllRelatedBorrowersByBrokerIds(Set<Id> brokerAccountIds, Set<Id> borrowerAccountIds){
        return [
            SELECT Id, clcommon__Entity__c, clcommon__Related_Entity__c, clcommon__Relationship__c
            FROM clcommon__Relationship__c
            WHERE clcommon__Entity__c IN :borrowerAccountIds
                AND clcommon__Related_Entity__c IN :brokerAccountIds
        ];
    }
    public List<clcommon__Relationship__c> getCLCommonRelationships(Set<Id> entityIds, Set<Id> relatedEntityIds, Set<Id> relationshipIds){
        return [
            SELECT Id, clcommon__Entity__c, clcommon__Related_Entity__c, clcommon__Relationship__c, clcommon__Ownership_Percentage__c
            FROM clcommon__Relationship__c
            WHERE clcommon__Entity__c IN :entityIds
                AND clcommon__Related_Entity__c = :relatedEntityIds
                AND clcommon__Relationship__c IN :relationshipIds
          ];
    }
}