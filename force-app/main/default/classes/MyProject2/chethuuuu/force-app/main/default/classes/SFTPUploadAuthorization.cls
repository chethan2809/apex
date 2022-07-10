public class SFTPUploadAuthorization {
    public static final String SFTP_UPLOAD_AUTHORIZATION_SANDBOX = 'SFTP_Upload_Authorization_Sandbox';
    public static final String SFTP_UPLOAD_AUTHORIZATION_PRODUCTION = 'SFTP_Upload_Authorization_Production';

    public static String getIdToken() {
        API_Detail__mdt apiDetails;
        if(GeneralHelper.getOrgInformation.isSandbox) {
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(SFTP_UPLOAD_AUTHORIZATION_SANDBOX);
        } else {
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(SFTP_UPLOAD_AUTHORIZATION_PRODUCTION);
        }

        HttpRequest request = CallOutHelper.createRequest(apiDetails.Endpoint_URL__c, 'POST');

        request.setHeader('id', apiDetails.Header_Id__c);
        request.setHeader('issuer', apiDetails.Issuer__c);
        request.setHeader('subject', apiDetails.Subject__c);

        HttpResponse response = CallOutHelper.sendRequest(request);

        return String.valueOf(response.getBody());
    }
}