@isTest
private class CLCommonRelationshipTriggerTests {
    @isTest
    private static void beforeInsertRelationshipTests() {
        Account entity = TestUtility.createBorrowerAccount();
        Contact contact = TestUtility.createContact();

        Test.startTest();
            clcommon__Relationship__c relationshipRecord = new clcommon__Relationship__c();
            relationshipRecord.clcommon__Entity__c = entity.Id;
            relationshipRecord.Legacy_Account_External_Id__c = entity.Id;
            relationshipRecord.Contact__c = contact.Id;
            insert relationshipRecord;
        Test.stopTest();

        System.assert(relationshipRecord.Id != null);
    }
}