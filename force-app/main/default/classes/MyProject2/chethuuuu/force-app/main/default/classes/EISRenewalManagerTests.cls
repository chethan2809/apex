@IsTest
private class EISRenewalManagerTests
{
    public static Date currentSystemDate = Date.newInstance(2020, 1, 1);

    @TestSetup
    static void makeData() {
        TestUtility.runSetupData();
        TestUtility.createLegalEntity();
        TestUtility.createDocumentDefinition();
        TestUtility.createReciprocalRole();

        TestUtility.createBrokerContact();
    }

    @IsTest
    private static void createRenewalApplicationTest()
    {
        Id userId = TestUtility.getFakeId(User.getSObjectType());
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/New_York', UserName=TestUtility.generateFakeName() + 'test2@test.com');

        User userRec = [SELECT ID FROM user LIMIT 1];

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

        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountRecord.Name = 'Opp EIS Account Test';
        accountRecord.Broker_Account__c = brokerContact.AccountId;
        accountRecord.Broker_Contact__c = brokerContact.Id;
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '075898984';
        accountRecord.Biz_Start_Date__c = currentSystemDate.addYears(-10);
        accountRecord.Type = 'Borrower';
        accountRecord.Legacy_Renewal_Eligible__c = true;
        accountRecord.Legacy_Renewal_Application_Created_Date__c = null;
        accountRecord.Migrated_Date__c = Date.newInstance(2021, 1, 1);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{accountRecord};
        EISRenewalManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub accountAppDBStubInstance = new DBManagerTestsStub();
        accountAppDBStubInstance.genericReturnObject = new List<Account>{accountRecord};
        ApplicationManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountAppDBStubInstance);

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'Opp EIS';
        contactRecord.LastName = 'Contact Opp Test';
        contactRecord.loan__Contact_Type__c = 'Guarantor';
        contactRecord.AccountId = accountRecord.Id;

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact>{contactRecord};
        EISRenewalManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        DBManagerTestsStub clCommonRelationship1DBStubInstance = new DBManagerTestsStub();
        EISRenewalManager.clCommonRelationshipDBInstance = (CLCommonRelationshipDB) Test.createStub(CLCommonRelationshipDB.class, clCommonRelationship1DBStubInstance);

        DBManagerTestsStub opportunity1DBStubInstance = new DBManagerTestsStub();
        EISRenewalManager.opportunityDBInstance = (OpportunityDB) Test.createStub(OpportunityDB.class, opportunity1DBStubInstance);

