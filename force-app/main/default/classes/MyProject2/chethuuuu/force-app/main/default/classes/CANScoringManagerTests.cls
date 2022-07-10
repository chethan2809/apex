@isTest
private class CANScoringManagerTests {

    @isTest
    private static void requestCANScoring() {
        TestUtility.runSetupData();
        genesis__Applications__c application = TestUtility.createApplication();
        List<genesis__Applications__c> listOfApplications = new List<genesis__Applications__c>();
        application.genesis__Status__c = 'NEW ENTERED';
        application.Type__c = 'New';
        update application;
        listOfApplications.add(application);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        CANScoringManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        CANScoringManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        clcommon__Party__c party = new clcommon__Party__c();
        party.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = new List<clcommon__Party__c>{party};
        CANScoringManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        Account account = TestUtility.createAccount();
        Contact contact = TestUtility.createContact();

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{account};
        CANScoringManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        List<Credit_Report_Detail__c> creditReportList = new List<Credit_Report_Detail__c>();
        Credit_Report_Detail__c creditReportDetail = new Credit_Report_Detail__c();
        creditReportDetail.Application__c = application.Id;
        creditReportDetail.Account__c = account.Id;
        creditReportDetail.Type__c = 'Experian Business';
        insert creditReportDetail;
        creditReportList.add(creditReportDetail);
        Credit_Report_Detail__c creditReportDetail1 = new Credit_Report_Detail__c();
        creditReportDetail.Application__c = application.Id;
        creditReportDetail1.Contact__c = contact.Id;
        creditReportDetail1.Type__c = 'CAN Scoring';
        insert creditReportDetail1;
        creditReportList.add(creditReportDetail1);

        DBManagerTestsStub creditReportDetailDBStubInstance = new DBManagerTestsStub();
        creditReportDetailDBStubInstance.genericReturnObject = new List<Credit_Report_Detail__c>{creditReportDetail};
        CANScoringManager.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, creditReportDetailDBStubInstance);

        Test.startTest();
        CANScoringManager.requestCANScoring(listOfApplications);
        Test.stopTest();

        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
        System.assertEquals(1, applicationDBStubInstance.forUpdateSObjects.size());
    }
}