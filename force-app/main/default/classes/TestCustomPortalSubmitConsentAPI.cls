@IsTest(isParallel=true)
public class TestCustomPortalSubmitConsentAPI {
    @testSetup
    private static void setup() {
            TestUtility.runSetupData();
            genesis__Applications__c application = TestUtility.createApplication();            

            clcommon__Disclosure_Definition__c disclosureDefinition = new clcommon__Disclosure_Definition__c();
            disclosureDefinition.Name = 'clx_consumer_GeneralDisclosure';
            disclosureDefinition.clcommon__Disclosure_Type__c = 'E-Sign';
            INSERT disclosureDefinition;
    }

    @isTest
    static void invokeActionSuccess() 
    {
        genesis__Applications__c application = [SELECT Id, genesis__Account__c, Name FROM genesis__Applications__c];
        application.SIC_Code__c = '25';
        application.Business_Start_Date__c = Date.newInstance(2016, 12, 9);
        UPDATE application;

        clcommon__Party__c party = new clcommon__Party__c();
        party.genesis__Application__c = application.Id;
        party.clcommon__Account__c = application.genesis__Account__c;
        party.Competitor_Amount__c = 1000;
        INSERT party;

        Map<String, Object> argumentToAPI = new Map<String, Object>{
            PortalConstants.APPLICATION_ID => application.Id
        };

        List<String> disclosures = new List<String>{
            'clx_consumer_GeneralDisclosure'
        };

       CustomPortalSubmitConsentAPI consentAPI = new CustomPortalSubmitConsentAPI();            

       Test.startTest();
            clcommon.Response response = consentAPI.invokeAction(null, disclosures, argumentToAPI);
       Test.stopTest();

       System.assertEquals(true, [SELECT Id, Credit_Check_Consent__c FROM genesis__Applications__c].Credit_Check_Consent__c);
    }
    @isTest
    static void invokeActionFail() 
    {
        genesis__Applications__c application = [SELECT Id, genesis__Account__c, Name FROM genesis__Applications__c];


        Map<String, Object> argumentToAPI = new Map<String, Object>{
            PortalConstants.APPLICATION_ID => null
        };

        List<String> disclosures = new List<String>{
            'clx_consumer_GeneralDisclosure'
        };

       CustomPortalSubmitConsentAPI consentAPI = new CustomPortalSubmitConsentAPI();            

       Test.startTest();
            clcommon.Response response = consentAPI.invokeAction(null, disclosures, argumentToAPI);
       Test.stopTest();

       System.assertEquals(false, [SELECT Id, Credit_Check_Consent__c FROM genesis__Applications__c].Credit_Check_Consent__c);
    }
}