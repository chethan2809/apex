@isTest(isParallel=true)
private class BusinessHourDBTests {

    @isTest
    static void getOrgActiveBusinessHours() {
        BusinessHourDB businessHourDBInstance = new BusinessHourDB();

        Test.startTest();
            List<BusinessHours> businessHourList = businessHourDBInstance.getOrgActiveBusinessHours();
        Test.stopTest();

        System.assert(businessHourList != null);
    }
}