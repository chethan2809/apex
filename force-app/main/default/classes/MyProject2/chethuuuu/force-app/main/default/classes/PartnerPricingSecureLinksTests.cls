@isTest
    private class PartnerPricingSecureLinksTests {

    @isTest
    private static void generatePartnerPricingSecureLinkTest() {
        genesis__Applications__c genesisApplication = new genesis__Applications__c();
        genesisApplication.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        CAN_General_Settings__c generalSettings = new CAN_General_Settings__c();
        generalSettings.Partner_Pricing_Secure_Link_Key__c = 'rWCV4l71cN6wvog3Hrthsw==';
        CustomSettingsHelper.generalSettings = generalSettings;

        Test.startTest();
            String actualPartnerPricingSecureLinks = PartnerPricingSecureLinks.generatePartnerPricingSecureLink(genesisApplication.Id);
        Test.stopTest();

        System.assert(actualPartnerPricingSecureLinks != null);
    }
 }