public class OcrolusManager {
    @TestVisible
    private static OcrolusReportDB ocrolusReportDBInstance = new OcrolusReportDB();
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    @TestVisible
    private static ApplicationDB applicationDBInstance = new ApplicationDB();
    @TestVisible
    private static DocumentCategoryDB documentCategoryDBInstance = new DocumentCategoryDB();
    @TestVisible
    private static AttachmentDB attachmentDBDBInstance = new AttachmentDB();
    @TestVisible
    private static CategoryAttachmentAssociationDB categoryAttachmentAssociationDBInstance = new CategoryAttachmentAssociationDB();

    public static void processOcrolusAnalytics(Map<String, Object> requestOcrolusAnalytics) {

        String pk = String.valueOf(requestOcrolusAnalytics.get('pk'));
        List<CAN_Ocrolus_Report__c> ocrolusReportList = ocrolusReportDBInstance.getCANOcrolusReportByPK(pk);

        if(ocrolusReportList.isEmpty()) {
            throw new OcrolusManagerException('There was no ocrolus report found for PK : ' + pk);
        }

        CAN_Ocrolus_Report__c existingOcrolusReport = ocrolusReportList.get(0);
        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>(
            applicationDBInstance.getApplicationsByIds(new Set<Id> {existingOcrolusReport.Application__c})
        );
        genesis__Applications__c application = applicationMap.get(existingOcrolusReport.Application__c);

        if(application.genesis__Status__c == Applications.STATUS_BANK_STATEMENT_PROCESSING_FAILED){
            return;
        }

        if(application.genesis__Status__c != Applications.STATUS_BANK_STATEMENT_PROCESSING) {
            throw new OcrolusManagerException('Application status is not in Bank Statement Processing');
        }

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c(
            Id = existingOcrolusReport.Id, Analytics_PK__c = existingOcrolusReport.Analytics_PK__c,
            Analytics_Count__c = existingOcrolusReport.Analytics_Count__c
        );
        Ocrolus.setOcrolusReport((Map<String, Object>) requestOcrolusAnalytics, application, ocrolusReport);
        if(ocrolusReport.Analytics_Count__c != null) {
            ocrolusReport.Analytics_Count__c++;
        } else {
            ocrolusReport.Analytics_Count__c = 1;
        }
        ocrolusReport.Application__c = existingOcrolusReport.Application__c;
        ocrolusReport.Document_Status__c = Ocrolus.OCROLUS_DOC_STATUS_COMPLETE;

        application.genesis__Status__c = Applications.STATUS_PRICING_GENERATION;

        if(application.Annual_Volume__c == null || application.Annual_Volume__c <= 0) {
            application.Annual_Volume__c = ocrolusReport.Offer_GAV_Amount__c;
        }

        if(existingOcrolusReport.Offer_GAV_Amount__c == null && ocrolusReport.Offer_GAV_Amount__c != null) {
            application.Annual_Volume__c = ocrolusReport.Offer_GAV_Amount__c;
        } else if(existingOcrolusReport.Offer_GAV_Amount__c != null && ocrolusReport.Offer_GAV_Amount__c != existingOcrolusReport.Offer_GAV_Amount__c){
            application.Annual_Volume__c = CANOcrolusReports.calculateGAV(application, ocrolusReport);
        }

        ocrolusReportDBInstance.addUpdate(ocrolusReport).executeUpdates();
        BusinessRuleManager.runOcrolusDeclineRules(applicationMap, new List<CAN_Ocrolus_Report__c> {ocrolusReport});
        applicationDBInstance.addUpdate(application).executeUpdates();
        getBookDocumentStatusAsync(new Set<Id> {application.Id});
        getOcrolusAnalyticsExcel(new Set<Id> {ocrolusReport.Id});
    }

    @future (callout=true)
    public static void getBookDocumentStatusAsync(Set<Id> applicationIds) {
        getBookDocumentStatus(applicationIds);
    }

