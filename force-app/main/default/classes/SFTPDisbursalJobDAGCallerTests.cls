@isTest
private class SFTPDisbursalJobDAGCallerTests {

    @isTest
    private static void disbursalJobSFTP(){

       Folder folder = [
           SELECT Id, Name
           FROM Folder
           WHERE Name = 'ACH Outbound' ];

        Document document = new Document();
        document.FolderId = folder.Id;
        document.body = blob.valueOf('body');
        document.Name = 'dummy';
        document.Type = 'txt';
        insert document;

        Document documentRecord = [
            SELECT Id, FolderId, Body, Name, Folder.Name, Type
            FROM Document
        ];

        documentRecord.Type = 'pdf';
        update documentRecord;

        Exception ex;
        SFTPDisbursalJobDAGCaller disbursalDynamicJobInstanceCon = new SFTPDisbursalJobDAGCaller('DUMMY String');
        SFTPDisbursalJobDAGCaller disbursalDynamicJobInstance = new SFTPDisbursalJobDAGCaller();
        disbursalDynamicJobInstance.doInitialize();
        disbursalDynamicJobInstance.getRuntimeQuery();
        disbursalDynamicJobInstance.getRuntimeQueryForPipelinedExecution(new Set<Id>());
        disbursalDynamicJobInstance.doFinish(null);

        Test.startTest();
            try {
                disbursalDynamicJobInstance.doExecute(null);
                Database.executeBatch(disbursalDynamicJobInstance);
            } catch(Exception e) {
                ex = e;
            }
        Test.stopTest();

        list<Document> documentList = [
            SELECT Id, FolderId, Body, Name, Folder.Name, Type
            FROM Document
            WHERE Id = :documentRecord.Id
        ];

        System.assertEquals(1, documentList.size());
        System.assertEquals(documentRecord.Type, documentList.get(0).Type);
    }
}