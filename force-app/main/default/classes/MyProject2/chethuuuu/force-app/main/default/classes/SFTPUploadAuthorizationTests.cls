@isTest
private class SFTPUploadAuthorizationTests {

    @isTest
    private static void getIdToken() {
        Test.setMock(HttpCalloutMock.class, new SFTPUploadAuthorizationMock());

        Test.startTest();
            String token = SFTPUploadAuthorization.getIdToken();
        Test.stopTest();

        System.assertEquals('tokenAuthorization', token);
    }
}