    private static CAN_Ocrolus_Report__c createNewBook(
        genesis__Applications__c application, Map<Id, CAN_Ocrolus_Report__c> existingOcrolusReportByApplicationId
    ) {
        if(!existingOcrolusReportByApplicationId.containsKey(application.Id)
            || existingOcrolusReportByApplicationId.get(application.Id).Analytics_PK__c == null
        ) {
            String bookName = GeneralHelper.getOrgInformation.isSandbox?
                GeneralHelper.getOrgInformation.Id + '-' + application.Name : application.Name;

            Map<String, Object> canOcrolusResponseMap = OcrolusCallOut.createBookByName(bookName);

            CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
            if(existingOcrolusReportByApplicationId.containsKey(application.Id)) {
                ocrolusReport = existingOcrolusReportByApplicationId.get(application.Id);
            }

            Ocrolus.createCANOcrolusReportDetail(canOcrolusResponseMap, application, ocrolusReport);
            ocrolusReportDBInstance.addUpsert(ocrolusReport);
            return ocrolusReport;
        } else {
            return existingOcrolusReportByApplicationId.get(application.Id);
        }
    }

    public static void manualRequestOcrolusFileUpload(Set<Id> applicationIds) {
        genesis__Applications__c application = applicationDBInstance.getApplicationsByIds(applicationIds).get(0);
        application.Is_Manual_Score_Run__c = true;
        Ocrolus.isManualRun = true;
        OcrolusManager.requestOcrolusFileUpload(new List<genesis__Applications__c> { application });
    }

    public static void requestOcrolusFileUpload(List<genesis__Applications__c> listOfApplications) {

        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>(listOfApplications);
        Map<String, List<clcommon__Category_Attachment_Association__c>> appIdPKIdToCategoryAttachments = new Map<String, List<clcommon__Category_Attachment_Association__c>>();
        Map<Id, genesis__Applications__c> applicationShellMap = new Map<Id, genesis__Applications__c>(listOfApplications);
        Map<String, CAN_Ocrolus_Report__c> ocrolusReportsByPKId = new Map<String, CAN_Ocrolus_Report__c>();
        Map<Id, Boolean> hasNewAttachmentsByApplicationId = new Map<Id, Boolean>();
        Map<Id, Id> categoryAttachmentAssocIdToApplicationId = new Map<Id, Id>();
        Map<Id, CAN_Ocrolus_Report__c> existingOcrolusReportByApplicationId = CANOcrolusReports.getOcrolusReportByApplicationId(
            ocrolusReportDBInstance.getCANOcrolusReportByApplicationIDs(applicationMap.keySet())
        );
        List<clcommon__Document_Category__c> documentCategoryList = documentCategoryDBInstance.getDocumentCategoriesAndItsAttachmentByApplicationIdsAndName(
            applicationMap.keySet(), GeneralConstants.DOCUMENT_TYPE_BANK_STATEMENTS
        );
        Map<Id, List<clcommon__Category_Attachment_Association__c>> applicationIdToCategoryAttachmentList = DocumentCategories.getCategoryAttachmentListByApplicationId(
            documentCategoryList
        );

        for (genesis__Applications__c application : applicationMap.values()) {
            genesis__Applications__c applicationShell = new genesis__Applications__c(Id = application.Id, Is_Manual_Score_Run__c = application.Is_Manual_Score_Run__c, genesis__Status__c = application.genesis__Status__c);
            applicationShellMap.put(applicationShell.Id, applicationShell);
            CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();

            if(Ocrolus.isManualRun && !applicationIdToCategoryAttachmentList.containsKey(application.Id)) {
                throw new OcrolusManagerException('There was no Bank Statement uploaded to Wasabi for this application');
            }

            try {
                ocrolusReport = createNewBook(application, existingOcrolusReportByApplicationId);
                ocrolusReportsByPKId.put(ocrolusReport.Analytics_PK__c, ocrolusReport);

                if(ocrolusReport.Document_Status__c == Ocrolus.OCROLUS_DOC_STATUS_COMPLETE && !Ocrolus.isManualRun
                    && application.Auto_Renewed__c
                ) {
                    applicationShell.genesis__Status__c = Applications.STATUS_PRICING_GENERATION;
                    continue;
                }

                if(!Ocrolus.isManualRun && !applicationIdToCategoryAttachmentList.containsKey(application.Id)) {
                    continue;
                }

                processUploadDocuments(
                    applicationIdToCategoryAttachmentList.get(application.Id), categoryAttachmentAssocIdToApplicationId, appIdPKIdToCategoryAttachments,
                    applicationShell, ocrolusReport, hasNewAttachmentsByApplicationId
                );

                ocrolusReportDBInstance.addUpsert(ocrolusReport);

            } catch(Exception e) {
                if(ocrolusReport.Analytics_PK__c != null) {
                    ocrolusReportDBInstance.addUpsert(ocrolusReport);
                }
                Error_Log__c errorLog = ErrorLogs.createErrorLog('Ocrolus Bank Statement Upload', e, application.Id, false);
                errorLogDBInstance.addInsert(errorLog);
                applicationShell.genesis__Status__c = Applications.STATUS_BANK_STATEMENT_UPLOAD_FAILED;
                applicationShellMap.put(applicationShell.Id, applicationShell);
            }

            if(!appIdPKIdToCategoryAttachments.isEmpty() && hasNewAttachmentsByApplicationId.values().contains(false)) {
                requestAsyncAnalytics(
                    appIdPKIdToCategoryAttachments.keySet(), applicationShellMap, ocrolusReportsByPKId, hasNewAttachmentsByApplicationId
                );
            }
        }

        ocrolusReportDBInstance.executeUpserts();
        applicationDBInstance.addUpdates(applicationShellMap.values()).executeUpdates();
        errorLogDBInstance.executeInserts();

        if(!categoryAttachmentAssocIdToApplicationId.isEmpty()) {
            Database.executeBatch(new OcrolusFileUploadJob(categoryAttachmentAssocIdToApplicationId), 1);
        }
    }

