@isTest
public class TestPortalApplicationAPI
{
    @testSetup static void dataSetup()
    {
        Account acc=TestUtility.createAccount();
        contact con=TestUtility.createContact();
        /*TestUtility.runSetupData();
        genesis__Applications__c genApp=TestUtility.createApplication();
        genApp.Portal_Stage__c='LoanInfo';
        update genApp;*/
    }

@isTest
    private static void testPortalApplication()
    {
        Account acc=[select id from Account limit 1];
        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        Map<String,Object> con= new Map<String,String>{'loan__Contact_Type__c'=>Leads.GUARANTOR ,'Birthdate' => '2000-03-11','Title__c' => 'Owner','FirstName' => 'Contact ','LastName' => ' Lastname','Email' => 'Testcontactx@email.com','MobilePhone' => ''};
        Map<String,Object> contactMap = new Map<String,Object>{'clcommon__Contact__r.' => con};
        //genesis__Applications__c appln =[select id from genesis__Applications__c where Portal_Stage__c='LoanInfo'];

        test.startTest();
        clcommon.Response response = new PortalApplicationAPI().invokeAction('', null, new Map<String, Object>{
                  'Account' => acc.Id,
                  CustomConstants.APPLICATION_ID => acc.Id,
                  'borrowerAddr' => contactRecord.Id
        });
        test.stopTest();
    }

    @isTest
    private static void testPortalApplicationEx()
    {
        /*
        genesis__Applications__c acc=[select id from genesis__Applications__c limit 1];
        Map<String,Object> con= new Map<String,String>{'loan__Contact_Type__c'=>Leads.GUARANTOR ,'Birthdate' => '2000-03-11','Title__c' => 'Owner','FirstName' => 'Contact ','LastName' => ' Lastname','Email' => 'Testcontactx@email.com','MobilePhone' => ''};
        Map<String,Object> contactMap = new Map<String,Object>{'clcommon__Contact__r.' => con};
        genesis__Applications__c appln =[select id from genesis__Applications__c where Portal_Stage__c='LoanInfo'];
        */

        test.startTest();

        clcommon.Response response = new PortalApplicationAPI().invokeAction(null, null, new Map<String, Object>{

        });

        test.stopTest();
    }
}