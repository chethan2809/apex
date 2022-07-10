@isTest
private class LexixNexissTests {
@isTest
    public static void lexisnexismethod(){
        
         Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduserlexisnexiss@testingorglexis.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduserlexisnexiss@testingorglexis.com');

        System.runAs(u) {
TestUtility.runSetupData();
Account account = TestUtility.createAccount();
Contact contact = TestUtility.createContact();
genesis__Applications__c Application = TestUtility.createApplication();
            Credit_Report_Detail__c creditreport = new Credit_Report_Detail__c();
            creditreport.Application__c=application.id;
            insert creditreport;
            
       
    } 
    }
}