    private static void processUploadDocuments(
        List<clcommon__Category_Attachment_Association__c> applicationCategoryAttachmentList, Map<Id, Id> categoryAttachmentAssocIdToApplicationId,
        Map<String, List<clcommon__Category_Attachment_Association__c>> appIdPKIdToCategoryAttachments,
        genesis__Applications__c applicationShell, CAN_Ocrolus_Report__c ocrolusReport, Map<Id, Boolean> hasNewAttachmentsByApplicationId
    ) {
        Boolean hasNewAttachments = false;
        for(clcommon__Category_Attachment_Association__c categoryAttachment :applicationCategoryAttachmentList) {
            if(categoryAttachment.Ocrolus_Uploaded_PK__c == null && categoryAttachment.Ocrolus_Document_Status__c != Ocrolus.OCROLUS_DOC_STATUS_FAILED) {
                hasNewAttachments = true;
                categoryAttachmentAssocIdToApplicationId.put(categoryAttachment.Id, applicationShell.Id);

            } else if (categoryAttachment.Ocrolus_Document_Status__c == Ocrolus.OCROLUS_DOC_STATUS_COMPLETE) {
                String appAndPkIdKey = applicationShell.Id + ';' + ocrolusReport.Analytics_PK__c;
                if(!appIdPKIdToCategoryAttachments.containsKey(appAndPkIdKey)) {
                    appIdPKIdToCategoryAttachments.put(
                        appAndPkIdKey, new List<clcommon__Category_Attachment_Association__c> {categoryAttachment}
                    );
                } else {
                    appIdPKIdToCategoryAttachments.get(appAndPkIdKey).add(categoryAttachment);
                }
            }
        }

        hasNewAttachmentsByApplicationId.put(applicationShell.Id, hasNewAttachments);

        if(hasNewAttachments) {
            ocrolusReport.Document_Status__c = Ocrolus.OCROLUS_DOC_STATUS_VERIFYING;
            applicationShell.genesis__Status__c = Applications.STATUS_BANK_STATEMENT_PROCESSING;
        }
    }

