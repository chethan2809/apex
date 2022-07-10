public class SFTPRepaymentJob implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts {

    @TestVisible
    private static Origination_Settings__mdt defaultSFTPSetting = CustomMetaDataHelper.defaultOriginationSetting;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, FolderId, Body, Name, Folder.Name, Type
            FROM Document
            WHERE Folder.Name =: GeneralConstants.FOLDER_ACH_INBOUND
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Document> listOfDocuments) {
        SFTPRepaymentManager.uploadSFTPRepayment(listOfDocuments);
    }

    public void execute(SchedulableContext sc) {
        if (defaultSFTPSetting.SFTP_Document_Upload_Batch_Size__c == null) {
            throw new SFTPRepaymentJobException('SFTP_Document_Upload_Batch_Size__c is null');
        }
        Database.executeBatch(this, Integer.ValueOf(defaultSFTPSetting.SFTP_Document_Upload_Batch_Size__c));
    }

    public static void execute() {
        SFTPRepaymentJob sFTPRepaymentJobJobInstance = new SFTPRepaymentJob();
        sFTPRepaymentJobJobInstance.execute(null);
    }

    public void finish(Database.BatchableContext bc) {
    }

    private class SFTPRepaymentJobException extends Exception {}
}