@isTest
private class SFTPRepaymentJobDAGCallerTests {

    @isTest
    private static void repaymentDynamicJob(){
        Folder folder = [
            SELECT Id, Name
            FROM Folder
            WHERE Name = 'ACH Inbound'
        ];

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
        SFTPRepaymentJobDAGCaller repaymentDynamicJobInstanceCon = new SFTPRepaymentJobDAGCaller('DUMMY String');
        SFTPRepaymentJobDAGCaller repaymentDynamicJobInstance = new SFTPRepaymentJobDAGCaller();
        repaymentDynamicJobInstance.doInitialize();
        repaymentDynamicJobInstance.getRuntimeQuery();
        repaymentDynamicJobInstance.getRuntimeQueryForPipelinedExecution(new Set<Id>());
        repaymentDynamicJobInstance.doFinish(null);

        Test.startTest();
            try {
                repaymentDynamicJobInstance.doExecute(null);
                Database.executeBatch(repaymentDynamicJobInstance);
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