public class CongaManager {

    @TestVisible
    private static ApplicationDB applicationDBInstance = new ApplicationDB();
    @TestVisible
    private static CongaQueryDB congaQueryDBInstance = new CongaQueryDB();
    @TestVisible
    private static CongaTemplateDB congaTemplateDBInstance = new CongaTemplateDB();
    @TestVisible
    private static PartyDB partyDBInstance = new PartyDB();

    public static void processApplicationCongaDocuments(Map<String, Object> requestRecord) {

        Id applicationId = (Id) requestRecord.get('parentId');
        String templateType = (String) requestRecord.get('templateType');
        Integer apiMODE = ((Boolean) requestRecord.get('sendForESign')? 3 : 1);

        List<genesis__Applications__c> applicationList = applicationDBInstance.getApplicationsByIds(new Set<Id> {applicationId});
        if(applicationList.isEmpty()) {
            throw new CongaCalloutManagerException('No Application found with Id ' + applicationId);
        }
        genesis__Applications__c application = applicationList.get(0);

        String queryIds = '';
        for(APXTConga4__Conga_Merge_Query__c query : congaQueryDBInstance.getCongaQueriesByMatchingName(templateType)) {
            queryIds += (queryIds != '')? ',' + query.Id : query.Id;
        }

        Set<String> eligibleTemplateGroups = Congas.buildApplicationTemplateGroupNames(application);
        String templateIds = '';
        for(APXTConga4__Conga_Template__c template : congaTemplateDBInstance.getCongaTemplatesByGroupNames(eligibleTemplateGroups)) {
            templateIds += (templateIds != '')? ',' + template.Id : template.Id;
        }

        String recipients = '';
        Integer recipientCount = 1;

        for(clcommon__Party__c party : partyDBInstance.getGuarantorANDBrokerPartiesByApplicationIds(new Set<Id> { applicationId })) {
            if(party.clcommon__Type__r.Name == GeneralConstants.PARTY_TYPE_BROKER) {
                recipients += '&CSRecipient' + recipientCount + '=' + party.clcommon__Contact__c + '&csRole' + recipientCount + '=CC';
            } else {
                recipients += '&CSRecipient' + recipientCount + '=' + party.clcommon__Contact__c;
            }
            recipientCount++;
        }

        CongaCallout.requestApplicationAgreementDocument(application, templateIds, queryIds, recipients, apiMODE);
    }

    private class CongaCalloutManagerException extends Exception {}
}