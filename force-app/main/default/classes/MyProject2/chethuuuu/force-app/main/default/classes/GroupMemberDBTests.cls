@isTest
private class GroupMemberDBTests {

    private static GroupMemberDB groupMemberDBInstance = new GroupMemberDB();

    @isTest
    private static void getAllLowBalanceQueueUsersTest() {

        Test.startTest();
            List<GroupMember> groupMemberList = groupMemberDBInstance.getAllLowBalanceQueueUsers();
        Test.stopTest();

        System.assert(groupMemberList != null);
    }

    @isTest
    private static void getAllHighBalanceQueueUsersTest() {

        Test.startTest();
            List<GroupMember> groupMemberList = groupMemberDBInstance.getAllHighBalanceQueueUsers();
        Test.stopTest();

        System.assert(groupMemberList != null);
    }
}