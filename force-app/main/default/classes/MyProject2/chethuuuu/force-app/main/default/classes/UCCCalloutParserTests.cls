@isTest
public class UCCCalloutParserTests {

    @isTest
    public static void getCreateFilingRequestBodyTest(){
        UCC_Filing_Detail__c uccDetail = new UCC_Filing_Detail__c();
        uccDetail.Filer_Organization_Name__c = 'CSC';
        uccDetail.Filer_Mail_Address__c = '100 MAIN STREET';
        uccDetail.Filer_City__c = 'TOWN';
        uccDetail.Filer_State__c = 'IL';
        uccDetail.Filer_PostalCode__c = '66219';
        uccDetail.Filer_Contact_Name__c = 'CSC';
        uccDetail.Filer_Contact_Phone__c = '1-800-858-5294';
        uccDetail.Filer_Contact_Email__c = '801 Adlai Stevenson';
        uccDetail.Filer_Contact_Fax__c = '1-800-345-6059';
        uccDetail.Debtor_Organization_Name__c = 'My First Debtor';
        uccDetail.Debtor_Mail_Address__c = '123 Debtor St';
        uccDetail.Debtor_City__c = 'Debtorville';
        uccDetail.Debtor_Organization_State__c = 'IL';
        uccDetail.Debtor_Organization_PostalCode__c = '12345-6789';
        uccDetail.Debtor_Organization_Country__c = 'USA';
        uccDetail.Debtor_Organizational_Type__c = 'Corporation';
        uccDetail.Debtor_Organizational_Jurisdiction__c = 'IL';
        uccDetail.Debtor_Organizational_ID__c = '7777777';
        uccDetail.Debtor_Individual_LastName__c = 'LASTNAME';
        uccDetail.Debtor_Individual_FirstName__c = 'FIRSTNAME';
        uccDetail.Debtor_Individual_MiddleName__c = 'I';
        uccDetail.Debtor_Individual_Suffix__c = 'JR';
        uccDetail.Debtor_Individual_MailAddress__c = '100 MAIN STREET';
        uccDetail.Debtor_Individual_City__c = 'TOWN';
        uccDetail.Debtor_Individual_State__c = 'IL';
        uccDetail.Debtor_Individual_PostalCode__c = '66219';
        uccDetail.Debtor_Individual_Country__c = 'USA';
        uccDetail.Secured_Organization_Name__c = 'Secured Party Name';
        uccDetail.Secured_MailAddress__c = '500 Street Avenue';
        uccDetail.Secured_City__c = 'SPRINGFIELD';
        uccDetail.Secured_State__c = 'IL';
        uccDetail.Secured_postalCode__c = '62708';
        uccDetail.Secured_Country__c = 'USA';
        uccDetail.Collateral_Text1__c = 'Collateral Information to be included in Collateral Box on UCC1 filing.';

        API_Detail__mdt apiDetails = new API_Detail__mdt();
        apiDetails.Login_GUID__c = '1EAC3362-AC78-4186-8D56-67BEF84567';
        
        UCC_Setting__mdt uccSettings = new UCC_Setting__mdt();

        Map<Id, Id> contractIdToAccountIdMap = new Map<Id, Id>();
        Map<Id, Account> accountMap = new Map<Id, Account>();

        Account accountRecord = new Account ();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountRecord.Merchant_ID__c = '600037';

        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c ();
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        contractIdToAccountIdMap.put(loanAccount.Id, accountRecord.Id);
        accountMap.put(accountRecord.Id, accountRecord);

        Test.startTest();
            String reqXML = UCCCalloutParser.getCreateFilingRequestBody(uccDetail, uccSettings, contractIdToAccountIdMap, accountMap, loanAccount, apiDetails);
        Test.stopTest();

        system.assert(reqXML.contains(uccDetail.Filer_Organization_Name__c));
    }

    @isTest
    public static void getOrderInformationRequestBodyTest() {
        
        UCC_Setting__mdt uccSettings = new UCC_Setting__mdt();

        API_Detail__mdt apiDetails = new API_Detail__mdt();
        apiDetails.Login_GUID__c = '1EAC3362-AC78-4186-8D56-67BEF84567';

        String orderId = '1.533961478';

        Test.startTest();
        String reqXML = UCCCalloutParser.getOrderInformationRequestBody(orderId, uccSettings, apiDetails);
        Test.stopTest();

        system.assert(reqXML.contains(orderId));
    }

