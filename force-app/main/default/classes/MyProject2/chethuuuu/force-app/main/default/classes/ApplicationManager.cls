public class ApplicationManager {

    @TestVisible
    private static ApplicationDB applicationDBInstance = new ApplicationDB();
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    @TestVisible
    private static AccountDB accountDBInstance = new AccountDB();
    @TestVisible
    private static CANPricingDetailDB canPricingDetailDBInstance = new CANPricingDetailDB();
    @TestVisible
    private static UserDB userDBInstance = new userDB();
    @TestVisible
    private static EmailDB emailDBInstance = new EmailDB();
    @TestVisible
    private static PartyDB partyDBInstance = new PartyDB();
    @TestVisible
    private static PartyDB fraudPartyDBInstance = new PartyDB();
    @TestVisible
    private static OcrolusReportDB ocrolusReportDBInstance = new OcrolusReportDB();
    @TestVisible
    private static CLContractDB clContractDBInstance = new CLContractDB();
    @TestVisible
    private static DocumentDB documentDBInstance = new DocumentDB();
    @TestVisible
    private static ContactDB contactDBInstance = new ContactDB();

    public static genesis__Applications__c createApplicationAndParties(
        Id opportunityId, Decimal loanAmount, Id borrowerAccountId, Id guarantorAccountId, Id guarantorContactId, User brokerUserRecord,
        String applicationType
    ) {
        genesis__Applications__c application = Applications.createApplication(borrowerAccountId, loanAmount, opportunityId, applicationType);

        if(brokerUserRecord != null) {
            application.Broker_Contact__c = brokerUserRecord.ContactId;
            application.Broker_Account__c = brokerUserRecord.AccountId;
        }

        Account accountRecord = accountDBInstance.getAccountByIds(new Set<Id> { borrowerAccountId }).get(0);
        Applications.setApplicationFieldsFromAccount(application, accountRecord);

        applicationDBInstance.executeInserts(application);
        PartyManager.createApplicationParties(application, borrowerAccountId, guarantorAccountId, guarantorContactId, brokerUserRecord);
        return application;
    }

    public static void handleBeforeStatusChange(Map<String, List<genesis__Applications__c>> applicationByStatusChange) {
        if(applicationByStatusChange.containsKey(Applications.STATUS_INDUSTRY_CHECK)) {
            CreditReportDetailManager.setSICCodeAndTimeInBusiness(applicationByStatusChange.get(Applications.STATUS_INDUSTRY_CHECK));
            IndustryRatingProfileManager.calculateIndustryRating(applicationByStatusChange.get(Applications.STATUS_INDUSTRY_CHECK));
        }

        if(applicationByStatusChange.containsKey(Applications.STATUS_OFFER_SENT)) {
            for(genesis__Applications__c application :applicationByStatusChange.get(Applications.STATUS_OFFER_SENT)) {
                if(application.Partner_Pricing_Secure_Link__c == null) {
                    application.Partner_Pricing_Secure_Link__c = PartnerPricingSecureLinks.generatePartnerPricingSecureLink(application.Id);
                }
            }
        }

        if(applicationByStatusChange.containsKey(Applications.STATUS_READY_TO_FUND)) {
            handleReadyToFundStatusBeforeUpdate(applicationByStatusChange.get(Applications.STATUS_READY_TO_FUND));
        }
    }

    public static void handleAfterStatusChange(Map<String, List<genesis__Applications__c>> applicationByStatusChange) {
        if(applicationByStatusChange.containsKey(Applications.STATUS_GUARANTOR_CREDIT_CHECK)) {
            new QueueableJobHandler().executeExperianConsumerQueueableJob(
                applicationByStatusChange.get(Applications.STATUS_GUARANTOR_CREDIT_CHECK)
            );
        }

        if(applicationByStatusChange.containsKey(Applications.STATUS_BUSINESS_CREDIT_CHECK)) {
            new QueueableJobHandler().executeExperianBusinessQueueableJob(
                applicationByStatusChange.get(Applications.STATUS_BUSINESS_CREDIT_CHECK)
            );
        }

        if(applicationByStatusChange.containsKey(Applications.STATUS_CAN_SCORING)) {
            new QueueableJobHandler().executeCANScoringQueueableJob(
                applicationByStatusChange.get(Applications.STATUS_CAN_SCORING)
            );
        }

        if(applicationByStatusChange.containsKey(Applications.STATUS_DATAMERCH_CHECK)) {
            new QueueableJobHandler().executeDataMerchQueueableJob(
                applicationByStatusChange.get(Applications.STATUS_DATAMERCH_CHECK)
            );
        }

        if(applicationByStatusChange.containsKey(Applications.STATUS_DATAMERCH_CHECK_FAILED)) {
            new QueueableJobHandler().executeLexisNexisBIIDQueueableJob(
                applicationByStatusChange.get(Applications.STATUS_DATAMERCH_CHECK_FAILED)
            );
        }

        if(applicationByStatusChange.containsKey(Applications.STATUS_LEXISNEXIS_CHECK)) {
            new QueueableJobHandler().executeLexisNexisBIIDQueueableJob(
                applicationByStatusChange.get(Applications.STATUS_LEXISNEXIS_CHECK)
            );
        }

        if(applicationByStatusChange.containsKey(Applications.STATUS_INDUSTRY_CHECK)) {
            handleAfterIndustryCheck(applicationByStatusChange.get(Applications.STATUS_INDUSTRY_CHECK));
        }

        if(applicationByStatusChange.containsKey(Applications.STATUS_BANK_STATEMENT_UPLOAD)) {
            new QueueableJobHandler().executeOcrolusQueueableJob(
                applicationByStatusChange.get(Applications.STATUS_BANK_STATEMENT_UPLOAD)
            );
        }

        if(applicationByStatusChange.containsKey(Applications.STATUS_PRICING_GENERATION)) {
            CANPricingDetailManager.createInitialCANPricingDetail(
                new Map<Id, genesis__Applications__c>(applicationByStatusChange.get(Applications.STATUS_PRICING_GENERATION)).keySet()
            );
        }

        if(applicationByStatusChange.containsKey(Applications.STATUS_OFFER_SENT)) {
            BusinessRuleManager.runSTIPSAndUWTasksVerificationRules(applicationByStatusChange.get(Applications.STATUS_OFFER_SENT));
            Map<Id,genesis__Applications__c> applicationOfferSentMap = new Map<Id,genesis__Applications__c>(
                applicationByStatusChange.get(Applications.STATUS_OFFER_SENT)
            );
            ApplicationManager.sendSTIPsIncompleteNotification(applicationOfferSentMap.keySet());
        }

        if(applicationByStatusChange.containsKey(Applications.STATUS_DOCS_IN)) {
            Set<Id> applicationIdsForFundingCase = new Set<Id>();

            for(genesis__Applications__c application : applicationByStatusChange.get(Applications.STATUS_DOCS_IN)){
                if(application.Type__c == GeneralConstants.LOAN_TYPE_CONCURRENT) {
                    applicationIdsForFundingCase.add(application.Id);
                }
            }
            CaseManager.createFundingReleaseCase(applicationIdsForFundingCase);
        }

        if(applicationByStatusChange.containsKey(Applications.STATUS_APPROVED)) {
           handleAfterApproved(applicationByStatusChange.get(Applications.STATUS_APPROVED));
        }

        if(applicationByStatusChange.containsKey(Applications.STATUS_DECLINED)) {
            handleAfterDecline(applicationByStatusChange.get(Applications.STATUS_DECLINED));
        }

        if(applicationByStatusChange.containsKey(Applications.STATUS_READY_TO_FUND)) {
            Map<Id, genesis__Applications__c> applicationMap = new Map<Id,genesis__Applications__c>(
                applicationByStatusChange.get(Applications.STATUS_READY_TO_FUND)
            );
            sendReadyToFundNotification(applicationMap.keySet());
        }

        if(applicationByStatusChange.containsKey(Applications.STATUS_BANK_STATEMENT_PROCESSING_FAILED)){
            OcrolusManager.requestOcrolusFileUpload(applicationByStatusChange.get(Applications.STATUS_BANK_STATEMENT_PROCESSING_FAILED));
        }
    }

    public static void setAcceptedPricingDetailsToApplication(Map<Id, genesis__Applications__c> applicationMapForPricingUpdate) {
        List<CAN_Pricing_Detail__c> canPricingDetailList = canPricingDetailDBInstance.getCANPricingListByApplicationIdsAndStatuses(
            applicationMapForPricingUpdate.keySet(), ApplicationDailyUpdates.ELIGIBLE_PRICING_STATUS
        );

        Map<Id, CAN_Pricing_Detail__c> canPricingDetailByApplicationId = new Map<Id, CAN_Pricing_Detail__c>();
        for(CAN_Pricing_Detail__c pricingDetail : canPricingDetailList) {
            if(!canPricingDetailByApplicationId.containsKey(pricingDetail.Application__c)) {
                canPricingDetailByApplicationId.put(pricingDetail.Application__c, pricingDetail);
            }
        }

        if(!canPricingDetailByApplicationId.isEmpty()) {
            for(genesis__Applications__c application : applicationMapForPricingUpdate.values()) {
                Applications.setApplicationFieldsFromPricingForApplicationFrequency(application, canPricingDetailByApplicationId.get(application.Id));
            }
        }
    }

    @future
    public static void createCommunityUser(Set<Id> contactIds) {
        CreatePortalUserManager.createCommunityUser(contactIds, GeneralConstants.MERCHANT_USER_PROFILE_NAME , null);
    }

    @future
    public static void sendSTIPsIncompleteNotification(Set<Id> applicationIds) {
        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>(
            applicationDBInstance.getApplicationsWithPricingAndSTIPListByIds(applicationIds)
        );

        List<Document> documents = documentDBInstance.getDocumentByDeveloperName(Applications.CAN_CAPITAL_LOGO);

        EmailTemplate emailTemplate;
        if(CustomSettingsHelper.generalSettings.enable_offer_email_term_matrix__c) {
            emailTemplate = GeneralHelper.emailTemplateByName.get(Applications.BROKER_CREDIT_INCOMPLETE_TERM_MATRIX);
        } else {
            emailTemplate = GeneralHelper.emailTemplateByName.get(Applications.BROKER_CREDIT_INCOMPLETE);
        }

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

        for(genesis__Applications__c application :applicationMap.values()) {
            try {
                if(emailTemplate == null){
                    throw new ApplicationManagerException('No template found with the name brokerCreditIncomplete');
                }

                List<STIPS_Checklist__c> stipsCheckList = application.STIPS_Checklists__r;

                if((application.Type__c == GeneralConstants.LOAN_TYPE_RENEWAL && application.Auto_Renewed__c)
                    || application.CAN_Pricing_Details__r.isEmpty() || stipsCheckList.isEmpty() || !Applications.hasIncompleteSTIPS(stipsCheckList.get(0))
                    || application.Broker_Contact__c == null || application.Opportunity__c == null || !application.Opportunity__r.Offer_Notification_To_Broker__c
                ) {
                    continue;
                }

                String body;
                if(CustomSettingsHelper.generalSettings.enable_offer_email_term_matrix__c) {
                    body = Applications.buildApplicationEmailTermMatrixBody(emailTemplate.HtmlValue, application, documents, stipsCheckList.get(0));
                } else {
                    body = Applications.buildApplicationDetailsEmailBody(emailTemplate.HtmlValue, application, documents, stipsCheckList.get(0));
                }

                String subject = Applications.buildApplicationDetailsEmailSubject(emailTemplate.Subject, application);

                List<String> toAddresses = new List<String>();
                List<String> ccAddresses = new List<String>();
                String salesRepEmailAddress = application.Sales_Rep__c != null && application.Sales_Rep__r.Email != null? application.Sales_Rep__r.Email : null;

                Map<String, List<String>> stringToEmailAddressesMap = Applications.addEmailAddressToBrokerNotification(application, salesRepEmailAddress);

                if(stringToEmailAddressesMap.get('toAddresses') != null) {
                    toAddresses.addAll(stringToEmailAddressesMap.get('toAddresses'));
                }
                if(stringToEmailAddressesMap.get('ccAddresses') != null) {
                    ccAddresses.addAll(stringToEmailAddressesMap.get('ccAddresses'));
                }

                OrgWideEmailAddress orgWideAddress = GeneralHelper.orgWideEmailAddressByEmail.get(GeneralConstants.CAN_PARTNER_SALES_EMAIL_ADDRESS);

                emailList.add(Emails.getEmailMessageSetup(
                    toAddresses, ccAddresses, CustomMetaDataHelper.defaultGeneralSetting.From_Email__c, subject, body, true, null, orgWideAddress
                ));

            } catch(Exception e){
                Error_Log__c errorLog = ErrorLogs.createErrorLog(
                    'STIPS Email Notification Failed', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                    application.Id, false
                );
                errorLogDBInstance.addInsert(errorLog);
            }
        }

        try {
            emailDBInstance.sendBulkEmail(emailList);
        } catch(Exception e){
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'STIPS Email Notification Failed', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                null, false
            );
            errorLogDBInstance.addInsert(errorLog);
        }

        errorLogDBInstance.executeInserts();
    }

    private static void handleAfterIndustryCheck(List<genesis__Applications__c> listOfApplications) {
        List<genesis__Applications__c> applicationsToIndustryCheck = new List<genesis__Applications__c>();
        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>(listOfApplications);

        List<genesis__Applications__c> applicationListToDeclineCheck =
            BusinessRuleManager.runIndustryCheckDeclineRulesAndUWTask(listOfApplications);

        for (genesis__Applications__c application : applicationListToDeclineCheck) {
            if(application.genesis__Status__c == Applications.STATUS_DECLINED) {
                genesis__Applications__c applicationShell = new genesis__Applications__c(Id = application.Id);
                applicationShell.genesis__Status__c = Applications.STATUS_DECLINED;
                applicationShell.Decline_Reasons__c = application.Decline_Reasons__c;
                applicationDBInstance.addUpdate(applicationShell);
            } else {
                applicationsToIndustryCheck.add(applicationMap.get(application.Id));
            }
        }
        applicationDBInstance.executeUpdates();

        if(!applicationsToIndustryCheck.isEmpty()) {
            new QueueableJobHandler().executeLexisNexisFraudScoreQueueableJob(applicationsToIndustryCheck);
        }
    }

    public static void handleRenewalAndConcurrentApplicationsBeforeUpdate(Map<Id, genesis__Applications__c> renewalAndConcurrentContractIdToApplication) {
        Map<Id, loan__Loan_Account__c> renewalLoanAccountMap = new Map<Id, loan__Loan_Account__c>(
            clContractDBInstance.getLoanAccountsByIds(renewalAndConcurrentContractIdToApplication.keySet())
        );
        Map<Id, Id> existingApplicationIdToRenewalApplicationId = new Map<Id, Id>();

        for(Id contractId : renewalAndConcurrentContractIdToApplication.keySet()) {
            genesis__Applications__c application = renewalAndConcurrentContractIdToApplication.get(contractId);
            loan__Loan_Account__c loanAccount = renewalLoanAccountMap.get(application.Renewal_Concurrent_LoanAccount__c);
            if(application.Disbursement_Id__c != null && loanAccount.Application__r.Disbursement_Id__c != null) {
                application.Disbursement_Id__c += loanAccount.Application__r.Disbursement_Id__c;
            }
            if(application.Type__c == GeneralConstants.LOAN_TYPE_CONCURRENT) {
                Applications.setConcurrentApplicationFields(application, loanAccount);
            } else if (application.Type__c == GeneralConstants.LOAN_TYPE_RENEWAL) {
                existingApplicationIdToRenewalApplicationId.put(loanAccount.Application__c, application.Id);
            }
        }

        if(!existingApplicationIdToRenewalApplicationId.isEmpty()) {
            createRenewalApplicationRelatedRecords(existingApplicationIdToRenewalApplicationId);
        }
    }

    public static void recalculateConcurrentRelatedFields(Map<Id, genesis__Applications__c> concurrentContractIdToApplication) {
        Map<Id, loan__Loan_Account__c> concurrentLoanAccountMap = new Map<Id, loan__Loan_Account__c>(
            clContractDBInstance.getLoanAccountsByIds(concurrentContractIdToApplication.keySet())
        );

        for(Id contractId : concurrentContractIdToApplication.keySet()) {
            genesis__Applications__c application = concurrentContractIdToApplication.get(contractId);
            loan__Loan_Account__c loanAccount = concurrentLoanAccountMap.get(application.Renewal_Concurrent_LoanAccount__c);
            Applications.setConcurrentApplicationFields(application, loanAccount);
        }
    }

    public static void handleAfterApproved(List<genesis__Applications__c> approvedApplicationList) {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        for(genesis__Applications__c application : approvedApplicationList) {
            accountIds.add(application.genesis__Account__c);
            contactIds.add(application.Primary_Guarantor__c);
        }

        List<genesis__Applications__c> applicationList = applicationDBInstance.getInProgressApplicationsByAccountIds(accountIds);
        for(genesis__Applications__c application :applicationList) {
            Applications.setDenialReasons(application, BusinessRules.DENIAL_REASON_ACTIVE_APPLICATION_OR_CONTRACT );
            applicationDBInstance.addUpdate(application);
        }

        if(!contactIds.isEmpty()) {
            createCommunityUser(contactIds);
        }

        applicationDBInstance.executeUpdates();
    }

    public static void createRenewalApplicationRelatedRecords(Map<Id, Id> existingApplicationIdToRenewalApplicationId) {
        for (clcommon__Party__c party : partyDBInstance.getAdditionalGuarantorsAndContactBeneficialOwnersByApplicationIds(
            existingApplicationIdToRenewalApplicationId.keySet())
        ) {
            clcommon__Party__c beneficialParty = party;
            beneficialParty.Id = null;
            beneficialParty.genesis__Application__c = existingApplicationIdToRenewalApplicationId.get(party.genesis__Application__c);
            partyDBInstance.addInsert(beneficialParty);
        }

        for (CAN_Ocrolus_Report__c originalAppOcrolusReport : ocrolusReportDBInstance.getCANOcrolusReportByApplicationIDs(
            existingApplicationIdToRenewalApplicationId.keySet())
        ) {
            CAN_Ocrolus_Report__c renewalOcrolusReport = CANOcrolusReports.createRenewalApplicationOcrolusReport(
                originalAppOcrolusReport, existingApplicationIdToRenewalApplicationId.get(originalAppOcrolusReport.Application__c)
            );
            ocrolusReportDBInstance.addInsert(renewalOcrolusReport);
        }

        partyDBInstance.executeInserts();
        ocrolusReportDBInstance.executeInserts();
    }

    public static void handleAfterDecline(List<genesis__Applications__c> declinedApplicationList) {
        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>();
        Map<String, AAN_Decline_Code_Mapping__mdt> declineCodeMap = CustomMetaDataHelper.declineCodeMap;
        for(genesis__Applications__c application :declinedApplicationList) {
            if(application.Decline_Reasons__c != null) {
                for(String declineReason :application.Decline_Reasons__c.split(';')){
                    if( (declineCodeMap.containsKey(declineReason) && declineCodeMap.get(declineReason).Apply_for_AAN__c) ||
                         (declineReason == BusinessRules.DENIAL_REASON_ACTIVE_APPLICATION_OR_CONTRACT)) {
                        applicationMap.put(application.Id, application);
                    }
                }
            }

            if(application.Auto_Renewed__c && application.Type__c == GeneralConstants.LOAN_TYPE_RENEWAL){
                loan__Loan_Account__c loanAccount = new loan__Loan_Account__c(Id = application.Renewal_Concurrent_LoanAccount__c);
                Account borrowerAccount = new Account (Id = application.genesis__Account__c);
                Applications.setContractAndAccountFieldsOnRenewalApplicationDecline(application, loanAccount, borrowerAccount);
                accountDBInstance.addUpdate(borrowerAccount);
                if(loanAccount.Id != null) {
                    clContractDBInstance.addUpdate(loanAccount);
                }
            }
        }

        if(!applicationMap.isEmpty()) {
            sendDeclineNotificationToBroker(applicationMap);
        }
        accountDBInstance.executeUpdates();
        clContractDBInstance.executeUpdates();
    }

    @TestVisible
    private static void sendDeclineNotificationToBroker(Map<Id, genesis__Applications__c> applicationMapToSendEmail) {
        List<genesis__Applications__c> applicationsToSendEmail = applicationDBInstance.getApplicationsByIds(applicationMapToSendEmail.keySet());
        EmailTemplate emailTemplate = GeneralHelper.emailTemplateByName.get(Applications.BROKER_DECLINE_NOTIFICATION);
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(genesis__Applications__c application :applicationsToSendEmail) {
            try {
                if(emailTemplate == null){
                    throw new ApplicationManagerException('No template found with the name Broker Decline Notification');
                }

                String body = emailTemplate.HtmlValue;
                String subject = emailTemplate.Subject;
                body = Applications.buildBrokerDeclineTemplateBody(application, body);
                subject = Applications.buildBrokerDeclineTemplateSubject(application, subject);
                List<String> toAddresses = new List<String>();
                List<String> ccAddresses = new List<String>();
                String salesRepEmailAddress = application.Sales_Rep__c != null && application.Sales_Rep__r.Email != null? application.Sales_Rep__r.Email : null;

                if((application.Type__c == GeneralConstants.LOAN_TYPE_RENEWAL && application.Auto_Renewed__c) || application.Broker_Contact__c == null) {
                    continue;
                }

                Map<String, List<String>> stringToEmailAddressesMap = Applications.addEmailAddressToBrokerNotification(application, salesRepEmailAddress);

                if(stringToEmailAddressesMap.get('toAddresses') != null) {
                    toAddresses.addAll(stringToEmailAddressesMap.get('toAddresses'));
                }
                if(stringToEmailAddressesMap.get('ccAddresses') != null) {
                    ccAddresses.addAll(stringToEmailAddressesMap.get('ccAddresses'));
                    if (body.contains(BusinessRules.DENIAL_REASON_ACTIVE_APPLICATION_OR_CONTRACT)){
                        if (application.genesis__Account__r.Partner_Account_Manager__r.Email !=  null){
                            ccAddresses.add(application.genesis__Account__r.partner_account_manager__r.Email);
                        }
                        if (application.Opportunity__r.Owner.Email !=  null){
                            ccAddresses.add(application.Opportunity__r.Owner.Email);
                        }
                    }
                }

                OrgWideEmailAddress orgWideAddress = GeneralHelper.orgWideEmailAddressByEmail.get(GeneralConstants.CAN_APP_SUPPORT_EMAIL_ADDRESS);
                Messaging.SingleEmailMessage email = Emails.getEmailMessageSetup(
                    toAddresses, ccAddresses, CustomMetaDataHelper.defaultGeneralSetting.From_Email__c, subject, body, true, null, orgWideAddress
                );
                emailList.add(email);
            }
            catch(Exception e){
                Error_Log__c errorLog = ErrorLogs.createErrorLog(
                    'Broker Decline Notification Failed', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                    application.Id, false
                );
                errorLogDBInstance.addInsert(errorLog);
            }
        }

        try {
            emailDBInstance.sendBulkEmail(emailList);
        }
        catch(Exception e){
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'Broker Decline Notification Failed', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                null, false
            );
            errorLogDBInstance.addInsert(errorLog);
        }

        errorLogDBInstance.executeInserts();
    }

    public static void sendReadyToFundNotification(Set<Id> applicationIds) {
        List<genesis__Applications__c> applicationsToSendEmail = applicationDBInstance.getApplicationsByIds(applicationIds);
        List<Document> documents = documentDBInstance.getDocumentByDeveloperName(Applications.CAN_CAPITAL_LOGO);
        EmailTemplate emailTemplate = GeneralHelper.emailTemplateByName.get(Applications.READY_TO_FUND_NOTIFICATION);
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

        for(genesis__Applications__c application :applicationsToSendEmail) {
            try {
                if(emailTemplate == null){
                    throw new ApplicationManagerException('No template found with the name Ready To Fund Notification');
                }

                if(application.Type__c == GeneralConstants.LOAN_TYPE_RENEWAL && (!application.Broker_Contact__r.Account.renewal_funding_notice__c ||
                   application.Broker_Contact__r.Account.Type != Accounts.BROKER) )
                {
                    continue;
                }

                String body = Applications.buildReadyToFundEmailBody(emailTemplate.HtmlValue, application, documents);
                String subject = Applications.buildReadyToFundEmailSubject(emailTemplate.Subject, application);

                List<String> toAddresses = new List<String>();
                List<String> ccAddresses = new List<String>();
                String salesRepEmailAddress = application.Sales_Rep__c != null && application.Sales_Rep__r.Email != null? application.Sales_Rep__r.Email : null;

                if(application.Broker_Contact__c != null && application.Broker_Contact__r.Email != null) {
                    toAddresses.add(application.Broker_Contact__r.Email);
                    if(salesRepEmailAddress != null) {
                        ccAddresses.add(salesRepEmailAddress);
                    }
                    if(application.Broker_Contact__r.Account != null && application.Broker_Contact__r.Account.Email_cc__c != null) {
                        for(String additionalEmail :application.Broker_Contact__r.Account.Email_cc__c.split(',')) {
                            ccAddresses.add(additionalEmail);
                        }
                    }

                    OrgWideEmailAddress orgWideAddress = GeneralHelper.orgWideEmailAddressByEmail.get(GeneralConstants.CAN_NO_REPLY_EMAIL_ADDRESS);

                    emailList.add(Emails.getEmailMessageSetup(
                        toAddresses, ccAddresses, CustomMetaDataHelper.defaultGeneralSetting.From_Email__c, subject, body, true, null, orgWideAddress
                    ));
                }

            } catch(Exception e){
                Error_Log__c errorLog = ErrorLogs.createErrorLog(
                    'Ready To Fund Email Notification Failed', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                    application.Id, false
                );
                errorLogDBInstance.addInsert(errorLog);
            }
        }

        try {
            if(!emailList.isEmpty()) {
                emailDBInstance.sendBulkEmail(emailList);
            }
        } catch(Exception e){
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'Ready To Fund Notification Failed', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                null, false
            );
            errorLogDBInstance.addInsert(errorLog);
        }

        errorLogDBInstance.executeInserts();
    }

    public static void handleFraudFlagChanges(Set<Id> fraudFlagIdsApplicationIds) {
        Set<Id> partyBorrowerAndGuarantorIds = new Set<Id>();
        partyBorrowerAndGuarantorIds.add(OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_GUARANTOR));
        partyBorrowerAndGuarantorIds.add(OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BORROWER));

        Set<Id> nonFraudAccountsAndContactIds = new Set<Id>();

        List<clcommon__Party__c> fraudPartyList = partyDBInstance.getPartiesByApplicationIdsAndPartyTypeIds(fraudFlagIdsApplicationIds, partyBorrowerAndGuarantorIds);

        for(clcommon__Party__c party : fraudPartyList) {
            if(party.genesis__Application__r.Confirmed_Fraud_Flag__c) {
                setConfirmedFraudFlagBasedOnPartyType(party, true);
            } else {
                nonFraudAccountsAndContactIds.add(
                    (party.clcommon__Type__c == OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BORROWER))?
                    party.clcommon__Account__c : party.clcommon__Contact__c
                );
            }
        }

        Set<Id> accountOrContactIds = new Set<Id>();
        if (!nonFraudAccountsAndContactIds.isEmpty()) {
            for(clcommon__Party__c party : fraudPartyDBInstance.getFraudBorrowerANDGuarantorPartiesByAccountContactIds(nonFraudAccountsAndContactIds)) {
                Id accountOrContactId = (party.clcommon__Type__c == OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BORROWER)) ?
                    party.clcommon__Account__c : party.clcommon__Contact__c;
                if(!accountOrContactIds.contains(accountOrContactId)) {
                    accountOrContactIds.add(accountOrContactId);
                }
            }

            for(clcommon__Party__c party : fraudPartyList) {
                Id accountOrContactId = (party.clcommon__Type__c == OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BORROWER)) ?
                    party.clcommon__Account__c : party.clcommon__Contact__c;
                if (!accountOrContactIds.contains(accountOrContactId)) {
                    setConfirmedFraudFlagBasedOnPartyType(party, false);
                }
            }
        }

        accountDBInstance.executeUpdates();
        contactDBInstance.executeUpdates();
    }

    @TestVisible
    private static void setConfirmedFraudFlagBasedOnPartyType(clcommon__Party__c party, Boolean fraudFlag) {
        if (party.clcommon__Type__c == OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BORROWER)) {
            Account accountToUpdate = new Account(Id = party.clcommon__Account__c);
            accountToUpdate.Confirmed_Fraud_Flag__c =  fraudFlag;
            accountDBInstance.addUpdate(accountToUpdate);
        } else {
            Contact contactToUpdate = new Contact(Id = party.clcommon__Contact__c);
            contactToUpdate.Confirmed_Fraud_Flag__c =  fraudFlag;
            contactDBInstance.addUpdate(contactToUpdate);
        }
    }

    public static String runApplicationConversionRule(Id applicationId) {
        String finalResult = '';
        List<CAN_Pricing_Detail__c> canPricingDetailList = canPricingDetailDBInstance.getUnArchivedPricingDetailsByApplicationIds(new Set<Id> {applicationId});
        List<genesis__Applications__c> applicationList = applicationDBInstance.getApplicationsByIds(new Set<Id> {applicationId});
        genesis__Applications__c applicationDetail = applicationList.get(0);
        String minAndMaxPricingKey = applicationDetail.SC4_Tier__c + applicationDetail.genesis__Term__c;

        if(canPricingDetailList.isEmpty()) {
            finalResult = CANPricingDetails.NO_ACTIVE_PRICING_RECORD_FOUND_ERROR_MSG + '\n';
        } else {
            CAN_Pricing_Detail__c activeCANPricingDetail = canPricingDetailList.get(0);
            if(activeCANPricingDetail.Status__c != CANPricingDetails.STATUS_ACCEPTED || !activeCANPricingDetail.term_audit_complete__c) {
                finalResult = finalResult + ' -' + CANPricingDetails.TERM_AUDIT_NO_COMPLETE_ERROR_MSG + '\n';
            }
        }

        if(OriginationHelper.minAndMaxPricingByCriteria.containsKey(minAndMaxPricingKey)) {
            CAN_Min_And_Max_Pricing_Detail__c minAndMaxPricing = OriginationHelper.minAndMaxPricingByCriteria.get(minAndMaxPricingKey);
            if((applicationDetail.Pricing_Factor__c + (applicationDetail.Origination_Fee_Percentage__c / 100)) > minAndMaxPricing.max_price__c){
                finalResult = finalResult + ' -' + CANPricingDetails.MAXIMUM_PRICING_FACTOR_ORIGINATION_FEE_PCT_ERROR_MSG + '\n';
            } else if(applicationDetail.Pricing_Factor__c < minAndMaxPricing.min_price__c) {
                finalResult = finalResult + ' -' + CANPricingDetails.MINIMUM_PRICING_FACTOR_ORIGINATION_FEE_PCT_ERROR_MSG + '\n';
            }
        } else {
            finalResult = finalResult + ' -' + CANPricingDetails.NO_MAX_AND_MIN_PRICING_MAPPING_FOUND_ERROR_MSG + '\n';
        }

        return finalResult == '' ? 'SUCCESS': finalResult;
    }

    @TestVisible
    private static void handleReadyToFundStatusBeforeUpdate(List<genesis__Applications__c> applicationList) {
        Map<Id, genesis__Applications__c> brokerAccountIdToApplication= new Map<Id, genesis__Applications__c>();
        for(genesis__Applications__c application : applicationList) {
            if(application.Broker_Account__c != null) {
                brokerAccountIdToApplication.put(application.Broker_Account__c, application);
            }
        }

        if(!brokerAccountIdToApplication.isEmpty()) {
            Map<Id, Account> inActiveBrokerAccountMap = new Map<Id, Account>(
                accountDBInstance.getInActiveBrokerDetailsByIds(brokerAccountIdToApplication.keySet())
            );
            for(Id inActiveBrokerId : inActiveBrokerAccountMap.keySet()) {
                CustomError.addError(
                    brokerAccountIdToApplication.get(inactiveBrokerId),
                    'Broker is not Active. Broker Commission will not be calculated properly unless Broker Account is active prior to funding Application. Please reach out to the Broker Account Owner.'
                );
            }
        }
    }

    private class ApplicationManagerException extends Exception {}
}