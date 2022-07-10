@isTest(isParallel=true)
private class UserPackageLicenseDBTests {

    private static UserPackageLicenseDB userPackageLicenseDBInstance = new UserPackageLicenseDB();

    @isTest
    private static void getLicensesByPackageNameSpacePrefixAndUserIds() {
        Id userId = TestUtility.getFakeId(User.getSObjectType());

        Test.startTest();
            List<UserPackageLicense> userPackageLicensesList = userPackageLicenseDBInstance.getLicensesByPackageNameSpacePrefixAndUserIds(GeneralConstants.SKUID_PACKAGE_NAME_SPACE_PREFIX, new Set<Id> {userId});
        Test.stopTest();

        System.assert(userPackageLicensesList != null);
        System.assert(userPackageLicensesList.isEmpty());
    }
}