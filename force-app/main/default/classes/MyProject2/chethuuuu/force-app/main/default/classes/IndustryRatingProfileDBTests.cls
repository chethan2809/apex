@isTest(isParallel=true)
private class IndustryRatingProfileDBTests {

    private static IndustryRatingProfileDB industryProfileDBInstance = new IndustryRatingProfileDB();

    @isTest
    static void getIndustryProfilesByNames() {

        Test.startTest();
            List<CAN_Industry_Rating_Profile__c> actualIndustryProfiles = industryProfileDBInstance.getIndustryProfiles();
        Test.stopTest();

        System.assert(actualIndustryProfiles != null);
        System.assert(actualIndustryProfiles.isEmpty());
    }

    @isTest
    static void getIndustryProfilesById() {

        Test.startTest();
        List<CAN_Industry_Rating_Profile__c> actualIndustryProfiles = industryProfileDBInstance.getIndustryProfilesById(
                new List<String> {'59'}
            );
        Test.stopTest();

        System.assert(actualIndustryProfiles != null);
        System.assert(actualIndustryProfiles.isEmpty());
    }
}