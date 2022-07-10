@isTest
private class CollectorAssignmentManagerTests {
    @TestSetup
    static void makeData(){
        TestUtility.runSetupData();
        loan__Loan_Account__c loanAccount = TestUtility.createContract();
    }

    @isTest
    private static void collectorAssignmentManagerTests() {

        Id clContractId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Id collectionCaseId = TestUtility.getFakeId(Collection_Case__c.getSObjectType());

        List<GroupMember> userList = new List<GroupMember>();
        GroupMember groupMember = new GroupMember();
        groupMember.UserOrGroupId = UserInfo.getUserId();
        userList.add(groupMember);
        CollectionCaseHelper.lowBalanceQueueUsersList = userList;

        loan__Loan_Account__c clContract = new loan__Loan_Account__c();
        clContract.Id = clContractId;

        Collection_Case__c collectionCase = new Collection_Case__c();
        collectionCase.Id = collectionCaseId;
        collectionCase.CL_Contract_Id__c = clContractId;
        collectionCase.Manual_Collector_Assigned__c = false;
        collectionCase.Is_Same_Queue__c = false;
        collectionCase.Case_Queue__c = CollectionCaseConstants.LOW_BALANCE_QUEUE;

        DBManagerTestsStub collectionCaseDBStubInstance = new DBManagerTestsStub();
        collectionCaseDBStubInstance.genericReturnObject = new List<Collection_Case__c> {collectionCase};
        CollectorAssignmentManager.collectionCaseDBInstance = (CollectionCaseDB) Test.createStub(CollectionCaseDB.class, collectionCaseDBStubInstance);

        Test.startTest();
            CollectorAssignmentManager.collectorAssignment(new List<loan__Loan_Account__c> {clContract});
        Test.stopTest();
    }

    @isTest
    private static void collectorAssignmentManagerHighBalanceTests() {

        Id clContractId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Id collectionCaseId = TestUtility.getFakeId(Collection_Case__c.getSObjectType());

        Collection_Case__c collectionCase = new Collection_Case__c();
        collectionCase.Id = collectionCaseId;
        collectionCase.CL_Contract_Id__c = clContractId;
        collectionCase.Manual_Collector_Assigned__c = false;
        collectionCase.Is_Same_Queue__c = false;
        collectionCase.Case_Queue__c = CollectionCaseConstants.HIGH_BALANCE_QUEUE;

        List<GroupMember> userList = new List<GroupMember>();
        GroupMember groupMember = new GroupMember();
        groupMember.UserOrGroupId = UserInfo.getUserId();
        userList.add(groupMember);
        CollectionCaseHelper.highBalanceQueueUsersList = userList;

        loan__Loan_Account__c clContract = new loan__Loan_Account__c();
        clContract.Id = clContractId;

        DBManagerTestsStub collectionCaseDBStubInstance = new DBManagerTestsStub();
        collectionCaseDBStubInstance.genericReturnObject = new List<Collection_Case__c> {collectionCase};
        CollectorAssignmentManager.collectionCaseDBInstance = (CollectionCaseDB) Test.createStub(CollectionCaseDB.class, collectionCaseDBStubInstance);

        Test.startTest();
            CollectorAssignmentManager.collectorAssignment(new List<loan__Loan_Account__c> {clContract});
        Test.stopTest();
    }

    @isTest
    private static void manualCollectorAssignmentTests() {

        Id collectionCaseId = TestUtility.getFakeId(Collection_Case__c.getSObjectType());
        String queue = CollectionCaseConstants.LOW_BALANCE_QUEUE;
        Id collectorId = TestUtility.getFakeId(User.getSObjectType());

        DBManagerTestsStub collectionCaseDBStubInstance = new DBManagerTestsStub();
        CollectorAssignmentManager.collectionCaseDBInstance = (collectionCaseDB) Test.createStub(collectionCaseDB.class, collectionCaseDBStubInstance);

        Test.startTest();
            CollectorAssignmentManager.manualCollectorAssignment(collectionCaseId, queue, collectorId);
        Test.stopTest();

        System.assertEquals(1, collectionCaseDBStubInstance.forUpdateSObjects.size());
    }
}