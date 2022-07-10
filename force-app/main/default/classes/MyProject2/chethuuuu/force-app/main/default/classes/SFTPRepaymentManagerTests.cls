@isTest
private class SFTPRepaymentManagerTests {

    private class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    private static void uploadSFTPRepayment() {
        Test.setMock(HttpCalloutMock.class, new RestMock());

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Date todaysDate = GeneralHelper.currentSystemDate;

        Folder folderRecord = new Folder();
        folderRecord.Name = 'ACH Inbound Processed';

        List<Document> documentList = new List<Document>();
        Document documentRecord = new Document();
        documentRecord.Name = todaysDate+ '.ach';
        documentRecord.DeveloperName = 'CAN_CAPITAL_IMAGE';
        documentRecord.Body = Blob.valueOf('Dummy File Body');
        documentRecord.FolderId = TestUtility.getFakeId(Folder.getSObjectType());
        documentRecord.Type = 'txt';
        documentRecord.ContentType = 'test';
        documentRecord.Id = TestUtility.getFakeId(Document.getSObjectType());
        documentList.add(documentRecord);

        DBManagerTestsStub documentDBStubInstance = new DBManagerTestsStub();
        documentDBStubInstance.genericReturnObject = new List<Document>{documentRecord};
        SFTPRepaymentManager.documentDBInstance = (DocumentDB) Test.createStub(DocumentDB.class, documentDBStubInstance);

        Test.startTest();
            SFTPRepaymentManager.uploadSFTPRepayment(documentList);
        Test.stopTest();

        System.assertEquals(1, documentDBStubInstance.forUpdateSObjects.size());
        System.assertEquals('txt', ((Document)documentDBStubInstance.forUpdateSObjects.get(0)).Type);
    }

    @isTest
    private static void uploadSFTPRepaymentException() {
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Date todaysDate = GeneralHelper.currentSystemDate;

        Folder folderDetail = new Folder();
        folderDetail.Name = 'ACH Inbound Processed';
        folderDetail.Id = TestUtility.getFakeId(Folder.getSObjectType());

        List<Document> documentList = new List<Document>();
        Document documentRecord = new Document();
        documentRecord.Name = todaysDate+ '.ach';
        documentRecord.DeveloperName = 'CAN_CAPITAL_IMAGE';
        documentRecord.Body = Blob.valueOf('Dummy File Body');
        documentRecord.FolderId = TestUtility.getFakeId(Folder.getSObjectType());
        documentRecord.Type = 'txt';
        documentRecord.ContentType = 'test';
        documentRecord.Id = TestUtility.getFakeId(Document.getSObjectType());
        documentList.add(documentRecord);

        DBManagerTestsStub documentDBStubInstance = new DBManagerTestsStub();
        documentDBStubInstance.genericReturnObject = new List<Document>{documentRecord};
        SFTPRepaymentManager.documentDBInstance = (DocumentDB) Test.createStub(DocumentDB.class, documentDBStubInstance);

        Test.startTest();
            SFTPRepaymentManager.uploadSFTPRepayment(documentList);
        Test.stopTest();

        System.assertEquals(0, documentDBStubInstance.forUpdateSObjects.size());
    }
}