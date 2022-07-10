@IsTest
public class OppurtunityManagerTests
{
    @TestSetup
    static void makeData() {
        TestUtility.runSetupData();
        TestUtility.createLegalEntity();
        TestUtility.createDocumentDefinition();

        loan__Loan_Account__c clContract = TestUtility.createContract();
    }

    @IsTest
    public static void opportunityMandatoryFieldsTestMethod()
    {
        Account borrowerAccount = [SELECT Id,Name,Type,OwnerId,Legacy_Current_Balance__c,Industry,clcommon__Legal_Entity_type__c,
                                    BillingCountry,Biz_Start_Date__c,Business_Tax_ID__c,
                                    Broker_Contact__c,Broker_Account__c FROM Account LIMIT 1];
        borrowerAccount.Legacy_Current_Balance__c = null;
        borrowerAccount.BillingCountry = null;
        borrowerAccount.Industry = null;
        borrowerAccount.Biz_Start_Date__c = null;
        borrowerAccount.Business_Tax_ID__c = null;
        borrowerAccount.clcommon__Legal_Entity_type__c = null;
        update borrowerAccount;

        Contact guarantorContact = [SELECT Id,Name,Email,Title__c,BirthDate FROM Contact LIMIT 1];
        guarantorContact.Email = null;
        guarantorContact.loan__Contact_Type__c = null;
        guarantorContact.Title__c = null;
        guarantorContact.BirthDate = null;
        update guarantorContact;

        Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.Name = borrowerAccount.Name;
        opportunityRecord.StageName = 'App Submitted';
        opportunityRecord.Sub_Status__c = 'Score Pending';
        opportunityRecord.Type = 'Renewal';
        opportunityRecord.LeadSource = 'Email';
        opportunityRecord.CloseDate = GeneralHelper.currentSystemDate.addYears(1);
        opportunityRecord.AccountId = borrowerAccount.Id;
        opportunityRecord.OwnerId = borrowerAccount.OwnerId != null ? borrowerAccount.OwnerId : UserInfo.getUserId();
        opportunityRecord.Requested_Loan_Amount__c = borrowerAccount.Legacy_Current_Balance__c != null ? borrowerAccount.Legacy_Current_Balance__c : 100;
        opportunityRecord.Primary_Contact__c = guarantorContact.Id;
        if(borrowerAccount.Broker_Account__c != null && borrowerAccount.Broker_Contact__c != null) {
            opportunityRecord.Broker_Account__c = borrowerAccount.Broker_Account__c;
            opportunityRecord.Broker_Contact__c = borrowerAccount.Broker_Contact__c;
        }
        insert opportunityRecord;

        Test.startTest();
            OpportunityManager.mandatoryInformationCheck(opportunityRecord);
        Test.stopTest();

        System.assertEquals(OpportunityManager.mandatoryCheck, false);
    }

