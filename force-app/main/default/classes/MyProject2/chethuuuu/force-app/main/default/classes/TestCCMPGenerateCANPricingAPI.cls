@isTest
private class TestCCMPGenerateCANPricingAPI {
    @testSetup static void dataSetup()
    {
        Account acc=TestUtility.createAccount();
        contact con=TestUtility.createContact();
        TestUtility.runSetupData();
        genesis__Applications__c genApp=TestUtility.createApplication();
    }

    @isTest
    private static void testCMPGenerateCANPricingAPI()
    {
        genesis__Applications__c acc = new genesis__Applications__c();
        acc.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        acc.Annual_Volume__c = 100.00;
        acc.Portal_Stage__c='LoanInfo';
        acc.genesis__Status__c = Applications.STATUS_NEW_ENTERED;
        acc.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        acc.genesis__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        acc.Opportunity__c = TestUtility.getFakeId(Account.getSObjectType());
        acc.Industry_Rating__c = 'A+ Medical';
        acc.SC4_Tier__c = 'TIER 1';
        acc.Annual_Volume__c = 13412312;
        acc.Origination_Fee_Percentage__c = 12;
        acc.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;

        CAN_Max_Amount_And_Max_Term_Mapping__c canMaxAmountMaxTerm = new CAN_Max_Amount_And_Max_Term_Mapping__c();
        canMaxAmountMaxTerm.Loan_Type__c = GeneralConstants.LOAN_TYPE_NEW;
        canMaxAmountMaxTerm.Industry_Rating__c = 'A+ Medical';
        canMaxAmountMaxTerm.SC4_Tier__c = 'TIER 1';

        CAN_Pricing_Detail__c pricingDetails = new CAN_Pricing_Detail__c();
        pricingDetails.Id = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());
       	pricingDetails.Offer_Type__c = null;
        pricingDetails.Ocrolus_Max_Daily_Payment__c = 1000;
        pricingDetails.Buy_Rate__c = 10;
        pricingDetails.GAV__c = 20;
        pricingDetails.Overwrite_Policy_Default__c = false;
        pricingDetails.Application__c = acc.Id;
        pricingDetails.Loan_Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;
        pricingDetails.Overwrite_Policy_Default__c = true;
        pricingDetails.Standard_Commission__c = 100;
        pricingDetails.Selected_Amount__c = 5000;
        pricingDetails.Broker_Commission_Based_On__c = Brokers.COMMISSION_CALC_METHOD_PERCENTAGE;
        pricingDetails.Industry_Rating__c = 'A+ Medical';
        pricingDetails.SC4_Tier__c = 'TIER 1';
        pricingDetails.Term__c = 6;
        pricingDetails.Maximum_Exception_Amount__c = null;
        pricingDetails.Policy_Maximum_Amount__c = 100;
        pricingDetails.Pricing_Factor__c = 1.2;
        pricingDetails.Maximum_Amount__c = 9000;
        pricingDetails.Annual_Volume__c = 1235000;
        pricingDetails.Origination_Fee_Percentage__c = 12;

        CAN_Pricing_Matrix_Detail__c canPricingMatrixDetail = new CAN_Pricing_Matrix_Detail__c();
        canPricingMatrixDetail.Term__c = 6;
        canPricingMatrixDetail.Loan_Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;
        canPricingMatrixDetail.SC4_Tier__c = 'TIER 1';
        canPricingMatrixDetail.Industry_Rating__c = null;
        canPricingMatrixDetail.Pricing_Rate__c = 2.2;

        CAN_GAV_Matrix_Detail__c canGavMatrix = new CAN_GAV_Matrix_Detail__c();
        canGavMatrix.Term__c = 6;
        canGavMatrix.SC4_Tier__c = 'TIER 1';
        canGavMatrix.Industry_Rating__c = 'A+ Medical';
        canGavMatrix.GAV__c = 3;

        DBManagerTestsStub pricingMatrixDetailDBStubInstance = new DBManagerTestsStub();
        pricingMatrixDetailDBStubInstance.genericReturnObject = new List<CAN_Pricing_Matrix_Detail__c> {canPricingMatrixDetail};
        OriginationHelper.pricingMatrixDetailDBInstance = (PricingMatrixDetailDB) Test.createStub(PricingMatrixDetailDB.class, pricingMatrixDetailDBStubInstance);

        DBManagerTestsStub gavMatrixDetailDBStubInstance = new DBManagerTestsStub();
        gavMatrixDetailDBStubInstance.genericReturnObject = new List<CAN_GAV_Matrix_Detail__c> {canGavMatrix};
        OriginationHelper.gavMatrixDetailDBInstance = (GAVMatrixDetailDB) Test.createStub(GAVMatrixDetailDB.class, gavMatrixDetailDBStubInstance);

