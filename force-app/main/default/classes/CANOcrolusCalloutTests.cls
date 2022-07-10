@isTest
private class CANOcrolusCalloutTests {
    @isTest
    private static void uploadFile() {
        String pkId  = '12730281';
        String filePath  = 'https://upload.test.com/happiest-minds-test/APP-0000000104/Bank_Statements/428551jul.pdf';
        CANOcrolusCallOut.token = 'idToken';

        Test.setMock(HttpCalloutMock.class, new CANOcrolusCallOutMock.CANOcrolusCallOutMockUploadFileSuccessResponse());
        Test.startTest();
            Map<String, Object> canOcrolusResponseMap = CANOcrolusCallOut.uploadFile(pkId, filePath);
        Test.stopTest();

        Map<String, Object> dataMap = (Map<String, Object>) canOcrolusResponseMap.get('Data');
        Map<String, Object> responseMap = (Map<String, Object>) dataMap.get('response');
        List<Object> uploadedDocsList = (List<Object>) responseMap.get('uploaded_docs');

        Map<String, Object> uploadedDocMap = (Map<String, Object>) (uploadedDocsList[0]);

        System.assertEquals('OK' , String.valueOf(dataMap.get('message')));
        System.assertEquals('BankStatement.pdf' , uploadedDocMap.get('name'));
    }

    @isTest
    private static void uploadFileBadRequest() {
        String pkId  = '12730281';
        String filePath  = 'https://upload.test.com/happiest-minds-test/APP-0000000104/Bank_Statements/428551jul.pdf';
        CANOcrolusCallOut.token = 'idToken';

        Test.setMock(HttpCalloutMock.class, new CANOcrolusCallOutMock.CANOcrolusCallOutMockUploadFileFailureResponse());

        Exception ex;
        Test.startTest();
        try {
            Map<String, Object> canOcrolusResponseMap = CANOcrolusCallOut.uploadFile(pkId, filePath);
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

        System.assertEquals('Status Code: Failed | Message: BookPK is Required' , ex.getMessage());
    }

    @isTest
    private static void uploadFileOcrolusError() {
        String pkId  = '12730281';
        String filePath  = 'https://upload.test.com/happiest-minds-test/APP-0000000104/Bank_Statements/428551jul.pdf';
        CANOcrolusCallOut.token = 'idToken';

        Test.setMock(HttpCalloutMock.class, new CANOcrolusCallOutMock.CANOcrolusCallOutMockUploadOcrolusFailureResponse());

        Exception ex;
        Test.startTest();
        try {
            Map<String, Object> canOcrolusResponseMap = CANOcrolusCallOut.uploadFile(pkId, filePath);
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

        String expectedValue = 'SUCCESSReference: 0234SDF3LCN22R | Request: {"filePath":"happiest-minds-test/APP-0000000104/Bank_Statements/428551jul.pdf","bookPK":12730281} | Response: {"REFERENCE":"0234SDF3LCN22R","MESSAGE":"SUCCESS","STATUS":"OK","Data":{"message":"Failed","status":400}}';

        System.assertEquals(expectedValue , ex.getMessage());
    }
}