    @IsTest
    public static void createApplicationTestMethod()
    {
        Id userId = TestUtility.getFakeId(User.getSObjectType());
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/New_York', UserName='standarduser1@testorg.com');

        User userRec = [Select id from user LIMIT 1];

        Account brokerAccount = [SELECT Id FROM Account WHERE Type = 'Broker' LIMIT 1];
        Contact brokerContact = [SELECT Id FROM Contact WHERE loan__Contact_Type__c = 'Broker' LIMIT 1];

        brokerContact.AccountId = brokerAccount.Id;
        update brokerContact;

        loan__Loan_Product__c loanProduct = new loan__Loan_Product__c();
        loanProduct.Name = 'CAN Capital';
        loanProduct.loan__Default_Number_of_Installments__c = 6;
        loanProduct.loan__Frequency_of_Loan_Payment__c = 'WEEKLY';
        insert loanProduct;

        clcommon__CL_Product__c productCL = new clcommon__CL_Product__c();
        productCL.clcommon__Product_Name__c = GeneralConstants.PRODUCT_NAME_DEFAULT;
        productCL.loan__Lending_Product__c = loanProduct.Id;
        insert productCL;

        genesis__Company__c company = new genesis__Company__c();
        company.Name = 'CAN Capital';
        company.genesis__Short_Name__c = 'CAN';
        insert company;

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        clcommon__Company__c clCompany = new clcommon__Company__c();
        clCompany.clcommon__Company_Name__c = 'CAN Capital';
        clCompany.clcommon__Branch_Date__c = GeneralHelper.currentSystemDate;
        insert clCompany;

        genesis__Applications__c application = [SELECT Id, genesis__Payment_Frequency__c, Annual_Volume__c, Total_Competitors_Amount__c, Sales_Rep__c
            FROM genesis__Applications__c];
        application.genesis__Payment_Frequency__c = 'WEEKLY';
        application.Sales_Rep__c = UserInfo.getUserId();
        application.Total_Competitors_Amount__c = 3333;
        application.Annual_Volume__c = 2444;
        update application;

        UnderWriter_Task__c taskDetail = new UnderWriter_Task__c();
        taskDetail.Application__c = application.Id;
        taskDetail.Task_Name__c = 'Test Task';
        taskDetail.Category__c = 'Test category';
        insert taskDetail;

        User brokerUserRecord = new User();
        brokerUserRecord.Id = TestUtility.getFakeId(User.getSObjectType());
        brokerUserRecord.ContactId = brokerContact.Id;

        clcommon__Party__c party = new clcommon__Party__c();
        party.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        party.genesis__Application__c = application.Id;

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = new List<clcommon__Party__c>{party};
        PartyManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        clcommon__Legal_Entity__c legalEntity = [SELECT Id, Name FROM clcommon__Legal_Entity__c WHERE Name = 'Partnership'];
        Account borrowerAccount = [SELECT Id,Name,Type,OwnerId,Industry,clcommon__Legal_Entity_type__c,
                                    BillingCountry,Biz_Start_Date__c,Business_Tax_ID__c, Legacy_Current_Balance__c,
                                    Broker_Contact__c,Broker_Account__c FROM Account LIMIT 1];
        borrowerAccount.BillingCountry = 'US';
        borrowerAccount.Industry = 'BUSINESS SERVICES';
        borrowerAccount.Biz_Start_Date__c = Date.newInstance(2017, 1, 1);
        borrowerAccount.Business_Tax_ID__c = '5465876';
        borrowerAccount.clcommon__Legal_Entity_type__c = legalEntity.Id;
        update borrowerAccount;

        Contact guarantorContact = [SELECT Id,Name,Email,Title__c,BirthDate FROM Contact LIMIT 1];
        guarantorContact.Email = 'testRanOpp@YopMail.com';
        guarantorContact.loan__Contact_Type__c = Leads.GUARANTOR;
        guarantorContact.Title__c = 'CEO';
        guarantorContact.BirthDate = Date.newInstance(2000, 1, 1);
        update guarantorContact;

        loan__Loan_Account__c clContract = [SELECT Id FROM loan__Loan_Account__c LIMIT 1];
        Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.Name = borrowerAccount.Name;
        opportunityRecord.Refinanced_CL_Contract__c = clContract.Id;
        opportunityRecord.Type = GeneralConstants.LOAN_TYPE_RENEWAL;
        opportunityRecord.Create_Application__c = true;
        opportunityRecord.StageName = 'App Submitted';
        opportunityRecord.Sub_Status__c = 'Score Pending';
        opportunityRecord.LeadSource = 'Email';
        opportunityRecord.CloseDate = GeneralHelper.currentSystemDate.addYears(1);
        opportunityRecord.AccountId = borrowerAccount.Id;
        opportunityRecord.OwnerId = borrowerAccount.OwnerId != null ? borrowerAccount.OwnerId : UserInfo.getUserId();
        opportunityRecord.Requested_Loan_Amount__c = borrowerAccount.Legacy_Current_Balance__c != null ? borrowerAccount.Legacy_Current_Balance__c : 100;
        opportunityRecord.Primary_Contact__c = guarantorContact.Id;
        if(borrowerAccount.Broker_Account__c != null && borrowerAccount.Broker_Contact__c != null) {
            opportunityRecord.Broker_Account__c = borrowerAccount.Broker_Account__c;
            opportunityRecord.Broker_Contact__c = borrowerAccount.Broker_Contact__c;
        }
        insert opportunityRecord;

        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        opportunityMap.put(opportunityRecord.Id, opportunityRecord);

        Test.startTest();
            OpportunityManager.createApplication(opportunityMap);
        Test.stopTest();

        genesis__Applications__c applicationRecord = [SELECT Id FROM genesis__Applications__c
                                                WHERE genesis__Account__c = :borrowerAccount.Id LIMIT 1];
        System.assert(applicationRecord != null);
    }

