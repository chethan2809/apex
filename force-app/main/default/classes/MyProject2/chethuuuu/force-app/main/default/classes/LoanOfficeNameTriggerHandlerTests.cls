@isTest
private class LoanOfficeNameTriggerHandlerTests {
    private static LoanOfficeNameTriggerHandler loanOfficeNameTriggerHandlerInstance = new LoanOfficeNameTriggerHandler();

    @isTest
    private static void afterUpdate() {

        Map<Id, loan__Office_Name__c> newLoanOfficeNameMap = new Map<Id, loan__Office_Name__c>();
        Map<Id, loan__Office_Name__c> oldLoanOfficeNameMap = new Map<Id, loan__Office_Name__c>();

        loan__Office_Name__c newLoanOfficeName = new loan__Office_Name__c();
        newLoanOfficeName.Id = TestUtility.getFakeId(loan__Office_Name__c.getSObjectType());
        newLoanOfficeName.loan__Current_System_Date__c = TestUtility.currentSystemDate.addDays(2);
        newLoanOfficeNameMap.put(newLoanOfficeName.Id, newLoanOfficeName);

        loan__Office_Name__c oldLoanOfficeName = new loan__Office_Name__c();
        oldLoanOfficeName.Id = newLoanOfficeName.Id;
        oldLoanOfficeName.loan__Current_System_Date__c = TestUtility.currentSystemDate;
        oldLoanOfficeNameMap.put(oldLoanOfficeName.Id, oldLoanOfficeName);

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
            loanOfficeNameTriggerHandlerInstance.afterUpdate(newLoanOfficeNameMap, oldLoanOfficeNameMap);
        Test.stopTest();

        System.assertEquals(1, userDBStubInstance.forUpdateSObjects.size());
    }
}