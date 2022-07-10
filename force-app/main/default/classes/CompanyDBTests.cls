@isTest(isParallel=true)
private class CompanyDBTests {

    private static CompanyDB companyDBInstance = new CompanyDB();

    @isTest
    private static void getCompaniesNames() {

        Test.startTest();
            List<genesis__Company__c> companyList = companyDBInstance.getCompanies();
        Test.stopTest();

        System.assert(companyList != null);
        System.assert(companyList.isEmpty());
    }
}