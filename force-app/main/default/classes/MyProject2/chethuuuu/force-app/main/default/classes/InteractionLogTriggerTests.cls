@isTest
private class InteractionLogTriggerTests {

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
    private static void interactionLogTriggerInsert() {

        Collection_Case__c collectionCase = [
            SELECT Id,Name, Contract_Number__c, CL_Contract_Id__c,
            Supervisor__c, OwnerId, Account__c FROM Collection_Case__c LIMIT 1
        ];

        Interaction_Log__c interactionLog = new Interaction_Log__c();
        interactionLog.Action_Code__c = 'Fraud';
        interactionLog.Sub_Action_Code__c = 'Fraud Alleged';
        interactionLog.Fraud_Alleged_Type__c = 'Other';
        interactionLog.Collection_Case__c = collectionCase.Id;
		insert interactionLog;

        list<Interaction_Log__c> interactionLogList = [
            SELECT Id, Name, Action_Code__c
            FROM Interaction_Log__c
        ];

        System.assert(interactionLog.Id != null);
    }

    @isTest
    private static void interactionLogTriggerUpdate() {

        Collection_Case__c collectionCase = [
            SELECT Id,Name, Contract_Number__c, CL_Contract_Id__c,
            Supervisor__c, OwnerId, Account__c FROM Collection_Case__c LIMIT 1
        ];

        Interaction_Log__c interactionLog = new Interaction_Log__c();
        interactionLog.Action_Code__c = 'Fraud';
        interactionLog.Sub_Action_Code__c = 'Fraud Alleged';
        interactionLog.Fraud_Alleged_Type__c = 'Other';
        interactionLog.Collection_Case__c = collectionCase.Id;
		insert interactionLog;

        Interaction_Log__c interaction = new Interaction_Log__c();
        interaction.Id = interactionLog.Id;
		update interaction;

        list<Interaction_Log__c> interactionLogList = [
            SELECT Id, Name, Action_Code__c
            FROM Interaction_Log__c
        ];

        System.assert(interactionLog.Id != null);
    }
}