@isTest
public with sharing class TestCLSBPCreateApplicationAPI {
     @IsTest
    static void testCreateNewApplication() {
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
        appln.genesis__Account__c = testAccount.Id;
        appln.genesis__Expected_Start_Date__c = system.today();
        appln.genesis__Expected_First_Payment_Date__c = system.today();
        appln.genesis__Due_Day__c = system.today().day();
        
        clcommon__Party__c party = new clcommon__Party__c();
        party.clcommon__Account__c = testAccount.Id;
        party.genesis__Application__c = appln.Id;
        party.clcommon__Type__c = partyType.Id;
        insert party;
   
        Map<String,Object> fields = new Map<String,Object>();
        fields.put(CLSBPPortalConstants.APPLICATION_ID,appln.Id);
               
        clcommon.Response response = new CLSBPCreateApplicationAPI().invokeAction('', null, new Map<String, Object>{
                'accountId' => testAccount.Id,
                'contactId' => testContact.Id,
                'loanInfo' => JSON.serialize(appln)
                //'KEY_RESPONSE' => fields
        });
        
        system.debug('--response--'+response);
        system.assertEquals(response.Status,'ERROR');
        
    }
    @IsTest
    static void testCreateNewApplicationExp() {
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
        
       Map<String,Object> fields = new Map<String,Object>();
        fields.put(CLSBPPortalConstants.APPLICATION_ID,appln.Id);
        
        clcommon.Response response = new CLSBPCreateApplicationAPI().invokeAction('', null, new Map<String, Object>{
                'accountId' => testAccount.Id,
                'contactId' => testContact.Id,
                'loanInfo' => JSON.serialize(appln)
        });
        
        system.debug('--response--'+response);
        system.assertEquals(response.Status,'ERROR');
    }

}