@IsTest(isParallel=true)
private class CLCommonRelationshipDBTests {

    private static CLCommonRelationshipDB clCommonRelationshipDBInstance = new CLCommonRelationshipDB();

    @IsTest
    private static void getPrimaryGuarantorDetailsByBorrowerId() {
        Id borrowerAccId = TestUtility.getFakeId(Account.getSObjectType());
        Set<Id> borrowerAccIds = new Set<Id>();
        borrowerAccIds.add(borrowerAccId);

        Id relationshipId = TestUtility.getFakeId(clcommon__Reciprocal_Role__c.getSObjectType());
        Set<Id> relationshipIds = new Set<Id>();
        relationshipIds.add(relationshipId);

        Test.startTest();
            List<clcommon__Relationship__c> relationshipRecord = clCommonRelationshipDBInstance.getPrimaryGuarantorDetailsByBorrowerId(borrowerAccIds, relationshipIds);
        Test.stopTest();

        System.assert(relationshipRecord != null);
        System.assert(relationshipRecord.isEmpty());
    }

    @IsTest
    private static void getBrokerDetailsByBorrowerId() {
        Id borrowerAccId = TestUtility.getFakeId(Account.getSObjectType());
        Set<Id> borrowerAccIds = new Set<Id>();
        borrowerAccIds.add(borrowerAccId);

        Id relationshipId = TestUtility.getFakeId(clcommon__Reciprocal_Role__c.getSObjectType());
        Set<Id> relationshipIds = new Set<Id>();
        relationshipIds.add(relationshipId);

        Test.startTest();
            List<clcommon__Relationship__c> relationshipRecord = clCommonRelationshipDBInstance.getBrokerDetailsByBorrowerId(borrowerAccIds, relationshipIds);
        Test.stopTest();

        System.assert(relationshipRecord != null);
        System.assert(relationshipRecord.isEmpty());
    }

    @IsTest
    private static void getGuarantorDetailsByBorrowerId() {
        Id guarantorAccId = TestUtility.getFakeId(Account.getSObjectType());
        Set<Id> guarantorAccIds = new Set<Id>();
        guarantorAccIds.add(guarantorAccId);

        Id relationshipId = TestUtility.getFakeId(clcommon__Reciprocal_Role__c.getSObjectType());
        Set<Id> relationshipIds = new Set<Id>();
        relationshipIds.add(relationshipId);

        Test.startTest();
            List<clcommon__Relationship__c> relationshipGuarantorRecord = clCommonRelationshipDBInstance.getGuarantorsByBorrowerIds(guarantorAccIds, relationshipIds);
        Test.stopTest();

        System.assert(relationshipGuarantorRecord != null);
        System.assert(relationshipGuarantorRecord.isEmpty());
    }

    @IsTest
    private static void getBorrowerDetailsByBorrowerId() {
        Id borrowerAccId = TestUtility.getFakeId(Account.getSObjectType());
        Set<Id> borrowerAccIds = new Set<Id>();
        borrowerAccIds.add(borrowerAccId);

        Id relationshipId = TestUtility.getFakeId(clcommon__Reciprocal_Role__c.getSObjectType());
        Set<Id> relationshipIds = new Set<Id>();
        relationshipIds.add(relationshipId);

        Test.startTest();
            List<clcommon__Relationship__c> relationshipBorrowerRecord = clCommonRelationshipDBInstance.getBorrowerDetailsByBrokerDetails(borrowerAccIds, relationshipIds);
            List<clcommon__Relationship__c> relationshipGuarantorRecord = clCommonRelationshipDBInstance.getGuarantorDetailsByBorrowerId(borrowerAccIds, relationshipIds, borrowerAccId);
        Test.stopTest();

        System.assert(relationshipBorrowerRecord != null);
        System.assert(relationshipBorrowerRecord.isEmpty());
    }
}