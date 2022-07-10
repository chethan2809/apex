@isTest
private class CongaCalloutTests {
    @isTest
    private static void requestApplicationAgreementDocument() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        Id congaTemplateId = TestUtility.getFakeId(APXTConga4__Conga_Template__c.getSObjectType());
        Id congaQueryId = TestUtility.getFakeId(APXTConga4__Conga_Merge_Query__c.getSObjectType());
        Id recipientId = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        String templateIds = congaTemplateId;
        String queryIds= congaQueryId;
        String recipients = '&CSRecipient1=' + recipientId;
        CAN_Conga_Settings__c congaSettings = new CAN_Conga_Settings__c();
        congaSettings.Id = TestUtility.getFakeId(CAN_Conga_Settings__c.getSObjectType());
        congaSettings.Conga_Sign_BLA_Subject__c = 'Please sign your document';
        CustomSettingsHelper.congaSettings = congaSettings;

        System.Test.setMock(HttpCalloutMock.class, new CongaCalloutMock.CongaCalloutSuccessResponse());

        System.Test.startTest();
            HttpResponse response = CongaCallout.requestApplicationAgreementDocument(application, templateIds, queryIds, recipients, 3);
        System.Test.stopTest();

        Integer expectedValue = 200;
        System.assertEquals(expectedValue , response.getStatusCode());
    }
}