@isTest
private class IndustryRatingProfileManagerTests {

    @isTest
    private static void calculateIndustryRatingThreeDigitSICCode() {

        CAN_Industry_Rating_Profile__c industryProfile = new CAN_Industry_Rating_Profile__c();
        industryProfile.Id = TestUtility.getFakeId(CAN_Industry_Rating_Profile__c.getSObjectType());
        industryProfile.Digit_Code__c = '951';
        industryProfile.Industry_Rating__c = 'A+ Medical';
        industryProfile.Excluded_For_Renewal__c = true;

        DBManagerTestsStub industryRatingProfileDBStubInstance = new DBManagerTestsStub();
        industryRatingProfileDBStubInstance.genericReturnObject = new List<CAN_Industry_Rating_Profile__c>{industryProfile};
        IndustryRatingProfileManager.industryRatingProfileDBInstance = (IndustryRatingProfileDB) Test.createStub(IndustryRatingProfileDB.class, industryRatingProfileDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        IndustryRatingProfileManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Status__c = 'NEW - ENTERED';
        application.Type__c = 'Renewal';
        application.SIC_Code__c = '951';
        application.Industry_Rating__c = industryProfile.Id;
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        applicationList.add(application);

        Test.startTest();
            IndustryRatingProfileManager.calculateIndustryRating(applicationList);
        Test.stopTest();

        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void calculateIndustryRatingException() {

        CAN_Industry_Rating_Profile__c industryProfile = new CAN_Industry_Rating_Profile__c();
        industryProfile.Id = TestUtility.getFakeId(CAN_Industry_Rating_Profile__c.getSObjectType());
        industryProfile.Digit_Code__c = '0188';
        industryProfile.Industry_Rating__c = 'A+ Medical';
        industryProfile.Excluded_For_Renewal__c = false;

        DBManagerTestsStub industryRatingProfileDBStubInstance = new DBManagerTestsStub();
        industryRatingProfileDBStubInstance.genericReturnObject = new List<CAN_Industry_Rating_Profile__c>{industryProfile};
        IndustryRatingProfileManager.industryRatingProfileDBInstance = (IndustryRatingProfileDB) Test.createStub(IndustryRatingProfileDB.class, industryRatingProfileDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        IndustryRatingProfileManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        genesis__Applications__c application = new genesis__Applications__c();
        application.Type__c = 'Renewal';
        application.SIC_Code__c = '37';
        application.Industry_Rating__c = industryProfile.Id;
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        applicationList.add(application);

        List<String> sicIds = new List<String>();
        sicIds.add(application.SIC_Code__c);

        Test.startTest();
            IndustryRatingProfileManager.calculateIndustryRating(applicationList);
        Test.stopTest();

        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void getIndustryRatingDescriptionBySICCodeThreeDigit() {

        CAN_Industry_Rating_Profile__c canRatingProfile = new CAN_Industry_Rating_Profile__c();
        canRatingProfile.Digit_Code__c = '951';

        DBManagerTestsStub industryRatingProfileDBStubInstance = new DBManagerTestsStub();
        industryRatingProfileDBStubInstance.genericReturnObject = new List<CAN_Industry_Rating_Profile__c> {canRatingProfile};
        OriginationHelper.industryRatingProfileDBInstance = (IndustryRatingProfileDB) Test.createStub(IndustryRatingProfileDB.class, industryRatingProfileDBStubInstance);

        Test.startTest();
            String actualDescription = IndustryRatingProfileManager.getIndustryRatingDescriptionBySICCode(canRatingProfile.Digit_Code__c);
        Test.stopTest();

        System.assertEquals(null, actualDescription);
    }

    @isTest
    private static void getIndustryRatingDescriptionBySICCodeTwoDigit() {

        CAN_Industry_Rating_Profile__c canRatingProfile = new CAN_Industry_Rating_Profile__c();
        canRatingProfile.Digit_Code__c = '37';

        DBManagerTestsStub industryRatingProfileDBStubInstance = new DBManagerTestsStub();
        industryRatingProfileDBStubInstance.genericReturnObject = new List<CAN_Industry_Rating_Profile__c> {canRatingProfile};
        OriginationHelper.industryRatingProfileDBInstance = (IndustryRatingProfileDB) Test.createStub(IndustryRatingProfileDB.class, industryRatingProfileDBStubInstance);

        Test.startTest();
            String actualDescription = IndustryRatingProfileManager.getIndustryRatingDescriptionBySICCode(canRatingProfile.Digit_Code__c);
        Test.stopTest();

        System.assertEquals(null, actualDescription);
    }

    @isTest
    private static void calculateIndustryRatingWithSICCodeMapping() {

        CAN_Industry_Rating_Profile__c industryProfile = new CAN_Industry_Rating_Profile__c();
        industryProfile.Id = TestUtility.getFakeId(CAN_Industry_Rating_Profile__c.getSObjectType());
        industryProfile.Digit_Code__c = '47';
        industryProfile.Industry_Rating__c = 'A+ Medical';
        industryProfile.Excluded_For_Renewal__c = true;

        DefaultSICCodeToIndustryRatingMapping__mdt sicCodeMapping = new DefaultSICCodeToIndustryRatingMapping__mdt();
        sicCodeMapping.masterLabel = '47';
        sicCodeMapping.Type__c = 'New';
        sicCodeMapping.Industry_Rating__c = 'Prohibited';

        DBManagerTestsStub industryRatingProfileDBStubInstance = new DBManagerTestsStub();
        industryRatingProfileDBStubInstance.genericReturnObject = new List<CAN_Industry_Rating_Profile__c>{industryProfile};
        IndustryRatingProfileManager.industryRatingProfileDBInstance = (IndustryRatingProfileDB) Test.createStub(IndustryRatingProfileDB.class, industryRatingProfileDBStubInstance);

        Map<String, CAN_Industry_Rating_Profile__c> canIndustryProfileSicDescription = new  Map<String, CAN_Industry_Rating_Profile__c>();
        canIndustryProfileSicDescription.put(industryProfile.Digit_Code__c, industryProfile);
        OriginationHelper.canIndustryProfileSicDescription = canIndustryProfileSicDescription;

        Map<String, DefaultSICCodeToIndustryRatingMapping__mdt> sicCodeToIndustryRatingMapping = new  Map<String, DefaultSICCodeToIndustryRatingMapping__mdt>();
        sicCodeToIndustryRatingMapping.put(sicCodeMapping.masterLabel, sicCodeMapping);
        CustomMetaDataHelper.defaultSICCodeToIndustryRatingMapping = sicCodeToIndustryRatingMapping;

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        IndustryRatingProfileManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Status__c = 'NEW - ENTERED';
        application.Type__c = 'New';
        application.SIC_Code__c = '47';
        application.Industry_Rating__c = industryProfile.Industry_Rating__c;
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        applicationList.add(application);

        Test.startTest();
            IndustryRatingProfileManager.calculateIndustryRating(applicationList);
        Test.stopTest();

        System.assertEquals(sicCodeMapping.Industry_Rating__c, application.Industry_Rating__c);
    }
}