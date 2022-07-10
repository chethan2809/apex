public class Opportunities {

    @TestVisible
    private static Map<String, String> appStatusToOpportunityStage {
        get {
            if(appStatusToOpportunityStage == null) {
                appStatusToOpportunityStage = new Map<String, String>();
                appStatusToOpportunityStage.put(Applications.STATUS_NEW_ENTERED, 'In Market');
                appStatusToOpportunityStage.put(Applications.STATUS_APPLICATION_CREATED, 'App Submitted');
                appStatusToOpportunityStage.put(Applications.STATUS_GUARANTOR_CREDIT_CHECK, 'App Submitted');
                appStatusToOpportunityStage.put(Applications.STATUS_GUARANTOR_CREDIT_CHECK_FAILED, 'App Submitted');
                appStatusToOpportunityStage.put(Applications.STATUS_BUSINESS_CREDIT_CHECK, 'App Submitted');
                appStatusToOpportunityStage.put(Applications.STATUS_BUSINESS_CREDIT_CHECK_FAILED, 'App Submitted');
                appStatusToOpportunityStage.put(Applications.STATUS_LEXISNEXIS_CHECK, 'App Submitted');
                appStatusToOpportunityStage.put(Applications.STATUS_LEXISNEXIS_CHECK_FAILED, 'App Submitted');
                appStatusToOpportunityStage.put(Applications.STATUS_CAN_SCORING, 'App Submitted');
                appStatusToOpportunityStage.put(Applications.STATUS_CAN_SCORING_FAILED, 'App Submitted');
                appStatusToOpportunityStage.put(Applications.STATUS_INDUSTRY_CHECK, 'App Submitted');
                appStatusToOpportunityStage.put(Applications.STATUS_INDUSTRY_CHECK_FAILED, 'App Submitted');
                appStatusToOpportunityStage.put(Applications.STATUS_BANK_STATEMENT_UPLOAD, 'App Submitted');
                appStatusToOpportunityStage.put(Applications.STATUS_BANK_STATEMENT_UPLOAD_FAILED, 'App Submitted');
                appStatusToOpportunityStage.put(Applications.STATUS_BANK_STATEMENT_PROCESSING, 'App Submitted');
                appStatusToOpportunityStage.put(Applications.STATUS_BANK_STATEMENT_PROCESSING_FAILED, 'App Submitted');
                appStatusToOpportunityStage.put(Applications.STATUS_PRICING_GENERATION, 'App Submitted');
                appStatusToOpportunityStage.put(Applications.STATUS_PRICING_GENERATION_FAILED, 'App Submitted');
                appStatusToOpportunityStage.put(Applications.STATUS_OFFER_SENT, 'Approved');
                appStatusToOpportunityStage.put(Applications.STATUS_UW_EXCEPTION_REVIEW, 'Approved');
                appStatusToOpportunityStage.put(Applications.STATUS_OFFER_ACCEPTED, 'Approved');
                appStatusToOpportunityStage.put(Applications.STATUS_DOCS_OUT, 'Docs Out');
                appStatusToOpportunityStage.put(Applications.STATUS_DOCS_IN, 'Docs In');
                appStatusToOpportunityStage.put(Applications.STATUS_DUE_DILIGENCE, 'Docs In');
                appStatusToOpportunityStage.put(Applications.STATUS_PENDING_DOCS, 'Docs In');
                appStatusToOpportunityStage.put(Applications.STATUS_MANAGER_ESCALATION, 'Docs In');
                appStatusToOpportunityStage.put(Applications.STATUS_READY_TO_FUND, 'Ready To Fund');
                appStatusToOpportunityStage.put(Applications.STATUS_APPROVED, 'Closed Won');
                appStatusToOpportunityStage.put(Applications.STATUS_DECLINED, 'Closed Lost');
            }
            return appStatusToOpportunityStage;
        }
        set;
    }

    @TestVisible
    private static Map<String, String> appStatusToOpportunitySubStatus {
        get {
            if(appStatusToOpportunitySubStatus == null) {
                appStatusToOpportunitySubStatus = new Map<String, String>();
                appStatusToOpportunitySubStatus.put(Applications.STATUS_NEW_ENTERED, 'In Market- Now');
                appStatusToOpportunitySubStatus.put(Applications.STATUS_APPLICATION_CREATED, 'Score Pending');
                appStatusToOpportunitySubStatus.put(Applications.STATUS_GUARANTOR_CREDIT_CHECK, 'Score Pending');
                appStatusToOpportunitySubStatus.put(Applications.STATUS_GUARANTOR_CREDIT_CHECK_FAILED, 'Scoring Error');
                appStatusToOpportunitySubStatus.put(Applications.STATUS_BUSINESS_CREDIT_CHECK, 'Score Pending');
                appStatusToOpportunitySubStatus.put(Applications.STATUS_BUSINESS_CREDIT_CHECK_FAILED, 'Scoring Error');
                appStatusToOpportunitySubStatus.put(Applications.STATUS_LEXISNEXIS_CHECK, 'Score Pending');
                appStatusToOpportunitySubStatus.put(Applications.STATUS_LEXISNEXIS_CHECK_FAILED, 'Scoring Error');
                appStatusToOpportunitySubStatus.put(Applications.STATUS_CAN_SCORING, 'Score Pending');
                appStatusToOpportunitySubStatus.put(Applications.STATUS_CAN_SCORING_FAILED, 'Scoring Error');
                appStatusToOpportunitySubStatus.put(Applications.STATUS_INDUSTRY_CHECK, 'Score Pending');
                appStatusToOpportunitySubStatus.put(Applications.STATUS_INDUSTRY_CHECK_FAILED, 'Scoring Error');
                appStatusToOpportunitySubStatus.put(Applications.STATUS_BANK_STATEMENT_UPLOAD, 'Score Pending');
                appStatusToOpportunitySubStatus.put(Applications.STATUS_BANK_STATEMENT_UPLOAD_FAILED, 'Scoring Error');
                appStatusToOpportunitySubStatus.put(Applications.STATUS_BANK_STATEMENT_PROCESSING, 'Bank Statement Processing');
                appStatusToOpportunitySubStatus.put(Applications.STATUS_BANK_STATEMENT_PROCESSING_FAILED, 'Scoring Error');
                appStatusToOpportunitySubStatus.put(Applications.STATUS_OFFER_SENT, 'Options Available');
                appStatusToOpportunitySubStatus.put(Applications.STATUS_OFFER_ACCEPTED, 'Offer Accepted');
                appStatusToOpportunitySubStatus.put(Applications.STATUS_DOCS_OUT, 'Docs Out');
                appStatusToOpportunitySubStatus.put(Applications.STATUS_DOCS_IN, 'STIPS Not Cleared');
                appStatusToOpportunitySubStatus.put(Applications.STATUS_DUE_DILIGENCE, 'STIPS Not Cleared');
                appStatusToOpportunitySubStatus.put(Applications.STATUS_PENDING_DOCS, 'STIPS Not Cleared');
                appStatusToOpportunitySubStatus.put(Applications.STATUS_MANAGER_ESCALATION, 'STIPS Not Cleared');
                appStatusToOpportunitySubStatus.put(Applications.STATUS_READY_TO_FUND, 'Ready To Fund');
                appStatusToOpportunitySubStatus.put(Applications.STATUS_APPROVED, 'Closed Won');
                appStatusToOpportunitySubStatus.put(Applications.STATUS_DECLINED, 'Policy Decline');
            }
            return appStatusToOpportunitySubStatus;
        }
        set;
    }

    public static Opportunity setOpportunityStageWithApplicationStatus(genesis__Applications__c application, Opportunity opportunity) {
        Opportunity opportunityObject = new Opportunity(Id = application.Opportunity__c);
        if(appStatusToOpportunityStage.containsKey(application.genesis__Status__c)) {
            opportunityObject.StageName = appStatusToOpportunityStage.get(application.genesis__Status__c);
        }

        if(appStatusToOpportunitySubStatus.containsKey(application.genesis__Status__c)) {
            if(application.Decline_Reasons__c != null && application.Decline_Reasons__c.split(';').contains('Closed Expired')) {
                opportunityObject.Sub_Status__c = 'Customer Not Interested';
            } else if(application.Decline_Reasons__c != null && application.Decline_Reasons__c.split(';').contains('Offers Expired')) {
                opportunityObject.Sub_Status__c = 'Offers Expired';
            } else if(appStatusToOpportunityStage.get(application.genesis__Status__c) == 'Closed Lost' &&
                opportunity.StageName == 'Closed Lost') {
                opportunityObject.Sub_Status__c = opportunity.Sub_Status__c;
            } else {
                opportunityObject.Sub_Status__c = appStatusToOpportunitySubStatus.get(application.genesis__Status__c);
            }
        }
        return opportunityObject;
    }

    public static Opportunity createOpportunity(Lead lead, Account borrowerAccount)
    {
        Opportunity opportunity = new Opportunity();
        opportunity.Id = lead.ConvertedOpportunityId;
        opportunity.AccountId = borrowerAccount.Id;
        opportunity.Requested_Loan_Amount__c = lead.How_much_do_you_Need__c;
        if(lead.LeadSource == PortalConstants.BROKER_PORTAL ||
            lead.LeadSource == PortalConstants.MERCHANT_PORTAL ||
            lead.LeadSource == PortalConstants.PARTNER_API)
        {
            opportunity.LeadSource = lead.LeadSource;
        }
        if(lead.Lead_Type__c == Leads.MERCHANT)
        {
            opportunity.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GeneralConstants.MERCHANT).getRecordTypeId();
            opportunity.StageName = 'App Submitted';
            opportunity.Sub_Status__c = 'Score Pending';
            opportunity.Type = GeneralConstants.LOAN_TYPE_NEW;
        }
        else if(lead.Lead_Type__c == Leads.BROKER)
        {
            opportunity.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GeneralConstants.BROKER).getRecordTypeId();
            opportunity.StageName = 'NEW';
        }
        return opportunity;
    }

    public static Boolean isStageChanged(Opportunity newOpportunity, Opportunity oldOpportunity) {
        return (newOpportunity.StageName != oldOpportunity.StageName);
    }

    public static Opportunity getOpportunityRecordForPortal(Id borrowerAccountId, Id guarantorContactId) {
        Opportunity oppRecord = new Opportunity();
        oppRecord.AccountId = borrowerAccountId;
        oppRecord.Primary_Contact__c = guarantorContactId;
        oppRecord.ContactId = guarantorContactId;
        oppRecord.StageName = PortalConstants.LEAD_STAGE_APP_SUBMITTED;
        oppRecord.Sub_Status__c = PortalConstants.LEAD_SUB_STATUS_SCORE_PENDING;
        oppRecord.CloseDate = System.today().addMonths(2).addDays(19);
        oppRecord.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        return oppRecord;
    }

    private class OpportunitiesException extends Exception {}
}