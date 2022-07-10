@isTest
private class TestCCBPGenerateCANPricingAPI {
    @testSetup static void dataSetup()
    {
        Account acc=TestUtility.createAccount();
        contact con=TestUtility.createContact();
        TestUtility.runSetupData();
        genesis__Applications__c genApp=TestUtility.createApplication();
        genApp.Annual_Volume__c = 100.00;
        genApp.Portal_Stage__c='LoanInfo';
        update genApp;
    }

    @isTest
    private static void testCCBPGenerateCANPricingAPIDataSetup()
    {
        genesis__Applications__c acc=[select id from genesis__Applications__c limit 1];
        Map<String,Object> con= new Map<String,String>{'loan__Contact_Type__c'=>Leads.GUARANTOR ,'Birthdate' => '2000-03-11','Title__c' => 'Owner','FirstName' => 'Contact ','LastName' => ' Lastname','Email' => 'Testcontactx@email.com','MobilePhone' => ''};
        Map<String,Object> contactMap = new Map<String,Object>{'clcommon__Contact__r.' => con};
        genesis__Applications__c appln =[select id from genesis__Applications__c where Portal_Stage__c='LoanInfo'];

        test.startTest();
        clcommon.Response response = new CCBPGenerateCANPricingAPI().invokeAction('', null, new Map<String, Object>{});
        test.stopTest();
        System.assert(response != null);
    }

    @isTest
    private static void testCCBPGenerateCANPricingAPIValidApplication()
    {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        genesis__Applications__c application = [SELECT Id FROM genesis__Applications__c LIMIT 1];

        CAN_Pricing_Detail__c pricingDetail = generateCANPricing();
        pricingDetail.Application__c = application.Id;
        pricingDetail.Loan_Type__c = GeneralConstants.LOAN_TYPE_NEW;
        pricingDetail.Overwrite_Policy_Default__c = true;
        pricingDetail.Standard_Commission__c = 100;
        pricingDetail.Selected_Amount__c = 5000;
        pricingDetail.Broker_Commission_Based_On__c = Brokers.COMMISSION_CALC_METHOD_PERCENTAGE;
        pricingDetail.Industry_Rating__c = 'A+ Medical';
        pricingDetail.SC4_Tier__c = 'TIER 1';
        pricingDetail.Loan_Type__c =  GeneralConstants.LOAN_TYPE_NEW;
        pricingDetail.Term__c = 6;
        pricingDetail.Maximum_Exception_Amount__c = null;
        pricingDetail.Policy_Maximum_Amount__c = 100;
        pricingDetail.Annual_Volume__c = 1235000;
        pricingDetail.Origination_Fee_Percentage__c = 12;

        CAN_Pricing_Matrix_Detail__c canPricingMatrixDetail = new CAN_Pricing_Matrix_Detail__c();
        canPricingMatrixDetail.Term__c = 6;
        canPricingMatrixDetail.Loan_Type__c = GeneralConstants.LOAN_TYPE_NEW;
        canPricingMatrixDetail.SC4_Tier__c = 'TIER 1';
        canPricingMatrixDetail.Industry_Rating__c = 'A+ Medical';
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

        genesis__Applications__c acc=[select id from genesis__Applications__c limit 1];
        Map<String, String> canPricingDetailMap = new Map<String, String>();
        canPricingDetailMap.put('Application__c', application.Id);
        canPricingDetailMap.put('Term__c','6');
        canPricingDetailMap.put('Maximum_Exception_Amount__c','10000');
        canPricingDetailMap.put('Offer_Type__c','');
        canPricingDetailMap.put('Ocrolus_Max_Daily_Payment__c','1000');
        canPricingDetailMap.put('Buy_Rate__c','10');
        canPricingDetailMap.put('GAV__c','20');
        canPricingDetailMap.put('Overwrite_Policy_Default__c','true');
        canPricingDetailMap.put('Loan_Type__c','NEW');
        canPricingDetailMap.put('Standard_Commission__c','100');
        canPricingDetailMap.put('Selected_Amount__c','5000');
        canPricingDetailMap.put('Industry_Rating__c','A+ Medical');
        canPricingDetailMap.put('SC4_Tier__c','TIER 1');
        canPricingDetailMap.put('Policy_Maximum_Amount__c','100');
        canPricingDetailMap.put('Annual_Volume__c','12300');
        canPricingDetailMap.put('Origination_Fee_Percentage__c','12');
        canPricingDetailMap.put('Broker_Commission_Based_On__c','Percentage Of Financed Amount');
        String jsonString = JSON.serialize(canPricingDetailMap);

        Map<String,Object> contactMap = new Map<String,Object>{'applicationId' => application.Id,'sliderValuesFromPortal' => jsonString, 'calculateOffer' => canPricingMatrixDetail, 'offerValuesFromPortal'=> canPricingMatrixDetail};
        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{account};
        CLSPBPortalSecurity.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub accountDBStubInstance2 = new DBManagerTestsStub();
        accountDBStubInstance2.genericReturnObject = new List<Account>{account};
        CCBPBrokerHierarchyManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance2);

