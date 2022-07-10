@isTest
private class LexisNexisManagerTests {
    @TestSetup
    static void makeData(){
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        TestUtility.runSetupData();
        genesis__Applications__c application = TestUtility.createApplication();

        clcommon__Party_Type__c partyTypeGuarantor = new clcommon__Party_Type__c();
        partyTypeGuarantor.Name = GeneralConstants.PARTY_TYPE_GUARANTOR;
        insert partyTypeGuarantor;

        clcommon__Party_Type__c partyTypeBorrower = new clcommon__Party_Type__c();
        partyTypeBorrower.Name = GeneralConstants.PARTY_TYPE_BORROWER;
        insert partyTypeBorrower;

        List<clcommon__Party__c> partyList = new List<clcommon__Party__c>();
        clcommon__Party__c partyBorrower = new clcommon__Party__c();
        partyBorrower.genesis__Application__c = application.Id;
        partyBorrower.clcommon__Account__c = application.genesis__Account__c;
        partyBorrower.clcommon__Type__c = partyTypeBorrower.Id;
        partyBorrower.clcommon__isPrimary__c = false;
        partyList.add(partyBorrower);

        clcommon__Party__c partyGuarantor = new clcommon__Party__c();
        partyGuarantor.genesis__Application__c = application.Id;
        partyGuarantor.clcommon__Contact__c = application.Primary_Guarantor__c;
        partyGuarantor.clcommon__Account__c = application.genesis__Account__c;
        partyGuarantor.clcommon__Type__c = partyTypeGuarantor.Id;
        partyGuarantor.clcommon__isPrimary__c = true;
        partyList.add(partyGuarantor);

        insert partyList;
    }

    @isTest
    private static void requestLexisNexisBIIDCheck() {
        genesis__Applications__c application = [
            SELECT Id, Name, Opportunity__c, genesis__Payment_Frequency__c, genesis__Loan_Amount__c, genesis__Term__c, Industry_Rating__c,
                SC4_Tier__c, Type__c, Business_Type__c, genesis__Account__c, genesis__Account__r.AnnualRevenue, Primary_Guarantor__c, Is_Manual_Score_Run__c
            FROM genesis__Applications__c
        ];

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        LexisNexisManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        List<clcommon__Party__c> partyList = [
            SELECT Id, clcommon__Account__c, clcommon__Contact__c, genesis__Application__c,
                genesis__Application__r.genesis__Account__c, clcommon__Type__r.Name, clcommon__Type__c, clcommon__isPrimary__c,
                clcommon__Account__r.Name, clcommon__Contact__r.FirstName, clcommon__Contact__r.LastName
            FROM clcommon__Party__c
        ];

        Account accountRecord = [
            SELECT Id, Name, Phone, Business_Tax_ID__c, BillingStreet, BillingCity, BillingState, BillingPostalCode,
                Last_Business_Credit_Pull__c, Sic, Customer_Since__c, Legacy_Percent_Paid__c, Biz_Start_Date__c
            FROM Account
            WHERE Id = :application.genesis__Account__c
        ];

        Contact contactRecord = [
            SELECT Id, Name, AccountId, Last_Consumer_Credit_Pull__c, LastName, FirstName, genesis__SSN__c,
                MailingBuildingNumber__c, MailingAddress, Email, Birthdate, ints__Driver_License__c, Phone, Credit_Report_Message__c,
                loan__Contact_Type__c, Title__c
            FROM Contact
            WHERE Id = :application.Primary_Guarantor__c
        ];

        List<clcommon__Party_Type__c> partyTypeList = [SELECT Id, Name FROM clcommon__Party_Type__c];

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = partyList;
        LexisNexisManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {accountRecord};
        LexisNexisManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact> {contactRecord};
        LexisNexisManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        DBManagerTestsStub partyTypeDBStubInstance = new DBManagerTestsStub();
        partyTypeDBStubInstance.genericReturnObject = partyTypeList;
        OriginationHelper.partyTypeDBInstance = (PartyTypeDB) Test.createStub(PartyTypeDB.class, partyTypeDBStubInstance);

        Credit_Report_Detail__c creditReportDetail = new Credit_Report_Detail__c();
        creditReportDetail.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        creditReportDetail.Type__c = 'Lexis Nexis';
        creditReportDetail.Application__c = application.Id;

        DBManagerTestsStub creditReportDetailDBStubInstance = new DBManagerTestsStub();
        creditReportDetailDBStubInstance.genericReturnObject = new List<Credit_Report_Detail__c> {creditReportDetail};
        LexisNexisManager.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, creditReportDetailDBStubInstance);

