@isTest
private class UserTriggerHandlerTests {

    private static UserTriggerHandler userTriggerHandlerInstance = new UserTriggerHandler();

    @isTest
    private static void beforeInsert() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        User userRecord = new User();

        Test.startTest();
            userTriggerHandlerInstance.beforeInsert(new List<User> {userRecord});
        Test.stopTest();

        System.assertEquals(GeneralConstants.COMPANY_NAME, userRecord.loan__Current_Branch__c);
    }

    @isTest
    private static void afterInsert() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        User userRecord = (User) JSON.deserialize('{ "UserType" : "'+ GeneralConstants.USER_TYPE_STANDARD + '" }', User.class);
        userRecord.Id = TestUtility.getFakeId(User.getSObjectType());

        loan__Office_Name__c loanOfficeName = new loan__Office_Name__c();
        loanOfficeName.Id = TestUtility.getFakeId(loan__Office_Name__c.getSObjectType());

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User> {userRecord};
        UserManager.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        DBManagerTestsStub loanOfficeNameDBStubInstance = new DBManagerTestsStub();
        loanOfficeNameDBStubInstance.genericReturnObject = new List<loan__Office_Name__c> {loanOfficeName};
        UserManager.loanOfficeNameDBInstance = (LoanOfficeNameDB) Test.createStub(LoanOfficeNameDB.class, loanOfficeNameDBStubInstance);

        DBManagerTestsStub userBranchInfoDBStubInstance = new DBManagerTestsStub();
        UserManager.userBranchInfoDBInstance = (UserBranchInfoDB) Test.createStub(UserBranchInfoDB.class, userBranchInfoDBStubInstance);

        Map<Id, User> userMap = new Map<Id, User>();
        userMap.put(userRecord.Id, userRecord);

        Test.startTest();
            userTriggerHandlerInstance.afterInsert(userMap);
        Test.stopTest();

        System.assertEquals(1, userBranchInfoDBStubInstance.forInsertSObjects.size());

    }
}