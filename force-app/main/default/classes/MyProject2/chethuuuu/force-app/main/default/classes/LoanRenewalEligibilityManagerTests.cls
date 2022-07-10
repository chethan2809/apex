@isTest
private class LoanRenewalEligibilityManagerTests {
    @TestSetup
    static void makeData(){
        TestUtility.runSetupData();
        loan__Loan_Account__c loanAccount = TestUtility.createContract();
        Contact brokerContact = TestUtility.createContact();
        Account brokerAccount = TestUtility.createAccount();
    }

    @isTest
    private static void createRenewalOpportunity(){
        Id userId = TestUtility.getFakeId(User.getSObjectType());
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1@testorg.com');

        User userRec = [Select id from user LIMIT 1];

        Account brokerAccount = [
            SELECT Id
            FROM Account LIMIT 1
        ];
        Contact brokerContact = [
            SELECT Id, AccountId
            FROM Contact LIMIT 1
        ];

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

        loan__Loan_Account__c loanAccount = [
            SELECT Id, Name, loan__Account__c, loan__Frequency_of_Loan_Payment__c, Latest_Missed_Payment_Date__c, Broker_Contact__r.AccountId,
                loan__Interest_Paid__c, loan__Principal_Paid__c, loan__Fees_Paid__c, loan__Penalty_Paid__c,
                loan__Principal_Remaining__c, loan__Interest_Accrued_Not_Due__c, loan__Fees_Remaining__c, Application__c,
                loan__Account__r.Name, Application__r.Primary_Guarantor__c, Broker_Contact__c, Application__r.Sales_Rep__c,
                Application__r.Primary_Guarantor__r.AccountId, loan__Loan_Product_Name__c,Application__r.Underwriter__c,
                Application__r.Annual_Volume__c,Application__r.OwnerId
            FROM loan__Loan_Account__c
        ];

        List<loan__Loan_Account__c> contractList = new List<loan__Loan_Account__c>();
        loanAccount.Application__c = application.Id;
        loanAccount.loan__Frequency_of_Loan_Payment__c = 'Weekly';
        loanAccount.Latest_Missed_Payment_Date__c = GeneralHelper.currentSystemDate.addDays(-12);
        loanAccount.loan__Interest_Paid__c = 2000;
        loanAccount.loan__Principal_Paid__c = 6000;
        loanAccount.loan__Fees_Paid__c = 9000;
        loanAccount.loan__Penalty_Paid__c = 1000;
        loanAccount.loan__Principal_Remaining__c = 4000;
        loanAccount.loan__Interest_Accrued_Not_Due__c = 2000;
        loanAccount.loan__Fees_Remaining__c = 5350;
        loanAccount.Broker_Contact__c = brokerContact.Id;
        update loanAccount;
        contractList.add(loanAccount);

        Test.startTest();
            LoanRenewalEligibilityManager.createRenewalOpportunity(contractList);
        Test.stopTest();

        System.assert(contractList != null);
    }
}