        DBManagerTestsStub application1DBStubInstance = new DBManagerTestsStub();
        EISRenewalManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, application1DBStubInstance);

        DBManagerTestsStub application2DBStubInstance = new DBManagerTestsStub();
        ApplicationManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, application2DBStubInstance);

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        PartyManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        DBManagerTestsStub ocrolusReportDBStubInstance = new DBManagerTestsStub();
        EISRenewalManager.ocrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBStubInstance);

        Profile profileRecord = [SELECT Id, Name FROM Profile WHERE Name = 'BrokerCommunityPlus'];
        User newUser = new User ();
        newUser.Alias = 'rnT';
        newUser.Email = 'ranTest@YopMail.com';
        newUser.EmailEncodingKey = 'UTF-8';
        newUser.FirstName = 'contactRecord.FirstName';
        newUser.LastName = 'contactRecord.LastName';
        newUser.LanguageLocaleKey = 'en_US';
        newUser.LocaleSidKey = 'en_US';
        newUser.ContactId = accountRecord.Broker_Contact__c;
        newUser.TimeZoneSidKey = 'America/New_York';
        newUser.Username = TestUtility.generateFakeName() + '@example.com';
        newUser.CommunityNickname = 'nickName';
        newUser.ProfileId = profileRecord.Id;
        newUser.IsActive = true;
        newUser.Id = TestUtility.getFakeId(User.getSObjectType());

        DBManagerTestsStub newUserDBStubInstance = new DBManagerTestsStub();
        newUserDBStubInstance.genericReturnObject = new List<User>{newUser};
        EISRenewalManager.userDBInstance = (UserDB) Test.createStub(UserDB.class, newUserDBStubInstance);


        EISRenewalManager.createRenewalApplication(accountRecord);
    }

    @IsTest
    private static void createRenewalApplicationWithCLSDataTest()
    {
        Id userId = TestUtility.getFakeId(User.getSObjectType());
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/New_York', UserName=TestUtility.generateFakeName() + 'test2@test.com');

        User userRec = [SELECT ID FROM user LIMIT 1];

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

        Account accountCLSRecord = new Account();
        accountCLSRecord.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountCLSRecord.Name = 'Opp CLS Account Test';
        accountCLSRecord.Broker_Account__c = brokerContact.AccountId;
        accountCLSRecord.Broker_Contact__c = brokerContact.Id;
        accountCLSRecord.Sic = '23';
        accountCLSRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountCLSRecord.Business_Tax_ID__c = '075898984';
        accountCLSRecord.Biz_Start_Date__c = currentSystemDate.addYears(-10);
        accountCLSRecord.Type = 'Borrower';
        accountCLSRecord.Legacy_Renewal_Eligible__c = true;
        accountCLSRecord.Legacy_Renewal_Application_Created_Date__c = null;
        accountCLSRecord.Migrated_Date__c = Date.newInstance(2021, 1, 1);

        DBManagerTestsStub accountCLSDBStubInstance = new DBManagerTestsStub();
        accountCLSDBStubInstance.genericReturnObject = new List<Account>{accountCLSRecord};
        EISRenewalManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountCLSDBStubInstance);

        DBManagerTestsStub accountCLSApplicationDBStubInstance = new DBManagerTestsStub();
        accountCLSApplicationDBStubInstance.genericReturnObject = new List<Account>{accountCLSRecord};
        ApplicationManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountCLSApplicationDBStubInstance);

        Account guarantorAccountRecord = new Account();
        guarantorAccountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());
        guarantorAccountRecord.Name = 'Opp CLS guarantor Account Test';
        guarantorAccountRecord.Type = 'Guarantor';

        DBManagerTestsStub guarantorAccountDBStubInstance = new DBManagerTestsStub();
        guarantorAccountDBStubInstance.genericReturnObject = new List<Account>{guarantorAccountRecord};
        EISRenewalManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, guarantorAccountDBStubInstance);

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'Opp CLS';
        contactRecord.LastName = 'Contact Opp Test';
        contactRecord.loan__Contact_Type__c = 'Guarantor';
        contactRecord.AccountId = guarantorAccountRecord.Id;

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact>{contactRecord};
        EISRenewalManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        DBManagerTestsStub clCommonRelationshipDBStubInstance = new DBManagerTestsStub();
        EISRenewalManager.clCommonRelationshipDBInstance = (CLCommonRelationshipDB) Test.createStub(CLCommonRelationshipDB.class, clCommonRelationshipDBStubInstance);

        DBManagerTestsStub opportunityDBStubInstance = new DBManagerTestsStub();
        EISRenewalManager.opportunityDBInstance = (OpportunityDB) Test.createStub(OpportunityDB.class, opportunityDBStubInstance);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        EISRenewalManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        PartyManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        DBManagerTestsStub ocrolusReportDBStubInstance = new DBManagerTestsStub();
        EISRenewalManager.ocrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBStubInstance);

        Profile profileRecord = [SELECT Id, Name FROM Profile WHERE Name = 'BrokerCommunityPlus'];
        User newUser = new User ();
        newUser.Alias = 'rnT';
        newUser.Email = 'ranTestCLS@YopMail.com';
        newUser.EmailEncodingKey = 'UTF-8';
        newUser.FirstName = 'contact.FirstName';
        newUser.LastName = 'contact.LastName';
        newUser.LanguageLocaleKey = 'en_US';
        newUser.LocaleSidKey = 'en_US';
        newUser.ContactId = accountCLSRecord.Broker_Contact__c;
        newUser.TimeZoneSidKey = 'America/New_York';
        newUser.Username = TestUtility.generateFakeName() + 'test2@test.com';
        newUser.CommunityNickname = 'nickName';
        newUser.ProfileId = profileRecord.Id;
        newUser.IsActive = true;
        newUser.Id = TestUtility.getFakeId(User.getSObjectType());

        DBManagerTestsStub newUserDBStubInstance = new DBManagerTestsStub();
        newUserDBStubInstance.genericReturnObject = new List<User>{newUser};
        EISRenewalManager.userDBInstance = (UserDB) Test.createStub(UserDB.class, newUserDBStubInstance);


        EISRenewalManager.createRenewalApplication(accountCLSRecord);
    }
}