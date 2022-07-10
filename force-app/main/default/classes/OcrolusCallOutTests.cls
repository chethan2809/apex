@isTest
public class OcrolusCallOutTests{
    @isTest
    private static void createBookByName() {
        String name = '00D17000000L7TQEA0-APP-0000000102';
        System.Test.setMock(HttpCalloutMock.class, new OcrolusCallOutMock.OcrolusCallOutMockCreateBookByNameSuccessResponse());

        System.Test.startTest();
            Map<String, Object> responseMap = OcrolusCallOut.createBookByName(name);
        System.Test.stopTest();

        String expectedValue = 'Book Created Successfully';
        System.assertEquals(expectedValue , String.valueOf(responseMap.get('msg')));
    }

    @isTest
    private static void uploadFileToBook() {
        String pk = '12872807';
        Blob fileBlob = Blob.valueOf('Attachment example. Upload it today');
        String file64 = EncodingUtil.base64Encode(fileBlob);
        String fileName = 'BankStatement.pdf';

        System.Test.setMock(HttpCalloutMock.class, new OcrolusCallOutMock.OcrolusCallOutMockUploadFileToBookSuccessResponse());

        System.Test.startTest();
            Map<String, Object> responseMap = OcrolusCallOut.uploadFileToBook(pk, fileName, file64);
        System.Test.stopTest();

        String expectedValue = 'BankStatement.pdf';
        String actualValue = '';
        List<Object> documentList = (List<Object>) responseMap.get('uploaded_docs');
        for (Object document : documentList) {
            Map<String, Object> documentMap = (Map<String, Object>) document;
            actualValue = String.valueOf(documentMap.get('name'));
        }

        System.assertEquals(expectedValue , actualValue);
    }

    @isTest
    private static void getBookStatus() {
        String pk = '12872807';
        System.Test.setMock(HttpCalloutMock.class, new OcrolusCallOutMock.OcrolusCallOutMockGetBookStatusSuccessResponse());

        System.Test.startTest();
            Map<String, Object> responseMap = OcrolusCallOut.getBookStatus(pk);
        System.Test.stopTest();

        String expectedValue = 'VERIFICATION_COMPLETE';
        String actualValue = '';
        List<Object> documentList = (List<Object>) responseMap.get('docs');
        for (Object document : documentList) {
            Map<String, Object> documentMap = (Map<String, Object>) document;
            actualValue = String.valueOf(documentMap.get('status'));
        }

        System.assertEquals(expectedValue , actualValue);
    }

    @isTest
    private static void requestAsyncAnalytics(){
        String pk = '12872807';
        System.Test.setMock(HttpCalloutMock.class, new OcrolusCallOutMock.OcrolusCallOutMockRequestAsyncAnalyticsSuccessResponse());
        System.Test.startTest();
            Map<String, Object> responseMap = OcrolusCallOut.requestAsyncAnalytics(pk);
        System.Test.stopTest();
        String expectedValue = 'b735f9e3-8d97-4978-a72b-fe76fbe44584';

        System.assertEquals(expectedValue , String.valueOf(responseMap.get('analytics_request_id')));
    }

    @isTest
    private static void getOcrolusAnalyticsExcel() {
        String pk = '12872807';
        System.Test.setMock(HttpCalloutMock.class, new OcrolusCallOutMock.OcrolusCallOutMockGetOcrolusAnalyticsExcelSuccessResponse());
        System.Test.startTest();
            Blob responseBlob = OcrolusCallOut.getOcrolusAnalyticsExcel(pk);
        System.Test.stopTest();

        Blob expectedValue = Blob.valueOf('Attachment example. Upload it today');
        System.assertEquals(expectedValue , responseBlob);
    }

    @isTest
    private static void deleteFile() {
        String docId = '12872807';
        System.Test.setMock(HttpCalloutMock.class, new OcrolusCallOutMock.OcrolusCallOutMockGetdeleteFileSuccessResponse());

        System.Test.startTest();
            Map<String, Object> responseMap = OcrolusCallOut.deleteFile(docId);
        System.Test.stopTest();

        String expectedValue = 'DELETING';
        System.assertEquals(expectedValue , String.valueOf(responseMap.get('document_status')));
    }
}