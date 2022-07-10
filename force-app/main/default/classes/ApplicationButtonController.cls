global class ApplicationButtonController {

    @TestVisible
    private static ApplicationDB applicationDBInstance = new ApplicationDB();
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    @TestVisible
    private static CategoryAttachmentAssociationDB categoryAttachmentAssociationDBInstance = new CategoryAttachmentAssociationDB();
    @TestVisible
    private static AttachmentDB attachmentDBInstance = new AttachmentDB();
    @TestVisible
    private static DocumentCategoryDB documentCategoryDBInstance = new DocumentCategoryDB();
    @TestVisible
    private static CANPricingDetailDB canPricingDetailDBInstance = new CANPricingDetailDB();
    @TestVisible
    private static ContactDB contactDBInstance = new ContactDB();
    @TestVisible
    private static AccountDB accountDBInstance = new AccountDB();
    @TestVisible
    private static PartyDB partyDBInstance = new PartyDB();
    @TestVisible
    private static CLCommonRelationshipDB clCommonRelationshipDBInstance = new CLCommonRelationshipDB();
    @TestVisible
    private static CLCommonReciprocalRoleDB clCommonReciprocalRoleDBInstance = new CLCommonReciprocalRoleDB();

    webService static String convertApplicationToContract(Id appId) {
        String result = ApplicationManager.runApplicationConversionRule(appId);

        if(result != 'SUCCESS') {
            return result;
        }

        genesis__Applications__c application = new genesis__Applications__c(Id = appId);
        try {
            result = Applications.convertApplication(application);
        } catch (Exception e) {
            application.genesis__Status__c = Applications.STATUS_CONVERSION_FAILED;
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'Application To Contract Conversion', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                application.Id, false
            );
            result = e.getMessage();
            errorLogDBInstance.addInsert(errorLog);
            errorLogDBInstance.executeInserts();
        }

        applicationDBInstance.addUpdate(application);
        applicationDBInstance.executeUpdates();
        return result;
    }

    webService static String uploadFilesToFolder(Id documentCategoryId, Id applicationId) {
        for(Attachment attachmentObj : attachmentDBInstance.getAllAttachmentsByParentIdAndDescription(documentCategoryId, applicationId)) {
            clcommon__Category_Attachment_Association__c documentCategoryAsst = CategoryAttachAssns.createCategoryAttachAssn(
                attachmentObj.Name, attachmentObj.Id, documentCategoryId
            );
            attachmentObj.Description = null;
            attachmentDBInstance.addUpdate(attachmentObj);
            categoryAttachmentAssociationDBInstance.addInsert(documentCategoryAsst);
        }

        try {
            attachmentDBInstance.executeUpdates();
            categoryAttachmentAssociationDBInstance.executeInserts();
            return 'Success';
        } catch(Exception e) {
            throw e;
        }
    }

    webService static void moveFilesToFolder(String fileName, Id attachmentId, Id documentCategoryId, Id documentCategoryAsstId) {
        List<clcommon__Category_Attachment_Association__c> categoryAttachmentList = categoryAttachmentAssociationDBInstance.getCategoryAttachmentAssociationsByIds(
            new Set<Id> {documentCategoryAsstId}
        );
        if(!categoryAttachmentList.isEmpty()) {
            CategoryAttachAssns.validateBeforeDeletion(categoryAttachmentList.get(0));
            moveFilesToFolderAsync(fileName, attachmentId, documentCategoryId, documentCategoryAsstId);
        }
    }

    @future(callout=true)
    private static void moveFilesToFolderAsync(String fileName, Id attachmentId, Id documentCategoryId, Id documentCategoryAsstId) {

        Id parentFolderId;
        try {
            clcommon__Category_Attachment_Association__c oldCategoryAttachment = categoryAttachmentAssociationDBInstance.getCategoryAttachmentAssociationsByIds(
            new Set<Id> {documentCategoryAsstId}
            ).get(0);
            clcommon__Document_Category__c documentCategory = documentCategoryDBInstance.getDocumentCategoriesByIds(
                new Set<Id> {documentCategoryId}
            ).get(0);

            parentFolderId = documentCategory.genesis__Application__c != null? documentCategory.genesis__Application__c : documentCategory.clcommon__Account__c;

            String oldPath = oldCategoryAttachment.Wasabi_Link__c;

            String oldFolder = oldPath.substringBetween(oldCategoryAttachment.Application__c + '/','/');
            String newPath = oldPath.replace(oldFolder, documentCategory.clcommon__Category_Name__c.replaceAll('\\s','_'));

            clcommon__Category_Attachment_Association__c documentCategoryAsst = CategoryAttachAssns.createCategoryAttachAssn(
                fileName, attachmentId, documentCategoryId
            );
            documentCategoryAsst.Wasabi_Link__c = newPath;
            categoryAttachmentAssociationDBInstance.addInsert(documentCategoryAsst);
            categoryAttachmentAssociationDBInstance.addDelete(new clcommon__Category_Attachment_Association__c(Id = documentCategoryAsstId));

            Blob body = WasabiHTTPCallOut.getFile(oldPath);
            WasabiHTTPCallOut.sendDocument(newPath.substringAfter('com/'), body);
            categoryAttachmentAssociationDBInstance.executeInserts();
            categoryAttachmentAssociationDBInstance.executeDeletes();
        } catch(Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'Application File Move Failed', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                parentFolderId, false
            );

            errorLogDBInstance.addInsert(errorLog).executeInserts();
        }
    }

    webService static void sendToWasabi(Id categoryAttachmentAssId) {
        sendToWasabiAsync(categoryAttachmentAssId);
    }

    @future(callout=true)
    private static void sendToWasabiAsync(Id categoryAttachmentAssId) {
        Id parentFolderId;
        Map<Id, clcommon__Category_Attachment_Association__c> attachmentIdToCategoryAss = new Map<Id, clcommon__Category_Attachment_Association__c>();
        for(clcommon__Category_Attachment_Association__c categoryAttachmentAss
            : categoryAttachmentAssociationDBInstance.getCategoryAttachmentAssociationsByIds(new Set<Id> {categoryAttachmentAssId})
        ) {
            attachmentIdToCategoryAss.put(categoryAttachmentAss.clcommon__Attachment_Id__c, categoryAttachmentAss);
            parentFolderId = categoryAttachmentAss.clcommon__Document_Category__r.genesis__Application__c != null?
                categoryAttachmentAss.clcommon__Document_Category__r.genesis__Application__c : categoryAttachmentAss.clcommon__Document_Category__r.clcommon__Account__c;
        }

        try {
            if(attachmentIdToCategoryAss.containsKey(null)) {
                throw new ApplicationButtonControllerException('Attachment Id is null');
            }
            WasabiManager.sendToWasabi(attachmentIdToCategoryAss, CategoryAttachAssns.RequestType.INSERT_FILE);
        } catch(Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'Send To Wasabi Failed', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                parentFolderId, false
            );

            errorLogDBInstance.addInsert(errorLog).executeInserts();
        }
    }

    webService static String requestConsumerCreditCheck(Id applicationId) {
        genesis__Applications__c application = new genesis__Applications__c(Id = applicationId);
        applicationDBInstance.addUpdate(new genesis__Applications__c(Id = applicationId, Is_Manual_Score_Run__c = true));
        ExperianManager.requestConsumerCreditCheck(new List<genesis__Applications__c> { application });
        applicationDBInstance.executeUpdates();
        return 'Done! Please check the status';
    }

    webService static String runBusinessCreditCheck(Id applicationId) {
        genesis__Applications__c application = applicationDBInstance.getApplicationsByIds(new Set<Id> {applicationId}).get(0);
        application.Is_Manual_Score_Run__c = true;
        ExperianManager.requestBusinessCreditCheck(new List<genesis__Applications__c> { application });
        return 'Done! Please check the status';
    }

    webService static String runLexisNexisCheck(Id applicationId) {
        genesis__Applications__c application = applicationDBInstance.getApplicationsByIds(new Set<Id> {applicationId}).get(0);
        application.Is_Manual_Score_Run__c = true;
        LexisNexisManager.requestLexisNexisBIIDCheck(new List<genesis__Applications__c> { application });
        return 'Done! Please check the status';
    }

    webService static String runCANScoring(Id applicationId) {
        genesis__Applications__c application = applicationDBInstance.getApplicationsByIds(new Set<Id> {applicationId}).get(0);
        application.Is_Manual_Score_Run__c = true;
        CANScoringManager.requestCANScoring(new List<genesis__Applications__c> { application });
        return 'Done! Please check the status';
    }

    webService static String runOcrolusBankStatementProcess(Id applicationId) {
        OcrolusManager.manualRequestOcrolusFileUpload(new Set<Id> {applicationId});
        return 'Done! Please check the status';
    }

    webService static String runOcrolusDocumentGetStatus(Id applicationId) {
        return OcrolusManager.getBookDocumentStatus(new Set<Id> {applicationId});
    }

    webService static String acceptPricingOffer(Id pricingId) {

        CAN_Pricing_Detail__c pricingDetail = canPricingDetailDBInstance.getCANPricingListByIds(new Set<Id> {pricingId}).get(0);
        CAN_Pricing_Detail__c finalPricing = CCAcceptOfferFromPortalAPI.createAcceptedPricingRecordFromBrokerPortal(
            pricingDetail, pricingDetail.Application__c
        );
        canPricingDetailDBInstance.addInsert(finalPricing);

        try {
            canPricingDetailDBInstance.executeInserts();
            return 'Success';
        } catch(Exception e) {
            throw e;
        }
    }

    webService static String createNewParty(Id contactId, Id applicationId, Id borrowerAccountId, String beneficialOwnerType) {
        try {
            Contact contactRecord = contactDBInstance.getContactsByIds(new Set<Id> {contactId}).get(0);

            Account guarantorAccount = new Account();
            guarantorAccount.Name = contactRecord.FirstName  + ' ' + contactRecord.LastName;
            guarantorAccount.clcommon__Legal_Entity_type__c = OriginationHelper.legalNameToId.get(GeneralConstants.LEGAL_TYPE_INDIVIDUAL);
            guarantorAccount.Type = contactRecord.loan__Contact_Type__c;
            if( guarantorAccount.Type != null) {
                guarantorAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get( guarantorAccount.Type.toUpperCase()).getRecordTypeId();
            }
            accountDBInstance.addInsert(guarantorAccount).executeInserts();

            contactRecord.AccountId = guarantorAccount.Id;
            if(contactRecord.loan__Contact_Type__c != null) {
                contactRecord.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(contactRecord.loan__Contact_Type__c.toUpperCase()).getRecordTypeId();
            }
            contactRecord.ints__Social_Security_Number__c = contactRecord.genesis__SSN__c;
            contactDBInstance.addUpdate(contactRecord).executeUpdates();

            clcommon__Party__c party = Parties.createParty(
                applicationId, guarantorAccount.Id, contactId,
                OriginationHelper.partyTypeToId.get(contactRecord.loan__Contact_Type__c.toUpperCase())
            );
            party.Beneficial_Owner_Type__c = (beneficialOwnerType == 'undefined')? null: beneficialOwnerType;
            partyDBInstance.addInsert(party).executeInserts();

            List<clcommon__Reciprocal_Role__c> relationshipRoleList = clCommonReciprocalRoleDBInstance.getCLCommonRelationship(
                new Set<String> {contactRecord.loan__Contact_Type__c.toUpperCase()}
            );
            Id relationshipRoleId = relationshipRoleList.isEmpty() ? null : relationshipRoleList[0].Id;
            List<clcommon__Relationship__c> relationshipGuarantorList = clCommonRelationshipDBInstance.getCLCommonRelationships(
                new Set<Id> {borrowerAccountId}, new Set<Id> {guarantorAccount.Id}, new Set<Id> {relationshipRoleId});
            if(relationshipGuarantorList.isEmpty()) {
                clcommon__Relationship__c relationship = CLCommonRelationships.createCLCommonRelationships(
                    borrowerAccountId, guarantorAccount.Id, relationshipRoleId
                );
                clCommonRelationshipDBInstance.addUpsert(relationship).executeUpserts();
            }

            return 'Success';
        } catch(Exception e) {
            throw e;
        }
    }

    webService static String updateApplicationPaymentDate(Id applicationId) {
        return ApplicationDailyUpdateManager.updateApplicationAndPricingByApplicationId(applicationId);
    }

    webService static String runDataMerchCheck(Id applicationId) {
        genesis__Applications__c application = applicationDBInstance.getApplicationsByIds(new Set<Id> {applicationId}).get(0);
        application.Is_Manual_Score_Run__c = true;
        DataMerchManager.requestDataMerchMerchants(new List<genesis__Applications__c> { application });
        return 'Done! Please check the status';
    }

    private class ApplicationButtonControllerException extends Exception {}
}