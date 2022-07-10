@isTest
private class InteractionLogManagerTests {

    @TestSetup
    static void makeData() {
        TestUtility.runSetupData();
        loan__Loan_Account__c clContract = TestUtility.createContract();

        updateUser();

        Collection_Case__c collectionCase = new Collection_Case__c();
        collectionCase.Contract_Number__c = clContract.Name;
        collectionCase.CL_Contract_Id__c = clContract.Id;
        collectionCase.Supervisor__c = UserInfo.getUserId();
        collectionCase.OwnerId = UserInfo.getUserId();
        collectionCase.Account__c = clContract.loan__Account__c;
        insert collectionCase;
    }

    private static void updateUser() {
        User user = new User(Id = UserInfo.getUserId());
        user.Supervisor__c = true;
        update user;
    }

    @isTest
    private static void handleActionCodeForCreateTask() {
        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id userId = TestUtility.getFakeId(User.getSObjectType());
        Collection_Case__c collectionCase = [
            SELECT Id,Name, Contract_Number__c, CL_Contract_Id__c,
            Supervisor__c, OwnerId, Account__c FROM Collection_Case__c LIMIT 1
        ];

        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Action_Code__c = CollectionCaseConstants.BANKRUPTCY;
        interactionLogRecord.Sub_Action_Code__c = CollectionCaseConstants.BANKRUPTCY_FILED;
        interactionLogRecord.Collection_Case__c = collectionCase.Id;

        Task taskRecord = new Task();
        taskRecord.WhatId = interactionLogRecord.Id;
        taskRecord.Collection_Contract__c = collectionCase.CL_Contract_Id__c;
        taskRecord.Priority = 'Normal';
        taskRecord.Status = 'Open';

        DBManagerTestsStub taskDBStubInstance = new DBManagerTestsStub();
        taskDBStubInstance.genericReturnObject = new List<Task> {taskRecord};
        InteractionLogManager.taskDBInstance = (TaskDB) Test.createStub(TaskDB.class, taskDBStubInstance);

        Test.startTest();
            InteractionLogManager.handleActionCode(new List<Interaction_Log__c> {interactionLogRecord});
        Test.stopTest();

        System.assert(interactionLogRecord != null);
    }

    @isTest
    private static void handleActionCodeToCreateCase() {
        User user = new User();
        user.ProfileID = [Select Id From Profile Where Name='System Administrator'].Id;
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.FirstName = 'first';
        user.LastName = 'last';
        user.Username = TestUtility.generateFakeName() + '@example.com';
        user.CommunityNickname = 'testUser123';
        user.Alias = 't1';
        user.Email = 'no@email.com';
        user.IsActive = true;
        user.Id = TestUtility.getFakeId(User.getSObjectType());

        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        Id accountId = TestUtility.getFakeId(Account.getSObjectType());

        Collection_Case__c collectionCase = [
            SELECT Id,Name, Contract_Number__c, CL_Contract_Id__c,
            Supervisor__c, OwnerId, Account__c FROM Collection_Case__c LIMIT 1
        ];

        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Action_Code__c = CollectionCaseConstants.CEASE_AND_DESIST;
        interactionLogRecord.Collection_Case__c = collectionCase.Id;

        Case caseRecord = new Case();
        caseRecord.Description = 'Test Description';
        caseRecord.Subject = '';
        caseRecord.OwnerId = collectionCase.Supervisor__c;

        DBManagerTestsStub caseDBStubInstance = new DBManagerTestsStub();
        caseDBStubInstance.genericReturnObject = new List<Case> {caseRecord};
        InteractionLogManager.caseDBInstance = (CaseDB) Test.createStub(CaseDB.class, caseDBStubInstance);

        Test.startTest();
            InteractionLogManager.handleActionCode(new List<Interaction_Log__c> {interactionLogRecord});
        Test.stopTest();

        System.assert(interactionLogRecord != null);
    }

