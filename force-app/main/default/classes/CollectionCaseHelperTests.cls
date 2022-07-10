@isTest
public class CollectionCaseHelperTests {
    @isTest
    static void getAllCollectionCasesMap() {
        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        Collection_Case__c collectionCase = new Collection_Case__c();
        collectionCase.Id = TestUtility.getFakeId(Collection_Case__c.getSObjectType());
        collectionCase.Contract_Number__c = 'LAI0000002';
        collectionCase.CL_Contract_Id__c = testExternalId;

        Test.StartTest();
            Map<Id, Collection_Case__c> returnMap = CollectionCaseHelper.getAllCollectionCasesMap;
        Test.stopTest();

        System.assert(returnMap != null);
    }

    @isTest
    static void lowBalanceQueueUsersList() {
        Group testGroup = new Group();
        testGroup.Name ='LOW BALANCE';
        testGroup.Type = 'Queue';
        testGroup.Id = TestUtility.getFakeId(Group.getSObjectType());

        GroupMember testGroupMember = new GroupMember();
        testGroupMember.UserOrGroupId = testGroup.Id;
        testGroupMember.Id = TestUtility.getFakeId(GroupMember.getSObjectType());

        Test.StartTest();
            List<GroupMember> returnUsersList = CollectionCaseHelper.lowBalanceQueueUsersList;
        Test.stopTest();

        System.assert(returnUsersList != null);
    }

    @isTest
    static void highBalanceQueueUsersList() {
        Group testGroup = new Group();
        testGroup.Name ='HIGH BALANCE';
        testGroup.Type = 'Queue';
        testGroup.Id = TestUtility.getFakeId(Group.getSObjectType());

        GroupMember testGroupMember = new GroupMember();
        testGroupMember.UserOrGroupId = testGroup.Id;
        testGroupMember.Id = TestUtility.getFakeId(GroupMember.getSObjectType());

        Test.StartTest();
            List<GroupMember> returnUsersList = CollectionCaseHelper.highBalanceQueueUsersList;
        Test.stopTest();

        System.assert(returnUsersList != null);
    }
}