public class UCCFilingManager {

    @TestVisible
    private static CLContractDB contractDBInstance = new CLContractDB();
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    @TestVisible
    private static UCCFilingDB uccFilingDBInstance = new UCCFilingDB();
    @TestVisible
    private static UCCValidationLogDB uccValidationLogDBInstance = new UCCValidationLogDB();
    @TestVisible
    private static AccountDB accountDBInstance = new AccountDB();
    @TestVisible
    private static UCCNoteDB uccNoteDBInstance = new UCCNoteDB();
    @TestVisible
    private static UCCFilingAttachmentDB uccFilingAttachmentDBInstance = new UCCFilingAttachmentDB();

    @AuraEnabled
    public static void getContractIdForUCC(Id accountId){
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contractIds = new Set<Id>();
        Set<String> contractNames = new Set<String>();
        accountIds.add(accountId);
        List<Account> accountRecordList = accountDBInstance.getAccountByIds(accountIds);

        for(Account accountRecord : accountRecordList){
            if(accountRecord.UCC_Status__c != GeneralConstants.UCC_STATUS_ACTIVE && !accountRecord.UCC_Opt_Out__c
            && accountRecord.Current_Active_Contract_Number__c != null && (accountRecord.CLS_Active_Contract__c || accountRecord.Legacy_Active_Contract__c))
            {
                contractNames.add(accountRecord.Current_Active_Contract_Number__c);
            }
        }

        for(loan__Loan_Account__c contractRecord : (contractDBInstance.getLoanAccountsByNames(contractNames))){
            if(contractRecord.loan__Disbursed_Amount__c >= CustomSettingsHelper.generalSettings.UCC_Filing_Eligible_Amount__c){
                contractIds.add(contractRecord.Id);
            }
        }
        createUCCFilingAsync(contractIds);
    }

    @future (callout=true)
    public static void createUCCFilingAsync(Set<Id> contractIds) {
        createUCCFiling(contractIds);
    }