    @IsTest
    public static void createEISNewApplicationTestMethod()
    {
        Id userId = TestUtility.getFakeId(User.getSObjectType());
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/New_York', UserName='standarduser1@testorg.com');

        User userRec = [Select id from user LIMIT 1];

        Account brokerAccount = [SELECT Id FROM Account WHERE Type = 'Broker' LIMIT 1];
        Contact brokerContact = [SELECT Id FROM Contact WHERE loan__Contact_Type__c = 'Broker' LIMIT 1];

        brokerContact.AccountId = brokerAccount.Id;
        update brokerContact;

        loan__Loan_Product__c loanProduct = new loan__Loan_Product__c();
        loanProduct.Name = 'CAN Capital';
        loanProduct.loan__Default_Number_of_Installments__c = 6;
        loanProduct.loan__Frequency_of_Loan_Payment__c = 'WEEKLY';
        insert loanProduct;

        clcommon__CL_Product__c productCL = new clcommon__CL_Product__c();
        productCL.clcommon__Product_Name__c = GeneralConstants.PRODUCT_NAME_DEFAULT;
        productCL.loan__Lending_Product__c = loanProduct.Id;
        insert productCL;

        genesis__Company__c company = new genesis__Company__c();
        company.Name = 'CAN Capital';
        company.genesis__Short_Name__c = 'CAN';
        insert company;

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        clcommon__Company__c clCompany = new clcommon__Company__c();
        clCompany.clcommon__Company_Name__c = 'CAN Capital';
        clCompany.clcommon__Branch_Date__c = GeneralHelper.currentSystemDate;
        insert clCompany;

        genesis__Applications__c application = [SELECT Id, genesis__Payment_Frequency__c, Annual_Volume__c, Total_Competitors_Amount__c, Sales_Rep__c
            FROM genesis__Applications__c];
        application.genesis__Payment_Frequency__c = 'WEEKLY';
        application.Sales_Rep__c = UserInfo.getUserId();
        application.Total_Competitors_Amount__c = 3333;
        application.Annual_Volume__c = 2444;
        update application;

        UnderWriter_Task__c taskDetail = new UnderWriter_Task__c();
        taskDetail.Application__c = application.Id;
        taskDetail.Task_Name__c = 'Test Task';
        taskDetail.Category__c = 'Test category';
        insert taskDetail;

        User brokerUserRecord = new User();
        brokerUserRecord.Id = TestUtility.getFakeId(User.getSObjectType());
        brokerUserRecord.ContactId = brokerContact.Id;

        clcommon__Party__c party = new clcommon__Party__c();
        party.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        party.genesis__Application__c = application.Id;

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = new List<clcommon__Party__c>{party};
        PartyManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        clcommon__Legal_Entity__c legalEntity = [SELECT Id, Name FROM clcommon__Legal_Entity__c WHERE Name = 'Partnership'];
        Account borrowerAccount = [SELECT Id,Name,Type,OwnerId,Industry,clcommon__Legal_Entity_type__c,
                                    BillingCountry,Biz_Start_Date__c,Business_Tax_ID__c, Legacy_Current_Balance__c,
                                    Broker_Contact__c,Broker_Account__c FROM Account LIMIT 1];
        borrowerAccount.BillingCountry = 'US';
        borrowerAccount.Industry = 'BUSINESS SERVICES';
        borrowerAccount.Biz_Start_Date__c = Date.newInstance(2017, 1, 1);
        borrowerAccount.Business_Tax_ID__c = '5465876';
        borrowerAccount.clcommon__Legal_Entity_type__c = legalEntity.Id;
        update borrowerAccount;

        Contact guarantorContact = [SELECT Id,Name,Email,Title__c,BirthDate FROM Contact LIMIT 1];
        guarantorContact.Email = 'testRanOpp@YopMail.com';
        guarantorContact.loan__Contact_Type__c = Leads.GUARANTOR;
        guarantorContact.Title__c = 'CEO';
        guarantorContact.BirthDate = Date.newInstance(2000, 1, 1);
        update guarantorContact;

        Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.Name = borrowerAccount.Name;
        opportunityRecord.Type = GeneralConstants.LOAN_TYPE_NEW;
        opportunityRecord.Create_Application__c = true;
        opportunityRecord.StageName = 'App Submitted';
        opportunityRecord.Sub_Status__c = 'Score Pending';
        opportunityRecord.LeadSource = 'EIS';
        opportunityRecord.CloseDate = GeneralHelper.currentSystemDate.addYears(1);
        opportunityRecord.AccountId = borrowerAccount.Id;
        opportunityRecord.OwnerId = borrowerAccount.OwnerId != null ? borrowerAccount.OwnerId : UserInfo.getUserId();
        opportunityRecord.Requested_Loan_Amount__c = borrowerAccount.Legacy_Current_Balance__c != null ? borrowerAccount.Legacy_Current_Balance__c : 100;
        opportunityRecord.Primary_Contact__c = guarantorContact.Id;
        if(borrowerAccount.Broker_Account__c != null && borrowerAccount.Broker_Contact__c != null) {
            opportunityRecord.Broker_Account__c = borrowerAccount.Broker_Account__c;
            opportunityRecord.Broker_Contact__c = borrowerAccount.Broker_Contact__c;
        }
        insert opportunityRecord;

        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        opportunityMap.put(opportunityRecord.Id, opportunityRecord);

        Test.startTest();
            OpportunityManager.createApplication(opportunityMap);
        Test.stopTest();
    }

