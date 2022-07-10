@isTest
private class SFTPDisbursalJobTests {

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
        Test.startTest();
        try{
            SFTPDisbursalJob.execute();
        }
        catch(Exception e) {
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

    @isTest
    private static void disbursalJobSFTPCheckBatchSizeException() {

        Origination_Settings__mdt originationSettings = new Origination_Settings__mdt();
        originationSettings.SFTP_Document_Upload_Batch_Size__c = null;
        CustomMetaDataHelper.defaultOriginationSetting = originationSettings;
        Exception ex;

        Test.startTest();
            try {
                SFTPDisbursalJob.execute();
            }
            catch(Exception e){
                ex = e;
            }
        Test.stopTest();

        TestUtility.assertException(ex);
        System.assertEquals('SFTP_Document_Upload_Batch_Size__c is null', ex.getMessage());
    }
}