        Map<String,Object> con= new Map<String,String>{'loan__Contact_Type__c'=>Leads.GUARANTOR ,'Birthdate' => '2000-03-11','Title__c' => 'Owner','FirstName' => 'Contact ','LastName' => ' Lastname','Email' => 'Testcontactx@email.com','MobilePhone' => ''};
        Map<String,Object> contactMap = new Map<String,Object>{'clcommon__Contact__r.' => con};
        Map<String, Object> argumentsFromPortal = new Map<String, Object>();
        argumentsFromPortal.put('sliderValuesFromPortal', JSON.serialize(pricingDetails));
        argumentsFromPortal.put('calculateOffer','calculateOffer');

        Test.startTest();
            clcommon.Response response = new CCMPGenerateCANPricingAPI().invokeAction('', null,argumentsFromPortal);
        Test.stopTest();

        System.assertEquals('SUCCESS', response.Status);
    }

    @isTest
    private static void testCMPGenerateCANPricingAPI1()
    {
        Account acc = [select id from account limit 1];
        genesis__Applications__c app = [select id, Annual_Volume__c from genesis__Applications__c limit 1];
        app.Annual_Volume__c = 100.00;
        app.Portal_Stage__c='LoanInfo';
        update app;

        Map<String,Object> con= new Map<String,String>{'loan__Contact_Type__c'=>Leads.GUARANTOR ,'Birthdate' => '2000-03-11','Title__c' => 'Owner','FirstName' => 'Contact ','LastName' => ' Lastname','Email' => 'Testcontactx@email.com','MobilePhone' => ''};
        Map<String,Object> contactMap = new Map<String,Object>{'sliderValuesFromPortal' => con, 'calculateOffer' => con};

        CAN_Pricing_Detail__c cpd = new CAN_Pricing_Detail__c();
        cpd.Account__c = acc.id;
        cpd.Application__c = app.id;
        cpd.Status__c = 'Draft';
        cpd.Annual_Volume__c = app.Annual_Volume__c;

        DBManagerTestsStub canPricingDetailDbStubInstance = new DBManagerTestsStub();
        canPricingDetailDbStubInstance.genericReturnObject = new List<CAN_Pricing_Detail__c> {cpd};

        map<String,String> cpdDetails= new Map<String,String>{'Id' => cpd.id, 'Account__c' => acc.id, 'applicationId'=>app.id};
        test.startTest();
            clcommon.Response response = new CCMPGenerateCANPricingAPI().invokeAction('', null, new Map<String, Object>{
                'sliderValuesFromPortal' => JSON.serialize(cpdDetails),
                'calculateOffer'=> 'test',
                'applicationId'=>app.id,
                'term' => 60.00
            });
        test.stopTest();
    }

    @isTest
    private static void testCMPGenerateCANPricingAPI2()
    {
        Account acc = [select id from account limit 1];
        genesis__Applications__c app = [select id, Annual_Volume__c from genesis__Applications__c limit 1];
        app.Annual_Volume__c = 100.00;
        app.Portal_Stage__c='LoanInfo';
        update app;

        Map<String,Object> con= new Map<String,String>{'loan__Contact_Type__c'=>Leads.GUARANTOR ,'Birthdate' => '2000-03-11','Title__c' => 'Owner','FirstName' => 'Contact ','LastName' => ' Lastname','Email' => 'Testcontactx@email.com','MobilePhone' => ''};
        Map<String,Object> contactMap = new Map<String,Object>{'sliderValuesFromPortal' => con, 'calculateOffer' => con};

        CAN_Pricing_Detail__c cpd = new CAN_Pricing_Detail__c();
        cpd.Account__c = acc.id;
        cpd.Application__c = app.id;
        cpd.Status__c = 'Draft';
        cpd.Annual_Volume__c = app.Annual_Volume__c;

        DBManagerTestsStub canPricingDetailDbStubInstance = new DBManagerTestsStub();
        canPricingDetailDbStubInstance.genericReturnObject = new List<CAN_Pricing_Detail__c> {cpd};

        map<String,String> cpdDetails= new Map<String,String>{'Id' => cpd.id,'Application__c'=>app.id, 'Account__c' => acc.id};

        test.startTest();
            clcommon.Response response = new CCMPGenerateCANPricingAPI().invokeAction('', null, new Map<String, Object>{
                'offerValuesFromPortal' => JSON.serialize(cpdDetails),
                'submitOffer'=> 'test',
                'Term__c' => '60'
            });
        test.stopTest();
    }

    @isTest
    private static void testCMPGenerateCANPricingAPIExc()
    {

        Map<String,Object> con= new Map<String,String>{'loan__Contact_Type__c'=>Leads.GUARANTOR ,'Birthdate' => '2000-03-11','Title__c' => 'Owner','FirstName' => 'Contact ','LastName' => ' Lastname','Email' => 'Testcontactx@email.com','MobilePhone' => ''};
        Map<String,Object> contactMap = new Map<String,Object>{'clcommon__Contact__r.' => con};

        test.startTest();

        clcommon.Response response = new CCMPGenerateCANPricingAPI().invokeAction('', null, new Map<String, Object>{
          'sliderValuesFromPortal' => ')0000)'
        });

        test.stopTest();
    }
}