    @IsTest
    public static void createEISRenewalApplicationTestMethod()
    {
        Id userId = TestUtility.getFakeId(User.getSObjectType());
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/New_York', UserName='standarduser1@testorg.com');

        User userRec = [Select id from user LIMIT 1];

        Account brokerAccount = [SELECT Id FROM Account WHERE Type = 'Broker' LIMIT 1];
        Contact brokerContact = [SELECT Id FROM Contact WHERE loan__Contact_Type__c = 'Broker' LIMIT 1];

        brokerContact.AccountId = brokerAccount.Id;
        update brokerContact;

        loan__Loan_Product__c loanProduct = new loan__Loan_Product__c();
        loanProduct.Name = 'CAN Capital';
        loanProduct.loan__Default_Number_of_Installments__c = 6;
        loanProduct.loan__Frequency_of_Loan_Payment__c = 'WEEKLY';
        insert loanProduct;

        clcommon__CL_Product__c productCL = new clcommon__CL_Product__c();
        productCL.clcommon__Product_Name__c = GeneralConstants.PRODUCT_NAME_DEFAULT;
        productCL.loan__Lending_Product__c = loanProduct.Id;
        insert productCL;

        genesis__Company__c company = new genesis__Company__c();
        company.Name = 'CAN Capital';
        company.genesis__Short_Name__c = 'CAN';
        insert company;

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        clcommon__Company__c clCompany = new clcommon__Company__c();
        clCompany.clcommon__Company_Name__c = 'CAN Capital';
        clCompany.clcommon__Branch_Date__c = GeneralHelper.currentSystemDate;
        insert clCompany;

        genesis__Applications__c application = [SELECT Id, genesis__Payment_Frequency__c, Annual_Volume__c, Total_Competitors_Amount__c, Sales_Rep__c
            FROM genesis__Applications__c];
        application.genesis__Payment_Frequency__c = 'WEEKLY';
        application.Sales_Rep__c = UserInfo.getUserId();
        application.Total_Competitors_Amount__c = 3333;
        application.Annual_Volume__c = 2444;
        update application;

        UnderWriter_Task__c taskDetail = new UnderWriter_Task__c();
        taskDetail.Application__c = application.Id;
        taskDetail.Task_Name__c = 'Test Task';
        taskDetail.Category__c = 'Test category';
        insert taskDetail;

        User brokerUserRecord = new User();
        brokerUserRecord.Id = TestUtility.getFakeId(User.getSObjectType());
        brokerUserRecord.ContactId = brokerContact.Id;

        clcommon__Party__c party = new clcommon__Party__c();
        party.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        party.genesis__Application__c = application.Id;

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = new List<clcommon__Party__c>{party};
        PartyManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        clcommon__Legal_Entity__c legalEntity = [SELECT Id, Name FROM clcommon__Legal_Entity__c WHERE Name = 'Partnership'];
        Account borrowerAccount = [SELECT Id,Name,Type,OwnerId,Industry,clcommon__Legal_Entity_type__c,
                                    BillingCountry,Biz_Start_Date__c,Business_Tax_ID__c, Legacy_Current_Balance__c,
                                    Broker_Contact__c,Broker_Account__c FROM Account LIMIT 1];
        borrowerAccount.BillingCountry = 'US';
        borrowerAccount.Industry = 'BUSINESS SERVICES';
        borrowerAccount.Biz_Start_Date__c = Date.newInstance(2017, 1, 1);
        borrowerAccount.Business_Tax_ID__c = '5465876';
        borrowerAccount.clcommon__Legal_Entity_type__c = legalEntity.Id;
        update borrowerAccount;

        Contact guarantorContact = [SELECT Id,Name,Email,Title__c,BirthDate FROM Contact LIMIT 1];
        guarantorContact.Email = 'testRanOpp@YopMail.com';
        guarantorContact.loan__Contact_Type__c = Leads.GUARANTOR;
        guarantorContact.Title__c = 'CEO';
        guarantorContact.BirthDate = Date.newInstance(2000, 1, 1);
        update guarantorContact;

        loan__Loan_Account__c clContract = [SELECT Id FROM loan__Loan_Account__c LIMIT 1];
        Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.Name = borrowerAccount.Name;
        opportunityRecord.Refinanced_CL_Contract__c = clContract.Id;
        opportunityRecord.Type = GeneralConstants.LOAN_TYPE_RENEWAL;
        opportunityRecord.Create_Application__c = true;
        opportunityRecord.StageName = 'App Submitted';
        opportunityRecord.Sub_Status__c = 'Score Pending';
        opportunityRecord.LeadSource = 'EIS';
        opportunityRecord.CloseDate = GeneralHelper.currentSystemDate.addYears(1);
        opportunityRecord.AccountId = borrowerAccount.Id;
        opportunityRecord.OwnerId = borrowerAccount.OwnerId != null ? borrowerAccount.OwnerId : UserInfo.getUserId();
        opportunityRecord.Requested_Loan_Amount__c = borrowerAccount.Legacy_Current_Balance__c != null ? borrowerAccount.Legacy_Current_Balance__c : 100;
        opportunityRecord.Primary_Contact__c = guarantorContact.Id;
        if(borrowerAccount.Broker_Account__c != null && borrowerAccount.Broker_Contact__c != null) {
            opportunityRecord.Broker_Account__c = borrowerAccount.Broker_Account__c;
            opportunityRecord.Broker_Contact__c = borrowerAccount.Broker_Contact__c;
        }
        insert opportunityRecord;

        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        opportunityMap.put(opportunityRecord.Id, opportunityRecord);

        Test.startTest();
            OpportunityManager.createApplication(opportunityMap);
        Test.stopTest();
    }