    @isTest
    private static void handleActionCodeForOwner() {

        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id userId = TestUtility.getFakeId(User.getSObjectType());

        Collection_Case__c collectionCase = [
            SELECT Id,Name, Contract_Number__c, CL_Contract_Id__c,
            Supervisor__c, OwnerId, Account__c FROM Collection_Case__c LIMIT 1
        ];

        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Sub_Action_Code__c = CollectionCaseConstants.BANKRUPTCY_IN_PROCESS;
        interactionLogRecord.Collection_Case__c = collectionCase.Id;

        Task taskRecord = new Task();
        taskRecord.WhatId = interactionLogRecord.Id;
        taskRecord.Collection_Contract__c = collectionCase.CL_Contract_Id__c;
        taskRecord.Priority = 'Normal';
        taskRecord.Status = 'Open';

        DBManagerTestsStub taskDBStubInstance = new DBManagerTestsStub();
        taskDBStubInstance.genericReturnObject = new List<Task> {taskRecord};
        InteractionLogManager.taskDBInstance = (TaskDB) Test.createStub(TaskDB.class, taskDBStubInstance);

        Test.startTest();
            InteractionLogManager.handleActionCode(new List<Interaction_Log__c> {interactionLogRecord});
        Test.stopTest();

        System.assert(interactionLogRecord != null);
    }

    @isTest
    private static void sendChatterNotificationsTest() {
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id userId = TestUtility.getFakeId(User.getSObjectType());
        Id collectionCaseId = TestUtility.getFakeId(Collection_Case__c.getSObjectType());

        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Sub_Action_Code__c = CollectionCaseConstants.BANKRUPTCY_IN_PROCESS;
        interactionLogRecord.Collection_Case__c = collectionCaseId;

        Test.startTest();
            InteractionLogManager.sendChatterNotifications(interactionLogRecord, 'title', 'body', userId);
        Test.stopTest();

        System.assert(interactionLogRecord != null);
    }

    @isTest
    private static void handleActionCodeForBankruptcy() {

        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id userId = TestUtility.getFakeId(User.getSObjectType());

        Collection_Case__c collectionCase = [
            SELECT Id,Name, Contract_Number__c, CL_Contract_Id__c,
            Supervisor__c, OwnerId, Account__c FROM Collection_Case__c LIMIT 1
        ];

        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Action_Code__c = CollectionCaseConstants.BANKRUPTCY;
        interactionLogRecord.Sub_Action_Code__c = CollectionCaseConstants.BANKRUPTCY_FILED;
        interactionLogRecord.Collection_Case__c = collectionCase.Id;

        Task taskRecord = new Task();
        taskRecord.WhatId = interactionLogRecord.Id;
        taskRecord.Collection_Contract__c = collectionCase.CL_Contract_Id__c;
        taskRecord.Priority = 'Normal';
        taskRecord.Status = 'Open';

        DBManagerTestsStub taskDBStubInstance = new DBManagerTestsStub();
        taskDBStubInstance.genericReturnObject = new List<Task> {taskRecord};
        InteractionLogManager.taskDBInstance = (TaskDB) Test.createStub(TaskDB.class, taskDBStubInstance);

        Test.startTest();
            InteractionLogManager.handleActionCode(new List<Interaction_Log__c> {interactionLogRecord});
        Test.stopTest();

        System.assert(interactionLogRecord != null);
    }

    @isTest
    private static void handleActionCodeForLegal() {

        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id userId = TestUtility.getFakeId(User.getSObjectType());

        Collection_Case__c collectionCase = [
            SELECT Id,Name, Contract_Number__c, CL_Contract_Id__c,
            Supervisor__c, OwnerId, Account__c FROM Collection_Case__c LIMIT 1
        ];

        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Action_Code__c = CollectionCaseConstants.LEGAL;
        interactionLogRecord.Sub_Action_Code__c = CollectionCaseConstants.LEGAL_REVIEW;
        interactionLogRecord.Collection_Case__c = collectionCase.Id;

        Task taskRecord = new Task();
        taskRecord.WhatId = interactionLogRecord.Id;
        taskRecord.Collection_Contract__c = collectionCase.CL_Contract_Id__c;
        taskRecord.Priority = 'Normal';
        taskRecord.Status = 'Open';

        DBManagerTestsStub taskDBStubInstance = new DBManagerTestsStub();
        taskDBStubInstance.genericReturnObject = new List<Task> {taskRecord};
        InteractionLogManager.taskDBInstance = (TaskDB) Test.createStub(TaskDB.class, taskDBStubInstance);

        Test.startTest();
            InteractionLogManager.handleActionCode(new List<Interaction_Log__c> {interactionLogRecord});
        Test.stopTest();

        System.assert(interactionLogRecord != null);
    }

