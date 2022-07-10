@isTest
public class TestPortalCreateApplicationAPI {
@IsTest
static void testPortalCreateAPI() {
        Test.startTest();
        genesis.TestHelper testHelp = new genesis.TestHelper();
        testHelp.createDefaultOrgParametersForCLProduct();
        RecordType recType = [SELECT Id, Name, SobjectType, DeveloperName
                                FROM RecordType
                                WHERE DeveloperName = 'Loan'
                                AND SObjectType = 'genesis__Applications__c'
                                LIMIT 1 ];
        
        TestUtility.runSetupData();
        genesis__Applications__c appln = TestUtility.createApplication();
    
        clcommon__Party_Type__c partyType =new clcommon__Party_Type__c(Name = CustomConstants.BORROWER);
        insert partyType;
              
        clcommon__CL_Product__c clProduct = new clcommon__CL_Product__c(clcommon__Product_Name__c = 'Dummy Product');
        insert clProduct; 
        
        Account testAccount = TestUtility.createAccount();
                               
        Contact testContact = TestUtility.createContact();
            
        clcommon.Response response = new PortalCreateApplicationAPI().invokeAction('', null, new Map<String, Object>{
                'accountId' => testAccount.Id,
                'contactId' => testContact.Id
        });
        
        system.debug('--response--'+response);
        system.assertNotEquals('SUCCESS',response.Status);
        Test.stopTest();
    }
}