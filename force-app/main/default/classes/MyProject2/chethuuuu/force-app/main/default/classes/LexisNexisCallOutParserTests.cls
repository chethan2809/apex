@isTest
public class LexisNexisCallOutParserTests {

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
    @isTest
    public static void LexisNexisCallOutParserTestMethod(){

        Account accnt = [SELECT id,Name,BillingBuildingNumber__c,BillingStreet,BillingCity,
                                BillingState,BillingPostalCode,AnnualRevenue,Phone,Fax,Sic,Business_Tax_ID__c, Legal_Name__c
                       	 FROM Account
                         LIMIT 1];

        List<Contact> con = [SELECT id,Accountid,MailingBuildingNumber__c,MailingAddress,FirstName,
                                    LastName,Birthdate,genesis__SSN__c,Phone,ints__Driver_License__c,Email
                       		 FROM Contact];

        Map<String,List<Contact>> contactListByPartyType = new Map<String,List<Contact>>{'Primary Guarantor' => con};
        Map<String,List<Contact>> contactListByPartyType1 = new Map<String,List<Contact>>{'Additional Guarantors' => con};
        Map<String,List<Contact>> contactListByPartyType2 = new Map<String,List<Contact>>{'Beneficial Owner' => con};
		Map<String,List<Contact>> contactListByPartyType3 = new Map<String,List<Contact>>{'Primary Guarantor' => con};

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);
        response.setStatus('OK');
        response.setBody('{"response":"SUCCESS"}');

        HttpResponse response1 = new HttpResponse();
        response1.setHeader('Content-Type', 'application/json');
        response1.setStatusCode(200);
        response1.setStatus('OK');
        response1.setBody('{"response":"SUCCESS"}');

		Test.startTest();
            LexisNexisCallOutParser lexiNexis = new LexisNexisCallOutParser(accnt,contactListByPartyType,con,'BID');
            LexisNexisCallOutParser lexiNexis1 = new LexisNexisCallOutParser(accnt,contactListByPartyType1,con,'BID');
            LexisNexisCallOutParser lexiNexis2 = new LexisNexisCallOutParser(accnt,contactListByPartyType2,con,'BID');
            LexisNexisCallOutParser lexiNexis3 = new LexisNexisCallOutParser(accnt,contactListByPartyType3,con,'FraudPoint');
            lexiNexis.requestBodyForBusinessInstantId();
            lexiNexis.requestBodyForFraudPoint();
            lexiNexis3.requestBodyForBusinessInstantId();
            lexiNexis.businessInstantIdResponseParse(response);
            lexiNexis.fraudPointResponseParse(response1);
        Test.stopTest();

        System.assert(accnt != Null);
        System.assert(con != Null);
    }
}