    @isTest
    private static void handleSubActionCodeForLegalFeedback() {

        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id userId = TestUtility.getFakeId(User.getSObjectType());

        Collection_Case__c collectionCase = [
            SELECT Id,Name, Contract_Number__c, CL_Contract_Id__c,
            Supervisor__c, OwnerId, Account__c FROM Collection_Case__c LIMIT 1
        ];

        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Action_Code__c = CollectionCaseConstants.LEGAL;
        interactionLogRecord.Sub_Action_Code__c = CollectionCaseConstants.LEGAL_FEEDBACK;
        interactionLogRecord.Collection_Case__c = collectionCase.Id;

        Test.startTest();
            InteractionLogManager.handleActionCode(new List<Interaction_Log__c> {interactionLogRecord});
        Test.stopTest();

        System.assert(interactionLogRecord != null);
    }

    @isTest
    private static void handleActionCodeForContactAttempt() {
        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id userId = TestUtility.getFakeId(User.getSObjectType());
        Collection_Case__c collectionCase = [
            SELECT Id,Name, Contract_Number__c, CL_Contract_Id__c,
            Supervisor__c, OwnerId, Account__c FROM Collection_Case__c LIMIT 1
        ];

        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Action_Code__c = CollectionCaseConstants.CONTACT_ATTEMPT;
        interactionLogRecord.Sub_Action_Code__c = CollectionCaseConstants.CONTACTED;
        interactionLogRecord.Collection_Case__c = collectionCase.Id;

        Task taskRecord = new Task();
        taskRecord.WhatId = interactionLogRecord.Id;
        taskRecord.Collection_Contract__c = collectionCase.CL_Contract_Id__c;
        taskRecord.Priority = 'Normal';
        taskRecord.Status = 'Open';

        DBManagerTestsStub taskDBStubInstance = new DBManagerTestsStub();
        taskDBStubInstance.genericReturnObject = new List<Task> {taskRecord};
        InteractionLogManager.taskDBInstance = (TaskDB) Test.createStub(TaskDB.class, taskDBStubInstance);

        Test.startTest();
            InteractionLogManager.handleActionCode(new List<Interaction_Log__c> {interactionLogRecord});
        Test.stopTest();

        System.assert(interactionLogRecord != null);
    }

    @isTest
    private static void handleActionCodeForSupervisorReview() {
        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id userId = TestUtility.getFakeId(User.getSObjectType());
        Collection_Case__c collectionCase = [
            SELECT Id,Name, Contract_Number__c, CL_Contract_Id__c,
            Supervisor__c, OwnerId, Account__c FROM Collection_Case__c LIMIT 1
        ];

        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Sub_Action_Code__c = CollectionCaseConstants.SUPERVISOR_REVIEW;
        interactionLogRecord.Collection_Case__c = collectionCase.Id;

        Task taskRecord = new Task();
        taskRecord.WhatId = interactionLogRecord.Id;
        taskRecord.Collection_Contract__c = collectionCase.CL_Contract_Id__c;
        taskRecord.Priority = 'Normal';
        taskRecord.Status = 'Open';

        DBManagerTestsStub taskDBStubInstance = new DBManagerTestsStub();
        taskDBStubInstance.genericReturnObject = new List<Task> {taskRecord};
        InteractionLogManager.taskDBInstance = (TaskDB) Test.createStub(TaskDB.class, taskDBStubInstance);

        Test.startTest();
            InteractionLogManager.handleActionCode(new List<Interaction_Log__c> {interactionLogRecord});
        Test.stopTest();

        System.assert(interactionLogRecord != null);
    }

    @isTest
    private static void handleActionCodeForSupervisorFeedback() {
        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id userId = TestUtility.getFakeId(User.getSObjectType());
        Collection_Case__c collectionCase = [
            SELECT Id,Name, Contract_Number__c, CL_Contract_Id__c,
            Supervisor__c, OwnerId, Account__c FROM Collection_Case__c LIMIT 1
        ];

        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Sub_Action_Code__c = CollectionCaseConstants.SUPERVISOR_FEEDBACK;
        interactionLogRecord.Collection_Case__c = collectionCase.Id;

        Test.startTest();
            InteractionLogManager.handleActionCode(new List<Interaction_Log__c> {interactionLogRecord});
        Test.stopTest();

        System.assert(interactionLogRecord != null);
    }

