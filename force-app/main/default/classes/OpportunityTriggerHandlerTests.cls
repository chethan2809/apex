@isTest
private class OpportunityTriggerHandlerTests {

    private static OpportunityTriggerHandler opportunityTrigger = new OpportunityTriggerHandler();

    @testSetup
    static void makeData() {
        TestUtility.runSetupData();
        TestUtility.createLegalEntity();
        TestUtility.createDocumentDefinition();

        loan__Loan_Account__c clContract = TestUtility.createContract();
    }

    @isTest
    private static void beforeInsertOnApplicationStatus() {

        loan__Loan_Account__c clContract = [SELECT Id,Name,loan__Account__c,Concurrent_Eligible_Amount__c,
                                            Application__r.Opportunity__r.LeadSource,Broker_Contact__c,
                                            Broker_Contact__r.AccountId
                                            FROM loan__Loan_Account__c LIMIT 1];

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{clContract};
        OpportunityTriggerHandler.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Id = TestUtility.getFakeId(Opportunity.getSObjectType());
        newOpportunity.StageName = 'Closed Won';
        newOpportunity.Type = GeneralConstants.LOAN_TYPE_RENEWAL;
        newOpportunity.AccountId = clContract.loan__Account__c;

        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Status__c = Applications.STATUS_NEW_ENTERED;
        application.Opportunity__c = newOpportunity.Id;
        applicationList.add(application);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        OpportunityTriggerHandler.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        Test.startTest();
            opportunityTrigger.beforeInsert(new List<Opportunity> {newOpportunity});
        Test.stopTest();
    }

    @isTest
    private static void beforeInsertOnNewApplicationStatus() {

        loan__Loan_Account__c clContract = [SELECT Id,Name,loan__Account__c,Concurrent_Eligible_Amount__c,
                                            Application__r.Opportunity__r.LeadSource,Broker_Contact__c,
                                            Broker_Contact__r.AccountId
                                            FROM loan__Loan_Account__c LIMIT 1];

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{clContract};
        OpportunityTriggerHandler.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Id = TestUtility.getFakeId(Opportunity.getSObjectType());
        newOpportunity.StageName = 'Closed Won';
        newOpportunity.Type = GeneralConstants.LOAN_TYPE_NEW;
        newOpportunity.AccountId = clContract.loan__Account__c;

        Map<String, String> accountMap = new Map<String, String>();
        accountMap.put('Is_Exclusivity__c', 'true');
        accountMap.put('Id', clContract.loan__Account__c);
        accountMap.put('Name','Test Account EXC');
        String jsonString = JSON.serialize(accountMap);
        Account account = (Account) JSON.deserialize(jsonString, Account.class);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{account};
        OpportunityTriggerHandler.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Status__c = Applications.STATUS_NEW_ENTERED;
        application.Opportunity__c = newOpportunity.Id;
        applicationList.add(application);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        OpportunityTriggerHandler.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        Test.startTest();
            opportunityTrigger.beforeInsert(new List<Opportunity> {newOpportunity});
        Test.stopTest();

        System.assert(newOpportunity.Offer_Notification_To_Guarantor__c, true);
    }

    @isTest
    private static void beforeUpdateTests() {
        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Id = TestUtility.getFakeId(Opportunity.getSObjectType());
        newOpportunity.StageName = 'Closed Won';
        newOpportunity.Type = GeneralConstants.LOAN_TYPE_NEW;

        Test.startTest();
            opportunityTrigger.beforeUpdate(new List<Opportunity> {newOpportunity});
        Test.stopTest();

        System.assert(newOpportunity.Offer_Notification_To_Guarantor__c, false);
    }

    @IsTest
    private static void afterUpdateOnApplicationStatus() {

        Opportunity oldOpportunity = new Opportunity();
        oldOpportunity.Id = TestUtility.getFakeId(Opportunity.getSObjectType());
        oldOpportunity.StageName = 'Closed Won';
        oldOpportunity.OwnerId = TestUtility.getFakeId(User.getSObjectType());

        Map<Id, Opportunity> oldOpportunityMap = new Map<Id, Opportunity>();
        oldOpportunityMap.put(oldOpportunity.Id, oldOpportunity);

        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Id = oldOpportunity.Id;
        newOpportunity.StageName = 'Closed Lost';
        newOpportunity.OwnerId = TestUtility.getFakeId(User.getSObjectType());

        Map<Id, Opportunity> newOpportunityMap = new Map<Id, Opportunity>();
        newOpportunityMap.put(newOpportunity.Id, newOpportunity);

        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Status__c = Applications.STATUS_NEW_ENTERED;
        application.Opportunity__c = newOpportunity.Id;
        applicationList.add(application);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        OpportunityTriggerHandler.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        Test.startTest();
            opportunityTrigger.afterInsert(newOpportunityMap);
            opportunityTrigger.afterUpdate(newOpportunityMap, oldOpportunityMap);
        Test.stopTest();

        System.assertEquals(1, applicationDBStubInstance.forUpdateSObjects.size());
        System.assertEquals(Applications.STATUS_DECLINED, ((genesis__Applications__c)applicationDBStubInstance.forUpdateSObjects.get(0)).genesis__Status__c);
    }
}