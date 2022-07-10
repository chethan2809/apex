public class CompuMailCallOut {

    public static final String COMPUMAIL_DOCUMENT_UPLOAD_API_SANDBOX = 'Compumail_Document_Upload_API_Sandbox';
    public static final String COMPUMAIL_DOCUMENT_UPLOAD_API_PRODUCTION = 'Compumail_Document_Upload_API_Production';
    public static final String COMPUMAIL_FTP_SERVER = 'compumail';

    public static Integer uploadCompuMail(String fileBody, String fileName, String fileType) {
        API_Detail__mdt apiDetails;
        if(GeneralHelper.getOrgInformation.isSandbox){
            if(GeneralHelper.domainUrl.contains('uat')) {
                apiDetails = CustomMetaDataHelper.apiDetailsByName.get(COMPUMAIL_DOCUMENT_UPLOAD_API_SANDBOX);
            }
        }else{
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(COMPUMAIL_DOCUMENT_UPLOAD_API_PRODUCTION);
        }
        Blob body = Blob.ValueOf(fileBody);
        HttpRequest request = CallOutHelper.createLambdaRequest(apiDetails.Endpoint_URL__c, 'POST', COMPUMAIL_FTP_SERVER, apiDetails, body, fileName, fileType);

        HttpResponse response = CallOutHelper.sendRequest(request);
        return response.getStatusCode();
    }
}