    @IsTest
    public static void createApplicationConcurrentTestMethod()
    {
        Id userId = TestUtility.getFakeId(User.getSObjectType());
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/New_York', UserName='standarduser1@testorg.com');

        User userRec = [Select id from user LIMIT 1];

        Account brokerAccount = [SELECT Id FROM Account WHERE Type = 'Broker' LIMIT 1];
        Contact brokerContact = [SELECT Id FROM Contact WHERE loan__Contact_Type__c = 'Broker' LIMIT 1];

        brokerContact.AccountId = brokerAccount.Id;
        update brokerContact;

        loan__Loan_Product__c loanProduct = new loan__Loan_Product__c();
        loanProduct.Name = 'CAN Capital';
        loanProduct.loan__Default_Number_of_Installments__c = 6;
        loanProduct.loan__Frequency_of_Loan_Payment__c = 'WEEKLY';
        insert loanProduct;

        clcommon__CL_Product__c productCL = new clcommon__CL_Product__c();
        productCL.clcommon__Product_Name__c = GeneralConstants.PRODUCT_NAME_DEFAULT;
        productCL.loan__Lending_Product__c = loanProduct.Id;
        insert productCL;

        genesis__Company__c company = new genesis__Company__c();
        company.Name = 'CAN Capital';
        company.genesis__Short_Name__c = 'CAN';
        insert company;

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        clcommon__Company__c clCompany = new clcommon__Company__c();
        clCompany.clcommon__Company_Name__c = 'CAN Capital';
        clCompany.clcommon__Branch_Date__c = GeneralHelper.currentSystemDate;
        insert clCompany;

        genesis__Applications__c application = [SELECT Id, genesis__Payment_Frequency__c, Annual_Volume__c, Total_Competitors_Amount__c, Sales_Rep__c
            FROM genesis__Applications__c];
        application.genesis__Payment_Frequency__c = 'WEEKLY';
        application.Sales_Rep__c = UserInfo.getUserId();
        application.Total_Competitors_Amount__c = 3333;
        application.Annual_Volume__c = 2444;
        update application;

        UnderWriter_Task__c taskDetail = new UnderWriter_Task__c();
        taskDetail.Application__c = application.Id;
        taskDetail.Task_Name__c = 'Test Task';
        taskDetail.Category__c = 'Test category';
        insert taskDetail;

        User brokerUserRecord = new User();
        brokerUserRecord.Id = TestUtility.getFakeId(User.getSObjectType());
        brokerUserRecord.ContactId = brokerContact.Id;

        clcommon__Party__c party = new clcommon__Party__c();
        party.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        party.genesis__Application__c = application.Id;

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = new List<clcommon__Party__c>{party};
        PartyManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        clcommon__Legal_Entity__c legalEntity = [SELECT Id, Name FROM clcommon__Legal_Entity__c WHERE Name = 'Partnership'];
        Account borrowerAccount = [SELECT Id,Name,Type,OwnerId,Legacy_Current_Balance__c,Industry,clcommon__Legal_Entity_type__c,
                                    BillingCountry,Biz_Start_Date__c,Business_Tax_ID__c,
                                    Broker_Contact__c,Broker_Account__c FROM Account LIMIT 1];
        borrowerAccount.Legacy_Current_Balance__c = 5434.66;
        borrowerAccount.BillingCountry = 'US';
        borrowerAccount.Industry = 'BUSINESS SERVICES';
        borrowerAccount.Biz_Start_Date__c = Date.newInstance(2017, 1, 1);
        borrowerAccount.Business_Tax_ID__c = '5465876';
        borrowerAccount.clcommon__Legal_Entity_type__c = legalEntity.Id;
        update borrowerAccount;

        Contact guarantorContact = [SELECT Id,Name,Email,Title__c,BirthDate FROM Contact LIMIT 1];
        guarantorContact.Email = 'testRanOpp@YopMail.com';
        guarantorContact.loan__Contact_Type__c = Leads.GUARANTOR;
        guarantorContact.Title__c = 'CEO';
        guarantorContact.BirthDate = Date.newInstance(2000, 1, 1);
        update guarantorContact;

        loan__Loan_Account__c clContract = [SELECT Id FROM loan__Loan_Account__c LIMIT 1];
        Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.Name = borrowerAccount.Name;
        opportunityRecord.Refinanced_CL_Contract__c = clContract.Id;
        opportunityRecord.Type = GeneralConstants.LOAN_TYPE_CONCURRENT;
        opportunityRecord.Create_Application__c = true;
        opportunityRecord.StageName = 'App Submitted';
        opportunityRecord.Sub_Status__c = 'Score Pending';
        opportunityRecord.LeadSource = 'Email';
        opportunityRecord.CloseDate = GeneralHelper.currentSystemDate.addYears(1);
        opportunityRecord.AccountId = borrowerAccount.Id;
        opportunityRecord.OwnerId = borrowerAccount.OwnerId != null ? borrowerAccount.OwnerId : UserInfo.getUserId();
        opportunityRecord.Requested_Loan_Amount__c = borrowerAccount.Legacy_Current_Balance__c != null ? borrowerAccount.Legacy_Current_Balance__c : 100;
        opportunityRecord.Primary_Contact__c = guarantorContact.Id;
        opportunityRecord.Concurrent_Eligible_Amount__c = 100;
        if(borrowerAccount.Broker_Account__c != null && borrowerAccount.Broker_Contact__c != null) {
            opportunityRecord.Broker_Account__c = borrowerAccount.Broker_Account__c;
            opportunityRecord.Broker_Contact__c = borrowerAccount.Broker_Contact__c;
        }
        insert opportunityRecord;

        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        opportunityMap.put(opportunityRecord.Id, opportunityRecord);

        Test.startTest();
            OpportunityManager.createApplication(opportunityMap);
        Test.stopTest();

        genesis__Applications__c applicationRecord = [SELECT Id FROM genesis__Applications__c
                                                WHERE genesis__Account__c = :borrowerAccount.Id LIMIT 1];
        System.assert(applicationRecord != null);
    }
}