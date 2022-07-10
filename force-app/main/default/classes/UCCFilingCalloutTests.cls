@isTest
private class UCCFilingCalloutTests {

    @TestSetup
    static void makeData(){
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        TestUtility.runSetupData();
        loan__Loan_Account__c loanAccount = TestUtility.createContract();

    }

    @isTest
    private static void createFiling() {
    UCC_Filing_Detail__c uccFilingDetail = new UCC_Filing_Detail__c();
    uccFilingDetail.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());

    UCC_Setting__mdt uccSettings = new UCC_Setting__mdt();
    uccSettings.Filer_State__c = 'DummyString';
    String contentType = 'text/xml; charset=utf-8';

    Map<Id, Id> contractIdToAccountIdMap = new Map<Id, Id>();

    Account account = new Account();
    account.Id = TestUtility.getFakeId(Account.getSObjectType());

    loan__Loan_Account__c loanAccount = new loan__Loan_Account__c();
    loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
    loanAccount.loan__Account__c =  account.Id;

    contractIdToAccountIdMap.put(loanAccount.Id, account.Id);

    Map<Id, Account> accountMap = new Map<Id, Account>();
    accountMap.put(account.Id, account);

    System.Test.setMock(HttpCalloutMock.class, new UCCCalloutMock.UCCCallOutMockCreateFiling());

    String orderId;

    Test.startTest();
        orderId = UCCFilingCallout.createFiling(uccFilingDetail, uccSettings, contractIdToAccountIdMap, accountMap, loanAccount);
    Test.stopTest();