        UnderWriter_Task__c underWriterTask = new UnderWriter_Task__c();
        underWriterTask.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        underWriterTask.Application__c = application.Id;
        underWriterTask.Verification_Type__c = 'AUTOMATED';
        underWriterTask.Task_Name__c = 'Dummy Task';

        DBManagerTestsStub underWriterTaskDBStubInstance = new DBManagerTestsStub();
        underWriterTaskDBStubInstance.genericReturnObject = new List<UnderWriter_Task__c>{underWriterTask};
        LexisNexisManager.underWriterTaskDBInstance = (UnderWriterTaskDB) Test.createStub(UnderWriterTaskDB.class, underWriterTaskDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        LexisNexisManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Exception ex;
        Test.setMock(HttpCalloutMock.class, new LexisNexisCallOutMock.LexisNexisSuccessResponse());
        Test.startTest();

            LexisNexisManager.requestLexisNexisBIIDCheck(new List<genesis__Applications__c>{application});

        Test.stopTest();
    }

    @isTest
    private static void requestLexisNexisBIIDCheckException() {
        genesis__Applications__c application = [
            SELECT Id, Name, Opportunity__c, genesis__Payment_Frequency__c, genesis__Loan_Amount__c, genesis__Term__c, Industry_Rating__c,
                SC4_Tier__c, Type__c, Business_Type__c, genesis__Account__c, genesis__Account__r.AnnualRevenue, Primary_Guarantor__c, Is_Manual_Score_Run__c
            FROM genesis__Applications__c
        ];

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        LexisNexisManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        List<clcommon__Party__c> partyList = [
            SELECT Id, clcommon__Account__c, clcommon__Contact__c, genesis__Application__c,
                genesis__Application__r.genesis__Account__c, clcommon__Type__r.Name, clcommon__Type__c, clcommon__isPrimary__c,
                clcommon__Account__r.Name, clcommon__Contact__r.FirstName, clcommon__Contact__r.LastName
            FROM clcommon__Party__c
        ];

        Account accountRecord = [
            SELECT Id, Name, Phone, Business_Tax_ID__c, BillingStreet, BillingCity, BillingState, BillingPostalCode,
                Last_Business_Credit_Pull__c, Sic, Customer_Since__c, Legacy_Percent_Paid__c, Biz_Start_Date__c
            FROM Account
            WHERE Id = :application.genesis__Account__c
        ];

        Contact contactRecord = [
            SELECT Id, Name, AccountId, Last_Consumer_Credit_Pull__c, LastName, FirstName, genesis__SSN__c,
                MailingBuildingNumber__c, MailingAddress, Email, Birthdate, ints__Driver_License__c, Phone, Credit_Report_Message__c,
                loan__Contact_Type__c, Title__c
            FROM Contact
            WHERE Id = :application.Primary_Guarantor__c
        ];

        List<clcommon__Party_Type__c> partyTypeList = [SELECT Id, Name FROM clcommon__Party_Type__c];

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = partyList;
        LexisNexisManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {accountRecord};
        LexisNexisManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact> {contactRecord};
        LexisNexisManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        DBManagerTestsStub partyTypeDBStubInstance = new DBManagerTestsStub();
        partyTypeDBStubInstance.genericReturnObject = partyTypeList;
        OriginationHelper.partyTypeDBInstance = (PartyTypeDB) Test.createStub(PartyTypeDB.class, partyTypeDBStubInstance);

        Credit_Report_Detail__c creditReportDetail = new Credit_Report_Detail__c();
        creditReportDetail.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        creditReportDetail.Type__c = 'Lexis Nexis';
        creditReportDetail.Application__c = application.Id;

        DBManagerTestsStub creditReportDetailDBStubInstance = new DBManagerTestsStub();
        creditReportDetailDBStubInstance.genericReturnObject = new List<Credit_Report_Detail__c> {creditReportDetail};
        LexisNexisManager.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, creditReportDetailDBStubInstance);

        UnderWriter_Task__c underWriterTask = new UnderWriter_Task__c();
        underWriterTask.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        underWriterTask.Application__c = application.Id;
        underWriterTask.Verification_Type__c = 'AUTOMATED';
        underWriterTask.Task_Name__c = 'Dummy Task';

