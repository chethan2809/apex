@isTest(isParallel=true)
private class CompumailReturnsManagerTests {
    @isTest
    private static void processNCOAReturnFiles() {

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        List<Object> compumailReturnObject = new  List<Object>();
        compumailReturnObject.add(new List<Object>
        {
            '49', '48', '49', '32', '54', '57', '49', '48', '48', '48', '49', '51'
        });

        Map<String, Object> returnRecords = new Map<String, Object>();
        returnRecords.put('fileContentList', compumailReturnObject);

        Test.startTest();
            Integer filesProcessedCount = CompumailReturnsManager.processNCOAReturnFiles(returnRecords);
        Test.stopTest();

        System.assertEquals(1, filesProcessedCount);
    }
}