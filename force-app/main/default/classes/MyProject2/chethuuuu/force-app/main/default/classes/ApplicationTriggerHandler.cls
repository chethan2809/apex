public class ApplicationTriggerHandler {

    @TestVisible
    private static AccountDB accountDBInstance = new AccountDB();
    @TestVisible
    private static OpportunityDB opportunityDBInstance = new OpportunityDB();
    @TestVisible
    private static DocumentCategoryDB documentCategoryDBInstance = new DocumentCategoryDB();
    @TestVisible
    private static STIPSChecklistDB stipsChecklistDBInstance = new STIPSChecklistDB();
    @TestVisible
    private static ContactDB contactDBInstance = new ContactDB();
    @TestVisible
    private static PartyDB partyDBInstance = new PartyDB();



    public void beforeInsert(List<genesis__Applications__c> applicationList) {
        Map<Id, genesis__Applications__c> borrowerIdToApplicationForDuplicateCheck = new Map<Id, genesis__Applications__c>();
        Map<Id, genesis__Applications__c> borrowerIdToApplication = new Map<Id, genesis__Applications__c>();
        Set<Id> brokerContactIds = new Set<Id>();
        Map<Id, Account> accountMap;

        for (genesis__Applications__c application : applicationList) {
            application.Last_Status_Update_Date__c = GeneralHelper.currentSystemDateTime;
            application.genesis__Requested_Loan_Amount__c = application.genesis__Loan_Amount__c;
            if(application.Type__c == GeneralConstants.LOAN_TYPE_NEW) {
                borrowerIdToApplicationForDuplicateCheck.put(application.genesis__Account__c, application);
            }
            borrowerIdToApplication.put(application.genesis__Account__c, application);
            brokerContactIds.add(application.Broker_Contact__c);
        }

        accountMap = new Map<Id, Account> (accountDBInstance.getAccountByIds(borrowerIdToApplication.keySet()));

        if(!borrowerIdToApplicationForDuplicateCheck.isEmpty()) {
            BusinessRuleManager.declineDuplicateApplicationForBorrower(borrowerIdToApplicationForDuplicateCheck);
            BusinessRuleManager.declineDuplicateEISApplicationForBorrower(borrowerIdToApplicationForDuplicateCheck.values(), accountMap);
        }

        if(!borrowerIdToApplication.isEmpty()) {
            BusinessRuleManager.runDeclineRulesForExclusivityPeriod(borrowerIdToApplication, brokerContactIds);
            BusinessRuleManager.runAutoDeclineForSameBorrowerRules(borrowerIdToApplication.values());
        }
    }

    public void afterInsert(Map<Id, genesis__Applications__c> newApplicationMap) {
        Set<Id> opportunityIds = new Set<Id>();
        for (genesis__Applications__c application : newApplicationMap.values()) {
            opportunityIds.add(application.Opportunity__c);
            Account account = Accounts.setAccountFieldsFromApplication(application);
            accountDBInstance.addUpdate(account);
        }
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>(opportunityDBInstance.getOpportunityByIds(opportunityIds));
        for(genesis__Applications__c application : newApplicationMap.values()) {
            for(clcommon__Document_Definition__c documentDefinition :OriginationHelper.documentDefinitionList) {
                if(documentDefinition.Document_Category__c == 'Application') {
                    clcommon__Document_Category__c documentCategory = DocumentCategories.createDocumentCategory(documentDefinition);
                    documentCategory.genesis__Application__c = application.Id;
                    documentCategoryDBInstance.addInsert(documentCategory);
                }
            }
            STIPS_Checklist__c stipsChecklist = STIPSChecklists.createSTIPSChecklist(application.Id);
            stipsChecklistDBInstance.addInsert(stipsChecklist);

            Opportunity opportunityObject = Opportunities.setOpportunityStageWithApplicationStatus(application, opportunityMap.get(application.Opportunity__c));
            opportunityObject.Create_Application__c = true;
            opportunityDBInstance.addUpdate(opportunityObject);
        }

        List<genesis__Applications__c> applicationsForProcessAfterDecline = new List<genesis__Applications__c>();
        for (genesis__Applications__c application : newApplicationMap.values()) {
            if(application.genesis__Status__c == Applications.STATUS_DECLINED) {
                applicationsForProcessAfterDecline.add(application);
            }
        }

        if(!applicationsForProcessAfterDecline.isEmpty()) {
            ApplicationManager.handleAfterDecline(applicationsForProcessAfterDecline);
        }

        opportunityDBInstance.executeUpdates();
        accountDBInstance.executeUpdates();
        stipsChecklistDBInstance.executeInserts();
        documentCategoryDBInstance.executeInserts();
    }

    public void beforeUpdate(Map<Id, genesis__Applications__c> newApplicationMap, Map<Id, genesis__Applications__c> oldApplicationMap) {
        Map<String, List<genesis__Applications__c>> applicationByStatusChange = new Map<String, List<genesis__Applications__c>>();
        Map<Id, genesis__Applications__c> applicationMapForPricingUpdate = new Map<Id, genesis__Applications__c>();
        List<genesis__Applications__c> consentApplications = new List<genesis__Applications__c>();
        Map<Id, genesis__Applications__c> renewalAndConcurrentContractIdToApplication = new Map<Id, genesis__Applications__c>();
        Map<Id, genesis__Applications__c> concurrentContractIdToApplication = new Map<Id, genesis__Applications__c>();
        List<genesis__Applications__c> autoDeclineApplicationsToCheck = new List<genesis__Applications__c>();

        for(genesis__Applications__c application : newApplicationMap.values()) {
            genesis__Applications__c oldApplication = oldApplicationMap.get(application.Id);

            Applications.setFieldsOnBeforeUpdate(application, oldApplication);
            Applications.isConsentChecked(application, oldApplication, consentApplications);
            Applications.isRenewalConcurrentFieldUpdate(application, oldApplication, renewalAndConcurrentContractIdToApplication);
            Applications.handleStatusChangedOnBeforeUpdate(application, oldApplication, applicationByStatusChange);

            if(Applications.isStatusChanged(application, oldApplication) && !application.Credit_Check_Consent__c
                && application.Type__c != GeneralConstants.LOAN_TYPE_CONCURRENT
            ) {
                Applications.validateApplicationOnCreditCheck(application);
            }

            if(application.genesis__Loan_Amount__c != oldApplication.genesis__Loan_Amount__c
                && application.Type__c == GeneralConstants.LOAN_TYPE_CONCURRENT && application.Renewal_Concurrent_LoanAccount__c != null
            ) {
                concurrentContractIdToApplication.put(application.Renewal_Concurrent_LoanAccount__c, application);
            }

            if(oldApplication.genesis__Payment_Frequency__c != application.genesis__Payment_Frequency__c
                && !Applications.isStatusChanged(application, oldApplication) && application.Type__c != GeneralConstants.LOAN_TYPE_CONCURRENT
            ) {
                applicationMapForPricingUpdate.put(application.Id, application);
            }

            if(Applications.isStatusChanged(application, oldApplication)){
                autoDeclineApplicationsToCheck.add(application);
            }

        }

        if(!concurrentContractIdToApplication.isEmpty()) {
            ApplicationManager.recalculateConcurrentRelatedFields(concurrentContractIdToApplication);
        }

        if(!renewalAndConcurrentContractIdToApplication.isEmpty()) {
            ApplicationManager.handleRenewalAndConcurrentApplicationsBeforeUpdate(renewalAndConcurrentContractIdToApplication);
        }

        if(!applicationMapForPricingUpdate.isEmpty()) {
            ApplicationManager.setAcceptedPricingDetailsToApplication(applicationMapForPricingUpdate);
        }

        if(!applicationByStatusChange.isEmpty()) {
            ApplicationManager.handleBeforeStatusChange(applicationByStatusChange);
        }

        if(!consentApplications.isEmpty()) {
            BusinessRuleManager.runGeneralDeclineRules(consentApplications);
            UnderWriterTaskManager.createUnderWriterTasks(consentApplications);
        }
        if (!autoDeclineApplicationsToCheck.isEmpty()){
            BusinessRuleManager.runAutoDeclineForSameBorrowerRules(autoDeclineApplicationsToCheck);
        }
    }

    public void afterUpdate(Map<Id, genesis__Applications__c> newApplicationMap, Map<Id, genesis__Applications__c> oldApplicationMap) {
        Map<String, List<genesis__Applications__c>> applicationByStatusChange = new Map<String, List<genesis__Applications__c>>();

        Set<Id> opportunityIds = new Set<Id>();
        Set<Id> applicationFraudFlagIds = new Set<Id>();

        for(genesis__Applications__c application : newApplicationMap.values()) {
            genesis__Applications__c oldApplication = oldApplicationMap.get(application.Id);
            if(Applications.isStatusChanged(application, oldApplication)) {
                opportunityIds.add(application.Opportunity__c);
            }
        }

        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>(opportunityDBInstance.getOpportunityByIds(opportunityIds));
        Map<Id, Opportunity> opportunityMapForUpdate = new Map<Id, Opportunity>();
        for(genesis__Applications__c application : newApplicationMap.values()) {
            genesis__Applications__c oldApplication = oldApplicationMap.get(application.Id);
            if(Applications.isStatusChanged(application, oldApplication)) {
                Opportunity applicationOpportunity = Opportunities.setOpportunityStageWithApplicationStatus(application, opportunityMap.get(application.Opportunity__c));
                if(application.genesis__Status__c == Applications.STATUS_APPROVED) {
                    applicationOpportunity.Amount = application.genesis__Loan_Amount__c;
                }
                if(application.genesis__Status__c == Applications.STATUS_INDUSTRY_CHECK) {
                    Account accountRecord = Accounts.setSICCodeFromApplication(application);
                    accountDBInstance.addUpdate(accountRecord);
                }

                opportunityMapForUpdate.put(applicationOpportunity.Id, applicationOpportunity);

                Applications.groupApplicationByStatusChange(application, applicationByStatusChange);
            }

            if(application.Sales_Rep__c != null && application.Sales_Rep__c != oldApplication.Sales_Rep__c) {
                if(opportunityMapForUpdate.containsKey(application.Opportunity__c)) {
                    Opportunity opportunityObject = opportunityMapForUpdate.get(application.Opportunity__c);
                    opportunityObject.OwnerID = application.Sales_Rep__c;
                } else {
                    Opportunity opportunityObject = new Opportunity(Id = application.Opportunity__c);
                    opportunityObject.OwnerID = application.Sales_Rep__c;
                    opportunityMapForUpdate.put(opportunityObject.Id, opportunityObject);
                }
            }

            if(application.Confirmed_Fraud_Flag__c != oldApplication.Confirmed_Fraud_Flag__c) {
                applicationFraudFlagIds.add(application.Id);
            }

        }

        if (!applicationFraudFlagIds.isEmpty()) {
            ApplicationManager.handleFraudFlagChanges(applicationFraudFlagIds);
        }

        opportunityDBInstance.addUpdates(opportunityMapForUpdate.values()).executeUpdates();
        accountDBInstance.executeUpdates();
        ApplicationManager.handleAfterStatusChange(applicationByStatusChange);
    }

    private class ApplicationTriggerHandlerException extends Exception {}
}