    @isTest
    public static void getValidateFilingRequestBodyTest() {
        
        UCC_Setting__mdt uccSettings = new UCC_Setting__mdt();

        API_Detail__mdt apiDetails = new API_Detail__mdt();
        apiDetails.Login_GUID__c = '1EAC3362-AC78-4186-8D56-67BEF84567';

        UCC_Filing_Detail__c uccDetail = new UCC_Filing_Detail__c();
        uccDetail.Order_ID__c = '1533961478';

        Test.startTest();
        String reqXML = UCCCalloutParser.getValidateFilingRequestBody(uccDetail, uccSettings, apiDetails);
        Test.stopTest();

        system.assert(reqXML.contains(apiDetails.Login_GUID__c));
    }

    @isTest
    public static void uccFilingContinuationRequestBodyTest() {
        
        UCC_Setting__mdt uccSettings = new UCC_Setting__mdt();

        API_Detail__mdt apiDetails = new API_Detail__mdt();
        apiDetails.Login_GUID__c = '1EAC3362-AC78-4186-8D56-67BEF84567';

        String orderId = '1.5339618';

        Test.startTest();
        String reqXML = UCCCalloutParser.uccFilingContinuationRequestBody(orderId, uccSettings, apiDetails);
        Test.stopTest();

        system.assert(reqXML.contains(orderId));
    }

    @isTest
    public static void getApproveFilingRequestBodyTest() {

        UCC_Setting__mdt uccSettings = new UCC_Setting__mdt();
        
        API_Detail__mdt apiDetails = new API_Detail__mdt();
        apiDetails.Login_GUID__c = '1EAC3362-AC78-4186-8D56-67BEF84567';

        UCC_Filing_Detail__c uccDetail = new UCC_Filing_Detail__c();
        uccDetail.Order_ID__c = '1533961478';

        Test.startTest();
        String reqXML = UCCCalloutParser.getApproveFilingRequestBody(uccDetail, uccSettings, apiDetails);
        Test.stopTest();

        system.assert(reqXML.contains(apiDetails.Login_GUID__c));
    }

    @isTest
    public static void parseCreateFilingResponseIfTest() {

        HttpResponse response = new HttpResponse();
        response.setBody('<OrderID>1.5339618</OrderID>');
        response.setStatusCode(200);

        Test.startTest();
        String orderID = UCCCalloutParser.parseCreateFilingResponse(response);
        Test.stopTest();
    }

    @isTest
    public static void parseCreateFilingResponseElseTest() {

        HttpResponse response = new HttpResponse();
        response.setStatusCode(300);

        Test.startTest();
        UCCCalloutParser.parseCreateFilingResponse(response);
        Test.stopTest();
    }

    @isTest
    public static void parseValidateFilingResponseIfTest() {

        HttpResponse response = new HttpResponse();
        response.setBody('<Message level="0">testing</Message>');
        response.setStatusCode(200);

        Test.startTest();
        UCCCalloutParser.parseValidateFilingResponse(response);
        Test.stopTest();
    }

    @isTest
    public static void parseValidateFilingResponseElseTests() {

        HttpResponse response = new HttpResponse();
        response.setStatusCode(300);

        Test.startTest();
        UCCCalloutParser.parseValidateFilingResponse(response);
        Test.stopTest();
    }

    @isTest
    public static void parseTerminateFilingResponseIfTest() {

        HttpResponse response = new HttpResponse();
        response.setBody('<OrderID>1.5339618</OrderID>');
        response.setStatusCode(200);

        Test.startTest();
        UCCCalloutParser.parseTerminateFilingResponse(response);
        Test.stopTest();
    }

    @isTest
    public static void parseTerminateFilingResponseElseTest() {

        HttpResponse response = new HttpResponse();
        response.setStatusCode(300);

        Test.startTest();
        UCCCalloutParser.parseTerminateFilingResponse(response);
        Test.stopTest();
    }

