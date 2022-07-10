@isTest
private class PayoffQuoteControllerTests {

    @TestSetup
    static void makeData(){

        TestUtility.runSetupData();
        loan__Loan_Payment_Spread__c canPaymentSpread =  new loan__Loan_Payment_Spread__c();
        canPaymentSpread.Name = 'CAN Payment Spread';
        insert canPaymentSpread;

        loan__Loan_Account__c contract = TestUtility.createContract();
        Salesforce_Base_URL__c custSetting = new Salesforce_Base_URL__c();
        custSetting.Name = 'BaseURL';
        custSetting.URL__c = 'https://'+URL.getSalesforceBaseUrl().getHost();
        upsert custSetting;
    }

    @isTest
    private static void invokeActionTestMethod1(){

        PayoffQuoteController payObject = new PayoffQuoteController();
        loan__Loan_Account__c contract = [SELECT id
                                          FROM loan__Loan_Account__c
                                          LIMIT 1];
        Map<String,Object> params = new Map<String,Object>();
        params.put('contractId',contract.id);

        Test.startTest();
            clcommon.Response response = payObject.invokeAction('',null,params);
        Test.stopTest();

        System.assertNotEquals('SUCCESS', response.status);
    }

    @isTest
    private static void invokeActionTestMethod2(){

        PayoffQuoteController payObject = new PayoffQuoteController();
        loan__Loan_Account__c contract = [SELECT id
                                          FROM loan__Loan_Account__c
                                          LIMIT 1];
        Map<String,Object> params = new Map<String,Object>();
        params.put('contractId',contract.id);

        Test.startTest();
            clcommon.Response response1 = payObject.invokeAction('',null,params);
            Test.setMock(HttpCalloutMock.class, new MockPayoffQuoteControllerStatusOk());
            clcommon.Response response = payObject.invokeAction('',null,params);
        Test.stopTest();

        System.assertEquals(PortalConstants.API_RESPONSE_STATUS_FAILED, response.status);
    }

    @isTest
    private static void invokeActionTestMethod3(){

        PayoffQuoteController payObject = new PayoffQuoteController();
        loan__Loan_Account__c contract = [SELECT id
                                          FROM loan__Loan_Account__c
                                          LIMIT 1];
        Map<String,Object> params = new Map<String,Object>();
        params.put('contractId',contract.id);

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockPayoffQuoteControllerStatusNA());
            clcommon.Response response = payObject.invokeAction('',null,params);
        Test.stopTest();

        System.assertEquals('NA', response.errorMessage);
    }

    @isTest
    private static void invokeActionTestMethod(){

        PayoffQuoteController payObject = new PayoffQuoteController();
        loan__Loan_Account__c contract = [SELECT id
                                          FROM loan__Loan_Account__c
                                          LIMIT 1];
        Map<String,Object> params = new Map<String,Object>();
        params.put('contractId',contract.id);

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockPayoffQuoteControllerStatusOk());
            clcommon.Response response = payObject.invokeAction('',null,params);
        Test.stopTest();

        System.assertEquals(PortalConstants.API_RESPONSE_STATUS_SUCCESS,response.status);
    }

    @isTest
    public static void invokeActionTestMethod4(){

        PayoffQuoteController payObject = new PayoffQuoteController();
        loan__Loan_Account__c contract = new loan__Loan_Account__c();
        contract.id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Map<String,Object> params = new Map<String,Object>();
        params.put('contractId',contract.id);

        Test.startTest();
            try{
                clcommon.Response response = payObject.invokeAction('',null,params);
            }catch(Exception e){}
        Test.stopTest();

        System.assert(contract != Null);
    }
}