        DBManagerTestsStub underWriterTaskDBStubInstance = new DBManagerTestsStub();
        underWriterTaskDBStubInstance.genericReturnObject = new List<UnderWriter_Task__c>{underWriterTask};
        LexisNexisManager.underWriterTaskDBInstance = (UnderWriterTaskDB) Test.createStub(UnderWriterTaskDB.class, underWriterTaskDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        LexisNexisManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Exception ex;
        Test.setMock(HttpCalloutMock.class, new LexisNexisCallOutMock());
        Test.startTest();

                LexisNexisManager.requestLexisNexisBIIDCheck(new List<genesis__Applications__c>{application});

        Test.stopTest();
    }

    @isTest
    private static void requestLexisNexisFraudScoreCheck() {
        genesis__Applications__c application = [
            SELECT Id, Name, Opportunity__c, genesis__Payment_Frequency__c, genesis__Loan_Amount__c, genesis__Term__c, Industry_Rating__c,
                SC4_Tier__c, Type__c, Business_Type__c, genesis__Account__c, genesis__Account__r.AnnualRevenue, Primary_Guarantor__c
            FROM genesis__Applications__c
        ];

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        LexisNexisManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        List<clcommon__Party__c> partyList = [
            SELECT Id, clcommon__Account__c, clcommon__Contact__c, genesis__Application__c,
                genesis__Application__r.genesis__Account__c, clcommon__Type__r.Name, clcommon__Type__c, clcommon__isPrimary__c,
                clcommon__Account__r.Name, clcommon__Contact__r.FirstName, clcommon__Contact__r.LastName
            FROM clcommon__Party__c
        ];

        Account accountRecord = [
            SELECT Id, Name, Phone, Business_Tax_ID__c, BillingStreet, BillingCity, BillingState, BillingPostalCode,
                Last_Business_Credit_Pull__c, Sic, Customer_Since__c, Legacy_Percent_Paid__c, Biz_Start_Date__c
            FROM Account
            WHERE Id = :application.genesis__Account__c
        ];

        Contact contactRecord = [
            SELECT Id, Name, AccountId, Last_Consumer_Credit_Pull__c, LastName, FirstName, genesis__SSN__c,
                MailingBuildingNumber__c, MailingAddress, Email, Birthdate, ints__Driver_License__c, Phone, Credit_Report_Message__c,
                loan__Contact_Type__c, Title__c
            FROM Contact
            WHERE Id = :application.Primary_Guarantor__c
        ];

        List<clcommon__Party_Type__c> partyTypeList = [SELECT Id, Name FROM clcommon__Party_Type__c];

        DBManagerTestsStub partyTypeDBStubInstance = new DBManagerTestsStub();
        partyTypeDBStubInstance.genericReturnObject = partyTypeList;
        OriginationHelper.partyTypeDBInstance = (PartyTypeDB) Test.createStub(PartyTypeDB.class, partyTypeDBStubInstance);

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = partyList;
        LexisNexisManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{accountRecord};
        LexisNexisManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Credit_Report_Detail__c creditReportDetail = new Credit_Report_Detail__c();
        creditReportDetail.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        creditReportDetail.Type__c = 'Lexis Nexis';
        creditReportDetail.Application__c = application.Id;
        creditReportDetail.Account__c = accountRecord.Id;

        DBManagerTestsStub creditReportDetailDBStubInstance = new DBManagerTestsStub();
        creditReportDetailDBStubInstance.genericReturnObject = new List<Credit_Report_Detail__c>{creditReportDetail};
        LexisNexisManager.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, creditReportDetailDBStubInstance);

        UnderWriter_Task__c underWriterTask = new UnderWriter_Task__c();
        underWriterTask.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        underWriterTask.Application__c = application.Id;
        underWriterTask.Task_Name__c = LexisNexiss.TASK_TYPE_FRAUD_POINT_SCORE;

