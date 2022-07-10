@IsTest
private class WasabiHTTPCallOutTests {
    static final String OBJECT_PATH = 'www.dummy.com/SYSTechnoogies';
    static final String DOCUMENT_TYPE = 'BusinessDocument';
    static final String FILE_NAME = 'BusinessDocument.pdf';
    static final String FILE_BODY = 'Attachment example. Upload it today';

    @isTest
    private static void sendDocument() {
        Blob body = Blob.valueOf(FILE_BODY);

        System.Test.setMock(HttpCalloutMock.class, new WasabiHTTPCallOutMocks.WasabiSendDocumentSuccessResponse());

        System.Test.startTest();
            String path = WasabiHTTPCallOut.sendDocument(OBJECT_PATH, body);
        System.Test.stopTest();

        String expectedValue = OBJECT_PATH;
        System.assertEquals(expectedValue , path);
    }

    @isTest
    private static void getFile() {

        System.Test.setMock(HttpCalloutMock.class, new WasabiHTTPCallOutMocks.WasabiGetDocumentSuccessResponse());

        System.Test.startTest();
            Blob body = WasabiHTTPCallOut.getFile(OBJECT_PATH);
        System.Test.stopTest();

        Blob expectedValue = Blob.valueOf('Attachment example. Upload it today');
        System.assertEquals(expectedValue, body);
    }
}