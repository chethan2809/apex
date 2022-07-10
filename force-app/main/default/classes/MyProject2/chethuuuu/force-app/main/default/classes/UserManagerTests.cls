@isTest
private class UserManagerTests {
    @isTest
    private static void updateCommunityUserDetailsOnSystemDateChange() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        User userRecord = new User();
        userRecord.Id = TestUtility.getFakeId(User.getSObjectType());

        Profile merchantProfile = new Profile();
        merchantProfile.Id = TestUtility.getFakeId(Profile.getSObjectType());
        merchantProfile.Name = GeneralConstants.MERCHANT_USER_PROFILE_NAME;
        GeneralHelper.profileByName.put(GeneralConstants.MERCHANT_USER_PROFILE_NAME, merchantProfile);

        Profile brokerProfile = new Profile();
        brokerProfile.Id = TestUtility.getFakeId(Profile.getSObjectType());
        brokerProfile.Name = GeneralConstants.BROKER_USER_PROFILE_NAME;
        GeneralHelper.profileByName.put(GeneralConstants.BROKER_USER_PROFILE_NAME, brokerProfile);

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User> {userRecord};
        UserManager.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        Test.startTest();
            UserManager.updateCommunityUserDetailsOnSystemDateChange(TestUtility.currentSystemDate);
        Test.stopTest();

        System.assertEquals(1, userDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void createUserBranchAssignment() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        User userRecord = (User) JSON.deserialize('{ "UserType" : "'+ GeneralConstants.USER_TYPE_STANDARD + '" }', User.class);
        userRecord.Id = TestUtility.getFakeId(User.getSObjectType());

        loan__Office_Name__c loanOfficeName = new loan__Office_Name__c();
        loanOfficeName.Id = TestUtility.getFakeId(loan__Office_Name__c.getSObjectType());

        DBManagerTestsStub loanOfficeNameDBStubInstance = new DBManagerTestsStub();
        loanOfficeNameDBStubInstance.genericReturnObject = new List<loan__Office_Name__c> {loanOfficeName};
        UserManager.loanOfficeNameDBInstance = (LoanOfficeNameDB) Test.createStub(LoanOfficeNameDB.class, loanOfficeNameDBStubInstance);

        DBManagerTestsStub userBranchInfoDBStubInstance = new DBManagerTestsStub();
        UserManager.userBranchInfoDBInstance = (UserBranchInfoDB) Test.createStub(UserBranchInfoDB.class, userBranchInfoDBStubInstance);

        Test.startTest();
            UserManager.createUserBranchAssignment(new Set<Id> {userRecord.Id});
        Test.stopTest();

        System.assertEquals(1, userBranchInfoDBStubInstance.forInsertSObjects.size());
    }
}