        DBManagerTestsStub underWriterTaskDBStubInstance = new DBManagerTestsStub();
        underWriterTaskDBStubInstance.genericReturnObject = new List<UnderWriter_Task__c>{underWriterTask};
        LexisNexisManager.underWriterTaskDBInstance = (UnderWriterTaskDB) Test.createStub(UnderWriterTaskDB.class, underWriterTaskDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        LexisNexisManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact>{contactRecord};
        LexisNexisManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        Test.setMock(HttpCalloutMock.class, new LexisNexisCallOutMock.FraudScoreSuccessResponse());
        Test.startTest();

            LexisNexisManager.requestLexisNexisFraudScoreCheck(new List<genesis__Applications__c> {application});

        Test.stopTest();

        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
        System.assertEquals(0, creditReportDetailDBStubInstance.forUpdateSObjects.size());
        System.assertEquals(1, underWriterTaskDBStubInstance.forUpdateSObjects.size());
        System.assertEquals(1, applicationDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void requestLexisNexisFraudScoreCheckException() {
        genesis__Applications__c application = [
            SELECT Id, Name, Opportunity__c, genesis__Payment_Frequency__c, genesis__Loan_Amount__c, genesis__Term__c, Industry_Rating__c,
                SC4_Tier__c, Type__c, Business_Type__c, genesis__Account__c, genesis__Account__r.AnnualRevenue, Primary_Guarantor__c
            FROM genesis__Applications__c
        ];

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        LexisNexisManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        List<clcommon__Party__c> partyList = [
            SELECT Id, clcommon__Account__c, clcommon__Contact__c, genesis__Application__c,
                genesis__Application__r.genesis__Account__c, clcommon__Type__r.Name, clcommon__Type__c, clcommon__isPrimary__c,
                clcommon__Account__r.Name, clcommon__Contact__r.FirstName, clcommon__Contact__r.LastName
            FROM clcommon__Party__c
        ];

        Account accountRecord = [
            SELECT Id, Name, Phone, Business_Tax_ID__c, BillingStreet, BillingCity, BillingState, BillingPostalCode,
                Last_Business_Credit_Pull__c, Sic, Customer_Since__c, Legacy_Percent_Paid__c, Biz_Start_Date__c
            FROM Account
            WHERE Id = :application.genesis__Account__c
        ];

        Contact contactRecord = [
            SELECT Id, Name, AccountId, Last_Consumer_Credit_Pull__c, LastName, FirstName, genesis__SSN__c,
                MailingBuildingNumber__c, MailingAddress, Email, Birthdate, ints__Driver_License__c, Phone, Credit_Report_Message__c,
                loan__Contact_Type__c, Title__c
            FROM Contact
            WHERE Id = :application.Primary_Guarantor__c
        ];

        List<clcommon__Party_Type__c> partyTypeList = [SELECT Id, Name FROM clcommon__Party_Type__c];

        DBManagerTestsStub partyTypeDBStubInstance = new DBManagerTestsStub();
        partyTypeDBStubInstance.genericReturnObject = partyTypeList;
        OriginationHelper.partyTypeDBInstance = (PartyTypeDB) Test.createStub(PartyTypeDB.class, partyTypeDBStubInstance);

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = partyList;
        LexisNexisManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{accountRecord};
        LexisNexisManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Credit_Report_Detail__c creditReportDetail = new Credit_Report_Detail__c();
        creditReportDetail.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        creditReportDetail.Type__c = 'Lexis Nexis';
        creditReportDetail.Application__c = application.Id;
        creditReportDetail.Account__c = accountRecord.Id;

        DBManagerTestsStub creditReportDetailDBStubInstance = new DBManagerTestsStub();
        creditReportDetailDBStubInstance.genericReturnObject = new List<Credit_Report_Detail__c>{creditReportDetail};
        LexisNexisManager.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, creditReportDetailDBStubInstance);

        UnderWriter_Task__c underWriterTask = new UnderWriter_Task__c();
        underWriterTask.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        underWriterTask.Application__c = application.Id;
        underWriterTask.Verification_Type__c = 'AUTOMATED';
        underWriterTask.Task_Name__c = 'Dummy Task';

        DBManagerTestsStub underWriterTaskDBStubInstance = new DBManagerTestsStub();
        underWriterTaskDBStubInstance.genericReturnObject = new List<UnderWriter_Task__c>{underWriterTask};
        LexisNexisManager.underWriterTaskDBInstance = (UnderWriterTaskDB) Test.createStub(UnderWriterTaskDB.class, underWriterTaskDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        LexisNexisManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact>{contactRecord};
        LexisNexisManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        Test.setMock(HttpCalloutMock.class, new LexisNexisCallOutMock());
        Test.startTest();
            LexisNexisManager.requestLexisNexisFraudScoreCheck(new List<genesis__Applications__c>{application});
        Test.stopTest();

        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
        System.assertEquals(0, creditReportDetailDBStubInstance.forUpdateSObjects.size());
        System.assertEquals(1, underWriterTaskDBStubInstance.forUpdateSObjects.size());
        System.assertEquals(1, applicationDBStubInstance.forUpdateSObjects.size());
    }
}