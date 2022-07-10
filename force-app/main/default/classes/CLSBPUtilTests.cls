@isTest
private class CLSBPUtilTests {

    @isTest
    private static void getErrorResponse(){
        String errorMsg = 'Error Message';

        Test.startTest();
           clcommon.Response response = CLSBPUtil.getErrorResponse (errorMsg);
        Test.stopTest();

        System.assertEquals(errorMsg, response.errorMessage);
    }
}