    @isTest
    private static void handleActionCodeForCeaseAndDesist() {
        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id userId = TestUtility.getFakeId(User.getSObjectType());
        Collection_Case__c collectionCase = [
            SELECT Id,Name, Contract_Number__c, CL_Contract_Id__c,
            Supervisor__c, OwnerId, Account__c FROM Collection_Case__c LIMIT 1
        ];

        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Sub_Action_Code__c = CollectionCaseConstants.CEASE_AND_DESIST;
        interactionLogRecord.Collection_Case__c = collectionCase.Id;

        Case caseRecord = new Case();
        caseRecord.Description = 'Test Description';
        caseRecord.Subject = '';
        caseRecord.OwnerId = collectionCase.Supervisor__c;

        DBManagerTestsStub caseDBStubInstance = new DBManagerTestsStub();
        caseDBStubInstance.genericReturnObject = new List<Case> {caseRecord};
        InteractionLogManager.caseDBInstance = (CaseDB) Test.createStub(CaseDB.class, caseDBStubInstance);

        Test.startTest();
            InteractionLogManager.handleActionCode(new List<Interaction_Log__c> {interactionLogRecord});
        Test.stopTest();

        System.assert(interactionLogRecord != null);
    }

    @isTest
    private static void handleActionCodeForFraudConfirmed() {
        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id userId = TestUtility.getFakeId(User.getSObjectType());
        Collection_Case__c collectionCase = [
            SELECT Id,Name, Contract_Number__c, CL_Contract_Id__c,
            Supervisor__c, OwnerId, Account__c FROM Collection_Case__c LIMIT 1
        ];

        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Sub_Action_Code__c = CollectionCaseConstants.FRAUD_CONFIRMED;
        interactionLogRecord.Collection_Case__c = collectionCase.Id;

        Test.startTest();
            InteractionLogManager.handleActionCode(new List<Interaction_Log__c> {interactionLogRecord});
        Test.stopTest();

        System.assert(interactionLogRecord != null);
    }

    @isTest
    private static void handleActionCodeForDeceasedOwnerConfirmed() {
        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id userId = TestUtility.getFakeId(User.getSObjectType());
        Collection_Case__c collectionCase = [
            SELECT Id,Name, Contract_Number__c, CL_Contract_Id__c,
            Supervisor__c, OwnerId, Account__c FROM Collection_Case__c LIMIT 1
        ];

        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Sub_Action_Code__c = CollectionCaseConstants.DECEASED_OWNER_CONFIRMED;
        interactionLogRecord.Collection_Case__c = collectionCase.Id;

        Test.startTest();
            InteractionLogManager.handleActionCode(new List<Interaction_Log__c> {interactionLogRecord});
        Test.stopTest();

        System.assert(interactionLogRecord != null);
    }

    @isTest
    private static void handleActionCodeForDeceasedOwner() {
        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id userId = TestUtility.getFakeId(User.getSObjectType());
        Collection_Case__c collectionCase = [
            SELECT Id,Name, Contract_Number__c, CL_Contract_Id__c,
            Supervisor__c, OwnerId, Account__c FROM Collection_Case__c LIMIT 1
        ];

        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Action_Code__c = CollectionCaseConstants.DECEASED;
        interactionLogRecord.Sub_Action_Code__c = CollectionCaseConstants.DECEASED_OWNER;
        interactionLogRecord.Collection_Case__c = collectionCase.Id;

        Case caseRecord = new Case();
        caseRecord.Description = 'Test Description';
        caseRecord.Subject = '';
        caseRecord.OwnerId = collectionCase.Supervisor__c;

        DBManagerTestsStub caseDBStubInstance = new DBManagerTestsStub();
        caseDBStubInstance.genericReturnObject = new List<Case> {caseRecord};
        InteractionLogManager.caseDBInstance = (CaseDB) Test.createStub(CaseDB.class, caseDBStubInstance);

        Test.startTest();
            InteractionLogManager.handleActionCode(new List<Interaction_Log__c> {interactionLogRecord});
        Test.stopTest();

        System.assert(interactionLogRecord != null);
    }

