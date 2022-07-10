@isTest(isParallel=true)
private class GroupDBTests {

    private static GroupDB groupDBInstance = new GroupDB();

    @isTest
    private static void getAllQueues() {

        Test.startTest();
            List<Group> groupList = groupDBInstance.getAllQueues();
        Test.stopTest();

        System.assert(groupList != null);
    }
}