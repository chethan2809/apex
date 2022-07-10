@isTest(isParallel=true)
private class GAVMatrixDetailDBTests {

    private static GAVMatrixDetailDB gavMatrixDetailDBInstance = new GAVMatrixDetailDB();

    @isTest
    private static void getAllGAVMatrixDetails() {

        Test.startTest();
            List<CAN_GAV_Matrix_Detail__c> gavMatrixDetailList = gavMatrixDetailDBInstance.getAllGAVMatrixDetails();
        Test.stopTest();

        System.assert(gavMatrixDetailList != null);
        System.assert(gavMatrixDetailList.isEmpty());
    }

    @isTest
    private static void getGAVMatrixDetailsByRandomNumber() {

        Test.startTest();
            List<CAN_GAV_Matrix_Detail__c> gavMatrixDetailList = gavMatrixDetailDBInstance.getGAVMatrixDetailsByRandomNumber(1);
        Test.stopTest();

        System.assert(gavMatrixDetailList != null);
        System.assert(gavMatrixDetailList.isEmpty());
    }

}