public class SFTPScoringRawDataCallOut {
    public static final String SFTP_RAWDATA_UPLOAD_API_SANDBOX = 'SFTP_RawData_Upload_API_Sandbox';
    public static final String SFTP_RAWDATA_UPLOAD_API_PRODUCTION = 'SFTP_RawData_Upload_API_Production';

    public static Integer uploadSFTPRawData(String folderName, Blob fileBody, String fileType, String fileName) {
        API_Detail__mdt apiDetails;
        String boundary = '----------------------------741e90d31eff';

        if(GeneralHelper.getOrgInformation.isSandbox){
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(SFTP_RAWDATA_UPLOAD_API_SANDBOX);
        }else{
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(SFTP_RAWDATA_UPLOAD_API_PRODUCTION);
        }

        HttpRequest request = CallOutHelper.createRequest(apiDetails.Endpoint_URL__c, 'POST');
        request.setHeader('Content-Type', 'multipart/form-data; boundary='+boundary);
        request.setHeader('file-name', folderName + '/' +fileName);
        request.setHeader('file-type', fileType);
        request.setHeader('AccessKey', apiDetails.Client_Id__c);
        request.setHeader('SecretKey', apiDetails.Client_Secret__c);
        request.setHeader('folder-name', folderName);
        request.setBodyAsBlob(CallOutHelper.constructFormDataBody(fileBody, fileName, fileType));

        HttpResponse response = CallOutHelper.sendRequest(request);
        return response.getStatusCode();
    }
}