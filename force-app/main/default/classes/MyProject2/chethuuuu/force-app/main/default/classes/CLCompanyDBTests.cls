@isTest(isParallel=true)
private class CLCompanyDBTests {

    private static CLCompanyDB clCompanyDBInstance = new CLCompanyDB();

    @isTest
    private static void getCLCompanies() {

        Test.startTest();
            List<clcommon__Company__c> clCompanyList = clCompanyDBInstance.getCLCompanies();
        Test.stopTest();

        System.assert(clCompanyList != null);
        System.assert(clCompanyList.isEmpty());
    }
}