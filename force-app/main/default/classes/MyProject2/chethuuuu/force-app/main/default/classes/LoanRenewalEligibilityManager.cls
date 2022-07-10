public class LoanRenewalEligibilityManager {
    @TestVisible
    private static ClContractDB clContractDBInstance = new ClContractDB();
    @TestVisible
    private static OpportunityDB opportunityDBInstance = new OpportunityDB();
    @TestVisible
    private static UserDB userDBInstance = new UserDB();
    @TestVisible
    private static ApplicationDB applicationDBInstance = new ApplicationDB();

    public static void createRenewalOpportunity(List<loan__Loan_Account__c> contractList) {
        Map<Id, Id> accountToBrokerContactsId = new Map<Id, Id>();
        List<Opportunity> opportunityList = new List<Opportunity>();

        for(loan__Loan_Account__c loanAccount : contractList) {
            if(loanAccount.Application__c == null) {
                throw new LoanRenewalEligibilityManagerException(
                    'There was no Originate Application found for this Loan Account ' + loanAccount.Name
                );
            }

            if(loanAccount.Broker_Contact__c != null) {
                accountToBrokerContactsId.put(loanAccount.loan__Account__c, loanAccount.Broker_Contact__c);
            }

            Opportunity opportunityRecord = new Opportunity();
            opportunityRecord.Name = loanAccount.loan__Account__r.Name;
            opportunityRecord.StageName = PortalConstants.LEAD_INITIAL_STAGE_NAME;
            opportunityRecord.CloseDate = GeneralHelper.currentSystemDate.addYears(1);
            opportunityRecord.AccountId = loanAccount.loan__Account__c;
            opportunityRecord.Requested_Loan_Amount__c = loanAccount.loan__Principal_Paid__c;
            opportunityRecord.Primary_Contact__c = loanAccount.Application__r.Primary_Guarantor__c;
            opportunityRecord.Sub_Status__c = 'Score Pending';
            opportunityRecord.Type = GeneralConstants.LOAN_TYPE_RENEWAL;
            opportunityRecord.Refinanced_CL_Contract__c = loanAccount.Id;
            opportunityRecord.OwnerId = loanAccount.Application__r.Sales_Rep__c;
            opportunityRecord.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GeneralConstants.MERCHANT).getRecordTypeId();

            if(loanAccount.Broker_Contact__c != null) {
                accountToBrokerContactsId.put(loanAccount.loan__Account__c, loanAccount.Broker_Contact__c);
                opportunityRecord.Broker_Contact__c = loanAccount.Broker_Contact__c;
                opportunityRecord.Broker_Account__c = loanAccount.Broker_Contact__r.AccountId;
            }

            opportunityList.add(opportunityRecord);

            loanAccount.Auto_Renewed__c = true;
            clContractDBInstance.addUpdate(loanAccount);
        }

        opportunityDBInstance.addInserts(opportunityList).executeInserts();
        createRenewalApplicationAndParties(opportunityList, accountToBrokerContactsId, new Map<Id, loan__Loan_Account__c>(contractList));
        clContractDBInstance.executeUpdates();
    }

    private static void createRenewalApplicationAndParties(
        List<Opportunity> opportunityList, Map<Id, Id> accountToBrokerContactsId, Map<Id, loan__Loan_Account__c> loanAccountMap
    ) {
        Map<Id, User> contactIdToUser = new Map<Id, User>();
        if(!accountToBrokerContactsId.isEmpty()) {
            for(User userObj : userDBInstance.getUsersByContactIds(new Set<Id> (accountToBrokerContactsId.values()))) {
                contactIdToUser.put(userObj.ContactId, userObj);
            }
        }

        for(Opportunity opportunityRecord : opportunityList) {
            User brokerUserRecord;
            if(accountToBrokerContactsId.containsKey(opportunityRecord.AccountId)) {
                brokerUserRecord = contactIdToUser.get(accountToBrokerContactsId.get(opportunityRecord.AccountId));
            }

            loan__Loan_Account__c loanAccount = loanAccountMap.get(opportunityRecord.Refinanced_CL_Contract__c);

            genesis__Applications__c application = ApplicationManager.createApplicationAndParties(
                opportunityRecord.Id, opportunityRecord.Requested_Loan_Amount__c, opportunityRecord.AccountId,
                loanAccount.Application__r.Primary_Guarantor__r.AccountId, opportunityRecord.Primary_Contact__c, brokerUserRecord,
                GeneralConstants.LOAN_TYPE_RENEWAL
            );
            genesis__Applications__c applicationShell = new genesis__Applications__c(Id = application.Id);
            Applications.setRenewalApplicationFieldsFromLoanAccount(applicationShell, loanAccount);
            applicationShell.Credit_Check_Consent__c = true;
            applicationShell.Auto_Renewed__c = true;
            applicationDBInstance.addUpdate(applicationShell);
        }

        applicationDBInstance.executeUpdates();
    }

    private class LoanRenewalEligibilityManagerException extends Exception {}
}