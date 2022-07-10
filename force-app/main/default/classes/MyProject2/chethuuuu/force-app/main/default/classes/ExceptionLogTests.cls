@isTest
private class ExceptionLogTests {

    public static void addError() {
        throw new fakeException('This is Error Log Message');
    }

    @isTest
    private static void insertExceptionLog() {
        Exception genericException;
        String message = 'This is Error Log Message';
        String appId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        String exString;
        try {
            ExceptionLogTests.addError();
        }catch(Exception e) {
            genericException = e;
            exString = genericException.getMessage();
        }
        Test.startTest();
            ExceptionLog.insertExceptionLog(genericException, message, appId);
        Test.stopTest();

        System.assertEquals(message, exString);
    }
    private class fakeException extends Exception {}
}