    @isTest
    public static void getUpdateFilingRequestBodyTest() {

        UCC_Setting__mdt uccSettings = new UCC_Setting__mdt();
        
        API_Detail__mdt apiDetails = new API_Detail__mdt();
        apiDetails.Login_GUID__c = '1EAC3362-AC78-4186-8D56-67BEF87BD71B';

        UCC_Filing_Detail__c uccDetail = new UCC_Filing_Detail__c();
        uccDetail.Order_ID__c = '1533961478';
        uccDetail.Jurisdiction_State__c = 'NJ';
        uccDetail.Jurisdiction_Name__c = '(S.O.S.)';
        uccDetail.Jurisdiction_ID__c = '3154';
        uccDetail.Debtor_Organization_Name__c = 'My First Debtor';
        uccDetail.Debtor_Mail_Address__c = '123 Debtor St';
        uccDetail.Debtor_City__c = 'Debtorville';
        uccDetail.Debtor_Organization_State__c = 'IL';
        uccDetail.Debtor_Organization_PostalCode__c = '12345-6789';
        uccDetail.Debtor_Organization_Country__c = 'USA';
        uccDetail.Debtor_Organizational_Type__c = 'Corporation';
        uccDetail.Debtor_Organizational_Jurisdiction__c = 'IL';
        uccDetail.Debtor_Organizational_ID__c = '7777777';
        uccDetail.Secured_Organization_Name__c = 'Secured Party Name';
        uccDetail.Debtor_Individual_FirstName__c = 'FIRSTNAME';
        uccDetail.Debtor_Individual_MiddleName__c = 'I';
        uccDetail.Debtor_Individual_Suffix__c = 'JR';
        uccDetail.Debtor_Individual_MailAddress__c = '100 MAIN STREET';
        uccDetail.Debtor_Individual_City__c = 'TOWN';
        uccDetail.Debtor_Individual_State__c = 'IL';
        uccDetail.Debtor_Individual_PostalCode__c = '66219';
        uccDetail.Debtor_Individual_Country__c = 'USA';
        uccDetail.Secured_Organization_Name__c = 'Secured Party Name';
        uccDetail.Secured_MailAddress__c = '500 Street Avenue';
        uccDetail.Secured_City__c = 'SPRINGFIELD';
        uccDetail.Secured_State__c = 'IL';
        uccDetail.Secured_postalCode__c = '62708';
        uccDetail.Secured_Country__c = 'USA';
        uccDetail.Collateral_Text1__c = 'Collateral Information to be included in Collateral Box on UCC1 filing.';

        Account accountDetails = new Account();
        accountDetails.Merchant_ID__c = '600037';

        Test.startTest();
        String reqXML = UCCCalloutParser.getUpdateFilingRequestBody(uccDetail, uccSettings, accountDetails, apiDetails);
        Test.stopTest();

        system.assert(reqXML.contains(uccDetail.Debtor_Organization_Name__c));
    }

    @isTest
    public static void getTerminateFilingRequestBodyTest() {

        UCC_Setting__mdt uccSettings = new UCC_Setting__mdt();
        
        API_Detail__mdt apiDetails = new API_Detail__mdt();
        apiDetails.Login_GUID__c = '1EAC3362-AC78-4186-8D56-67BEF87BD71B';

        String orderId = '1.533961478';

        Test.startTest();
        String reqXML = UCCCalloutParser.getTerminateFilingRequestBody(orderID, uccSettings, apiDetails);
        Test.stopTest();

        system.assert(reqXML.contains(orderId));
    }

    @isTest
    public static void getUCCAttachmentsRequestBodyTest(){

        UCC_Setting__mdt uccSettings = new UCC_Setting__mdt();
        
        API_Detail__mdt apiDetails = new API_Detail__mdt();
        apiDetails.Login_GUID__c = '1EAC3362-AC78-4186-8D56-67BEF87BD71B';

        Id attachmentId = TestUtility.getFakeId(Attachment.getSObjectType());

        Test.startTest();
        String reqXML = UCCCalloutParser.getUCCAttachmentsRequestBody(attachmentId, uccSettings, apiDetails);
        Test.stopTest();

        system.assert(reqXML.contains(attachmentId));
    }
}