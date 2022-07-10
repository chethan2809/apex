public class OcrolusFileUploadJob implements Database.AllowsCallouts, Database.Batchable<SObject>, Database.Stateful {

    @TestVisible
    private static OcrolusReportDB ocrolusReportDBInstance = new OcrolusReportDB();
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    @TestVisible
    private static ApplicationDB applicationDBInstance = new ApplicationDB();
    @TestVisible
    private static CategoryAttachmentAssociationDB categoryAttachmentAssociationDBInstance = new CategoryAttachmentAssociationDB();
    @TestVisible
    private static AttachmentDB attachmentDBInstance = new AttachmentDB();

    public Set<Id> categoryAttachmentAssocIds = new Set<Id>();
    public Map<Id, Id> categoryAttachmentAssocIdToApplicationId = new Map<Id, Id>();
    public Map<Id, CAN_Ocrolus_Report__c> existingOcrolusReportByApplicationId = new  Map<Id, CAN_Ocrolus_Report__c>();
    public Map<Id, Boolean> applicationIdByAllFailed = new Map<Id, Boolean>();
    public Map<Id, String> applicationIdByFailedMessage = new Map<Id, String>();

    public OcrolusFileUploadJob(Map<Id, Id> categoryAttachmentAssocIdToApplicationId) {

        this.categoryAttachmentAssocIds = categoryAttachmentAssocIdToApplicationId.keySet();
        this.categoryAttachmentAssocIdToApplicationId = categoryAttachmentAssocIdToApplicationId;

        List<CAN_Ocrolus_Report__c> ocrolusReportList = ocrolusReportDBInstance.getCANOcrolusReportByApplicationIDs(
            new Set<Id> (categoryAttachmentAssocIdToApplicationId.values())
        );
        for(CAN_Ocrolus_Report__c ocrolusReport : ocrolusReportList) {
            this.existingOcrolusReportByApplicationId.put(ocrolusReport.Application__c, ocrolusReport);
        }
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name, Wasabi_Link__c
            FROM clcommon__Category_Attachment_Association__c
            WHERE Id IN :categoryAttachmentAssocIds
        ]);
    }

    public void execute(Database.BatchableContext bc, List<clcommon__Category_Attachment_Association__c> categoryAttachmentList) {
        for(clcommon__Category_Attachment_Association__c categoryAttachmentAssoc : categoryAttachmentList) {
            Id applicationId = categoryAttachmentAssocIdToApplicationId.get(categoryAttachmentAssoc.Id);

            CAN_Ocrolus_Report__c ocrolusReport = existingOcrolusReportByApplicationId.get(applicationId);

            try {
                if(categoryAttachmentAssoc.Wasabi_Link__c == null) {
                    throw new OcrolusFileUploadJobException(categoryAttachmentAssoc.Name + ' file is not available in Wasabi');
                }

                Map<String, Object> uploadedDetails = OcrolusFileUploadJobManager.uploadBankStatementToOcrolus(
                    OcrolusReport.Analytics_PK__c, categoryAttachmentAssoc.Wasabi_Link__c
                );
                ocrolusReport.CAN_File_Upload_Reference__c = String.valueOf(uploadedDetails.get('uploadReferenceValue'));
                CategoryAttachAssns.setCategoryAttachAssnOcrolusFields(
                    categoryAttachmentAssoc, String.valueOf(uploadedDetails.get('uploadedPK')), Ocrolus.OCROLUS_DOC_STATUS_VERIFYING, null
                );
                categoryAttachmentAssociationDBInstance.addUpdate(categoryAttachmentAssoc);
                ocrolusReportDBInstance.addUpdate(ocrolusReport);
                applicationIdByAllFailed.put(applicationId, false);
            } catch (Exception e) {
                if(!applicationIdByAllFailed.containsKey(applicationId)) {
                    applicationIdByAllFailed.put(applicationId, true);
                }

                String message = e.getMessage() + e.getStackTraceString();
                applicationIdByFailedMessage.put(applicationId, message);
                CategoryAttachAssns.setCategoryAttachAssnOcrolusFields(
                    categoryAttachmentAssoc, null, Ocrolus.OCROLUS_DOC_STATUS_FAILED, message
                );
                categoryAttachmentAssociationDBInstance.addUpdate(categoryAttachmentAssoc);
            }
        }
        ocrolusReportDBInstance.executeUpdates();
        categoryAttachmentAssociationDBInstance.executeUpdates();
    }

    public void finish(Database.BatchableContext bc) {
        if(!applicationIdByAllFailed.isEmpty() && applicationIdByAllFailed.values().contains(true)) {
            for(Id applicationId : applicationIdByAllFailed.keySet()) {
                if(applicationIdByAllFailed.get(applicationId)) {
                    Error_Log__c errorLog = ErrorLogs.createErrorLog(
                        'Ocrolus Bank Statement Upload Failed', applicationIdByFailedMessage.get(applicationId), null, null, ErrorLogs.ERROR,
                        applicationId, false
                    );
                    errorLogDBInstance.addInsert(errorLog);

                    CAN_Ocrolus_Report__c ocrolusReport = existingOcrolusReportByApplicationId.get(applicationId);
                    ocrolusReport.Document_Status__c= Ocrolus.OCROLUS_DOC_STATUS_FAILED;
                    ocrolusReportDBInstance.addUpdate(ocrolusReport);

                    genesis__Applications__c application = new genesis__Applications__c(Id = applicationId);
                    application.genesis__Status__c = Applications.STATUS_BANK_STATEMENT_UPLOAD_FAILED;
                    applicationDBInstance.addUpdate(application);
                }
            }
        }

        ocrolusReportDBInstance.executeUpdates();
        applicationDBInstance.executeUpdates();
        errorLogDBInstance.executeInserts();
    }

    private class OcrolusFileUploadJobException extends Exception {}

}