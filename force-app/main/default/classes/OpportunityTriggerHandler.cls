public class OpportunityTriggerHandler
{
    @TestVisible
    private static AccountDB accountDBInstance = new AccountDB();
    @TestVisible
    private static ApplicationDB applicationDBInstance = new ApplicationDB();
    @TestVisible
    private static CLContractDB clContractDBInstance = new CLContractDB();

    public void beforeInsert(List<Opportunity> newOpportunityList) {
        Set<Id> opportunityAccountIds = new Set<Id>();
        for (Opportunity opportunityAccount : newOpportunityList) {
            opportunityAccountIds.add(opportunityAccount.AccountId);
        }
        if(!opportunityAccountIds.isEmpty()) {
            Map<Id, loan__Loan_Account__c> loanContractByAccountId = new Map<Id, loan__Loan_Account__c>();
            for(loan__Loan_Account__c loanAccount : clContractDBInstance.getRecentLoanAccountsByOppAccountIds(opportunityAccountIds)) {
                loanContractByAccountId.put(loanAccount.loan__Account__c, loanAccount);
            }
            Map<Id, Account> accountIds = new Map<Id, Account>();
            for(Account account : accountDBInstance.getAccountByIds(opportunityAccountIds)) {
                accountIds.put(account.Id, account);
            }

            for(Opportunity opportunity : newOpportunityList) {
                if(!accountIds.isEmpty()) {
                    Account account = accountIds.get(opportunity.AccountId);
                    opportunity.LeadSource = opportunity.LeadSource != null ? opportunity.LeadSource : account.AccountSource;
                    if(account.Is_Exclusivity__c) {
                        opportunity.Broker_Contact__c = opportunity.Broker_Contact__c != null ? opportunity.Broker_Contact__c : account.Broker_Contact__c;
                        opportunity.Broker_Account__c = opportunity.Broker_Account__c != null ? opportunity.Broker_Account__c : account.Broker_Account__c;
                    }
                }
                if(!loanContractByAccountId.isEmpty()) {
                    loan__Loan_Account__c loanAccount = loanContractByAccountId.get(opportunity.AccountId);
                    opportunity.Refinanced_CL_Contract__c = loanAccount.Id;
                    opportunity.Concurrent_Eligible_Amount__c = loanAccount.Concurrent_Eligible_Amount__c;
                }
                if(opportunity.Type == GeneralConstants.LOAN_TYPE_NEW) {
                    if(opportunity.Broker_Contact__c != null) {
                        opportunity.Offer_Notification_To_Broker__c = true;
                        opportunity.Offer_Notification_To_Guarantor__c = false;
                    } else {
                        opportunity.Offer_Notification_To_Broker__c = false;
                        opportunity.Offer_Notification_To_Guarantor__c = true;
                    }
                }
            }
        }
    }

    public void afterInsert(Map<Id, Opportunity> newOpportunityMap) {
        OpportunityManager.createApplication(newOpportunityMap);
    }

    public void beforeUpdate(Map<Id, Opportunity> newOpportunityMap, Map<Id, Opportunity> oldOpportunityMap) {
        for (Opportunity newOpportunity : newOpportunityMap.values()) {
            Opportunity oldOpportunity = oldOpportunityMap.get(newOpportunity.Id);
            if(newOpportunity.Type == GeneralConstants.LOAN_TYPE_NEW &&
                newOpportunity.Broker_Contact__c != oldOpportunity.Broker_Contact__c
            ) {
                if(newOpportunity.Broker_Contact__c != null) {
                    newOpportunity.Offer_Notification_To_Broker__c = true;
                    newOpportunity.Offer_Notification_To_Guarantor__c = false;
                } else {
                    newOpportunity.Offer_Notification_To_Broker__c = false;
                    newOpportunity.Offer_Notification_To_Guarantor__c = true;
                }
            }
        }
    }

    public void afterUpdate(Map<Id, Opportunity> newOpportunityMap, Map<Id, Opportunity> oldOpportunityMap) {
        OpportunityManager.createApplication(newOpportunityMap);
        Map<Id, Opportunity> closedOpportunityIdMap = new Map<Id, Opportunity>();
        Map<Id, Id> opportunityOwnerIDMap = new Map<Id, Id>();
        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>();

        for (Opportunity newOpportunity : newOpportunityMap.values()) {
            Opportunity oldOpportunity = oldOpportunityMap.get(newOpportunity.Id);
            if(Opportunities.isStageChanged(newOpportunity, oldOpportunity) && newOpportunity.StageName == 'Closed Lost') {
                closedOpportunityIdMap.put(newOpportunity.Id, newOpportunity);
            }
            if(newOpportunity.OwnerId != oldOpportunity.OwnerId) {
                opportunityOwnerIDMap.put(newOpportunity.Id,newOpportunity.OwnerId);
            }
        }

        if(!closedOpportunityIdMap.isEmpty()) {
            List<genesis__Applications__c> applicationList = applicationDBInstance.getActiveApplicationsByOpportunityIds(closedOpportunityIdMap.keySet());
            for(genesis__Applications__c application : applicationList) {
                application.genesis__Status__c = Applications.STATUS_DECLINED;
                if(closedOpportunityIdMap.get(application.Opportunity__c).Sub_Status__c == 'Customer Not Interested') {
                    application.Decline_Reasons__c = BusinessRules.DENIAL_REASON_CUSTOMER_NOT_INTERESTED;
                }
                applicationMap.put(application.Id, application);
            }
        }

        if(!opportunityOwnerIDMap.isEmpty()){
            List<genesis__Applications__c> applicationListbyOppID = applicationDBInstance.getApplicationsByOpportunityIds(opportunityOwnerIDMap.keySet());
            for(genesis__Applications__c applicationRecord : applicationListbyOppID) {
                if(opportunityOwnerIDMap.containsKey(applicationRecord.Opportunity__c) &&
                    applicationRecord.Sales_Rep__c != opportunityOwnerIDMap.get(applicationRecord.Opportunity__c)
                ) {
                    if(applicationMap.containsKey(applicationRecord.Id)) {
                        applicationRecord = applicationMap.get(applicationRecord.Id);
                        applicationRecord.Sales_Rep__c = opportunityOwnerIDMap.get(applicationRecord.Opportunity__c);
                    } else {
                        applicationRecord.Sales_Rep__c = opportunityOwnerIDMap.get(applicationRecord.Opportunity__c);
                        applicationMap.put(applicationRecord.Id, applicationRecord);
                    }
                }
            }
        }
        applicationDBInstance.addUpdates(applicationMap.values()).executeUpdates();
    }
}