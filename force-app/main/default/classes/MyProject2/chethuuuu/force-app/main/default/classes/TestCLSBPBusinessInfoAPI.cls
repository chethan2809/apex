@isTest
public with sharing class TestCLSBPBusinessInfoAPI {
    @IsTest
    static void testBusinessInfo() {
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
        
        Account testAccount = new Account(Name = 'Test Borrower');
        insert testAccount;
                               
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Borrower', AccountId = testAccount.Id);
        insert testContact ;
        
        genesis__Applications__c appln = new genesis__Applications__c();
        appln.genesis__CL_Product__c = clProduct.Id;
        appln.genesis__Loan_Amount__c =  1000;
        
        clcommon.Response response = new CLSBPBusinessInfoAPI().invokeAction('', null, new Map<String, Object>{
                'accountId' => testAccount.Id,
                'contactId' => testContact.Id,
                'loanInfo' => JSON.serialize(appln)
        });
        
        system.debug('--response--'+response);
        system.assertEquals(response.Status,'ERROR');
        
    }

}