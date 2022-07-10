@isTest
private class OpportunityManagerTests
{
    @testSetup
    static void makeData() {
        TestUtility.runSetupData();
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

        TestUtility.createLegalEntity();
        TestUtility.createDocumentDefinition();

        loan__Loan_Account__c clContract = TestUtility.createContract();
    }

    @isTest
    private static void opportunityMandatoryFieldsTestMethod()
    {
        Account borrowerAccount = new Account();
        borrowerAccount.Name = 'g Borrower Opp';
        borrowerAccount.Legacy_Current_Balance__c = null;
        borrowerAccount.BillingCountry = null;
        borrowerAccount.Industry = null;
        borrowerAccount.Biz_Start_Date__c = null;
        borrowerAccount.Business_Tax_ID__c = null;
        borrowerAccount.clcommon__Legal_Entity_type__c = null;
        borrowerAccount.Current_Active_Contract_Number__c = 'Legacy Contract';

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{borrowerAccount};
        OpportunityManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Account guarantorAccount = new Account();
        guarantorAccount.Name = 'g Test Account';
        guarantorAccount.Id = TestUtility.getFakeId(Account.getSObjectType());

        DBManagerTestsStub guarantorAccountDBStubInstance = new DBManagerTestsStub();
        guarantorAccountDBStubInstance.genericReturnObject = new List<Account>{guarantorAccount};
        OpportunityManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, guarantorAccountDBStubInstance);

        Contact guarantorContact = new Contact();
        guarantorContact.LastName = 'g Test Contact';
        guarantorContact.Id = TestUtility.getFakeId(Contact.getSObjectType());
        guarantorContact.AccountId = guarantorAccount.Id;

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact>{guarantorContact};
        OpportunityManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        Map<String, String> opportunityRecordMap = new Map<String, String>();
        opportunityRecordMap.put('Name','App Submitted');
        opportunityRecordMap.put('Type','Renewal');
        opportunityRecordMap.put('LeadSource','Email');
        opportunityRecordMap.put('AccountId', borrowerAccount.Id);
        opportunityRecordMap.put('Primary_Contact__c', guarantorContact.Id);
        String jsonString = JSON.serialize(opportunityRecordMap);
        Opportunity opportunityRecord = (Opportunity) JSON.deserialize(jsonString, Opportunity.class);

        Test.startTest();
            OpportunityManager.mandatoryInformationCheck(opportunityRecord);
        Test.stopTest();

        System.assertEquals(OpportunityManager.mandatoryCheck, false);
    }

    @isTest
    private static void createApplicationTestMethod()
    {
        clcommon__Legal_Entity__c legalEntity = [SELECT Id, Name FROM clcommon__Legal_Entity__c WHERE Name = 'Partnership'];
        Account borrowerAccount = [SELECT Id,Name,Type,OwnerId,Industry,clcommon__Legal_Entity_type__c,
                                    BillingCountry,Biz_Start_Date__c,Business_Tax_ID__c, Legacy_Current_Balance__c,
                                    Broker_Contact__c,Broker_Account__c FROM Account LIMIT 1];
        borrowerAccount.BillingCountry = 'US';
        borrowerAccount.Industry = 'BUSINESS SERVICES';
        borrowerAccount.Biz_Start_Date__c = Date.newInstance(2017, 1, 1);
        borrowerAccount.Business_Tax_ID__c = '5465876';
        borrowerAccount.clcommon__Legal_Entity_type__c = legalEntity.Id;

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{borrowerAccount};
        OpportunityManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Contact guarantorContact = [SELECT Id, AccountId, Name, Email, Title__c, BirthDate FROM Contact LIMIT 1];
        guarantorContact.Email = 'testRanOpp@YopMail.com';
        guarantorContact.loan__Contact_Type__c = Leads.GUARANTOR;
        guarantorContact.Title__c = 'CEO';
        guarantorContact.BirthDate = Date.newInstance(2000, 1, 1);

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact>{guarantorContact};
        OpportunityManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        loan__Loan_Account__c clContract = [SELECT Id FROM loan__Loan_Account__c LIMIT 1];
        Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.Name = borrowerAccount.Name;
        opportunityRecord.Refinanced_CL_Contract__c = clContract.Id;
        opportunityRecord.Type = GeneralConstants.LOAN_TYPE_NEW;
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

    @isTest
    private static void createApplicationEISTestMethod()
    {
        clcommon__Legal_Entity__c legalEntity = [SELECT Id, Name FROM clcommon__Legal_Entity__c WHERE Name = 'Partnership'];
        Account borrowerAccount = [SELECT Id,Name,AccountSource,Type,OwnerId,Industry,clcommon__Legal_Entity_type__c,
                                    BillingCountry,Biz_Start_Date__c,Business_Tax_ID__c, Legacy_Current_Balance__c,
                                    Current_Active_Contract_Number__c, AnnualRevenue,
                                    Broker_Contact__c,Broker_Account__c FROM Account LIMIT 1];
        borrowerAccount.BillingCountry = 'US';
        borrowerAccount.Industry = 'BUSINESS SERVICES';
        borrowerAccount.Biz_Start_Date__c = Date.newInstance(2017, 1, 1);
        borrowerAccount.Business_Tax_ID__c = '5465876';
        borrowerAccount.clcommon__Legal_Entity_type__c = legalEntity.Id;
        borrowerAccount.Current_Active_Contract_Number__c = 'Legacy Contract';
        borrowerAccount.AnnualRevenue = 3343242;
        borrowerAccount.AccountSource = 'EIS';

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{borrowerAccount};
        OpportunityManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Contact guarantorContact = [SELECT Id, AccountId, Name, Email, Title__c, BirthDate FROM Contact LIMIT 1];
        guarantorContact.Email = 'testRanOpp@YopMail.com';
        guarantorContact.loan__Contact_Type__c = Leads.GUARANTOR;
        guarantorContact.Title__c = 'CEO';
        guarantorContact.BirthDate = Date.newInstance(2000, 1, 1);

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact>{guarantorContact};
        OpportunityManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

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

        genesis__Applications__c applicationRecord = [SELECT Id FROM genesis__Applications__c
                                                WHERE genesis__Account__c = :borrowerAccount.Id LIMIT 1];
        System.assert(applicationRecord != null);
    }
}