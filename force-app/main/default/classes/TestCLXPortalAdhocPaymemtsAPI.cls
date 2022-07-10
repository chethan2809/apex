@IsTest
public class TestCLXPortalAdhocPaymemtsAPI {
 @testSetup static void dataSetup() {
        // user usr= TestUtility.createUser( new Map<String,String>());
    }
    @isTest
    static void CLXPortalAdhocPaymemtsAPI()
    {
        Account acc= TestUtility.createAccount();
        Contact con = new Contact(FirstName = 'Test', LastName = 'Borrower',accountid=acc.id);
        insert con ;
       test.startTest();
        clcommon.Response response = new CLXPortalAdhocPaymemtsAPI().invokeAction('', null, new Map<String, Object>{
       'contractId' => con.id,
           'paymentAmt' => 200.00,
           'payoffFlg' => true
               });
        test.stoptest();  
    }

    @isTest
    static void CLXPortalAdhocPaymemtsAPI1() 
    {
        Account acc= TestUtility.createAccount();
        Contact con = new Contact(FirstName = 'Test', LastName = 'Borrower',accountid=acc.id);
        insert con ;
       test.startTest();
       map<String,String> afpDetails= new Map<String,String>{'contractId' => string.valueOf(con.id), 'paymentAmt' => '200.00', 'payoffFlg' => 'true'};
        clcommon.Response response = new CLXPortalAdhocPaymemtsAPI().invokeAction('', null, new Map<String, Object>{
              'argumentsFromPortal' => JSON.serialize(afpDetails) 
        });
        test.stoptest();  
    }
    
    @isTest
    static void CLXPortalAdhocPaymemtsAPI2() 
    {
        Account acc= TestUtility.createAccount();
        Contact con = new Contact(FirstName = 'Test', LastName = 'Borrower',accountid=acc.id);
        insert con ;
       test.startTest();
       map<String,String> afpDetails= new Map<String,String>{'contractId' => '', 'paymentAmt' => 'test', 'payoffFlg' => 'test'};
        clcommon.Response response = new CLXPortalAdhocPaymemtsAPI().invokeAction('', null, new Map<String, Object>{
              //'argumentsFromPortal' => JSON.serialize(afpDetails) 
              'contractId' => con.Id,
               'paymentAmt' => 0.0,
               'payoffFlg' => true
              
        });
        test.stoptest();  
    }
    
    /*@isTest
    static void CLXPortalAdhocPaymemtsAPIException() 
    {
        Account acc= testfactory.createAccount(new map<String,String>());
        Contact con = new Contact(FirstName = 'Test', LastName = 'Borrower',accountid=acc.id);
        insert con;
        
        Map<String,Object> con= new Map<String,String>{'loan__Contact_Type__c'=>Leads.GUARANTOR ,'Birthdate' => '2000-03-11','Title__c' => 'Owner','FirstName' => 'Contact ','LastName' => ' Lastname','Email' => 'Testcontactx@email.com', 'contractId' => 'contractid'};
        Map<String,Object> contactMap = new Map<String,Object>{'loan__Loan_Account__c' => con};
        
       test.startTest();
        clcommon.Response response = new CLXPortalAdhocPaymemtsAPI().invokeAction('', null, contactMap);
        test.stoptest();  
    }*/
}