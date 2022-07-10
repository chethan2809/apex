@isTest(isParallel=true)
private class UCCNotesTests {

    @isTest
    private static void createUCCNote() {
        Id parentId = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());
        String description = 'Test Data';
        GeneralHelper.currentSystemDate = Date.newInstance(2021, 14, 01);
        Date createdDate = GeneralHelper.currentSystemDate;

        System.Test.startTest();
            UCC_Notes__c actualUccNotes =
                UCCNotes.createUCCNote(
                    parentId, description, createdDate
                );
        System.Test.stopTest();

        System.assert(actualUccNotes != null);
        System.assertEquals(parentId, actualUccNotes.UCC_Filing_Detail__c);
        System.assertEquals(description, actualUccNotes.Description__c);
        System.assertEquals(createdDate, actualUccNotes.UCC_Note_Created_Date__c);
    }
}