    public static void createUCCFiling(Set<Id> contractIds) {
        UCC_Setting__mdt uccSettings = CustomMetaDataHelper.defaultuccSetting;
        Map<String, JurisdictionID_To_Name_Mapping__mdt> jurisdictionIDToNameMapping = CustomMetaDataHelper.jurisdictionIDToNameMapping;

        List<loan__Loan_Account__c> loanAccountList = contractDBInstance.getLoanAccountsByIds(contractIds);
        Map<Id, Id> contractIdToAccountIdMap = new Map<Id, Id>();
        Set<Id> accountIds = new Set<Id>();
        for(loan__Loan_Account__c loanAccount : loanAccountList){
            contractIdToAccountIdMap.put(loanAccount.Id, loanAccount.loan__Account__c);
            accountIds.add(loanAccount.loan__Account__c);
        }
        Map<Id, Account> accountMap = new Map<Id, Account>(accountDBInstance.getAccountByIds(accountIds));
        List<UCC_Filing_Detail__c> uccFilingList = new List<UCC_Filing_Detail__c>();
        String placeID;
        String countyParish;
        String jurisdictionID;
        String jurisdictionName;

        for(loan__Loan_Account__c loanAccount : loanAccountList){
            UCC_Filing_Detail__c uccFiling;
            try {
                if(accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).BillingState == UCCFilings.STATE_GEORGIA || accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).BillingState == UCCFilings.STATE_LOUISIANA){
                    placeID = UCCFilingCallout.getPlaceID(uccFiling, loanAccount, contractIdToAccountIdMap, accountMap);
                    countyParish = UCCFilingCallout.getCountyParishForUCC(placeID);
                    for(String countyParishName : jurisdictionIDToNameMapping.keySet()){
                        if(countyParish.contains(countyParishName.replaceAll('_',' '))){
                            jurisdictionID = jurisdictionIDToNameMapping.get(countyParishName).Jurisdiction_ID__c;
                            jurisdictionName = jurisdictionIDToNameMapping.get(countyParishName).DeveloperName;
                        }
                    }
                }
                uccFiling = UCCFilings.createUCCRecords(contractIdToAccountIdMap, loanAccount, accountMap, uccSettings, jurisdictionIDToNameMapping, jurisdictionID, jurisdictionName);

                String orderID = UCCFilingCallout.createFiling(uccFiling, uccSettings, contractIdToAccountIdMap, accountMap, loanAccount);
                if(!orderID.contains('Failure')) {
                    uccFiling.Order_ID__c = orderID;
                    uccFilingList.add(uccFiling);
                } else {
                    CustomError.addError(uccFiling, 'Creation of UCC Failing failed :'+orderID);
                }
            } catch (Exception e) {
                Error_Log__c errorLog = ErrorLogs.createErrorLog(
                    'Create UCC Filing', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                    null, false
                );
                errorLogDBInstance.addInsert(errorLog);
            }
        }
        uccFilingDBInstance.addInserts(uccFilingList).executeInserts();
        errorLogDBInstance.executeInserts();

        if(!uccFilingList.isEmpty()) {
            new QueueableJobHandler().executeUCCValidateApproveFilingQueueableJob(uccFilingList);
        }
    }

    @AuraEnabled
    public static void getOrderInformationOnClick(Id accountId) {
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(accountId);
        getOrderInformationAsync(accountIds);
    }

    @AuraEnabled
    public static void getUCCReportsOnClick(Id accountId) {
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(accountId);
        List<UCC_Filing_Detail__c> uccFilingList = uccFilingDBInstance.getUCCRecordsByAccountIds(accountIds);
        getUCCOrderStatus(uccFilingList);
    }

    @future (callout=true)
    public static void getOrderInformationAsync(Set<Id> accountIds) {
        getOrderInformation(accountIds);
    }

    @TestVisible
    private static void getOrderInformation(Set<Id> accountIds) {
        Map<Id, Map<String, List<String>>> uccFilingIdToOrderResponseMap = new Map<Id, Map<String, List<String>>>();
        List<UCC_Filing_Detail__c> uccFilingList = uccFilingDBInstance.getUCCRecordsByAccountIds(accountIds);
        for(UCC_Filing_Detail__c uccFiling : uccFilingList) {
            try {
                if(uccFiling.Order_ID__c == null){
                    CustomError.addError(uccFiling, 'UCC Order Id is equals to null');
                }
                uccFilingIdToOrderResponseMap.put(uccFiling.Id, UCCFilingCallout.getOrderInformationByOrderId(uccFiling.Order_ID__c));
            } catch (Exception e) {
                Error_Log__c errorLog = ErrorLogs.createErrorLog(
                    'UCC Filing Get Order Information Failed', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                    uccFiling.Id, false
                );
                errorLogDBInstance.addInsert(errorLog);
            }
        }
        if(!uccFilingIdToOrderResponseMap.isEmpty()) {
            setOrderInformation(uccFilingIdToOrderResponseMap, uccFilingList);
        }
        errorLogDBInstance.executeInserts();
    }

    @TestVisible
    private static void setOrderInformation(Map<Id, Map<String, List<String>>> uccFilingIdToOrderResponseMap, List<UCC_Filing_Detail__c> uccFilingList) {
        try {
            Map<Id,Map<String, String>> uccFilingIdToModelValueResponseMap = UCCFilings.prepareUCCFilingIdToModelValueResponseMap(
                uccFilingIdToOrderResponseMap
            );
            Map<Id, List<String>> uccFilingIdToDescriptionListMap = new Map<Id, List<String>>();
            List<UCC_Notes__c> existingUCCNotes = uccNoteDBInstance.getUCCNotsByUCCFilingIDs(uccFilingIdToOrderResponseMap.keySet());
            if(!existingUCCNotes.isEmpty()) {
                uccFilingIdToDescriptionListMap = UCCFilings.getExistingUCCNotes(existingUCCNotes);
            }
            for(UCC_Filing_Detail__c uccFiling : uccFilingList) {
                if(uccFilingIdToModelValueResponseMap.keySet().contains(uccFiling.Id)) {
                    Account accountRecord = new Account(Id = uccFiling.Account__c);
                    UCCFilings.setAccountAndUCCValues(uccFiling, accountRecord, uccFilingIdToModelValueResponseMap.get(uccFiling.Id));
                    List<UCC_Notes__c> notes = UCCFilings.createNotes(uccFiling.Id, uccFilingIdToModelValueResponseMap.get(uccFiling.Id),
                        uccFilingIdToDescriptionListMap.get(uccFiling.Id)
                    );
                    accountDBInstance.addUpdate(accountRecord);
                    uccFilingDBInstance.addUpdate(uccFiling);
                    uccNoteDBInstance.addInserts(notes);
                }
            }
            accountDBInstance.executeUpdates();
            uccFilingDBInstance.executeUpdates();
            uccNoteDBInstance.executeInserts();
        } catch (Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'UCC Filing Get Order Information Update Failed', e.getMessage() + e.getStackTraceString(), null, null,
                ErrorLogs.ERROR, null, false
            );
            errorLogDBInstance.addInsert(errorLog).executeInserts();
        }
    }

    public static void uccFilingContinuation(Set<Id> accountIds) {
        Map<Id, Map<String, List<String>>> uccFilingIdToContinuationResponseMap = new Map<Id, Map<String, List<String>>>();
        List<UCC_Filing_Detail__c> uccFilingList = uccFilingDBInstance.getUCCRecordsByAccountIds(accountIds);
        for(UCC_Filing_Detail__c uccFiling : uccFilingList) {
            try {
                if(uccFiling.Order_ID__c == null) {
                    CustomError.addError(uccFiling, 'UCC Order Id is equals to null');
                }
                uccFilingIdToContinuationResponseMap.put(uccFiling.Id,
                    UCCFilingCallout.uccFilingContinuation(uccFiling.Order_ID__c)
                );
            } catch (Exception e) {
                Error_Log__c errorLog = ErrorLogs.createErrorLog(
                    'UCC Filing Continuation Failed', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                    uccFiling.Id, false
                );
                errorLogDBInstance.addInsert(errorLog);
            }
        }

        if(!uccFilingIdToContinuationResponseMap.isEmpty()) {
            setContinuationInformation(uccFilingIdToContinuationResponseMap, uccFilingList);
        }

        errorLogDBInstance.executeInserts();
    }

    public static void uccValidateApproveFiling(List<UCC_Filing_Detail__c> uccFilingList) {
        UCC_Setting__mdt uccSettings = CustomMetaDataHelper.defaultuccSetting;
        String orderID;
        List<UCC_Validation_Log__c> uccValidationLogList = new List<UCC_Validation_Log__c>();
        List<UCC_Filing_Detail__c> uccApprovalSuccessList = new List<UCC_Filing_Detail__c>();

        UCC_Validation_Log__c validationLog;
        String validationMessage;
        Set<Id> accountIds =  new Set<Id>();
        for(UCC_Filing_Detail__c uccFiling : uccFilingList){
            try {
                accountIds.add(uccFiling.Account__c);
                validationMessage = UCCFilingCallout.validateFiling(uccFiling, uccSettings);
                validationLog = UCCFilings.createUCCValidationLog(uccFiling, validationMessage);
                uccValidationLogList.add(validationLog);

                orderID = UCCFilingCallout.approveFiling(uccFiling, uccSettings);
                if(!orderID.contains('Failure')) {
                    if(!uccFiling.Is_Terminated__c && !uccFiling.Is_UCC_Continued__c){
                        uccFiling.Approved__c = true;
                    } else if(uccFiling.Is_Terminated__c) {
                        uccFiling.Is_UCC_Termination_Approved__c = true;
                    } else if(uccFiling.Is_UCC_Continued__c){
                        uccFiling.Is_UCC_Continuation_Approved__c = true;
                    }
                    uccApprovalSuccessList.add(uccFiling);
                } else {
                    CustomError.addError(uccFiling, 'The Order is not approved :'+orderID);
                }
            } catch (Exception e) {
                Error_Log__c errorLog = ErrorLogs.createErrorLog(
                    'UCC Validate/Approve Filing', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                    null, false
                );
                errorLogDBInstance.addInsert(errorLog);
            }
        }

        if(!accountIds.isEmpty()) {
            getOrderInformation(accountIds);
        }

        uccFilingDBInstance.addUpdates(uccApprovalSuccessList).executeUpdates();
        uccValidationLogDBInstance.addInserts(uccValidationLogList).executeInserts();
    }

    @TestVisible
    private static void setContinuationInformation(Map<Id, Map<String, List<String>>> uccFilingIdToContinuationResponseMap, List<UCC_Filing_Detail__c> uccFilingList) {
        List<UCC_Filing_Detail__c> uccFilingContinuationList = new List<UCC_Filing_Detail__c>();
        try {
            Map<Id, Map<String, List<String>>> uccFilingIdToOrderResponseMap = new Map<Id, Map<String, List<String>>>();
            Map<Id,Map<String, String>> uccFilingIdToModelValueResponseMap = UCCFilings.prepareUCCFilingIdToModelValueResponseMap(
                uccFilingIdToContinuationResponseMap
            );
            for(UCC_Filing_Detail__c uccFiling : uccFilingList) {
                if(uccFilingIdToModelValueResponseMap.keySet().contains(uccFiling.Id)) {
                    Account accountRecord = new Account(Id = uccFiling.Account__c);
                    accountRecord.Override_UCC_status__c = GeneralConstants.OVERRIDE_UCC_STATUS_NONE;
                    UCCFilings.setContinuationFields(uccFiling, uccFilingIdToModelValueResponseMap.get(uccFiling.Id));
                    uccFilingIdToOrderResponseMap.put(uccFiling.Id, UCCFilingCallout.getOrderInformationByOrderId(uccFiling.Order_ID__c));
                    uccFilingContinuationList.add(uccFiling);
                    accountDBInstance.addUpdate(accountRecord);
                }
            }
            accountDBInstance.executeUpdates();
            if(!uccFilingIdToOrderResponseMap.isEmpty()) {
                setOrderInformation(uccFilingIdToOrderResponseMap, uccFilingContinuationList);
            }
        } catch (Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'UCC Filing Continuation Information Update Failed', e.getMessage() + e.getStackTraceString(),
                null, null, ErrorLogs.ERROR, null, false
            );
            errorLogDBInstance.addInsert(errorLog).executeInserts();
        }
        if(!uccFilingContinuationList.isEmpty()) {
            new QueueableJobHandler().executeUCCValidateApproveFilingQueueableJob(uccFilingContinuationList);
        }
    }

    public static void setAccountFieldsFromUCC(List<UCC_Filing_Detail__c> uccFilingList) {
        Map<Id, UCC_Filing_Detail__c> uccDetailByAccountId = new Map<Id, UCC_Filing_Detail__c>();
        for(UCC_Filing_Detail__c uccFiling : uccFilingList){
            uccDetailByAccountId.put(uccFiling.Account__c, uccFiling);
        }
        List<Account> accountList = accountDBInstance.getAccountByIds(uccDetailByAccountId.keySet());

        for(Account account : accountList){
            account.UCC_Status__c = GeneralConstants.UCC_STATUS_ACTIVE;
            account.UCC_Order_Number__c = uccDetailByAccountId.get(account.Id).Order_ID__c;
        }

        accountDBInstance.addUpdates(accountList).executeUpdates();
    }

    @AuraEnabled
    public static void terminateUCCFiling(Id accountId) {
        List<UCC_Filing_Detail__c> uccFilingTerminationList = new List<UCC_Filing_Detail__c>();
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(accountId);
        List<UCC_Filing_Detail__c> uccFilingList = uccFilingDBInstance.getUCCRecordsByAccountIds(accountIds);

        for(UCC_Filing_Detail__c uccFiling : uccFilingList){
            try {
                String orderID;
                if(uccFiling.Order_Status__c == GeneralConstants.UCC_ORDER_STATUS_COMPLETED) {
                    orderID = UCCFilingCallout.terminateUCC(uccFiling.Order_ID__c);
                }
                if(orderID != null && !orderID.contains('Failure')){
                    uccFiling.Is_Terminated__c = true;
                    uccFiling.Terminated_Order_ID__c = orderID;
                    uccFilingTerminationList.add(uccFiling);
                } else {
                    CustomError.addError(uccFiling, 'Termination of UCC Filing failed :'+orderID);
                }
            } catch (Exception e) {
                Error_Log__c errorLog = ErrorLogs.createErrorLog(
                    'UCC Terminate Filing', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                    uccFiling.Id, false
                );
                errorLogDBInstance.addInsert(errorLog);
            }
        }
        uccFilingDBInstance.addUpdates(uccFilingTerminationList).executeUpdates();
        errorLogDBInstance.executeInserts();

        if(!uccFilingTerminationList.isEmpty()) {
            new QueueableJobHandler().executeUCCValidateApproveFilingQueueableJob(uccFilingTerminationList);
        }
    }

    @AuraEnabled
    public static void updateUCCFiling(Id accountId) {

        Map<Id, Map<String, List<String>>> uccFilingIdToOrderResponseMap = new Map<Id, Map<String, List<String>>>();
        List<UCC_Filing_Detail__c> uccFilingUpdatedList = new List<UCC_Filing_Detail__c>();
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(accountId);
        List<UCC_Filing_Detail__c> uccFilingList = uccFilingDBInstance.getUCCRecordsByAccountIds(accountIds);
        Map<Id, Account> accountMap = new Map<Id, Account> (accountDBInstance.getAccountByIds(accountIds));

        for(UCC_Filing_Detail__c uccFiling : uccFilingList){
            try {
                String orderID = String.valueOf(uccFiling.Order_ID__c);
                Map<String, List<String>> getUpdateResponseMap = new Map<String, List<String>>();
                Account accountDetail = accountMap.get(uccFiling.Account__c);
                uccFilingUpdatedList.add(uccFiling);

                if(uccFiling.Order_ID__c != null){
                    getUpdateResponseMap = UCCFilingCallout.updateUCC(uccFiling, accountDetail);
                } else {
                    CustomError.addError(uccFiling, 'UCC Order Id is equals to null');
                }
                uccFilingIdToOrderResponseMap.put(uccFiling.Id, getUpdateResponseMap);
            } catch (Exception e) {
                Error_Log__c errorLog = ErrorLogs.createErrorLog(
                    'UCC Update Filing', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                    uccFiling.Id, false
                );
                errorLogDBInstance.addInsert(errorLog);
            }
        }

        if(!uccFilingIdToOrderResponseMap.isEmpty()) {
            setOrderInformation(uccFilingIdToOrderResponseMap, uccFilingList);
        }
        errorLogDBInstance.executeInserts();

        if(!uccFilingUpdatedList.isEmpty()) {
            new QueueableJobHandler().executeUCCValidateApproveFilingQueueableJob(uccFilingUpdatedList);
        }
    }

    public static void getUCCOrderStatus(List<UCC_Filing_Detail__c> uccFilingList) {
        Map<Id, Map<String, List<String>>> uccFilingIdToOrderResponseMap = new Map<Id, Map<String, List<String>>>();
        for(UCC_Filing_Detail__c uccFiling : uccFilingList) {
            try {
                String orderID;
                if(!uccFiling.Is_Terminated__c){
                    orderID = uccFiling.Order_ID__c;
                } else {
                    orderID = uccFiling.Terminated_Order_ID__c;
                }
                if(orderID == null) {
                    CustomError.addError(uccFiling, 'UCC Order Id is equals to null');
                }
                uccFilingIdToOrderResponseMap.put(uccFiling.Id, UCCFilingCallout.getOrderInformationByOrderId(orderID));
            } catch (Exception e) {
                Error_Log__c errorLog = ErrorLogs.createErrorLog(
                    'UCC Filing Get Order Status Failed', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                    uccFiling.Id, false
                );
                errorLogDBInstance.addInsert(errorLog);
            }
        }
        if(!uccFilingIdToOrderResponseMap.isEmpty()) {
            getUCCReports(uccFilingIdToOrderResponseMap);
        }
        errorLogDBInstance.executeInserts();
    }

    @TestVisible
    private static void getUCCReports(Map<Id, Map<String, List<String>>> uccFilingIdToOrderResponseMap) {
        try {
            Map<Id, Map<String, String>> uccFilingIdToModelValueResponseMap = UCCFilings.prepareUCCFilingIdToModelValueResponseMap(
                uccFilingIdToOrderResponseMap
            );
            List<UCC_Filing_Detail__c> uccFilingOrderCompletedList = new List<UCC_Filing_Detail__c>();
            List<UCC_Filing_Detail__c> uccFilingList = uccFilingDBInstance.getUCCFilingListByIds(uccFilingIdToModelValueResponseMap.keySet());
            List<UCC_Filing_Attachment__c> existingUCCAttachments = uccFilingAttachmentDBInstance.getUCCFilingAttachmentsByUCCFilingIDs(uccFilingIdToModelValueResponseMap.keySet());
            Set<String> existingUCCAttachmentsIds =  new Set<String>();
            for(UCC_Filing_Attachment__c existingUCCAttachment : existingUCCAttachments) {
                existingUCCAttachmentsIds.add(existingUCCAttachment.UCC_Attachment_ID__c);
            }
            Set<Id> accountIds =  new Set<Id>();
            for(UCC_Filing_Detail__c uccFiling : uccFilingList) {
                accountIds.add(uccFiling.Account__c);
            }
            Map<Id, List<String>> uccFilingIdToDescriptionListMap = new Map<Id, List<String>>();
            List<UCC_Notes__c> existingUCCNotes = uccNoteDBInstance.getUCCNotsByUCCFilingIDs(uccFilingIdToOrderResponseMap.keySet());
            if(!existingUCCNotes.isEmpty()) {
                uccFilingIdToDescriptionListMap = UCCFilings.getExistingUCCNotes(existingUCCNotes);
            }
            Map<Id, Account> accountMap = new Map<Id, Account>(accountDBInstance.getAccountByIds(accountIds));
            for(UCC_Filing_Detail__c uccFiling : uccFilingList) {
                if(!uccFiling.Is_Terminated__c) {
                    Account accountRecord = accountMap.get(uccFiling.Account__c);
                    UCCFilings.setAccountAndUCCValues(uccFiling, accountRecord, uccFilingIdToModelValueResponseMap.get(uccFiling.Id));
                }
                List<UCC_Notes__c> notes = UCCFilings.createNotes(uccFiling.Id, uccFilingIdToModelValueResponseMap.get(uccFiling.Id),
                    uccFilingIdToDescriptionListMap.get(uccFiling.Id)
                );
                if(uccFiling.Order_Status__c == GeneralConstants.UCC_ORDER_STATUS_COMPLETED) {
                    List<UCC_Filing_Attachment__c> uccAttachments = UCCFilings.getUCCAttachments(uccFiling, uccFilingIdToModelValueResponseMap.get(uccFiling.Id), existingUCCAttachmentsIds);
                    uccFilingOrderCompletedList.add(uccFiling);
                    uccFilingAttachmentDBInstance.addInserts(uccAttachments);
                }
                uccNoteDBInstance.addInserts(notes);
                uccFilingDBInstance.addUpdate(uccFiling);
            }
            accountDBInstance.executeUpdates();
            uccNoteDBInstance.executeInserts();
            uccFilingDBInstance.executeUpdates();
            uccFilingAttachmentDBInstance.executeInserts();
            if(!uccFilingOrderCompletedList.isEmpty()) {
                new QueueableJobHandler().executeUCCFilingReportQueueableJob(uccFilingOrderCompletedList);
            }
        } catch (Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'UCC Filing Get UCC Report Failed', e.getMessage() + e.getStackTraceString(), null, null,
                ErrorLogs.ERROR, null, false
            );
            errorLogDBInstance.addInsert(errorLog).executeInserts();
        }
    }

    public static void getUCCAttachmentReports(List<UCC_Filing_Detail__c> uccFilingList) {
        Map<Id, Map<String, List<String>>> uccFilingAttachmentIdToGetAttachmentResponseMap = new Map<Id, Map<String, List<String>>>();
        Set<Id> uccFilingIds = (new Map<Id, UCC_Filing_Detail__c>(uccFilingList)).keySet();
        Set<Id> pulledUCCReportIds = new Set<Id>();
        List<UCC_Filing_Attachment__c> uccFilingAttachmentList = uccFilingAttachmentDBInstance.getUCCFilingAttachmentsByUCCFilingIDs(uccFilingIds);
        for(UCC_Filing_Attachment__c uccAttachment : uccFilingAttachmentList) {
            try {
                if(uccAttachment.UCC_Attachment_ID__c == null){
                    CustomError.addError(uccAttachment, 'UCC Attachment ID is equals to null');
                }
                uccFilingAttachmentIdToGetAttachmentResponseMap.put(uccAttachment.Id, UCCFilingCallout.getUCCAttachmentsByAttachmentId(String.valueOf(uccAttachment.UCC_Attachment_ID__c)));
                pulledUCCReportIds.add(uccAttachment.UCC_Filing_Detail__c);
            } catch (Exception e) {
                Error_Log__c errorLog = ErrorLogs.createErrorLog(
                    'UCC Filing Get Attachment Link Failed', e.getMessage() + e.getStackTraceString(),
                    null, null, ErrorLogs.ERROR, null, false
                );
                errorLogDBInstance.addInsert(errorLog).executeInserts();
            }
        }
        if(!uccFilingAttachmentIdToGetAttachmentResponseMap.isEmpty()) {
            try {
                setUCCAttachments(uccFilingAttachmentIdToGetAttachmentResponseMap);
                for(UCC_Filing_Detail__c uccFiling : uccFilingList) {
                    if(pulledUCCReportIds.contains(uccFiling.Id)) {
                        uccFiling.UCC_Reports_Pulled__c = true;
                        if(uccFiling.Is_Terminated__c) {
                            uccFiling.UCC_Termination_Reports_Pulled__c = true;
                        } else if (uccFiling.Is_UCC_Continued__c) {
                            uccFiling.UCC_Continuation_Reports_Pulled__c = true;
                        }
                        uccFilingDBInstance.addUpdate(uccFiling);
                    }
                }
                uccFilingDBInstance.executeUpdates();
            } catch (Exception e) {
                Error_Log__c errorLog = ErrorLogs.createErrorLog(
                    'UCC Filing Get Attachment Information Failed', e.getMessage() + e.getStackTraceString(),
                    null, null, ErrorLogs.ERROR, null, false
                );
                errorLogDBInstance.addInsert(errorLog).executeInserts();
            }
        }
    }

    public static void setUCCAttachments(Map<Id, Map<String, List<String>>> uccFilingAttachmentIdToGetAttachmentResponseMap) {
        Map<Id,Map<String, String>> uccFilingAttachmentIdToModelValueResponseMap = UCCFilings.prepareUCCFilingIdToModelValueResponseMap(
            uccFilingAttachmentIdToGetAttachmentResponseMap
        );
        List<UCC_Filing_Attachment__c> uccFilingAttachmentList = uccFilingAttachmentDBInstance.getUCCFilingAttachmentsByIDs(uccFilingAttachmentIdToModelValueResponseMap.keySet());
        Exception reportException;
        for(UCC_Filing_Attachment__c uccFilingAttachment : uccFilingAttachmentList) {
            String attachmentLink = UCCFilings.setUCCAttachmentLinks(uccFilingAttachment, uccFilingAttachmentIdToModelValueResponseMap.get(uccFilingAttachment.Id));
            if(attachmentLink == null) {
                CustomError.addError(uccFilingAttachment, 'UCC Attachment Link is null');
            }
            uccFilingAttachment.CSC_Attachment_Link__c = attachmentLink;
            try {
                Blob fileBody = UCCFilingCallout.getUCCAttachmentsFromExternalURL(String.valueOf(attachmentLink));
                String extension = attachmentLink.substringAfterLast('.');
                String fileName = GeneralHelper.cleanSpecialCharacters(uccFilingAttachment.Description__c);
                fileName = fileName.replaceAll('\\s','_');
                fileName += '.' + extension;
                WasabiManager.uploadUCCFilesToWasabi(uccFilingAttachment, fileName, fileBody);
            } catch (Exception e) {
                reportException = e;
            }
            uccFilingAttachmentDBInstance.addUpdate(uccFilingAttachment);
        }
        errorLogDBInstance.executeInserts();
        uccFilingAttachmentDBInstance.executeUpdates();
        if(reportException != null) {
            throw new UCCFilingManagerException('Read UCC Attachment Information Failed');
        }
    }

    @TestVisible
    public static void setUCCExpiredFields(List<Account> accountList) {
        try {
            for(Account accountRecord : accountList) {
                accountRecord.UCC_Status__c = GeneralConstants.UCC_STATUS_NO_UCC;
                accountDBInstance.addUpdate(accountRecord);
            }
            accountDBInstance.executeUpdates();
        } catch (Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'UCC Expiration Fields Update Failed', e.getMessage() + e.getStackTraceString(), null, null,
                ErrorLogs.ERROR, null, false
            );
            errorLogDBInstance.addInsert(errorLog).executeInserts();
        }
    }

    private class UCCFilingManagerException extends Exception {}
}