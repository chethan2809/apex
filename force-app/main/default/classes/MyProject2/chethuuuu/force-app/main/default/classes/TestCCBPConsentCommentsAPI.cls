@IsTest
private class TestCCBPConsentCommentsAPI {
@testSetup static void dataSetup()
    {
        TestUtility.runSetupData();
        Account acc=TestUtility.createAccount();
        contact con=TestUtility.createContact();
        genesis__Applications__c genApp=TestUtility.createApplication();
    }

    @isTest
    private static void testCCBPConsentCommentsAPI()
    {
        genesis__Applications__c appln=[select id from genesis__Applications__c limit 1];
        Map<String,Object> con= new Map<String,String>{'loan__Contact_Type__c'=>Leads.GUARANTOR ,'Birthdate' => '2000-03-11','Title__c' => 'Owner','FirstName' => 'Contact ','LastName' => ' Lastname','Email' => 'Testcontactx@email.com','MobilePhone' => ''};
        Map<String,Object> contactMap = new Map<String,Object>{'clcommon__Contact__r.' => con};
        Map<String, Object> argumentsFromPortal = new Map<String, Object>();
        argumentsFromPortal.put('partnerInfo','partnerInfo');
        List<clcommon__Disclosure_Definition__c> disclosuresList = new List<clcommon__Disclosure_Definition__c>();
        Map<String,clcommon__Disclosure_Definition__c> disclosureNameToObjectMap = new Map<String,clcommon__Disclosure_Definition__c>();
        clcommon__Disclosure_Definition__c disclosureDefinition = new clcommon__Disclosure_Definition__c();
        disclosureDefinition.Name = PortalConstants.CC_Broker_General_Disclosure;
        disclosureDefinition.clcommon__Description__c = 'Description';
        insert disclosureDefinition;
        disclosuresList.add(disclosureDefinition);
        disclosureNameToObjectMap.put('DisclosureName',disclosureDefinition);
        argumentsFromPortal.put('DisclosureName',disclosureNameToObjectMap);

        Account acc = [SELECT Id,Name
                       FROM Account
                       LIMIT 1];

        genesis__Applications__c genApplication = [SELECT Id,Name,SIC_Code__c,Business_Start_Date__c
                                                   FROM genesis__Applications__c
                                                   LIMIT 1];
        genApplication.Business_Start_Date__c = Date.today();
        update genApplication;
        argumentsFromPortal.put('applicationId',genApplication.Id);

        clcommon__Party__c party = new clcommon__Party__c();
        party.clcommon__Account__c = acc.Id;
        party.genesis__Application__c = genApplication.Id;
        insert party;

        Test.startTest();
            clcommon.Response response = new CCBPConsentCommentsAPI().invokeAction('', null, new Map<String, Object>{'reviewComment' => string.valueof(appln.Id)});
            clcommon.Response response1 = new CCBPConsentCommentsAPI().invokeAction('', null,argumentsFromPortal);
            clcommon.Response response2 = new CCBPConsentCommentsAPI().invokeAction('', new List<String>{PortalConstants.CC_Broker_General_Disclosure},argumentsFromPortal);
        Test.stopTest();

        System.assertEquals(response.Status,'ERROR');
        System.assertEquals(PortalConstants.CC_Broker_General_Disclosure, disclosureDefinition.Name);
    }
}