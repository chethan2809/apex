public class OcrolusCallOut {

    private static String toggleCheck(){
        return (GeneralHelper.getOrgInformation.isSandbox ? 'callout:Ocrolus_Sandbox/' : 'callout:Ocrolus_Production/') ;
    }

    public static Map<String, Object> createBookByName(String name) {
        String body = JSON.serialize(new Map<String, Object> { 'name' => name });

        HttpRequest request = new HttpRequest();
        request.setEndpoint(toggleCheck() + 'v1/book/add');
        request.setMethod('POST');
        request.setHeader('Content-Type','application/json');
        request.setHeader('Accept', '*/*');
        request.setBody(body);

        Http http = new Http();
        HttpResponse response = CallOutHelper.sendRequest(request);

       	Map<String, Object> responseMap = validateResponse(response);
        return (Map<String, Object>) responseMap.get('response');
    }

    public static Map<String, Object> uploadFileToBook(String pk, String fileName, String file64) {

        HttpRequest request = new HttpRequest();
        request.setEndpoint(toggleCheck() + 'v1/book/upload');
        request.setMethod('POST');
        request.setHeader( 'Content-Type', HttpMultipartFormBuilder.getContentType());
        request.setHeader('Accept', '*/*');
        request.setHeader( 'Accept-Encoding', 'gzip, deflate, br' );
        request.setHeader( 'Cache-Control', 'no-cache' );
        request.setTimeout( 120000 );

        String multiPartFormData = '';
        multiPartFormData += HttpMultipartFormBuilder.writeBoundary();
        multiPartFormData += HttpMultipartFormBuilder.writeBodyParameter( 'pk', EncodingUtil.urlEncode(pk, 'UTF-8'));
        multiPartFormData += HttpMultipartFormBuilder.writeBoundary();
        multiPartFormData += HttpMultipartFormBuilder.writeBlobBodyParameter(
            'upload', file64, fileName, 'application/pdf'
        );
        multiPartFormData += HttpMultipartFormBuilder.writeBoundary(HttpMultipartFormBuilder.EndingType.NONE);

        Blob formBlob = EncodingUtil.base64Decode( multiPartFormData );
        request.setBodyAsBlob( formBlob );

        Http http = new Http();
        HttpResponse response = CallOutHelper.sendRequest(request);

       	Map<String, Object> responseMap = validateResponse(response);
        return (Map<String, Object>) responseMap.get('response');
    }

    public static Map<String, Object> getBookStatus(String pkId) {
        String body = JSON.serialize(new Map<String, Object> { 'pk' => pkId });

        HttpRequest request = new HttpRequest();
        request.setEndpoint(toggleCheck() + 'v1/book/status');
        request.setMethod('POST');
        request.setHeader('Content-Type','application/json');
        request.setHeader('Accept', '*/*');
        request.setBody(body);

        Http http = new Http();
        HttpResponse response = CallOutHelper.sendRequest(request);

        Map<String, Object> responseMap = validateResponse(response);
        return (Map<String, Object>) responseMap.get('response');
    }

    public static Map<String, Object> requestAsyncAnalytics(String pkId) {
        Map<String, Object> bodyMap = new Map<String, Object>();
        bodyMap.put('pk', pkId);
        bodyMap.put('extra_fields', CustomMetaDataHelper.defaultOcrolusSetting.Analytics_Extra_Fields__c);
        String body = JSON.serialize(bodyMap);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(toggleCheck() + 'v1/book/analytics/async/request');
        request.setMethod('POST');
        request.setHeader('Content-Type','application/json');
        request.setHeader('Accept', '*/*');
        request.setBody(body);

        Http http = new Http();
        HttpResponse response = CallOutHelper.sendRequest(request);

       	Map<String, Object> responseMap = validateResponse(response);
        return (Map<String, Object>) responseMap.get('response');
    }

    private static Map<String, Object> validateResponse(HttpResponse response) {
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

        if(responseMap.get('status') == 200) {
            return responseMap;
        }

        throw new OcrolusCallOutException('Status Code: ' + responseMap.get('status') + ' | Message: ' + responseMap.get('message'));
    }

    public static Blob getOcrolusAnalyticsExcel(String pkId) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(toggleCheck() + 'v1/book/export/xlsx/analytics');
        request.setMethod('GET');
        request.setHeader('Content-Type', HttpMultipartFormBuilder.getContentType());
        request.setHeader('Accept', '*/*');
        request.setHeader( 'Accept-Encoding', 'gzip, deflate, br' );
        request.setHeader( 'Cache-Control', 'no-cache' );
        request.setTimeout( 120000 );

        String multiPartFormData = '';
        multiPartFormData += HttpMultipartFormBuilder.writeBoundary();
        multiPartFormData += HttpMultipartFormBuilder.writeBodyParameter( 'pk', EncodingUtil.urlEncode(pkId, 'UTF-8'));
        multiPartFormData += HttpMultipartFormBuilder.writeBoundary(HttpMultipartFormBuilder.EndingType.NONE);
        Blob formBlob = EncodingUtil.base64Decode( multiPartFormData );

        request.setBodyAsBlob( formBlob );
        request.setHeader('Content-Length', String.valueOf(multiPartFormData.length()));

        HttpResponse response = CallOutHelper.sendRequest(request);

        if(response.getBodyAsBlob() != null) {
            return response.getBodyAsBlob();
        }
        throw new OcrolusCallOutException('Status Code: ' + response.getStatusCode() + ' | Message: ' + response.getStatus());
    }

    public static Map<String, Object> deleteFile(String docUploadedPKId) {

        String body = JSON.serialize(new Map<String, Object> { 'doc_id' => docUploadedPKId });

        HttpRequest request = new HttpRequest();
        request.setEndpoint(toggleCheck() + 'v1/document/remove');
        request.setMethod('POST');
        request.setHeader('Content-Type','application/json');
        request.setHeader('Accept', '*/*');
        request.setBody(body);

        Http http = new Http();
        HttpResponse response = CallOutHelper.sendRequest(request);

        Map<String, Object> responseMap = validateResponse(response);
        return (Map<String, Object>) responseMap.get('response');
    }

    private class OcrolusCallOutException extends Exception {}
}