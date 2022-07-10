@isTest(isParallel=true)
private class ContentDocumentLinkDBTests {

    private static ContentDocumentLinkDB contentDocumentLinkDBInstance = new ContentDocumentLinkDB();

    @isTest
    private static void getContentDocumentLinkIDs() {
        Id linkedEntityId = TestUtility.getFakeId(Account.getSObjectType());

        Test.startTest();
            List<ContentDocumentLink> contentDocumentLink = contentDocumentLinkDBInstance.getContentDocumentLinkIDs(new Set<Id>{linkedEntityId});
        Test.stopTest();

        System.assert(contentDocumentLink != null);
        System.assert(contentDocumentLink.isEmpty());
    }

    @isTest
    private static void getLinkedEntityIdByContentDocumentLinkIDs() {
        Id ContentDocumentId = TestUtility.getFakeId(Account.getSObjectType());

        Test.startTest();
            List<ContentDocumentLink> contentDocumentLink = contentDocumentLinkDBInstance.getLinkedEntityIdByContentDocumentLinkIDs(new Set<Id>{ContentDocumentId});
        Test.stopTest();

        System.assert(contentDocumentLink != null);
        System.assert(contentDocumentLink.isEmpty());
    }
}