public class CongaCallout {

    public static HttpResponse requestApplicationAgreementDocument(
        genesis__Applications__c application, String templateIds, String queryIds, String recipients, Integer apiMODE
    ) {

        String sessionId = UserInfo.getOrganizationId() + '' + UserInfo.getSessionId().SubString(15);
        String apiPartnerServerURL370 = URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/37.0/'
            + UserInfo.getOrganizationId();

        CAN_Conga_Settings__c congaSetting = CustomSettingsHelper.congaSettings;

        String endpoint = 'https://composer.congamerge.com/composer8/index.html?sessionId='
            + sessionId + '&serverUrl=' + apiPartnerServerURL370
            + '&id=' + application.Id
            + congaSetting.Conga_Generic_BLA_Parameter__c
            + '&CSVisible=1'
            + '&TemplateID=' + templateIds + '&QueryId=' + queryIds
            + '&OFN={Template.Label}%20' + application.Name
            + recipients
            + '&CSEmailSubject=' + EncodingUtil.urlEncode(congaSetting.Conga_Sign_BLA_Subject__c, 'UTF-8')
            + '&CSMultiDocs=1&APDF=0'
            + '&APIMODE=' + apiMODE;

        HttpRequest request = CallOutHelper.createRequest(endpoint, 'GET');
        request.setTimeout(60000);

        return CallOutHelper.sendRequest(request);
    }
}