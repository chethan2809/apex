@isTest(isParallel=true)
private class CompumailReturnsTests {
    @isTest
    private static void getDocumentName() {
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);

        Test.startTest();
            String documentName = CompumailReturns.getDocumentName();
        Test.stopTest();

        System.assert(documentName != Null);
    }

    @isTest
    private static void buildDocumentBody() {
        List<String> csvRowList = new List<String> {'34, 53, 54,'};
        Id parentId = TestUtility.getFakeId(Case.getSObjectType());

        Test.startTest();
            Attachment actualAttachment = CompumailReturns.buildDocumentBody('Dummy Name', csvRowList, parentId);
        Test.stopTest();

        System.assert(actualAttachment != Null);
        System.assertEquals('Dummy Name', actualAttachment.Name);
        System.assertEquals(parentId, actualAttachment.parentId);
    }
}