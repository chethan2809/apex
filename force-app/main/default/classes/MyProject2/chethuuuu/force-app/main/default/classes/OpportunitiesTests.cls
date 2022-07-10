@isTest
private class OpportunitiesTests {

    @isTest
    static void appStatusToOpportunityStatusValues(){

        Test.startTest();
            Map<String, String> appStatuses = Opportunities.appStatusToOpportunityStage;
        Test.stopTest();

        System.assert(appStatuses != null);
        System.assertEquals('In Market', appStatuses.get('NEW ENTERED'));
    }

    @isTest
    static void appStatusToOpportunitySubStatusValues(){

        Test.startTest();
            Map<String, String> appStatuses = Opportunities.appStatusToOpportunitySubStatus;
        Test.stopTest();

        System.assert(appStatuses != null);
        System.assertEquals('Score Pending', appStatuses.get('APPLICATION CREATED'));
    }

    @isTest
    static void setOpportunityStageWithApplicationStatuses(){

        Id opportunityId = TestUtility.getFakeId(Opportunity.getSObjectType());
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id contactId = TestUtility.getFakeId(Contact.getSObjectType());

        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Status__c = 'BANK STATEMENT PROCESSING';
        application.Opportunity__c = OpportunityId;

        Opportunity newOpportunity = new Opportunity();
        newOpportunity.StageName = 'App Submitted';
        newOpportunity.Sub_Status__c = 'Bank Statement Processing';

        Test.startTest();
            Opportunity opportunityObject = Opportunities.setOpportunityStageWithApplicationStatus(application, newOpportunity);
            Opportunity opportunityForPortal = Opportunities.getOpportunityRecordForPortal(accountId, contactId);
        Test.stopTest();

        System.assert(opportunityObject != null);
        System.assert(opportunityForPortal != null);
        System.assertEquals(accountId, opportunityForPortal.AccountId);
        System.assertEquals(contactId, opportunityForPortal.Primary_Contact__c);
        System.assertEquals('Bank Statement Processing', opportunityObject.Sub_Status__c);
        System.assertEquals('App Submitted', opportunityObject.StageName);
    }

    @isTest
    static void createOpportunityForBorrower() {
        Map<String, String> leadMap = TestUtility.getLeadMap();
        leadMap.put('LeadSource', 'Website Merchant');
        leadMap.put('Lead_Type__c', 'Merchant');
        String jsonString = JSON.serialize(leadMap);
        Lead leadRecord = (Lead) JSON.deserialize(jsonString, Lead.class);
        Account borrowerAccount = TestUtility.createAccount();

        Test.startTest();
            Opportunity opportunityObject = Opportunities.createOpportunity(leadRecord, borrowerAccount);
        Test.stopTest();

        System.assert(opportunityObject != null);
        System.assertEquals('App Submitted', opportunityObject.StageName);
    }

    @isTest
    static void createOpportunityForBroker() {
        Map<String, String> leadMap = TestUtility.getLeadMap();
        leadMap.put('LeadSource', 'Website Broker');
        leadMap.put('Lead_Type__c', 'Broker');
        String jsonString = JSON.serialize(leadMap);
        Lead leadRecord = (Lead) JSON.deserialize(jsonString, Lead.class);
        Account borrowerAccount = TestUtility.createAccount();

        Test.startTest();
            Opportunity opportunityObject = Opportunities.createOpportunity(leadRecord, borrowerAccount);
        Test.stopTest();

        System.assert(opportunityObject != null);
        System.assertEquals('NEW', opportunityObject.StageName);
    }

    @isTest
    static void stageChanged(){

        Opportunity oldOpportunity = new Opportunity();
        oldOpportunity.StageName = 'Closed Won';

        Opportunity newOpportunity = new Opportunity();
        newOpportunity.StageName = 'NEW';

        Test.startTest();
            Boolean result = Opportunities.isStageChanged(newOpportunity, oldOpportunity);
        Test.stopTest();

        System.assertEquals(true, result);
    }

    @isTest
    static void declineReasonsOffersExpired(){
     genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Status__c = 'BANK STATEMENT PROCESSING';
        application.Decline_Reasons__c = 'Offers Expired';

        Opportunity newOpportunity = new Opportunity();
        newOpportunity.StageName = 'App Submitted';
        newOpportunity.Sub_Status__c = 'Bank Statement Processing';

        Test.startTest();
           Opportunity opportunityObject = Opportunities.setOpportunityStageWithApplicationStatus(application, newOpportunity);
        Test.stopTest();

       System.assert(opportunityObject != null);
       System.assertEquals('Offers Expired', opportunityObject.Sub_Status__c);
    }

    @isTest
    static void declineReasonsClosedExpired(){
     genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Status__c = 'BANK STATEMENT PROCESSING';
        application.Decline_Reasons__c = 'Closed Expired';

        Opportunity newOpportunity = new Opportunity();
        newOpportunity.StageName = 'App Submitted';
        newOpportunity.Sub_Status__c = 'Bank Statement Processing';

        Test.startTest();
           Opportunity opportunityObject = Opportunities.setOpportunityStageWithApplicationStatus(application, newOpportunity);
        Test.stopTest();

       System.assert(opportunityObject != null);
       System.assertEquals('Customer Not Interested', opportunityObject.Sub_Status__c);
    }

}