        String accountIdjson = JSON.serialize(account.Id);
        User user = (User) JSON.deserialize(
            '{ "AccountId" : ' + accountIdjson + ' }', User.class
        );
        user.Id = UserInfo.getUserId();
        user.Email = 'test@uniquedomain.com';

        Contact con1 = new Contact();
        con1.LastName = 'CANPortalUser';
        con1.FirstName = 'CANUserAZ';
        con1.accountId = account.Id;

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User>{user};
        CCBPBrokerHierarchyManager.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        DBManagerTestsStub userDBStubInstance1 = new DBManagerTestsStub();
        userDBStubInstance1.genericReturnObject = new List<User>{user};
        CCBPCreatePartiesAPI.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance1);

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact>{con1};
        CCBPCreatePartiesAPI.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        clcommon__Relationship__c relationship = new clcommon__Relationship__c();
        relationship.clcommon__Entity__c = account.Id;
        relationship.clcommon__Related_Entity__c = account.Id;

        DBManagerTestsStub clCommonRelationshipDBStubInstance = new DBManagerTestsStub();
        clCommonRelationshipDBStubInstance.genericReturnObject = new List<clcommon__Relationship__c>{relationship};
        CCBPBrokerHierarchyManager.clCommonRelationshipDBInstance = (ClCommonRelationshipDB) Test.createStub(ClCommonRelationshipDB.class, clCommonRelationshipDBStubInstance);

        test.startTest();
        clcommon.Response response = new CCBPGenerateCANPricingAPI().invokeAction('', null, contactMap);
        test.stopTest();
        System.assert(response != null);
    }
    
     @isTest
    private static void testCCBPGenerateCANPricingAPIValidApplicationSliderAppStatus()
    {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        genesis__Applications__c application = [SELECT Id FROM genesis__Applications__c LIMIT 1];

        CAN_Pricing_Detail__c pricingDetail = generateCANPricing();
        pricingDetail.Application__c = application.Id;
        pricingDetail.Loan_Type__c = GeneralConstants.LOAN_TYPE_NEW;
        pricingDetail.Overwrite_Policy_Default__c = true;
        pricingDetail.Standard_Commission__c = 100;
        pricingDetail.Selected_Amount__c = 5000;
        pricingDetail.Broker_Commission_Based_On__c = Brokers.COMMISSION_CALC_METHOD_PERCENTAGE;
        pricingDetail.Industry_Rating__c = 'A+ Medical';
        pricingDetail.SC4_Tier__c = 'TIER 1';
        pricingDetail.Loan_Type__c =  GeneralConstants.LOAN_TYPE_NEW;
        pricingDetail.Term__c = 6;
        pricingDetail.Maximum_Exception_Amount__c = null;
        pricingDetail.Policy_Maximum_Amount__c = 100;
        pricingDetail.Annual_Volume__c = 1235000;
        pricingDetail.Origination_Fee_Percentage__c = 12;

        CAN_Pricing_Matrix_Detail__c canPricingMatrixDetail = new CAN_Pricing_Matrix_Detail__c();
        canPricingMatrixDetail.Term__c = 6;
        canPricingMatrixDetail.Loan_Type__c = GeneralConstants.LOAN_TYPE_NEW;
        canPricingMatrixDetail.SC4_Tier__c = 'TIER 1';
        canPricingMatrixDetail.Industry_Rating__c = 'A+ Medical';
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

        genesis__Applications__c acc=[select id from genesis__Applications__c limit 1];
        Map<String, String> canPricingDetailMap = new Map<String, String>();
        canPricingDetailMap.put('Application__c', application.Id);
        canPricingDetailMap.put('Term__c','6');
        canPricingDetailMap.put('Maximum_Exception_Amount__c','10000');
        canPricingDetailMap.put('Offer_Type__c','');
        canPricingDetailMap.put('Ocrolus_Max_Daily_Payment__c','1000');
        canPricingDetailMap.put('Buy_Rate__c','10');
        canPricingDetailMap.put('GAV__c','20');
        canPricingDetailMap.put('Overwrite_Policy_Default__c','true');
        canPricingDetailMap.put('Loan_Type__c','NEW');
        canPricingDetailMap.put('Standard_Commission__c','100');
        canPricingDetailMap.put('Selected_Amount__c','5000');
        canPricingDetailMap.put('Industry_Rating__c','A+ Medical');
        canPricingDetailMap.put('SC4_Tier__c','TIER 1');
        canPricingDetailMap.put('Policy_Maximum_Amount__c','100');
        canPricingDetailMap.put('Annual_Volume__c','12300');
        canPricingDetailMap.put('Origination_Fee_Percentage__c','12');
        canPricingDetailMap.put('Broker_Commission_Based_On__c','Percentage Of Financed Amount');
        String jsonString = JSON.serialize(canPricingDetailMap);

        Map<String,Object> contactMap = new Map<String,Object>{'applicationId' => application.Id,'sliderValuesFromPortal' => jsonString, 'calculateOffer' => canPricingMatrixDetail, 'offerValuesFromPortal'=> canPricingMatrixDetail, 'appValidationStatus' => true};
        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{account};
        CLSPBPortalSecurity.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub accountDBStubInstance2 = new DBManagerTestsStub();
        accountDBStubInstance2.genericReturnObject = new List<Account>{account};
        CCBPBrokerHierarchyManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance2);

        String accountIdjson = JSON.serialize(account.Id);
        User user = (User) JSON.deserialize(
            '{ "AccountId" : ' + accountIdjson + ' }', User.class
        );
        user.Id = UserInfo.getUserId();
        user.Email = 'test@uniquedomain.com';

        Contact con1 = new Contact();
        con1.LastName = 'CANPortalUser';
        con1.FirstName = 'CANUserAZ';
        con1.accountId = account.Id;

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User>{user};
        CCBPBrokerHierarchyManager.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        DBManagerTestsStub userDBStubInstance1 = new DBManagerTestsStub();
        userDBStubInstance1.genericReturnObject = new List<User>{user};
        CCBPCreatePartiesAPI.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance1);

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact>{con1};
        CCBPCreatePartiesAPI.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        clcommon__Relationship__c relationship = new clcommon__Relationship__c();
        relationship.clcommon__Entity__c = account.Id;
        relationship.clcommon__Related_Entity__c = account.Id;

        DBManagerTestsStub clCommonRelationshipDBStubInstance = new DBManagerTestsStub();
        clCommonRelationshipDBStubInstance.genericReturnObject = new List<clcommon__Relationship__c>{relationship};
        CCBPBrokerHierarchyManager.clCommonRelationshipDBInstance = (ClCommonRelationshipDB) Test.createStub(ClCommonRelationshipDB.class, clCommonRelationshipDBStubInstance);

        test.startTest();
        clcommon.Response response = new CCBPGenerateCANPricingAPI().invokeAction('', null, contactMap);
        test.stopTest();
        System.assert(response != null);
    }
    
     @isTest
    private static void testCCBPGenerateCANPricingAPIValidApplicationSliderAppStatusFalse()
    {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        genesis__Applications__c application = [SELECT Id FROM genesis__Applications__c LIMIT 1];
        

        CAN_Pricing_Detail__c pricingDetail = generateCANPricing();
        pricingDetail.Application__c = application.Id;
        pricingDetail.Loan_Type__c = GeneralConstants.LOAN_TYPE_NEW;
        pricingDetail.Overwrite_Policy_Default__c = true;
        pricingDetail.Standard_Commission__c = 100;
        pricingDetail.Selected_Amount__c = 5000;
        pricingDetail.Broker_Commission_Based_On__c = Brokers.COMMISSION_CALC_METHOD_PERCENTAGE;
        pricingDetail.Industry_Rating__c = 'A+ Medical';
        pricingDetail.SC4_Tier__c = 'TIER 1';
        pricingDetail.Loan_Type__c =  GeneralConstants.LOAN_TYPE_NEW;
        pricingDetail.Term__c = 6;
        pricingDetail.Maximum_Exception_Amount__c = null;
        pricingDetail.Policy_Maximum_Amount__c = 100;
        pricingDetail.Annual_Volume__c = 1235000;
        pricingDetail.Origination_Fee_Percentage__c = 12;

        CAN_Pricing_Matrix_Detail__c canPricingMatrixDetail = new CAN_Pricing_Matrix_Detail__c();
        canPricingMatrixDetail.Term__c = 6;
        canPricingMatrixDetail.Loan_Type__c = GeneralConstants.LOAN_TYPE_NEW;
        canPricingMatrixDetail.SC4_Tier__c = 'TIER 1';
        canPricingMatrixDetail.Industry_Rating__c = 'A+ Medical';
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

        genesis__Applications__c acc=[select id from genesis__Applications__c limit 1];
        Map<String, String> canPricingDetailMap = new Map<String, String>();
        canPricingDetailMap.put('Application__c', application.Id);
        canPricingDetailMap.put('Term__c','6');
        canPricingDetailMap.put('Maximum_Exception_Amount__c','10000');
        canPricingDetailMap.put('Offer_Type__c','');
        canPricingDetailMap.put('Ocrolus_Max_Daily_Payment__c','1000');
        canPricingDetailMap.put('Buy_Rate__c','10');
        canPricingDetailMap.put('GAV__c','20');
        canPricingDetailMap.put('Overwrite_Policy_Default__c','true');
        canPricingDetailMap.put('Loan_Type__c','NEW');
        canPricingDetailMap.put('Standard_Commission__c','100');
        canPricingDetailMap.put('Selected_Amount__c','5000');
        canPricingDetailMap.put('Industry_Rating__c','A+ Medical');
        canPricingDetailMap.put('SC4_Tier__c','TIER 1');
        canPricingDetailMap.put('Policy_Maximum_Amount__c','100');
        canPricingDetailMap.put('Annual_Volume__c','12300');
        canPricingDetailMap.put('Origination_Fee_Percentage__c','12');
        canPricingDetailMap.put('Broker_Commission_Based_On__c','Percentage Of Financed Amount');
        String jsonString = JSON.serialize(canPricingDetailMap);

        Map<String,Object> contactMap = new Map<String,Object>{'applicationId' => application.Id,'offerValuesFromPortal'=> canPricingMatrixDetail, 'submitOffer' =>'test'};
        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{account};
        CLSPBPortalSecurity.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub accountDBStubInstance2 = new DBManagerTestsStub();
        accountDBStubInstance2.genericReturnObject = new List<Account>{account};
        CCBPBrokerHierarchyManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance2);

        String accountIdjson = JSON.serialize(account.Id);
        User user = (User) JSON.deserialize(
            '{ "AccountId" : ' + accountIdjson + ' }', User.class
        );
        user.Id = UserInfo.getUserId();
        user.Email = 'test@uniquedomain.com';

        Contact con1 = new Contact();
        con1.LastName = 'CANPortalUser';
        con1.FirstName = 'CANUserAZ';
        con1.accountId = account.Id;

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User>{user};
        CCBPBrokerHierarchyManager.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        DBManagerTestsStub userDBStubInstance1 = new DBManagerTestsStub();
        userDBStubInstance1.genericReturnObject = new List<User>{user};
        CCBPCreatePartiesAPI.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance1);

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact>{con1};
        CCBPCreatePartiesAPI.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        clcommon__Relationship__c relationship = new clcommon__Relationship__c();
        relationship.clcommon__Entity__c = account.Id;
        relationship.clcommon__Related_Entity__c = account.Id;

        DBManagerTestsStub clCommonRelationshipDBStubInstance = new DBManagerTestsStub();
        clCommonRelationshipDBStubInstance.genericReturnObject = new List<clcommon__Relationship__c>{relationship};
        CCBPBrokerHierarchyManager.clCommonRelationshipDBInstance = (ClCommonRelationshipDB) Test.createStub(ClCommonRelationshipDB.class, clCommonRelationshipDBStubInstance);

        test.startTest();
        clcommon.Response response = new CCBPGenerateCANPricingAPI().invokeAction('', null, contactMap);
        test.stopTest();
        System.assert(response != null);
    }

    @isTest
    private static void testCCBPGenerateCANPricingAPI3()
    {
        Account acc = [select id from account limit 1];
        genesis__Applications__c app = [select id, Annual_Volume__c from genesis__Applications__c Where Annual_Volume__c  = 100.00 limit 1];

        Map<String,Object> con= new Map<String,String>{'loan__Contact_Type__c'=>Leads.GUARANTOR ,'Birthdate' => '2000-03-11','Title__c' => 'Owner','FirstName' => 'Contact ','LastName' => ' Lastname','Email' => 'Testcontactx@email.com','MobilePhone' => ''};
        Map<String,Object> contactMap = new Map<String,Object>{'sliderValuesFromPortal' => con, 'calculateOffer' => con};
        CAN_Pricing_Detail__c cpd = new CAN_Pricing_Detail__c();
        cpd.Account__c = acc.id;
        cpd.Application__c = app.id;
        cpd.Status__c = 'Draft';
        cpd.Annual_Volume__c = app.Annual_Volume__c;
        //insert cpd;

        DBManagerTestsStub canPricingDetailDbStubInstance = new DBManagerTestsStub();
        canPricingDetailDbStubInstance.genericReturnObject = new List<CAN_Pricing_Detail__c> {cpd};
        //CCBPGenerateCANPricingAPI.canPricingDetailDbInstance = (CANPricingDetailDB) Test.createStub(CANPricingDetailDB.class, canPricingDetailDbStubInstance);

        map<String,String> cpdDetails= new Map<String,String>{'Id' => cpd.id,'Application__c'=>app.id, 'Account__c' => acc.id};
        test.startTest();
            clcommon.Response response = new CCBPGenerateCANPricingAPI().invokeAction('', null, new Map<String, Object>{
                'offerValuesFromPortal' => JSON.serialize(cpdDetails),
                'submitOffer'=> 'test',
                'Term__c' => '60',
                'appValidationStatus' => true
            });
        test.stopTest();
        System.assertEquals('ERROR', response.status);
    }

    @isTest
    private static void testCCBPGenerateCANPricingAPIExc()
    {
        genesis__Applications__c acc=[select id from genesis__Applications__c limit 1];
        Map<String,Object> con= new Map<String,String>{'loan__Contact_Type__c'=>Leads.GUARANTOR ,'Birthdate' => '2000-03-11','Title__c' => 'Owner','FirstName' => 'Contact ','LastName' => ' Lastname','Email' => 'Testcontactx@email.com','MobilePhone' => ''};
        Map<String,Object> contactMap = new Map<String,Object>{'clcommon__Contact__r.' => con};
        genesis__Applications__c appln =[select id from genesis__Applications__c where Portal_Stage__c='LoanInfo'];

        test.startTest();

        clcommon.Response response = new CCBPGenerateCANPricingAPI().invokeAction('', null, new Map<String, Object>{
          'offerValuesFromPortal' => ')0000)',
          'sliderValuesFromPortal' => null
        });

        test.stopTest();
        System.assertEquals('ERROR', response.status);
    }

    private static CAN_Pricing_Detail__c generateCANPricing(){
        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Id = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());
        pricingDetail.Maximum_Exception_Amount__c = 10000;
        pricingDetail.Offer_Type__c = null;
        pricingDetail.Ocrolus_Max_Daily_Payment__c = 1000;
        pricingDetail.Buy_Rate__c = 10;
        pricingDetail.GAV__c = 20;
        pricingDetail.Overwrite_Policy_Default__c = false;
        return pricingDetail;
    }
}