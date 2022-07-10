public with sharing class CollectionCongaGenerateURL {

    @AuraEnabled(cacheable = true)
    public static String generateCongaDocumentURL(Id paymentArrangementId, Id contactId){
        String baseURL = System.URL.getSalesforceBaseUrl().toExternalForm();
        String orgId = UserInfo.getOrganizationId();
        String congaDocURL = CollectionCaseConstants.CONGA_GENERATE_DOCUMENT_URL;
        CAN_Conga_Settings__c canCongaSettings = CAN_Conga_Settings__c.getOrgDefaults();
        String collectionCaseQuery=canCongaSettings.Collection_Case_Query__c;

        congaDocURL = congaDocURL.replace(CollectionCaseConstants.SFDC_BASEURL_KEY, baseURL);
        congaDocURL = congaDocURL.replace(CollectionCaseConstants.ORG_ID_KEY, orgId);
        congaDocURL = congaDocURL.replace(CollectionCaseConstants.REC_ID_KEY, paymentArrangementId);
        congaDocURL = congaDocURL.replace(CollectionCaseConstants.COLLECTION_CASE_QUERY_KEY, collectionCaseQuery);
        congaDocURL = congaDocURL.replace(CollectionCaseConstants.RECIPIENT_ID_KEY, contactId);
    return congaDocURL;
    }
}