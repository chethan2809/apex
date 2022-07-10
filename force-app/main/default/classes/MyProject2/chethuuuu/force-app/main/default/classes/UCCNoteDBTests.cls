@isTest(isParallel=true)
private class UCCNoteDBTests {

    private static UCCNoteDB uccNoteDBInstance = new UCCNoteDB();

    @isTest
    private static void getUCCNotsByUCCFilingIDs() {
        Id uccNoteId = TestUtility.getFakeId(UCC_Notes__c.getSObjectType());

        System.Test.startTest();
            List<UCC_Notes__c> actualUccNotes = uccNoteDBInstance.getUCCNotsByUCCFilingIDs(new Set<Id>{uccNoteId});
        System.Test.stopTest();

        System.assert(actualUccNotes != null);
    }
}