    @isTest
    private static void handleActionCodeForBankruptcyPlanPayments() {
        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id userId = TestUtility.getFakeId(User.getSObjectType());
        Collection_Case__c collectionCase = [
            SELECT Id,Name, Contract_Number__c, CL_Contract_Id__c,
            Supervisor__c, OwnerId, Account__c FROM Collection_Case__c LIMIT 1
        ];

        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Sub_Action_Code__c = CollectionCaseConstants.BANKRUPTCY_PLAN_PAYMENTS;
        interactionLogRecord.Collection_Case__c = collectionCase.Id;

        Test.startTest();
            InteractionLogManager.handleActionCode(new List<Interaction_Log__c> {interactionLogRecord});
        Test.stopTest();

        System.assert(interactionLogRecord != null);
    }

    @isTest
    private static void handleActionCodeForBankruptcyStatusUpdate() {
        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id userId = TestUtility.getFakeId(User.getSObjectType());
        Collection_Case__c collectionCase = [
            SELECT Id,Name, Contract_Number__c, CL_Contract_Id__c,
            Supervisor__c, OwnerId, Account__c FROM Collection_Case__c LIMIT 1
        ];

        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Sub_Action_Code__c = CollectionCaseConstants.BANKRUPTCY_STATUS_UPDATE;
        interactionLogRecord.Collection_Case__c = collectionCase.Id;

        Test.startTest();
            InteractionLogManager.handleActionCode(new List<Interaction_Log__c> {interactionLogRecord});
        Test.stopTest();

        System.assert(interactionLogRecord != null);
    }

    @isTest
    private static void handleActionCodeForBankruptcyProofFailed() {
        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id userId = TestUtility.getFakeId(User.getSObjectType());
        Collection_Case__c collectionCase = [
            SELECT Id,Name, Contract_Number__c, CL_Contract_Id__c,
            Supervisor__c, OwnerId, Account__c FROM Collection_Case__c LIMIT 1
        ];

        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Sub_Action_Code__c = CollectionCaseConstants.BANKRUPTCY_PROOF_OF_CLAIM_FILED;
        interactionLogRecord.Collection_Case__c = collectionCase.Id;

        Test.startTest();
            InteractionLogManager.handleActionCode(new List<Interaction_Log__c> {interactionLogRecord});
        Test.stopTest();

        System.assert(interactionLogRecord != null);
    }

    @isTest
    private static void handleActionCodeForSettlementNegotiation() {
        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id userId = TestUtility.getFakeId(User.getSObjectType());
        Collection_Case__c collectionCase = [
            SELECT Id,Name, Contract_Number__c, CL_Contract_Id__c,
            Supervisor__c, OwnerId, Account__c FROM Collection_Case__c LIMIT 1
        ];

        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Action_Code__c = CollectionCaseConstants.SETTLEMENT_NEGOTIATION;
        interactionLogRecord.Collection_Case__c = collectionCase.Id;

        Test.startTest();
            InteractionLogManager.handleActionCode(new List<Interaction_Log__c> {interactionLogRecord});
        Test.stopTest();

        System.assert(interactionLogRecord != null);
    }

    @isTest
    private static void handleActionCodeForSiteInspection() {
        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id userId = TestUtility.getFakeId(User.getSObjectType());
        Collection_Case__c collectionCase = [
            SELECT Id,Name, Contract_Number__c, CL_Contract_Id__c,
            Supervisor__c, OwnerId, Account__c FROM Collection_Case__c LIMIT 1
        ];

        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Action_Code__c = CollectionCaseConstants.SITE_INSPECTION;
        interactionLogRecord.Collection_Case__c = collectionCase.Id;

        Test.startTest();
            InteractionLogManager.handleActionCode(new List<Interaction_Log__c> {interactionLogRecord});
        Test.stopTest();

        System.assert(interactionLogRecord != null);
    }