    public static String getBookDocumentStatus(Set<Id> applicationIds) {

        List<CAN_Ocrolus_Report__c> canOcrolusReportList = ocrolusReportDBInstance.getCANOcrolusReportByApplicationIDs(applicationIds);

        Map<String, clcommon__Category_Attachment_Association__c> pkIdToCategoryAttachment = new Map<String, clcommon__Category_Attachment_Association__c>();
        List<clcommon__Document_Category__c> documentCategoryList = documentCategoryDBInstance.getDocumentCategoriesAndItsAttachmentByApplicationIdsAndName(
            applicationIds, GeneralConstants.DOCUMENT_TYPE_BANK_STATEMENTS
        );

        for(clcommon__Document_Category__c docCategory : documentCategoryList) {
            if(!docCategory.clcommon__DocCat_Attachment_Associations__r.isEmpty()) {
                for(clcommon__Category_Attachment_Association__c categoryAttachment: docCategory.clcommon__DocCat_Attachment_Associations__r) {
                    if(categoryAttachment.Ocrolus_Uploaded_PK__c != null
                        && categoryAttachment.Ocrolus_Document_Status__c != Ocrolus.OCROLUS_DOC_STATUS_COMPLETE
                    ) {
                        pkIdToCategoryAttachment.put(categoryAttachment.Ocrolus_Uploaded_PK__c, categoryAttachment);
                    }
                }
            }
        }

        if(pkIdToCategoryAttachment.isEmpty() || canOcrolusReportList.isEmpty()) {
            return 'No documents uploaded for the application';
        }

        try {
            return processBookDocumentStatus(canOcrolusReportList, pkIdToCategoryAttachment);
        } catch (Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'Ocrolus Get Uploaded Document Status', e.getMessage(), String.valueOf(applicationIds), null, ErrorLogs.ERROR,
                null, false
            );
            errorLogDBInstance.addInsert(errorLog);
            return e.getMessage();
        }
    }

    private static String processBookDocumentStatus(
        List<CAN_Ocrolus_Report__c> canOcrolusReportList, Map<String, clcommon__Category_Attachment_Association__c> pkIdToCategoryAttachment
    ) {
        String finalStatus = 'No Status Found';
        for(CAN_Ocrolus_Report__c ocrolusReport :canOcrolusReportList) {

            Map<String, Object> uploadResponseMap = OcrolusCallOut.getBookStatus(ocrolusReport.Analytics_PK__c);

            if(uploadResponseMap.get('docs') == null || ((List<Object>) uploadResponseMap.get('docs')).isEmpty()) {
                return 'No matching document found for the application';
            }

            List<Object> uploadDocsList = (List<Object>) uploadResponseMap.get('docs');
            if(!uploadDocsList.isEmpty()) {
                finalStatus = 'Verification Completed';

                for(Object uploadDocObject : uploadDocsList) {
                    Map<String, Object> uploadDocMap = ( Map<String, Object>) uploadDocObject;

                    String documentStatus = String.valueOf(uploadDocMap.get('status'));
                    String uploadedPK = String.valueOf(uploadDocMap.get('pk'));
                    if(documentStatus != Ocrolus.OCROLUS_DOC_STATUS_COMPLETE) {
                        finalStatus = 'Verification Pending';
                    }
                    if(uploadedPK != null && pkIdToCategoryAttachment.containsKey(uploadedPK)) {
                        clcommon__Category_Attachment_Association__c categoryAttachment = pkIdToCategoryAttachment.get(uploadedPK);
                        categoryAttachment.Ocrolus_Document_Status__c = documentStatus;
                        categoryAttachmentAssociationDBInstance.addUpdate(categoryAttachment);
                    }
                }
            }
            categoryAttachmentAssociationDBInstance.executeUpdates();
        }
        return finalStatus;
    }

    public static void requestAsyncAnalytics(
        Set<String> appAndPKIds, Map<Id, genesis__Applications__c> applicationShellMap, Map<String, CAN_Ocrolus_Report__c> ocrolusReportsByPKId,
        Map<Id, Boolean> hasNewAttachmentsByApplicationId
    ) {
        for(String appAndPKId : appAndPKIds) {
            List<String> appAndPKIdsList = appAndPKId.split(';');
            Id applicationId = appAndPKIdsList.get(0);
            genesis__Applications__c applicationShell = applicationShellMap.get(applicationId);

            if(hasNewAttachmentsByApplicationId.get(applicationId) || applicationShell.genesis__Status__c == Applications.STATUS_BANK_STATEMENT_PROCESSING_FAILED) {
                continue;
            }

            String pkId = appAndPKIdsList.get(1);

            try {
                OcrolusCallOut.requestAsyncAnalytics(pkId);
                applicationShell.genesis__Status__c = Applications.STATUS_BANK_STATEMENT_PROCESSING;
                applicationShellMap.put(applicationShell.Id, applicationShell);

                CAN_Ocrolus_Report__c ocrolusReport = ocrolusReportsByPKId.get(pkId);
                ocrolusReport.Document_Status__c = Ocrolus.OCROLUS_DOC_STATUS_ANALYTICS_SENT;
                ocrolusReportDBInstance.addUpsert(ocrolusReport);
            } catch (Exception e) {
                applicationShell.genesis__Status__c = Applications.STATUS_BANK_STATEMENT_UPLOAD_FAILED;
                applicationShellMap.put(applicationShell.Id, applicationShell);
                Error_Log__c errorLog = ErrorLogs.createErrorLog('Ocrolus Request Async Analytics Failed', e, applicationId, false);
                errorLogDBInstance.addInsert(errorLog);
            }
        }
    }



    private static void createOcrolusAnalyticsReportDocument(Map<Id, Blob> applicationIdToOcrolusAnalyticsReport) {
        Map<Id, Attachment> applicationIdToAttachment = new Map<Id, Attachment>();
        String documentType = GeneralConstants.DOCUMENT_TYPE_OCROLUS_ANALYTICS_REPORT;
        List<Attachment> attachmentList = new List<Attachment>();

        for(Id applicationId : applicationIdToOcrolusAnalyticsReport.keySet()) {
            Attachment reportAttachment = Attachments.createAttachment(
                documentType + '.xlsx', applicationIdToOcrolusAnalyticsReport.get(applicationId), applicationId
            );
            attachmentList.add(reportAttachment);
        }

        attachmentDBDBInstance.addInserts(attachmentList).executeInserts();

        for(Attachment objAttachment: attachmentList) {
            applicationIdToAttachment.put(objAttachment.parentId, objAttachment);
        }

        if(!applicationIdToAttachment.isEmpty()) {
            CategoryAttachAssnManager.createDocumentCategoryAssociationForApplicationsByAttachmentId(applicationIdToAttachment, documentType);
        }
    }

    public static void processDeleteFile(Set<String> docUploadedPKIds) {
        for(String docUploadPKId : docUploadedPKIds){
            try{
                OcrolusCallOut.deleteFile(docUploadPKId);
            } catch(Exception e) {
                Error_Log__c errorLog = ErrorLogs.createErrorLog(
                    'Ocrolus File Deletion Failed', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                    null, false
                );
                errorLogDBInstance.addInsert(errorLog);
            }
        }
        errorLogDBInstance.executeInserts();
    }

    @future (callout=true)
    public static void processDeleteFileAsync(Set<String> docUploadedPKIds) {
        processDeleteFile(docUploadedPKIds);
    }

    public static void getOcrolusAnalyticsExcelSync(Id verificationCompletedOcrolusReportsId) {
        set<Id> ocrolusReportIds = new Set<Id>();
        ocrolusReportIds.add(verificationCompletedOcrolusReportsId);
        Map<Id, Blob> applicationIdToOcrolusAnalyticsReport = new Map<Id, Blob>();
        CAN_Ocrolus_Report__c ocrolusReport = ocrolusReportDBInstance.getCANOcrolusReportByIds(ocrolusReportIds).get(0);
        Blob analyticsReport = OcrolusCallOut.getOcrolusAnalyticsExcel(ocrolusReport.Analytics_PK__c);
        applicationIdToOcrolusAnalyticsReport.put(ocrolusReport.Application__c, analyticsReport);
        createOcrolusAnalyticsReportDocument(applicationIdToOcrolusAnalyticsReport);
    }

    @future (callout=true)
    public static void getOcrolusAnalyticsExcel(Set<Id> verificationCompletedOcrolusReportsIds) {
        CAN_Ocrolus_Report__c ocrolusReport = ocrolusReportDBInstance.getCANOcrolusReportByIds(verificationCompletedOcrolusReportsIds).get(0);
        try {
            getOcrolusAnalyticsExcelSync(ocrolusReport.id);
        } catch (Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'Ocrolus Analytics Save Excel Report Failed', e.getMessage(),null,
                null, ErrorLogs.ERROR, null, false
            );
            errorLogDBInstance.addInsert(errorLog);
        }
    }

    private class OcrolusManagerException extends Exception {}
}