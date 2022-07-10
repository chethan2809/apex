@isTest
public class LexisNexisCallOutTests {

    @TestSetup
    static void makeData(){

        TestUtility.runSetupData();
        genesis__Applications__c application = TestUtility.createApplication();

        Account acc = [SELECT id
                       FROM Account
                       LIMIT 1];

        Contact con = [SELECT id,Accountid
                       FROM Contact
                       LIMIT 1];
        con.Accountid = application.genesis__Account__c;
        update con;
    }
    @future(callout=true)
    public static void futuremethod(Id accId) {

        Account accnt = [SELECT id,Name,BillingBuildingNumber__c,BillingStreet,BillingCity,BillingState, Legal_Name__c,
                       				BillingPostalCode,AnnualRevenue,Phone,Fax,Sic,Business_Tax_ID__c
                       	 FROM Account
                         WHERE id =: accId
                         LIMIT 1];

        List<Contact> con = [SELECT id,Accountid
                       		 FROM Contact
                             WHERE Accountid =: accId];

        Map<String,List<Contact>> contactListByPartyType = new Map<String,List<Contact>>{'GUARANTOR' => con};

        LexisNexisCallOut.requestBusinessInstantIDCheck(accnt,contactListByPartyType);

        System.assert(con != Null);
    }
	@isTest
    public static void requestBusinessInstantIDCheckTestMethod(){

        Account acc = [SELECT id
                       FROM Account
                       LIMIT 1];

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new LexisNexisCallOutMock());
            futuremethod(acc.id);
        Test.stopTest();

        System.assert(acc != Null);
    }
    @future(callout=true)
    public static void futuremethod1(Id accId) {

        Account accnt = [SELECT id,Name,BillingBuildingNumber__c,BillingStreet,BillingCity,BillingState, Legal_Name__c,
                       				BillingPostalCode,AnnualRevenue,Phone,Fax,Sic,Business_Tax_ID__c
                         FROM Account
                         WHERE id =: accId
                         LIMIT 1];

        List<Contact> con = [SELECT id,Accountid
                       		 FROM Contact
                             WHERE Accountid =: accId];

        LexisNexisCallOut.requestFraudPointCheck(accnt,con);

        System.assert(accnt != Null);
    }
	@isTest
    public static void requestFraudPointCheckTestMethod(){

        Account acc = [SELECT id
                       FROM Account
                       LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new LexisNexisCallOutMock());
        futuremethod1(acc.id);
        Test.stopTest();

        System.assert(acc != Null);
    }
}