    System.assert(orderId != Null);
    }

    @isTest
    private static void validateFiling() {
        UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
        uccFiling.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());

        UCC_Setting__mdt uccDetails = new UCC_Setting__mdt();
        uccDetails.Filer_State__c = 'DummyString';
        String contentType = 'text/xml; charset=utf-8';

        System.Test.setMock(HttpCalloutMock.class, new UCCCalloutMock.UCCCalloutMockUccValidateFiling());

        String validationMessage;

        Test.startTest();
            validationMessage = UCCFilingCallout.validateFiling(uccFiling, uccDetails);
        Test.stopTest();

        System.assert(validationMessage != Null);
    }

    @isTest
    private static void approveFiling() {
        UCC_Filing_Detail__c uccFilingDetail = new UCC_Filing_Detail__c();
        uccFilingDetail.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());

        UCC_Setting__mdt UccSettings = new UCC_Setting__mdt();
        UccSettings.Filer_State__c = 'DummyString';
        String contentType = 'text/xml; charset=utf-8';

        System.Test.setMock(HttpCalloutMock.class, new UCCCalloutMock.UCCCalloutMockUccValidateApproveFiling());

        String orderId;

        Test.startTest();
            orderId = UCCFilingCallout.approveFiling(uccFilingDetail, UccSettings);
        Test.stopTest();

        System.assert(orderId != NULL);
    }

    @isTest
    private static void terminateUCC() {

        String orderId = '123456789';

        UCC_Setting__mdt UccSettings = new UCC_Setting__mdt();
        UccSettings.Filer_State__c = 'DummyString';
        String contentType = 'text/xml; charset=utf-8';

        System.Test.setMock(HttpCalloutMock.class, new UCCCalloutMock.UCCCalloutMockTerminateUCCFiling());

        String terminatedOrderId;

        Test.startTest();
            terminatedOrderId = UCCFilingCallout.terminateUCC(orderId);
        Test.stopTest();

        System.assert(terminatedOrderId != null);
    }

    @isTest
    private static void updateUCC() {

        UCC_Filing_Detail__c uccDetail = new UCC_Filing_Detail__c();
        uccDetail.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());

        List<String> responseValueList = new List<String>();
        responseValueList.add('dummyData1');
        responseValueList.add('dummyData2');

        Map<String, List<String>> ModelToResponseValueListMap = new Map<String, List<String>>();
        ModelToResponseValueListMap.put('dummyData1', responseValueList);
        ModelToResponseValueListMap.put('dummyData2', responseValueList);

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        UCC_Setting__mdt uccSettings = new UCC_Setting__mdt();
        uccSettings.Filer_State__c = 'DummyString';
        String contentType = 'text/xml; charset=utf-8';

        System.Test.setMock(HttpCalloutMock.class, new UCCCalloutMock.UCCCalloutMockUpdateUCCFiling());

        Map<String, List<String>> updateUCCList = new Map<String, List<String>>();

        Test.startTest();
            updateUCCList = UCCFilingCallout.updateUCC(uccDetail, account);
        Test.stopTest();

        System.assert(updateUCCList != null);
    }

    @isTest
    private static void getOrderInformationByOrderId() {

        List<String> responseValueList = new List<String>();
        responseValueList.add('dummyData1');
        responseValueList.add('dummyData2');

        Map<String, List<String>> ModelToResponseValueListMap = new Map<String, List<String>>();
        ModelToResponseValueListMap.put('dummyData1', responseValueList);
        ModelToResponseValueListMap.put('dummyData2', responseValueList);

        String orderId = '123456789';

        UCC_Setting__mdt uccDetails = new UCC_Setting__mdt();
        uccDetails.Filer_State__c = 'DummyString';
        String contentType = 'text/xml; charset=utf-8';

        System.Test.setMock(HttpCalloutMock.class, new UCCCalloutMock.UCCCalloutMockGetOrderInformationByUCCFilingDetail());

        Map<String, List<String>> getOrderInformationByOrderId = new Map<String, List<String>>();

        Test.startTest();
        	getOrderInformationByOrderId = UCCFilingCallout.getOrderInformationByOrderId(orderId);
        Test.stopTest();

        System.assert(getOrderInformationByOrderId != null);
    }

    @isTest
    private static void uccFilingContinuation() {

        String OrderId = '123456789';

        List<String> responseValueList = new List<String>();
        responseValueList.add('dummyData1');
        responseValueList.add('dummyData2');

        Map<String, List<String>> ModelToResponseValueListMap = new Map<String, List<String>>();
        ModelToResponseValueListMap.put('dummyData1', responseValueList);
        ModelToResponseValueListMap.put('dummyData2', responseValueList);

        UCC_Setting__mdt uccDetails = new UCC_Setting__mdt();
        uccDetails.Filer_State__c = 'DummyString';
        String contentType = 'text/xml; charset=utf-8';

        System.Test.setMock(HttpCalloutMock.class, new UCCCalloutMock.UCCCalloutMockUccFilingContinuation());

        Map<String, List<String>> uccFilingContinuation = new Map<String, List<String>>();

        Test.startTest();
        	 uccFilingContinuation = UCCFilingCallout.uccFilingContinuation(OrderId);
        Test.stopTest();

        System.assert(uccFilingContinuation != null);
    }

    @isTest
    private static void validateNullStringValue() {

        System.Test.setMock(HttpCalloutMock.class, new UCCCalloutMock.UCCCalloutMockValidateStringValue());
        Test.startTest();
            String newValues = UCCFilingCallout.validateStringValue(null);
        Test.stopTest();

        System.assertEquals(null, newValues);
    }

    @isTest
    private static void validateStringValue() {

        String stringToValidate = 'String Test \n Test String';

        Test.startTest();
            String validatedString = UCCFilingCallout.validateStringValue('null efsdaf');
        Test.stopTest();

        System.assertNotEquals(stringToValidate, validatedString);
    }

    @isTest
    private static void getPlaceIDTest() {
        loan__Loan_Account__c loanAccount = [Select Id,Name,Application__c,Application__r.Business_Type__c from loan__Loan_Account__c];
        String uccFilingAddress;

        UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
        uccFiling.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());

        genesis__Applications__c application = [
            SELECT Id, Name, Opportunity__c, genesis__Payment_Frequency__c, genesis__Loan_Amount__c, genesis__Term__c, Industry_Rating__c,
                SC4_Tier__c, Type__c, Business_Type__c, genesis__Account__c, genesis__Account__r.AnnualRevenue, Primary_Guarantor__c, Is_Manual_Score_Run__c
            FROM genesis__Applications__c where Id =: loanAccount.Application__c
        ];

        Account account = [
            SELECT Id, Name, Phone, Business_Tax_ID__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingAddress,
                Last_Business_Credit_Pull__c, Sic, Customer_Since__c, Legacy_Percent_Paid__c, Biz_Start_Date__c
            FROM Account
            WHERE Id = :application.genesis__Account__c
        ];
        account.BillingStreet = 'DummyStreet';
        account.BillingCity = 'Into';
        account.BillingState = 'AL';
        account.BillingPostalCode = '35222';
        account.BillingCountry = 'US';
        update account;

        Map<Id, Id> contractIdToAccountIdMap = new Map<Id,Id>();
        contractIdToAccountIdMap.put(loanAccount.Id, account.Id);

        Map<Id, Account> accountMap = new Map<Id, Account>();
        accountMap.put(account.Id, account);

        UCC_Setting__mdt uccSettings = new UCC_Setting__mdt();
        uccSettings.Filer_State__c = 'DummyString';
        System.debug(uccSettings);
        String contentType = 'text/xml; charset=utf-8';

        System.Test.setMock(HttpCalloutMock.class, new UCCCalloutMock.UCCCalloutMockGetPlaceID());

        String getPlaceId;

        Test.startTest();
            getPlaceId = UCCFilingCallout.getPlaceID(uccFiling, loanAccount, contractIdToAccountIdMap, accountMap);
        Test.stopTest();

        System.assert(getPlaceId != Null);
    }

    @isTest
    private static void getCountyParishForUCC() {

        String placeID = '123456789';

        UCC_Setting__mdt uccSettings = new UCC_Setting__mdt();
        uccSettings.Filer_State__c = 'DummyString';

        String contentType = 'text/xml; charset=utf-8';

        System.Test.setMock(HttpCalloutMock.class, new UCCCalloutMock.UCCCalloutMockGetCountyParishForUCC());

        Test.startTest();
            String getCountyParishForUCC = UCCFilingCallout.getCountyParishForUCC(placeID);
        Test.stopTest();

        System.assertNotEquals(placeID, getCountyParishForUCC);
    }

    @isTest
    private static void getUCCAttachmentsByAttachmentId() {

        String attachmentId = '123456789';

        UCC_Setting__mdt uccSettings = new UCC_Setting__mdt();
        uccSettings.Filer_State__c = 'DummyString';
        String contentType = 'text/xml; charset=utf-8';

        System.Test.setMock(HttpCalloutMock.class, new UCCCalloutMock.UCCCalloutMockGetUCCAttachmentsByAttachmentId());

        Map<String, List<String>> getUCCAttachmentsByAttachmentId = new Map<String, List<String>>();

        Test.startTest();
        	getUCCAttachmentsByAttachmentId = UCCFilingCallout.getUCCAttachmentsByAttachmentId(attachmentId);
        Test.stopTest();

        System.assert(getUCCAttachmentsByAttachmentId != Null);
    }

    @isTest
    private static void getUCCAttachmentsFromExternalURL() {

        String attachmentLink = 'https://eservices.cscfinancialonline.com/GetAttachment';

        UCC_Setting__mdt uccSettings = new UCC_Setting__mdt();
        uccSettings.Filer_State__c = 'DummyString';
        String contentType = 'text/xml; charset=utf-8';

        System.Test.setMock(HttpCalloutMock.class, new UCCCalloutMock.UCCCalloutMockGetUCCAttachmentsFromExternalURL());

        blob getUCCAttachmentsFromExternalURL;

        Test.startTest();
            getUCCAttachmentsFromExternalURL = UCCFilingCallout.getUCCAttachmentsFromExternalURL(attachmentLink);
        Test.stopTest();

        System.assert(getUCCAttachmentsFromExternalURL != Null);
    }
}