@isTest(isParallel=true)
private class SiteDBTests {

    private static SiteDB siteDBInstance = new SiteDB();

    @isTest
    private static void getAllSiteDetails() {

        Test.startTest();
            List<Site> siteList = siteDBInstance.getAllSiteDetails();
        Test.stopTest();

        System.assert(siteList != null);
    }
}