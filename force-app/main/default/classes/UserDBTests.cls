@isTest
private class UserDBTests {

    private static UserDB userDBInstance = new UserDB();

    @isTest
    private static void getUsersByUserNames() {

        Test.startTest();
            List<User> userList = userDBInstance.getUsersByUserNames(new Set<String>{'Test User'});
        Test.stopTest();

        System.assert(userList != null);
        System.assert(userList.isEmpty());
    }

    @isTest
    private static void getUserByAccountIds() {
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(accountId);

        Test.startTest();
            List<User> userList = userDBInstance.getUserByAccountIds(accountIds);
        Test.stopTest();

        System.assert(userList != null);
        System.assert(userList.isEmpty());
    }

    @isTest
    private static void getUsersByContactIds() {
        Id contactId = TestUtility.getFakeId(Contact.getSObjectType());
        Set<Id> contactIds = new Set<Id>();
        contactIds.add(contactId);

        Test.startTest();
            List<User> userList = userDBInstance.getUsersByContactIds(contactIds);
        Test.stopTest();

        System.assert(userList != null);
        System.assert(userList.isEmpty());
    }

    @isTest
    private static void getBrokerUserDetailsByLoggedInId() {

        Test.startTest();
            List<User> userList = userDBInstance.getBrokerUserDetailsByLoggedInId();
        Test.stopTest();

        System.assert(userList != null);
    }

    @isTest
    private static void getUserDetailsByUnderWriterIds() {
        Id underWriterId = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        Set<Id> underWriterIds = new Set<Id>();
        underWriterIds.add(underWriterId);

        Test.startTest();
            List<User> userList = userDBInstance.getUserDetailsByUnderWriterIds(underWriterIds);
        Test.stopTest();

        System.assert(userList != null);
        System.assert(userList.isEmpty());
    }

    @isTest
    private static void getDefaultPortalOwnerByEmail() {

        Test.startTest();
            List<User> userList = userDBInstance.getDefaultPortalOwnerByEmail(new Set<String>{'TestEmail@CANCapital.com'});
        Test.stopTest();

        System.assert(userList != null);
        System.assert(userList.isEmpty());
    }

    @isTest
    private static void getUserDetailsByIds() {
        Id userId = TestUtility.getFakeId(User.getSObjectType());

        Test.startTest();
            List<User> userList = userDBInstance.getUserDetailsByIds(new Set<Id>{userId});
        Test.stopTest();

        System.assert(userList != null);
        System.assert(userList.isEmpty());
    }

    @isTest
    private static void getUserDetailsByProfileIds() {
        Id profileId = TestUtility.getFakeId(Profile.getSObjectType());

        Test.startTest();
            List<User> userList = userDBInstance.getUserDetailsByProfileIds(new Set<Id>{profileId});
        Test.stopTest();

        System.assert(userList != null);
        System.assert(userList.isEmpty());
    }

    @isTest
    private static void getDerronHardyDetailsByEmailAddress() {

        Origination_Settings__mdt originationSettings = new Origination_Settings__mdt();
        originationSettings.DeveloperName = 'Default';
        originationSettings.MasterLabel = originationSettings.DeveloperName;
        originationSettings.Derron_Hardy_Email__c = 'testunique@cancapital.com';
        CustomMetaDataHelper.defaultOriginationSetting = originationSettings;

        Test.startTest();
            List<User> actualDerronHardy = userDBInstance.getDerronHardyDetailsByEmailAddress();
        Test.stopTest();

        System.assert(actualDerronHardy != null);
    }
}