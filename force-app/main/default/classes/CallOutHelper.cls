public class CallOutHelper {

    public static HttpRequest createRequest(String endPoint, String methodType) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod(methodType);
        request.setTimeout(100000);

        return request;
    }

    public static HttpRequest createLambdaRequest(String endPoint, String methodType, String ftpServer, API_Detail__mdt apiDetails, Blob body, String fileName, String fileType) {
        String boundary = '----------------------------741e90d31eff';

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod(methodType);
        request.setTimeout(100000);
        request.setHeader('Content-Type', 'multipart/form-data; boundary='+boundary);
        request.setHeader('file-type', fileType);
        request.setHeader('AccessKey', apiDetails.Client_Id__c);
        request.setHeader('SecretKey', apiDetails.Client_Secret__c);
        request.setHeader('file-name', fileName);
        request.setHeader('ftp-server', ftpServer);
        request.setBodyAsBlob(constructFormDataBody(body, fileName, fileType));
        return request;
    }

    public static HttpRequest createUCCRequest(String endPoint, String methodType, String fileType) {

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod(methodType);
        request.setTimeout(120000);
        request.setHeader('Content-Type', fileType);
        return request;
    }

    public static HttpResponse sendRequest(HttpRequest request) {
        Http httpObject = new Http();
        HttpResponse response = httpObject.send(request);

        if (response.getStatusCode() != 200) {
            String requestBody;
            if(request.getBody() != null) {
                requestBody = request.getBody();
            }
            throw new CallOutException(response.getStatusCode() + ' ' + response.getStatus() + ' | Request: ' + requestBody + ' | Response: ' + response.getBody());
        }

        System.debug(' ### ' + request.getEndPoint() + ' ### '+ response.getBody());

        return response;
    }

    public static Blob constructFormDataBody(Blob fileBody, String fileName, String contentType){
        String boundary = '----------------------------741e90d31eff';
        String header = '--'+ boundary + '\r\n' +'Content-Disposition: form-data; name="file"; filename="'+ fileName +'";Content-Type: ' + contentType + '\r\n';
        String footer = '--'+ boundary +'--';
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header +'\r\n\r\n'));

        while(headerEncoded.endsWith('=')) {
            header += ' ';
            headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header +'\r\n\r\n'));
        }

        String bodyEncoded = EncodingUtil.base64Encode(fileBody);
        Blob bodyBlob = null;
        String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());

       if(last4Bytes.endsWith('==')) {
          last4Bytes = last4Bytes.substring(0,2) + '0K';
          bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
          String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
          bodyBlob = EncodingUtil.base64Decode(headerEncoded + bodyEncoded + footerEncoded);

        } else if(last4Bytes.endsWith('=')) {
          last4Bytes = last4Bytes.substring(0,3) + 'N';
          bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
          footer = '\n' + footer;
          String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
          bodyBlob = EncodingUtil.base64Decode(headerEncoded + bodyEncoded + footerEncoded);

        } else {
          footer = '\r\n' + footer;
          String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
          bodyBlob = EncodingUtil.base64Decode(headerEncoded + bodyEncoded + footerEncoded);
        }

        return bodyBlob;
    }

    private class CallOutException extends Exception {}
}