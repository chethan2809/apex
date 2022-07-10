@isTest(isParallel=true)
private class GeneralHelperTests {

    @isTest
    private static void currentSystemDate() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        Date currentSystemDate;
        Exception ex;
        Test.startTest();
            try {
                currentSystemDate = GeneralHelper.currentSystemDate;
            }
            catch(Exception e){
                ex = e;
            }
        Test.stopTest();

        TestUtility.assertNullException(ex);
        System.assertEquals(TestUtility.currentSystemDate, currentSystemDate);
    }

    @isTest
    private static void currentSystemDateWithNull() {
        Date currentSystemDate;
        Exception ex;
        Test.startTest();
            try {
                currentSystemDate = GeneralHelper.currentSystemDate;
            }
            catch(Exception e){
                ex = e;
            }
        Test.stopTest();

        System.assertEquals(null, currentSystemDate);
    }

    @isTest
    private static void currentSystemDateTime() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        DateTime currentSystemDateTime;
        Exception ex;
        Test.startTest();
            try {
                currentSystemDateTime = GeneralHelper.currentSystemDateTime;
            }
            catch(Exception e){
                ex = e;
            }
        Test.stopTest();

        TestUtility.assertNullException(ex);
        System.assertNotEquals(null, currentSystemDateTime);
    }

    @isTest
    static void domainUrl() {

        Test.startTest();
            String domainUrl = GeneralHelper.domainUrl;
        Test.stopTest();

        System.assert(domainUrl != null, 'domainUrl should not be null');
    }

    @isTest
    static void getNBusinessDate() {
        GeneralHelper.currentSystemDate = Date.newInstance(2021, 01, 06);
        Date startDate = GeneralHelper.currentSystemDate.addDays(1);

        Test.startTest();
            Date businessDate = GeneralHelper.getNBusinessDate(startDate, 1);
        Test.stopTest();

        System.assertEquals(startDate+1, businessDate);
    }

    @isTest
    private static void getBusinessDate() {
        GeneralHelper.currentSystemDate = Date.newInstance(2021, 01, 01);
        Date startDate = GeneralHelper.currentSystemDate.addDays(5);

        Test.startTest();
            Date businessDate = GeneralHelper.getBusinessDate(startDate);
        Test.stopTest();

        System.assertEquals(startDate, businessDate);
    }

    @isTest
    static void getDateFromUntypedString() {
        GeneralHelper.currentSystemDate = system.today();
        Date currentDate = GeneralHelper.currentSystemDate.addDays(1);

        String dateString = String.valueOf(currentDate);
        Test.startTest();
            Date dateFromTypeString = GeneralHelper.getDateFromUntypedString(dateString, 0, 1, 2, '-');
        Test.stopTest();

        System.assertEquals(currentDate, dateFromTypeString);
    }

    @isTest
    static void getOrgInformation() {

        Test.startTest();
            Organization organization = GeneralHelper.getOrgInformation;
        Test.stopTest();

        System.assert(organization != null);
    }

    @isTest
    private static void businessHours() {
        BusinessHours businessHours = new BusinessHours();
        businessHours.Id = TestUtility.getFakeId(BusinessHours.getSObjectType());

        DBManagerTestsStub businessHourDBStubInstance = new DBManagerTestsStub();
        businessHourDBStubInstance.genericReturnObject = new List<BusinessHours> {businessHours};
        GeneralHelper.businessHourDBInstance = (BusinessHourDB) Test.createStub(BusinessHourDB.class, businessHourDBStubInstance);

        Test.startTest();
            BusinessHours getBusinessHours = GeneralHelper.businessHours;
        Test.stopTest();

        System.assertEquals(businessHours.Id, getBusinessHours.Id);
    }

    @isTest
    static void getAsyncCronExpression() {
        DateTime currentDateTime = DateTime.now().addSeconds(15);
        String nextFireTime = String.valueOf(currentDateTime.second()) + ' ' + String.valueOf(currentDateTime.minute()) + ' ' + String.valueOf(currentDateTime.hour()) + ' * * ?';

        Test.startTest();
            String asyncCronExpression = GeneralHelper.getAsyncCronExpression();
        Test.stopTest();

        System.assertEquals(nextFireTime, asyncCronExpression);
    }

    @isTest
    static void getAsyncCronExpressionByDate() {
        DateTime currentDateTime = DateTime.now().addSeconds(15);
        Date schedulerDate = Date.newInstance(2021, 01, 06);
        String nextFireTime = String.valueOf(currentDateTime.second()) + ' ' + String.valueOf(currentDateTime.minute()) + ' ' + String.valueOf(currentDateTime.hour()) + ' ' + String.valueOf(schedulerDate.day()) + ' ' + String.valueOf(schedulerDate.month()) + ' ' + '?' + ' ' + String.valueOf(schedulerDate.year());

        Test.startTest();
            String asyncCronExpression = GeneralHelper.getAsyncCronExpressionByDate(schedulerDate, String.valueOf(currentDateTime.hour()), String.valueOf(currentDateTime.minute()), String.valueOf(currentDateTime.second()));
        Test.stopTest();

        System.assertEquals(nextFireTime, asyncCronExpression);
    }

    @isTest
    private static void folderByFolderName() {
        Folder folderRecord = new Folder();
        folderRecord.Name = 'Service Dashboards';

        DBManagerTestsStub folderDBStubInstance = new DBManagerTestsStub();
        folderDBStubInstance.genericReturnObject = new List<Folder> {folderRecord};
        GeneralHelper.folderDBInstance = (FolderDB) Test.createStub(FolderDB.class, folderDBStubInstance);

        Test.startTest();
            Map<String, Folder> folderMap = GeneralHelper.folderByFolderName;
        Test.stopTest();

        System.assertEquals(1, folderMap.size());
        System.assertEquals(folderRecord, folderMap.get(folderRecord.Name));
    }

    @isTest
    private static void queueByNameMap() {
        Group groupRecord = new Group();
        groupRecord.Name = 'Test Group';

        DBManagerTestsStub groupDBInstance = new DBManagerTestsStub();
        groupDBInstance.genericReturnObject = new List<Group> {groupRecord};
        GeneralHelper.groupDBInstance = (GroupDB) Test.createStub(GroupDB.class, groupDBInstance);

        Test.startTest();
        Map<String, Group> queueMap = GeneralHelper.queueByNameMap;
        Test.stopTest();

        System.assertEquals(1, queueMap.size());
        System.assertEquals(groupRecord, queueMap.get(groupRecord.DeveloperName));
    }

    @isTest
    private static void siteByName() {
        Site siteRecord = (Site) JSON.deserialize(
            '{ "Subdomain" : "Partner_Portal"}' , Site.class
        );

        DBManagerTestsStub siteDBInstance = new DBManagerTestsStub();
        siteDBInstance.genericReturnObject = new List<Site> {siteRecord};
        GeneralHelper.siteDBInstance = (SiteDB) Test.createStub(SiteDB.class, siteDBInstance);

        Test.startTest();
        Map<String, Site> siteMap = GeneralHelper.siteByName;
        Test.stopTest();

        System.assertEquals(1, siteMap.size());
    }

    @isTest
    private static void siteFullURLByName() {
        Site siteRecord = (Site) JSON.deserialize(
            '{ "Subdomain" : "Partner_Portal"}' , Site.class
        );

        DBManagerTestsStub siteDBInstance = new DBManagerTestsStub();
        siteDBInstance.genericReturnObject = new List<Site> {siteRecord};
        GeneralHelper.siteDBInstance = (SiteDB) Test.createStub(SiteDB.class, siteDBInstance);

        Test.startTest();
            String url = GeneralHelper.siteFullURLByName(siteRecord.Subdomain);
        Test.stopTest();

        System.assert(url != null);
    }

    @isTest
    private static void orgWideEmailAddressByEmail() {

        Test.startTest();
            Map<String,OrgWideEmailAddress> orgWideEmailAddressByEmail = GeneralHelper.orgWideEmailAddressByEmail;
        Test.stopTest();

        System.assert(orgWideEmailAddressByEmail != null);
    }

    @isTest
    private static void profileByName() {

        Test.startTest();
            Map<String, Profile> profileByName = GeneralHelper.profileByName;
        Test.stopTest();

        System.assert(profileByName != null);
    }

    @isTest
    static void generateUniqueReferenceId() {

        Test.startTest();
            String uniqueReferenceIdOne = GeneralHelper.generateUniqueReferenceId('DUMMY STRING 1');
            String uniqueReferenceIdTwo = GeneralHelper.generateUniqueReferenceId('DUMMY STRING 2');
        Test.stopTest();

        System.assertNotEquals(uniqueReferenceIdOne, uniqueReferenceIdTwo);
    }

    @isTest
    static void cleanSpecialCharacters() {

        String variableWithSpecialCharacters = 'St. Peter!#%$';

        Test.startTest();
            String variableActualResult = GeneralHelper.cleanSpecialCharacters(variableWithSpecialCharacters);
        Test.stopTest();

        String variableExpectedResult = 'St Peter';
        System.assertEquals(variableExpectedResult, variableActualResult);

    }

    @isTest
    static void cleanSpecialCharactersForNull() {

        String variableWithSpecialCharacters;

        Test.startTest();
            String variableActualResult = GeneralHelper.cleanSpecialCharacters(variableWithSpecialCharacters);
        Test.stopTest();

        System.assertEquals(null, variableActualResult);

    }

    @isTest
    static void isAsynchronous() {

        Test.startTest();
            Boolean isAsynchronous = GeneralHelper.isAsynchronous();
        Test.stopTest();

        System.assertEquals(false, isAsynchronous);

    }

    @isTest
    static void convertStateNameToShortCodeTest() {
        Test.startTest();
            String inputString = GeneralHelper.convertStateNameToShortCode('new York');
        Test.stopTest();
        System.assert(inputString != '');
    }

    @isTest
    private static void customNotificationTypeByName() {

        Test.startTest();
            Map<String, Id> customNotificationTypeByName = GeneralHelper.customNotificationTypeByName;
        Test.stopTest();

        System.assert(customNotificationTypeByName != null);
    }

    @isTest
    private static void reciprocalRoleIdByName() {

        Test.startTest();
            Map<String, Id> reciprocalRoleIdByName = GeneralHelper.reciprocalRoleIdByName;
        Test.stopTest();

        System.assert(reciprocalRoleIdByName != null);
    }

    @isTest
    static void getObjectKeyPrefix() {

        String objectName = 'Account';
        String variableExpectedResult = '001';

        Test.startTest();
            String variableActualResult = GeneralHelper.getObjectKeyPrefix(objectName);
        Test.stopTest();

        System.assertEquals(variableExpectedResult, variableActualResult);

    }
}