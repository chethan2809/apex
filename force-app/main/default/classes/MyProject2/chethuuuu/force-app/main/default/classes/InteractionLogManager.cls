public class InteractionLogManager {

    @TestVisible
    private static AccountDB accountDBInstance = new AccountDB();
    @TestVisible
    private static TaskDB taskDBInstance = new TaskDB();
    @TestVisible
    private static CaseDB caseDBInstance = new CaseDB();
    @TestVisible
    private static CollectionCaseDB collectionCaseDBInstance = new CollectionCaseDB();

    public static void handleActionCode(List<Interaction_Log__c> interactionLogs)
    {
        Set<Id> collectionCaseIds = new Set<Id>();
        for(Interaction_Log__c interactionLog : interactionLogs) {
            collectionCaseIds.add(interactionLog.Collection_Case__c);
        }

        Map<Id, Collection_Case__c> collectionCaseMap = new Map<Id, Collection_Case__c> (
            collectionCaseDBInstance.getCollectionCasesByIds(collectionCaseIds)
        );

        for(Interaction_Log__c interactionLog : interactionLogs)
        {
            Collection_Case__c collectionCase = new Collection_Case__c();
            collectionCase.Id = interactionLog.Collection_Case__c;
            collectionCase.Last_Interaction_Log_Date__c = GeneralHelper.currentSystemDateTime;

            Id accountId = collectionCaseMap.get(interactionLog.Collection_Case__c).Account__c;

            Account account = new Account();
            account.Id = accountId;

            Id ownerId = collectionCaseMap.get(interactionLog.Collection_Case__c).OwnerId;
            Id supervisorId = collectionCaseMap.get(interactionLog.Collection_Case__c).Supervisor__c;
            Id legalUserId = collectionCaseMap.get(interactionLog.Collection_Case__c).Legal_User__c;
            String CaseName = collectionCaseMap.get(interactionLog.Collection_Case__c).Name;

            if(interactionLog.Action_Code__c == CollectionCaseConstants.LEFT_VOICEMAIL ||
                interactionLog.Action_Code__c == CollectionCaseConstants.GATEKEEPER ||
                (interactionLog.Action_Code__c == CollectionCaseConstants.CONTACT_ATTEMPT && (interactionLog.Sub_Action_Code__c == CollectionCaseConstants.CONTACTED || interactionLog.Sub_Action_Code__c == CollectionCaseConstants.REFUSAL_TO_PAY)) ||
                interactionLog.Action_Code__c == CollectionCaseConstants.BAD_CONTACT_INFO 
            ) {
                String title = 'Collection Case : ' + CaseName;
                String description = interactionLog.Action_Code__c + '\n' +
                   'Followup Date : ' + interactionLog.Followup_Date__c;
                sendChatterNotifications(interactionLog, title, description, ownerId);
                createTaskFromInteraction(interactionLog, title, description, ownerId, interactionLog.Followup_Date__c);
                collectionCaseDBInstance.addUpdate(collectionCase);
            }

            if(interactionLog.Action_Code__c == CollectionCaseConstants.BANKRUPTCY) {
                collectionCase.Bankruptcy_Chapter__c = interactionLog.Bankruptcy_Chapter__c;
                collectionCase.Bankruptcy_Status__c = interactionLog.Bankruptcy_Status__c;
                collectionCase.Proof_of_Claim_File_By_Date__c = interactionLog.Proof_of_Claim_File_By_Date__c;
                collectionCase.Proof_of_Claim_Filed_Date__c = interactionLog.Proof_of_Claim_Filed_Date__c;
                collectionCase.Parties_Who_Filed_Bankruptcy__c = interactionLog.Parties_Associated__c;
                collectionCase.Bankruptcy_Case_Number__c = interactionLog.Bankruptcy_Case_Number__c;
                collectionCase.Contacts_Who_Filed_Bankruptcy__c = interactionLog.Contacts_Who_Filed_Bankruptcy__c;
                collectionCaseDBInstance.addUpdate(collectionCase);
            }

            Integer proofOfClaimFileByDays = CustomSettingsHelper.generalSettings != null
            && CustomSettingsHelper.generalSettings.Proof_Of_Claim_File_By_Days__c != null ?
                Integer.ValueOf(CustomSettingsHelper.generalSettings.Proof_Of_Claim_File_By_Days__c) : CollectionCaseConstants.PROOF_OF_CLAIM_FILE_BY_DAYS;

            if(interactionLog.Action_Code__c == CollectionCaseConstants.BANKRUPTCY &&
                interactionLog.Sub_Action_Code__c == CollectionCaseConstants.BANKRUPTCY_FILED
            ) {
                if(legalUserId == null) {
                    interactionLog.addError('Please Select ' + CollectionCaseConstants.LEGAL_USER + ' In Collection Case Details');
                    return;
                }
                if(interactionLog.Bankruptcy_Proof_of_Claim_Filed__c == 'No' &&
                    interactionLog.Proof_of_Claim_File_By_Date__c >= GeneralHelper.currentSystemDate.addDays(-proofOfClaimFileByDays)
                ) {
                    String title = 'Collection Case : ' + CaseName;
                    String description = interactionLog.Sub_Action_Code__c;
                    sendChatterNotifications(interactionLog, title, description, legalUserId);
                    createTaskFromInteraction(interactionLog, title, description, legalUserId, interactionLog.Followup_Date__c);
                }
                collectionCaseDBInstance.addUpdate(collectionCase);
            }

            if(interactionLog.Action_Code__c == CollectionCaseConstants.LEGAL) {
                collectionCase.Case_Number__c = interactionLog.Case_Number__c;
                collectionCase.Court_Location__c = interactionLog.Court_Location__c;
                collectionCase.Legal_Counsel_Type__c = interactionLog.Legal_Counsel_Type__c;
                collectionCase.Last_Skip_Tracing_Date__c = interactionLog.Last_Skip_Tracing_Date__c;
                collectionCase.Date_Case_Filed__c = GeneralHelper.currentSystemDate;
                collectionCase.Receivership_Dissolution__c = interactionLog.Receivership_Dissolution__c;
                collectionCase.Debt_Consolidator_Name__c = interactionLog.Debt_Consolidator__c;
                collectionCaseDBInstance.addUpdate(collectionCase);
            }

            if(interactionLog.Sub_Action_Code__c == CollectionCaseConstants.LEGAL_REVIEW) {
                String title = 'Collection Case : ' + CaseName;
                String body = interactionLog.Sub_Action_Code__c;
                if(legalUserId == null) {
                    interactionLog.addError('Please Select ' + CollectionCaseConstants.LEGAL_USER + ' In Collection Case Details');
                    return;
                }
                createTaskFromInteraction(interactionLog, title, body, legalUserId, interactionLog.Followup_Date__c);
                sendChatterNotifications(interactionLog, title, body, legalUserId);
                collectionCaseDBInstance.addUpdate(collectionCase);
            }

            if(interactionLog.Sub_Action_Code__c == CollectionCaseConstants.LEGAL_FEEDBACK) {
                String title = 'Collection Case : ' + CaseName;
                String body = interactionLog.Sub_Action_Code__c;
                sendChatterNotifications(interactionLog, title, body, ownerId);
                if(legalUserId == null) {
                    interactionLog.addError('Please Select ' + CollectionCaseConstants.LEGAL_USER + ' In Collection Case Details');
                    return;
                }
                createTaskFromInteraction(interactionLog, title, body, ownerId, interactionLog.Followup_Date__c);
                sendChatterNotifications(interactionLog, title, body, legalUserId);
                collectionCaseDBInstance.addUpdate(collectionCase);
            }

            if(interactionLog.Sub_Action_Code__c == CollectionCaseConstants.SUPERVISOR_REVIEW) {
                String title = 'Collection Case : ' + CaseName;
                String body = interactionLog.Sub_Action_Code__c;
                createTaskFromInteraction(interactionLog, title, body, ownerId, interactionLog.Followup_Date__c);
                sendChatterNotifications(interactionLog, title, body, ownerId);
                collectionCaseDBInstance.addUpdate(collectionCase);
            }

            if(interactionLog.Sub_Action_Code__c == CollectionCaseConstants.SUPERVISOR_FEEDBACK) {
                String title = 'Collection Case : ' + CaseName;
                String body = interactionLog.Sub_Action_Code__c;
                if(supervisorId == null) {
                    interactionLog.addError('Please Select ' + CollectionCaseConstants.SUPERVISOR + ' In Collection Case Details');
                    return;
                }
                createTaskFromInteraction(interactionLog, title, body, ownerId, interactionLog.Followup_Date__c);
                sendChatterNotifications(interactionLog, title, body, ownerId);
                sendChatterNotifications(interactionLog, title, body, supervisorId);
                collectionCaseDBInstance.addUpdate(collectionCase);
            }

            if(interactionLog.Sub_Action_Code__c == CollectionCaseConstants.CEASE_AND_DESIST) {
                if(supervisorId == null) {
                    interactionLog.addError('Please Select ' + CollectionCaseConstants.SUPERVISOR + ' In Collection Case Details');
                    return;
                }
                Case newCase = new Case();
                newCase.Description = 'Case for Supervisor';
                newCase.Subject = CollectionCaseConstants.CEASE_AND_DESIST;
                newCase.OwnerId = supervisorId;
                caseDBInstance.addInsert(newCase);

                account.Cease_and_Desist__c = true;
                collectionCase.Cease_and_Desist__c = true;
                accountDBInstance.addUpdate(account);
                collectionCaseDBInstance.addUpdate(collectionCase);
            }

            if(interactionLog.Sub_Action_Code__c == CollectionCaseConstants.FRAUD_CONFIRMED) {
                if(interactionLog.Fraud_Confirmed__c){
                    account.Confirmed_Fraud_Flag__c = true;
                    accountDBInstance.addUpdate(account);
                    collectionCaseDBInstance.addUpdate(collectionCase);
                } else{
                    if(supervisorId == null) {
                        interactionLog.addError('Please Select ' + CollectionCaseConstants.SUPERVISOR + ' In Collection Case Details');
                        return;
                    }
                    String title = 'Collection Case : ' + CaseName;
                    String body = interactionLog.Sub_Action_Code__c;
                    createTaskFromInteraction(interactionLog, title, body, supervisorId, interactionLog.Followup_Date__c);
                    sendChatterNotifications(interactionLog, title, body, supervisorId);
                    collectionCaseDBInstance.addUpdate(collectionCase);
                }
            }

            if(interactionLog.Sub_Action_Code__c == CollectionCaseConstants.FRAUD_ALLEGED) {
                    if(supervisorId == null) {
                        interactionLog.addError('Please Select ' + CollectionCaseConstants.SUPERVISOR + ' In Collection Case Details');
                        return;
                    }
                    String title = 'Collection Case : ' + CaseName;
                    String body = interactionLog.Sub_Action_Code__c;
                    createTaskFromInteraction(interactionLog, title, body, supervisorId, interactionLog.Followup_Date__c);
                    sendChatterNotifications(interactionLog, title, body, supervisorId);
                    collectionCaseDBInstance.addUpdate(collectionCase);
            }

            if(interactionLog.Sub_Action_Code__c == CollectionCaseConstants.REQUEST_DEMAND_LETTER) {
                if(legalUserId == null) {
                    interactionLog.addError('Please Select ' + CollectionCaseConstants.LEGAL_USER + ' In Collection Case Details');
                    return;
                }
                String title = 'Collection Case : ' + CaseName;
                String body = interactionLog.Sub_Action_Code__c;
                createTaskFromInteraction(interactionLog, title, body, legalUserId, interactionLog.Followup_Date__c);
                sendChatterNotifications(interactionLog, title, body, legalUserId);
                collectionCaseDBInstance.addUpdate(collectionCase);
        }

            if(interactionLog.Action_Code__c == CollectionCaseConstants.DECEASED &&
                interactionLog.Sub_Action_Code__c == CollectionCaseConstants.DECEASED_OWNER
            ) {
                if(supervisorId == null) {
                    interactionLog.addError('Please Select ' + CollectionCaseConstants.SUPERVISOR + ' In Collection Case Details');
                    return;
                }
                Case newCase = new Case();
                newCase.Description = 'Case for Supervisor';
                newCase.Subject = CollectionCaseConstants.DECEASED_OWNER;
                newCase.OwnerId = supervisorId;
                caseDBInstance.addInsert(newCase);

                account.Deceased__c = true;
                collectionCase.Deceased_owner__c = true;
                accountDBInstance.addUpdate(account);
                collectionCaseDBInstance.addUpdate(collectionCase);
            }
            if(interactionLog.Sub_Action_Code__c == CollectionCaseConstants.DECEASED_OWNER_CONFIRMED) {
                account.Deceased__c = true;
                accountDBInstance.addUpdate(account);
                collectionCaseDBInstance.addUpdate(collectionCase);
            }
            if(interactionLog.Sub_Action_Code__c == CollectionCaseConstants.BANKRUPTCY_IN_PROCESS) {
                String description = CollectionCaseConstants.VERIFY_BANKRUPTCY_DETAILS;
                String title = 'Collection Case : ' + CaseName;
                createTaskFromInteraction(interactionLog, title, description, ownerId, interactionLog.Followup_Date__c);
                collectionCaseDBInstance.addUpdate(collectionCase);
            }
            if(interactionLog.Sub_Action_Code__c == CollectionCaseConstants.BANKRUPTCY_STATUS_UPDATE) {
                account.Bankruptcy_Status__c = interactionLog.Bankruptcy_Status__c;
                accountDBInstance.addUpdate(account);
                collectionCaseDBInstance.addUpdate(collectionCase);
            }
            if(interactionLog.Sub_Action_Code__c == CollectionCaseConstants.BANKRUPTCY_PROOF_OF_CLAIM_FILED) {
                account.Legacy_Negative_CAN_History__c = true;
                account.Has_Bankruptcy__c = true;
                account.Bankruptcy_Status__c = interactionLog.Bankruptcy_Status__c;
                account.Bankruptcy_File_Date__c = interactionLog.Proof_of_Claim_Filed_Date__c;
                accountDBInstance.addUpdate(account);
                collectionCaseDBInstance.addUpdate(collectionCase);
            }
            if(interactionLog.Sub_Action_Code__c == CollectionCaseConstants.BANKRUPTCY_PLAN_PAYMENTS) {
                collectionCase.Collections_status__c = CollectionCaseConstants.BANKRUPTCY_PLAN;
                collectionCase.Collections_sub_status__c = CollectionCaseConstants.BANKRUPTCY_SETTLEMENT_PLAN;
                collectionCaseDBInstance.addUpdate(collectionCase);
            }
            if(interactionLog.Action_Code__c == CollectionCaseConstants.SITE_INSPECTION) {
                collectionCase.Site_Inspection_Request_Date__c = interactionLog.Inspection_Date__c;
                collectionCase.Site_Inspection_Details__c = interactionLog.Site_Inspection_Details__c;
                collectionCase.Demand_Letter_Sent__c = interactionLog.Demand_Letter_Delivered__c;
                collectionCase.Contact_With_PG__c = interactionLog.Contact_Made_With_PG__c;
                collectionCase.Business_Status__c = interactionLog.Business_Status__c;
                collectionCase.Ownership_Change__c = interactionLog.Ownership_Change__c;
                collectionCase.Site_Inspection_Completed_Date__c = interactionLog.Site_Inspection_Completed_Date__c;
                collectionCaseDBInstance.addUpdate(collectionCase);
            }
            if(interactionLog.Sub_Action_Code__c == CollectionCaseConstants.SITE_INSPECTION_ORDERED) {
                collectionCase.Last_Site_Inspection_Date__c = GeneralHelper.currentSystemDate;
                collectionCaseDBInstance.addUpdate(collectionCase);
            }
            if(interactionLog.Action_Code__c == CollectionCaseConstants.SETTLEMENT_NEGOTIATION) {
                collectionCase.Collections_status__c = CollectionCaseConstants.SETTLEMENT_PLAN_REQUESTED;
                collectionCase.Collections_sub_status__c = CollectionCaseConstants.SETTLEMENT_NEGOTIATIONS;
                collectionCaseDBInstance.addUpdate(collectionCase);
            }
            if(interactionLog.Sub_Action_Code__c == CollectionCaseConstants.ACCOMMODATION_REQUESTED) {
                collectionCase.Collections_status__c = CollectionCaseConstants.ACCOMMODATION;
                collectionCase.Collections_sub_status__c = CollectionCaseConstants.ACCOMMODATION_REQUESTED;
                collectionCaseDBInstance.addUpdate(collectionCase);
            }
            if(interactionLog.Sub_Action_Code__c == CollectionCaseConstants.MOVE_TO_LEGAL_COUNSEL) {
                collectionCase.Collections_status__c = interactionLog.Legal_Counsel_Type__c == CollectionCaseConstants.INSIDE_COUNSEL ? CollectionCaseConstants.INSIDE_COUNSEL:CollectionCaseConstants.OUTSIDE_COUNSEL;
                collectionCase.Collections_sub_status__c = interactionLog.Legal_Counsel_Type__c == CollectionCaseConstants.INSIDE_COUNSEL ? CollectionCaseConstants.MOVE_TO_INSIDE_COUNSEL:CollectionCaseConstants.MOVE_TO_OUTSIDE_COUNSEL;
                collectionCaseDBInstance.addUpdate(collectionCase);
            }
            if(interactionLog.Sub_Action_Code__c == CollectionCaseConstants.PREPARING_SUIT) {
                collectionCase.Collections_status__c = interactionLog.Legal_Counsel_Type__c == CollectionCaseConstants.INSIDE_COUNSEL ? CollectionCaseConstants.INSIDE_COUNSEL:CollectionCaseConstants.OUTSIDE_COUNSEL;
                collectionCase.Collections_sub_status__c = CollectionCaseConstants.PREPARING_SUIT;
                collectionCaseDBInstance.addUpdate(collectionCase);

                account.Case_Number__c = interactionLog.Case_Number__c;
                account.Legal_Counsel_Type__c = interactionLog.Legal_Counsel_Type__c;
                accountDBInstance.addUpdate(account);
            }
            if(interactionLog.Sub_Action_Code__c == CollectionCaseConstants.SUIT_FILED) {
                collectionCase.Collections_status__c = interactionLog.Legal_Counsel_Type__c == CollectionCaseConstants.INSIDE_COUNSEL ? CollectionCaseConstants.INSIDE_COUNSEL:CollectionCaseConstants.OUTSIDE_COUNSEL;
                collectionCase.Collections_sub_status__c = CollectionCaseConstants.SUIT_FILED;
                collectionCaseDBInstance.addUpdate(collectionCase);
            }
            if(interactionLog.Sub_Action_Code__c == CollectionCaseConstants.RECEIVERSHIP_DISSOLUTION) {
                account.Receivership_Dissolution__c = interactionLog.Receivership_Dissolution__c;
                accountDBInstance.addUpdate(account);

                collectionCase.Receivership_Dissolution__c = interactionLog.Receivership_Dissolution__c;
                collectionCaseDBInstance.addUpdate(collectionCase);
            }
            if(interactionLog.Action_Code__c == CollectionCaseConstants.JUDGEMENT_AWARDED) {
                collectionCase.Judgment_Amount__c = interactionLog.Judgment_Amount__c;
                collectionCase.Judgment_Date__c = interactionLog.Judgment_Date__c;
                collectionCase.Judgment_Rate_of_Interest__c = interactionLog.Judgement_Rate_of_Interest__c;
                collectionCase.Collections_status__c = CollectionCaseConstants.JUDGEMENT;
                collectionCase.Collections_sub_status__c = CollectionCaseConstants.JUDGEMENT_AWARDED;
                collectionCaseDBInstance.addUpdate(collectionCase);

                account.Judgment_Amount__c = interactionLog.Judgment_Amount__c;
                accountDBInstance.addUpdate(account);
            }
            if(interactionLog.Action_Code__c == CollectionCaseConstants.DEBT_CONSOLIDATOR_FOUND) {
                collectionCase.Debt_Consolidator_Name__c = interactionLog.Debt_Consolidator__c;
                collectionCaseDBInstance.addUpdate(collectionCase);
            }
        }
        caseDBInstance.executeInserts();
        accountDBInstance.executeUpdates();
        collectionCaseDBInstance.executeUpdates();
    }

    public static void sendChatterNotifications(Interaction_Log__c interactionLog, String title,
        String body, Id userId
    ) {
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle(title);
        notification.setBody(body);
        notification.setSenderId(interactionLog.OwnerId);
        notification.setNotificationTypeId(GeneralHelper.customNotificationTypeByName.get('Collection_Notifications'));
        notification.setTargetId(interactionLog.Collection_Case__c);
        if(userId != null) {
            notification.send(new Set<String> { userId });
        }
    }

    public static void createTaskFromInteraction(Interaction_Log__c interactionLog,
        String Subject, String body, Id ownerId, Date followUpDate
    ) {
        Task newTask = new Task();
        newTask.subject = Subject;
        newTask.WhatId = interactionLog.Collection_Case__c;
        newTask.OwnerId = ownerId;
        newTask.Priority = 'Normal';
        newTask.Status = 'Open';
        newTask.Description = body;
        newTask.ActivityDate = followUpDate;
        taskDBInstance.addInsert(newTask);
        taskDBInstance.executeInserts();
    }
}