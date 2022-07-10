@IsTest
private class LeadManagerTests
{
    @TestSetup
    static void makeData() {
        TestUtility.runSetupData();
        TestUtility.createLegalEntity();
        TestUtility.createDocumentDefinition();

        genesis__Applications__c application = TestUtility.createApplication();
    }

    @IsTest
    private static void convertLeadsAsMerchantTests()
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

        String firstName = '';
        String guarantorAccountName = firstName  + ' ' + 'Test Lead';
        Account acc = new Account();
        acc.Name = guarantorAccountName;
        acc.Type = Accounts.GUARANTOR;
        acc.Legacy_AccountID__c = '60000001';

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{acc};
        LeadManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Opportunity opportunity = [SELECT Id, Name, AccountId, Primary_Contact__c FROM Opportunity
                                    WHERE AccountId != null AND Primary_Contact__c != null LIMIT 1];

        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id, Name FROM clcommon__Legal_Entity__c];
        Map<String, Id> legalNameToIds = new Map<String, Id>();
        for(clcommon__Legal_Entity__c legalEntity : legalEntityList) {
            legalNameToIds.put(legalEntity.Name, legalEntity.Id);
        }
        OriginationHelper.legalNameToId = legalNameToIds;

        Id leadId = TestUtility.getFakeId(Lead.getSObjectType());

        Map<String, String> leadMap = TestUtility.getLeadMap();
        leadMap.put('Id',leadId);
        leadMap.put('FirstName','Cloud');
        leadMap.put('LastName','Can Lead EIS');
        leadMap.put('ConvertedAccountId',opportunity.AccountId);
        leadMap.put('ConvertedContactId',opportunity.Primary_Contact__c);
        leadMap.put('ConvertedOpportunityId',opportunity.Id);
        leadMap.put('Broker_Contact__c',brokerContact.Id);
        leadMap.put('Lead_Type__c','Merchant');
        leadMap.put('LeadSource','Merchant Phone');
        leadMap.put('IsConverted', 'true');
        String jsonString = JSON.serialize(leadMap);
        Lead leadRecord = (Lead) JSON.deserialize(jsonString, Lead.class);

        Test.startTest();
        LeadManager.convertLeadsAsMerchant(leadRecord);
        Test.stopTest();

        System.assert(opportunity.Id != null);
    }

    @IsTest
    private static void convertLeadsAsBrokerTests()
    {
        Account brokerAccount = [SELECT Id FROM Account LIMIT 1];
        Contact brokerContact = [SELECT Id FROM Contact LIMIT 1];
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];

        Map<String, String> leadMap = TestUtility.getLeadMap();
        leadMap.put('ConvertedAccountId',brokerAccount.Id);
        leadMap.put('ConvertedContactId',brokerContact.Id);
        leadMap.put('ConvertedOpportunityId',opportunity.Id);
        leadMap.put('Broker_Contact__c',brokerContact.Id);
        leadMap.put('Lead_Type__c','Broker');
        leadMap.put('LeadSource','Broker Phone');
        leadMap.put('IsConverted', 'true');
        String jsonString = JSON.serialize(leadMap);
        Lead leadRecord = (Lead) JSON.deserialize(jsonString, Lead.class);

        DBManagerTestsStub opportunityDBStubInstance = new DBManagerTestsStub();
        LeadManager.opportunityDBInstance = (OpportunityDB) Test.createStub(OpportunityDB.class, opportunityDBStubInstance);

        Test.startTest();
            LeadManager.convertLeadsAsBroker(leadRecord);
        Test.stopTest();

        System.assert(brokerAccount.Id != null);
    }
}