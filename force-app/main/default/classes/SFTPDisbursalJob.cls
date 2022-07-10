public class SFTPDisbursalJob implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts {

    @TestVisible
    private static Origination_Settings__mdt defaultSFTPSetting = CustomMetaDataHelper.defaultOriginationSetting;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, FolderId, Body, Name, Folder.Name, Type
            FROM Document
            WHERE Folder.Name =: GeneralConstants.FOLDER_ACH_OUTBOUND
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Document> listOfDocuments) {
        SFTPDisbursalManager.uploadSFTPDisbursal(listOfDocuments);
    }

    public void execute(SchedulableContext sc) {
        if (defaultSFTPSetting.SFTP_Document_Upload_Batch_Size__c == null) {
            throw new SFTPDisbursalJobException('SFTP_Document_Upload_Batch_Size__c is null');
        }
        Database.executeBatch(this, Integer.ValueOf(defaultSFTPSetting.SFTP_Document_Upload_Batch_Size__c));
    }

    public static void execute() {
        SFTPDisbursalJob sFTPDisbursalJobJobInstance = new SFTPDisbursalJob();
        sFTPDisbursalJobJobInstance.execute(null);
    }

    public void finish(Database.BatchableContext bc) {
    }

    private class SFTPDisbursalJobException extends Exception {}
}