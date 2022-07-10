@isTest
private class DataMerchManagerTests {

    @isTest
    private static void runDataMerchCheck() {
        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());
        account.Business_Tax_ID__c = '123456789';

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{account};
        DataMerchManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Status__c = 'NEW ENTERED';
        application.genesis__Account__c = account.Id;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        DataMerchManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        Credit_Report_Detail__c creditReportDetail = new Credit_Report_Detail__c();
        creditReportDetail.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        creditReportDetail.Type__c = 'Data Merch';
        creditReportDetail.Application__c = application.Id;
        creditReportDetail.Account__c = account.Id;

        DBManagerTestsStub creditReportDetailDBStubInstance = new DBManagerTestsStub();
        creditReportDetailDBStubInstance.genericReturnObject = new List<Credit_Report_Detail__c>{creditReportDetail};
        DataMerchManager.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, creditReportDetailDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        DataMerchManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        UnderWriter_Task__c uwTask = new UnderWriter_Task__c();
        uwTask.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        uwTask.Application__c = application.Id;
        uwTask.IsCompleted__c = false;
        uwTask.Task_Name__c = DataMerch.TASK_TYPE_DATA_MERCH;

        DBManagerTestsStub underWriterTaskDBStubInstance = new DBManagerTestsStub();
        underWriterTaskDBStubInstance.genericReturnObject = new List<UnderWriter_Task__c>{uwTask};
        DataMerchManager.underWriterTaskDBInstance = (UnderWriterTaskDB) Test.createStub(UnderWriterTaskDB.class, underWriterTaskDBStubInstance);

        GeneralHelper.currentSystemDate = Date.newInstance(2022, 05, 30);

        Data_Merch_Note__c dataMerchNote = new Data_Merch_Note__c();
        dataMerchNote.Id = TestUtility.getFakeId(Data_Merch_Note__c.getSObjectType());
        dataMerchNote.Account__c = account.Id;
        dataMerchNote.Application__c = application.Id;
        dataMerchNote.Added_at__c = GeneralHelper.currentSystemDate.addDays(-20);
        dataMerchNote.Note_Category__c = 'Suspicious Activity';

        DBManagerTestsStub dataMerchNoteDBStubInstance = new DBManagerTestsStub();
        dataMerchNoteDBStubInstance.genericReturnObject = new List<Data_Merch_Note__c>{dataMerchNote};
        DataMerchManager.dataMerchNoteDBInstance = (DataMerchNoteDB) Test.createStub(DataMerchNoteDB.class, dataMerchNoteDBStubInstance);

        Test.setMock(HttpCalloutMock.class, new DataMerchCallOutMock.DataMerchSuccessResponse());
        Test.startTest();
        DataMerchManager.requestDataMerchMerchants(new List<genesis__Applications__c>{application});
        Test.stopTest();

        System.assertEquals(1, applicationDBStubInstance.forUpdateSObjects.size());
        System.assertEquals(1, creditReportDetailDBStubInstance.forUpsertSObjects.size());
        System.assertEquals(1, dataMerchNoteDBStubInstance.forUpsertSObjects.size());
    }

}