    @isTest
    private static void handleActionCodeForJudgmentAwarded() {
        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id userId = TestUtility.getFakeId(User.getSObjectType());
        Collection_Case__c collectionCase = [
            SELECT Id,Name, Contract_Number__c, CL_Contract_Id__c,
            Supervisor__c, OwnerId, Account__c FROM Collection_Case__c LIMIT 1
        ];

        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Action_Code__c = CollectionCaseConstants.JUDGEMENT_AWARDED;
        interactionLogRecord.Collection_Case__c = collectionCase.Id;

        Test.startTest();
            InteractionLogManager.handleActionCode(new List<Interaction_Log__c> {interactionLogRecord});
        Test.stopTest();

        System.assert(interactionLogRecord != null);
    }

    @isTest
    private static void handleActionCodeForAccommodationRequested() {
        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id userId = TestUtility.getFakeId(User.getSObjectType());
        Collection_Case__c collectionCase = [
            SELECT Id,Name, Contract_Number__c, CL_Contract_Id__c,
            Supervisor__c, OwnerId, Account__c FROM Collection_Case__c LIMIT 1
        ];

        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Sub_Action_Code__c = CollectionCaseConstants.ACCOMMODATION_REQUESTED;
        interactionLogRecord.Collection_Case__c = collectionCase.Id;

        Test.startTest();
            InteractionLogManager.handleActionCode(new List<Interaction_Log__c> {interactionLogRecord});
        Test.stopTest();

        System.assert(interactionLogRecord != null);
    }

    @isTest
    private static void handleSubActionCodeForLegalCounsel() {
        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id userId = TestUtility.getFakeId(User.getSObjectType());
        Collection_Case__c collectionCase = [
            SELECT Id,Name, Contract_Number__c, CL_Contract_Id__c,
            Supervisor__c, OwnerId, Account__c FROM Collection_Case__c LIMIT 1
        ];

        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Sub_Action_Code__c = CollectionCaseConstants.MOVE_TO_LEGAL_COUNSEL;
        interactionLogRecord.Collection_Case__c = collectionCase.Id;

        Test.startTest();
            InteractionLogManager.handleActionCode(new List<Interaction_Log__c> {interactionLogRecord});
        Test.stopTest();

        System.assert(interactionLogRecord != null);
    }

    @isTest
    private static void handleSubActionCodeForPreparingSuit() {
        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id userId = TestUtility.getFakeId(User.getSObjectType());
        Collection_Case__c collectionCase = [
            SELECT Id,Name, Contract_Number__c, CL_Contract_Id__c,
            Supervisor__c, OwnerId, Account__c FROM Collection_Case__c LIMIT 1
        ];

        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Sub_Action_Code__c = CollectionCaseConstants.PREPARING_SUIT;
        interactionLogRecord.Collection_Case__c = collectionCase.Id;

        Test.startTest();
            InteractionLogManager.handleActionCode(new List<Interaction_Log__c> {interactionLogRecord});
        Test.stopTest();

        System.assert(interactionLogRecord != null);
    }

    @isTest
    private static void handleSubActionCodeForSuitFiled() {
        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id userId = TestUtility.getFakeId(User.getSObjectType());
        Collection_Case__c collectionCase = [
            SELECT Id,Name, Contract_Number__c, CL_Contract_Id__c,
            Supervisor__c, OwnerId, Account__c FROM Collection_Case__c LIMIT 1
        ];

        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Sub_Action_Code__c = CollectionCaseConstants.SUIT_FILED;
        interactionLogRecord.Collection_Case__c = collectionCase.Id;

        Test.startTest();
            InteractionLogManager.handleActionCode(new List<Interaction_Log__c> {interactionLogRecord});
        Test.stopTest();

        System.assert(interactionLogRecord != null);
    }

    @isTest
    private static void handleActionCodeForReceivership() {
        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id userId = TestUtility.getFakeId(User.getSObjectType());
        Collection_Case__c collectionCase = [
            SELECT Id,Name, Contract_Number__c, CL_Contract_Id__c,
            Supervisor__c, OwnerId, Account__c FROM Collection_Case__c LIMIT 1
        ];

        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Sub_Action_Code__c = CollectionCaseConstants.RECEIVERSHIP_DISSOLUTION;
        interactionLogRecord.Collection_Case__c = collectionCase.Id;

        Test.startTest();
            InteractionLogManager.handleActionCode(new List<Interaction_Log__c> {interactionLogRecord});
        Test.stopTest();

        System.assert(interactionLogRecord != null);
    }
}