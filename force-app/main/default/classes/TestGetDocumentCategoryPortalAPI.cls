@isTest
public with sharing class TestGetDocumentCategoryPortalAPI {
     @IsTest
    static void testGetDocumentCategoryPortal() {
        genesis.TestHelper testHelp = new genesis.TestHelper();
        testHelp.createDefaultOrgParametersForCLProduct();
        RecordType recType = [SELECT Id, Name, SobjectType, DeveloperName
                                FROM RecordType
                                WHERE DeveloperName = 'Loan'
                                AND SObjectType = 'genesis__Applications__c'  
                                LIMIT 1 ];

        clcommon__Party_Type__c partyType =new clcommon__Party_Type__c(Name = CustomConstants.BORROWER);
        insert partyType;
        clcommon__CL_Product__c clProduct = new clcommon__CL_Product__c(clcommon__Product_Name__c = 'Dummy Product');
        insert clProduct;

        Account testAccount = TestUtility.createAccount();

        Contact testContact = TestUtility.createContact();

        TestUtility.runSetupData();
        genesis__Applications__c appln = TestUtility.createApplication();

        clcommon__Party__c party = new clcommon__Party__c();
        party.clcommon__Account__c = testAccount.Id;
        party.genesis__Application__c = appln.Id;
        party.clcommon__Type__c = partyType.Id;
        insert party;

        clcommon__Document_Category__c docCatParent = new clcommon__Document_Category__c();
        docCatParent.clcommon__Category_Name__c = 'TestParent';
        docCatParent.clcommon__Status__c = 'SUBMITTED';
        insert docCatParent;

        clcommon__Document_Category__c docCatChild = new clcommon__Document_Category__c();
        docCatChild.clcommon__Category_Name__c = 'Test';
        docCatChild.clcommon__Status__c = 'SUBMITTED';
        docCatChild.genesis__Application__c = appln.Id;
        docCatChild.clcommon__Parent_Document_Category__c = docCatParent.Id;
        insert docCatChild;

        Test.startTest();
        if (appln != null){
            clcommon.Response response = new GetDocumentCategoryPortalAPI().invokeAction('', null, new Map<String, Object>{
                    'accountId' => testAccount.Id,
                    'contactId' => testContact.Id,
                    'appId' => appln.Id,
                    'party' => partyType.Name,
                    'loanInfo' => JSON.serialize(appln)
            });
        }
        clcommon.Response response = new GetDocumentCategoryPortalAPI().invokeAction('', null, new Map<String, Object>{
            'accountId' => testAccount.Id,
                'contactId' => testContact.Id,
                'appId' => null,
                'party' => partyType.Name,
                'loanInfo' => JSON.serialize(appln)
        });

        system.assertNotEquals('SUCCESS',response.Status);

        Test.stopTest();
    }
}