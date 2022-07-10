@isTest
private class UsersTests {
    @isTest
    private static void setBranchFields() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        User userInfo = new User();
        userInfo.Id = TestUtility.getFakeId(User.getSObjectType());

        Test.startTest();
            Users.setBranchFields(userInfo);
        Test.stopTest();

        System.assertEquals(TestUtility.currentSystemDate, userInfo.loan__Current_Branch_s_System_Date__c);
    }
}