@isTest
private class HttpMultipartFormBuilderTests {

    @isTest
    private static void writeBlobBodyParameterDoubleEqualsTo() {

        Test.startTest();
            HttpMultipartFormBuilder.EndingType enumType = HttpMultipartFormBuilder.EndingType.NONE;
            String contentType = HttpMultipartFormBuilder.getContentType();
            String writeBoundary = HttpMultipartFormBuilder.writeBoundary();
            String writeBoundary2 = HttpMultipartFormBuilder.writeBoundary(enumType);
            String writeBodyParameter = HttpMultipartFormBuilder.writeBodyParameter('TestKey', 'TestValue');
            String multipartFormBuilder = HttpMultipartFormBuilder.writeBlobBodyParameter('TestKey', 'file64==', 'filename', 'mimeType');
        Test.stopTest();

        System.assert(contentType != null);
        System.assert(writeBoundary != null);
        System.assert(writeBodyParameter != null);
        System.assert(multipartFormBuilder != null);
    }

    @isTest
    private static void writeBlobBodyParameterEqualsTo() {

        Test.startTest();
            HttpMultipartFormBuilder.EndingType enumType = HttpMultipartFormBuilder.EndingType.CR;
            String contentType = HttpMultipartFormBuilder.getContentType();
            String writeBoundary = HttpMultipartFormBuilder.writeBoundary();
            String writeBoundary2 = HttpMultipartFormBuilder.writeBoundary(enumType);
            String writeBodyParameter = HttpMultipartFormBuilder.writeBodyParameter('TestKey', 'TestValue');
            String multipartFormBuilder = HttpMultipartFormBuilder.writeBlobBodyParameter('TestKey', 'file64=', 'filename', 'mimeType');
        Test.stopTest();

        System.assert(contentType != null);
        System.assert(writeBoundary != null);
        System.assert(writeBodyParameter != null);
        System.assert(multipartFormBuilder != null);
    }
}