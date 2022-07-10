@isTest
private class CLCommonRelationshipsTests {

    @isTest
    private static void createCLCommonRelationships() {
        Account entityId = new Account();
        entityId.Id = TestUtility.getFakeId(Account.getSObjectType());

        Account relatedEntityId = new Account();
        relatedEntityId.Id = TestUtility.getFakeId(Account.getSObjectType());

        clcommon__Reciprocal_Role__c relationshipId = new clcommon__Reciprocal_Role__c();
        relationshipId.Id = TestUtility.getFakeId(clcommon__Reciprocal_Role__c.getSObjectType());

        Test.startTest();
            clcommon__Relationship__c relationshipRecord = CLCommonRelationships.createCLCommonRelationships(entityId.Id, relatedEntityId.Id, relationshipId.Id);
        Test.stopTest();

        system.assert(relationshipRecord != Null);
        system.assertEquals(entityId.Id, relationshipRecord.clcommon__Entity__c );
        system.assertEquals(relatedEntityId.Id, relationshipRecord.clcommon__Related_Entity__c);
        system.assertEquals(relationshipId.Id, relationshipRecord.clcommon__Relationship__c );
    }
}