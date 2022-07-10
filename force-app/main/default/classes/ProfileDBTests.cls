@isTest(isParallel=true)
private class ProfileDBTests {
    private static ProfileDB profileDBInstance = new ProfileDB();

    @isTest
    private static void getProfileIdByNamesTest(){

        Test.startTest();
            List<Profile> profileList = profileDBInstance.getProfileIdByNames(new set<String> {'BrokerCommunityPlus'});
        Test.stopTest();

        System.assert(profileList != null);
    }

    @isTest
    private static void getAllProfilesTest(){

        Test.startTest();
            List<Profile> profileList = profileDBInstance.getAllProfiles();
        Test.stopTest();

        System.assert(profileList != null);
    }
}