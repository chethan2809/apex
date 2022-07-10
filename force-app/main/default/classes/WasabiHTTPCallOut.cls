public class WasabiHTTPCallOut {

    public static String getBaseEndpoint(){

        String baseEndpoint;
        if(GeneralHelper.getOrgInformation.isSandbox) {
            baseEndpoint = 'callout:Wasabisys_Sandbox/';
        } else {
            baseEndpoint = 'callout:Wasabisys_Production/';
        }
        return baseEndpoint;
    }

    public static String sendDocument(String path, Blob file) {

        HttpRequest request = CallOutHelper.createRequest(getBaseEndpoint() + path, 'PUT');
        request.setHeader('Connection', 'keep-alive');
        request.setHeader('ACL', 'public-read-write');
        request.setBodyAsBlob(file);

        HttpResponse response = CallOutHelper.sendRequest(request);

        return path;
    }

    public static Blob getFile(String path) {
        String filePath = path.substringAfter('com/');

        HttpRequest request = CallOutHelper.createRequest(getBaseEndpoint() + filePath, 'GET');

        HttpResponse response = CallOutHelper.sendRequest(request);

        return response.getBodyAsBlob();
    }

    public static void deleteFileFromWasabi(String path) {
        String filePath = path.substringAfter('com/');

        HttpRequest request = CallOutHelper.createRequest(getBaseEndpoint() + filePath, 'DELETE');

        HttpResponse response = CallOutHelper.sendRequest(request);

    }
}