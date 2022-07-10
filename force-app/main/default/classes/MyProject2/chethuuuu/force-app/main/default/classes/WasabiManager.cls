public class WasabiManager {

    @TestVisible
    private static AttachmentDB attachmentDBInstance = new AttachmentDB();
    @TestVisible
    private static ContentVersionDB contentVersionDBInstance = new ContentVersionDB();
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    @TestVisible
    private static CategoryAttachmentAssociationDB categoryAttachmentAssociationDBInstance = new CategoryAttachmentAssociationDB();
    @TestVisible
    private static Wasabi_Setting__mdt wasabiSetting = CustomMetaDataHelper.defaultWasabiSetting;
    @TestVisible
    private static UCCFilingAttachmentDB uccFilingAttachmentDBInstance = new UCCFilingAttachmentDB();

    public static void sendToWasabi(Map<Id, clcommon__Category_Attachment_Association__c> attachmentIdToCategoryAss, CategoryAttachAssns.RequestType requestType) {
        if(requestType == CategoryAttachAssns.RequestType.INSERT_FILE){
            processFilesForAttachmentType(attachmentIdToCategoryAss);
            processFilesForContentVersionType(attachmentIdToCategoryAss);

            DBManager.PartialResult partialInsertSaveResults = categoryAttachmentAssociationDBInstance.executePartialUpdates();

            for (Database.SaveResult insertSaveResult : partialInsertSaveResults.saveResults) {
                if (!insertSaveResult.isSuccess()) {
                    Integer resultIndex = partialInsertSaveResults.saveResults.indexOf(insertSaveResult);
                    clcommon__Category_Attachment_Association__c catAttachmentAss = (clcommon__Category_Attachment_Association__c) partialInsertSaveResults.sObjectList.get(resultIndex);

                    String errorMessage = ErrorLogs.constructErrorMessageFromDatabaseResult(
                        insertSaveResult.getErrors()
                    );

                    if(errorMessage != null && !errorMessage.contains('ENTITY_IS_DELETED')) {
                        Error_Log__c errorLog = ErrorLogs.createErrorLog(
                            'Wasabi callout', 'Failed document upload in wasabi ' + errorMessage, null, null, ErrorLogs.ERROR,
                            catAttachmentAss.Id, false
                        );
                        errorLogDBInstance.addInsert(errorLog);
                    }
                }
            }
            errorLogDBInstance.executeInserts();
        } else if(requestType == CategoryAttachAssns.RequestType.DELETE_FILE) {
            deleteFilesFromWasabi(attachmentIdToCategoryAss);
        }
    }

    private static void processFilesForAttachmentType(Map<Id, clcommon__Category_Attachment_Association__c> attachmentIdToCategoryAss) {
        List<Attachment> attachmentList = attachmentDBInstance.getAllAttachmentsByIds(attachmentIdToCategoryAss.keySet());

        for(Attachment attachmentObj : attachmentList){

            String callOutPath;
            clcommon__Category_Attachment_Association__c categoryAttachmentAss = attachmentIdToCategoryAss.get(attachmentObj.Id);
            Id referenceObjectId;

            try {

                String extension = attachmentObj.Name.substringAfterLast('.');
                String fileName = GeneralHelper.cleanSpecialCharacters(attachmentObj.Name.substringBefore('.'));
                fileName = fileName.replaceAll('\\s','_');
                String subFolder = categoryAttachmentAss.clcommon__Document_Category__r.clcommon__Category_Name__c.replaceAll('\\s','_');
                String parentFolder = '';
                if(categoryAttachmentAss.clcommon__Document_Category__r.genesis__Application__c != null) {
                    referenceObjectId = categoryAttachmentAss.clcommon__Document_Category__r.genesis__Application__c;
                    parentFolder = categoryAttachmentAss.clcommon__Document_Category__r.genesis__Application__r.Name;
                } else if(categoryAttachmentAss.clcommon__Document_Category__r.clcommon__Account__c != null) {
                    referenceObjectId = categoryAttachmentAss.clcommon__Document_Category__r.clcommon__Account__c;
                    parentFolder = GeneralHelper.cleanSpecialCharacters(categoryAttachmentAss.clcommon__Document_Category__r.clcommon__Account__r.Name).replaceAll('\\s', '_');
                    parentFolder += '_' + categoryAttachmentAss.clcommon__Document_Category__r.clcommon__Account__r.Merchant_ID__c;
                } else if(categoryAttachmentAss.clcommon__Document_Category__r.Collection_Case__c != null) {
                    referenceObjectId = categoryAttachmentAss.clcommon__Document_Category__r.Collection_Case__c;
                    parentFolder = categoryAttachmentAss.clcommon__Document_Category__r.Collection_Case__r.Name;
                }

                if(String.isBlank(fileName)) {
                    fileName = categoryAttachmentAss.Id;
                }

                callOutPath = wasabiSetting.Bucket_Name__c + '/' +
                    + parentFolder + '/' + subFolder + '/' + fileName + '_' + categoryAttachmentAss.Id + '.' + extension;

                categoryAttachmentAss.Wasabi_Link__c = wasabiSetting.Base_Path__c + '/' + callOutPath;

                WasabiHTTPCallOut.sendDocument(callOutPath, attachmentObj.Body);
                categoryAttachmentAssociationDBInstance.addUpdate(categoryAttachmentAss);
            } catch (Exception e) {
                Error_Log__c errorLog = ErrorLogs.createErrorLog(
                    'WasabiHTTPCallOut', e.getMessage() + e.getStackTraceString(), callOutPath, null, ErrorLogs.ERROR,
                    referenceObjectId, false
                );
                errorLogDBInstance.addInsert(errorLog);
            }
        }
    }

    private static void processFilesForContentVersionType(Map<Id, clcommon__Category_Attachment_Association__c > attachmentIdToCategoryAss) {
        List<ContentVersion> contentVersionList = contentVersionDBInstance.getContentVersionsByIds(attachmentIdToCategoryAss.keySet());

        for(ContentVersion contentVersionObj : contentVersionList) {

            String callOutPath;
            clcommon__Category_Attachment_Association__c categoryAttachmentAss = attachmentIdToCategoryAss.get(contentVersionObj.Id);
            Id referenceObjectId;

            try {

                String fileName = GeneralHelper.cleanSpecialCharacters(contentVersionObj.Title.substringBefore('.'));
                fileName = fileName.replaceAll('\\s', '_');
                String subFolder = categoryAttachmentAss.clcommon__Document_Category__r.clcommon__Category_Name__c.replaceAll('\\s','_');

                String parentFolder = '';
                if(categoryAttachmentAss.clcommon__Document_Category__r.genesis__Application__c != null) {
                    referenceObjectId = categoryAttachmentAss.clcommon__Document_Category__r.genesis__Application__c;
                    parentFolder = categoryAttachmentAss.clcommon__Document_Category__r.genesis__Application__r.Name;
                } else if(categoryAttachmentAss.clcommon__Document_Category__r.clcommon__Account__c != null) {
                    referenceObjectId = categoryAttachmentAss.clcommon__Document_Category__r.clcommon__Account__c;
                    parentFolder = GeneralHelper.cleanSpecialCharacters(categoryAttachmentAss.clcommon__Document_Category__r.clcommon__Account__r.Name).replaceAll('\\s', '_');
                    parentFolder += '_' + categoryAttachmentAss.clcommon__Document_Category__r.clcommon__Account__r.Merchant_ID__c;
                } else if(categoryAttachmentAss.clcommon__Document_Category__r.Collection_Case__c != null) {
                    referenceObjectId = categoryAttachmentAss.clcommon__Document_Category__r.Collection_Case__c;
                    parentFolder = categoryAttachmentAss.clcommon__Document_Category__r.Collection_Case__r.Name;
                }

                if(String.isBlank(fileName)) {
                    fileName = categoryAttachmentAss.Id;
                }

                callOutPath = wasabiSetting.Bucket_Name__c + '/' +
                    + parentFolder + '/' + subFolder + '/' + fileName + '_' + categoryAttachmentAss.Id + '.' + contentVersionObj.FileExtension;

                categoryAttachmentAss.Wasabi_Link__c = wasabiSetting.Base_Path__c + '/' + callOutPath;

                WasabiHTTPCallOut.sendDocument(callOutPath, contentVersionObj.VersionData);
                categoryAttachmentAssociationDBInstance.addUpdate(categoryAttachmentAss);
            } catch (Exception e) {
                Error_Log__c errorLog = ErrorLogs.createErrorLog(
                    'WasabiHTTPCallOut', e.getMessage() + e.getStackTraceString(), callOutPath, null, ErrorLogs.ERROR,
                    referenceObjectId, false
                );
                errorLogDBInstance.addInsert(errorLog);
            }
        }
    }

    private static void deleteFilesFromWasabi(Map<Id, clcommon__Category_Attachment_Association__c > categoryAssByIds) {
        for(clcommon__Category_Attachment_Association__c categoryAssociation : categoryAssByIds.values()){
            String wasabiLink = categoryAssociation.Wasabi_Link__c;

            try {
                WasabiHTTPCallOut.deleteFileFromWasabi(wasabiLink);
            } catch (Exception e) {
                Error_Log__c errorLog = ErrorLogs.createErrorLog(
                    'WasabiHTTPCallOut for Delete', e.getMessage() + e.getStackTraceString(), wasabiLink, null, ErrorLogs.ERROR,
                    categoryAssociation.Id, false
                );
                errorLogDBInstance.addInsert(errorLog);
            }
        }
    }

    public static void uploadUCCFilesToWasabi(UCC_Filing_Attachment__c uccFilingAttachment, String fileName, Blob fileBody) {
        Id referenceObjectId;
        String callOutPath;
        try {
            referenceObjectId = uccFilingAttachment.Account__c;
            String parentFolder = GeneralHelper.cleanSpecialCharacters(uccFilingAttachment.Account__r.Name).replaceAll('\\s', '_');

            callOutPath = wasabiSetting.Bucket_Name__c + '/' +
                + parentFolder + '/UCC_Reports' + '/' + fileName;

            uccFilingAttachment.Wasabi_Link__c = wasabiSetting.Base_Path__c + '/' + callOutPath;

            WasabiHTTPCallOut.sendDocument(callOutPath, fileBody);
        } catch (Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'WasabiHTTPCallOut UCC Report', e.getMessage() + e.getStackTraceString(), callOutPath, null, ErrorLogs.ERROR,
                referenceObjectId, false
            );
            errorLogDBInstance.addInsert(errorLog).executeInserts();
        }
    }
}