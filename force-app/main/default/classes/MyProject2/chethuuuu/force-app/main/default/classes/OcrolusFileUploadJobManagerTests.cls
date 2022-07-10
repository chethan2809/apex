@isTest
private class OcrolusFileUploadJobManagerTests {
    static final String FILE_CONTENT = 'The attachment upload today is a bank statement';

    @isTest
    private static void uploadBankStatementToOcrolus(){
        String filepath = 'https://upload.test.com/happiest-minds-test/APP-0000000123/bank_statements/document2.pdf';
        String ocrolusPK = '12872807';
        CANOcrolusCallOut.token = 'idToken';

        Test.setMock(HttpCalloutMock.class, new CANOcrolusCallOutMock.CANOcrolusCallOutMockUploadFileSuccessResponse());
        Test.startTest();

             Map<String, Object> responseMap = OcrolusFileUploadJobManager.uploadBankStatementToOcrolus(ocrolusPK, filepath);

        Test.stopTest();

        String expectedValue = '23524722';

        System.assertEquals(expectedValue, responseMap.get('uploadedPK'));
    }

    @isTest
    private static void uploadBankStatementToOcrolusStatusException(){
        String filepath = 'https://upload.test.com/happiest-minds-test/APP-0000000123/bank_statements/document2.pdf';
        String ocrolusPK = '12872807';
        CANOcrolusCallOut.token = 'idToken';

        Test.setMock(HttpCalloutMock.class, new CANOcrolusCallOutMock.OcrolusCallOutMockUploadFileToBookErrorStatusResponse());
        Exception ex;
        Test.startTest();

        try {
             Map<String, Object> responseMap = OcrolusFileUploadJobManager.uploadBankStatementToOcrolus(ocrolusPK, filepath);
        } catch (Exception e) {
            ex = e;
        }

        Test.stopTest();

        String expectedValue = 'Upload failed : Failed';

        System.assertEquals(expectedValue, ex.getMessage());
    }

    @isTest
    private static void uploadBankStatementToOcrolusException(){
        String filepath = 'https://upload.test.com/happiest-minds-test/APP-0000000123/bank_statements/document2.pdf';
        String ocrolusPK = '12872807';
        CANOcrolusCallOut.token = 'idToken';

        Test.setMock(HttpCalloutMock.class, new CANOcrolusCallOutMock.CANOcrolusCallOutMockUploadFileToBookErrorResponse());
        Exception ex;
        Test.startTest();

            try {
                 Map<String, Object> responseMap = OcrolusFileUploadJobManager.uploadBankStatementToOcrolus(ocrolusPK, filepath);
            } catch (Exception e) {
                ex = e;
            }

        Test.stopTest();

        String expectedValue = 'Upload failed : {uploaded_docs=null}';
        System.assertEquals(expectedValue, ex.getMessage());
    }
}