@isTest
private class FundingStatementJobDAGCallerTests {

    @isTest
    private static void fundingStatementJobTest(){

       Folder folder = [
           SELECT Id, Name
           FROM Folder
           WHERE Name = 'ACH Outbound'
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
        FundingStatementJobDAGCaller fundingDynamicJobInstanceCon = new FundingStatementJobDAGCaller('DUMMY String');
        FundingStatementJobDAGCaller fundingDynamicJobInstance = new FundingStatementJobDAGCaller();
        fundingDynamicJobInstance.doInitialize();
        fundingDynamicJobInstance.getRuntimeQuery();
        fundingDynamicJobInstance.getRuntimeQueryForPipelinedExecution(new Set<Id>());
        fundingDynamicJobInstance.doFinish(null);
        GeneralHelper.currentSystemDate = Date.newInstance(2010, 01, 01);

        Test.startTest();
            try {
                fundingDynamicJobInstance.doExecute(null);
                Database.executeBatch(fundingDynamicJobInstance);
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