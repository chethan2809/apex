@isTest
private class DataMerchTests {
    @isTest
    private static void dataMerchAPIDetails() {
        Test.startTest();
            String dataMerchTokenURL = DataMerch.dataMerchAPIDetails.Token_Endpoint_URL__c;
        Test.stopTest();

        System.assertEquals('https://api.datamerch.com/api/v2/get_token', dataMerchTokenURL);
    }

    @isTest
    private static void createDataMerchReportDetailWithoutExistingReport() {
        Map<Id, Credit_Report_Detail__c> existingCreditReportByAccountId = new Map<Id, Credit_Report_Detail__c>();
        Map<String, Object> accountDataMerch = new Map<String, Object>();

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-0000000002", "Business_Type__c" : "Corporation"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        Account accountDetail = new Account();
        accountDetail.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountDetail.Legacy_Negative_CAN_History__c = false;
        accountDetail.Legal_Name__c = 'FLASH DRONE';

        accountDataMerch.put('fein', '123456789');
        accountDataMerch.put('legal_name', 'FLASH DRONE');
        accountDataMerch.put('address', '1st Address');
        accountDataMerch.put('street1', 'Street address 1');
        accountDataMerch.put('street2', 'Street address 2');
        accountDataMerch.put('city', 'Beach City');
        accountDataMerch.put('state', 'MI');

        Test.startTest();
        Credit_Report_Detail__c dataMerchReport = DataMerch.createDataMerchReportDetail(accountDetail.Id, accountDataMerch, application.Id, existingCreditReportByAccountId);
        Test.stopTest();

        System.assertEquals('FLASH DRONE', dataMerchReport.Legal_Name__c);
        System.assertEquals(accountDetail.Id, dataMerchReport.Account__c);
        System.assertEquals(application.Id, dataMerchReport.Application__c);
    }

    @isTest
    private static void createDataMerchReportDetailWithExistingReport() {
        Map<Id, Credit_Report_Detail__c> existingCreditReportByAccountId = new Map<Id, Credit_Report_Detail__c>();
        Map<String, Object> accountDataMerch = new Map<String, Object>();

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-0000000002", "Business_Type__c" : "Corporation"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        Account accountDetail = new Account();
        accountDetail.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountDetail.Legacy_Negative_CAN_History__c = false;
        accountDetail.Legal_Name__c = 'FLASH DRONE';

        Credit_Report_Detail__c reportDetail = new Credit_Report_Detail__c();
        reportDetail.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        reportDetail.Type__c = GeneralConstants.CREDIT_REPORT_TYPE_DATA_MERCH;
        reportDetail.Account__c = accountDetail.Id;
        reportDetail.Application__c = application.Id;

        existingCreditReportByAccountId.put(reportDetail.Account__c, reportDetail);

        accountDataMerch.put('fein', '123456789');
        accountDataMerch.put('legal_name', 'FLASH DRONE');
        accountDataMerch.put('address', '1st Address');
        accountDataMerch.put('street1', 'Street address 1');
        accountDataMerch.put('street2', 'Street address 2');
        accountDataMerch.put('city', 'Beach City');
        accountDataMerch.put('state', 'MI');

        Test.startTest();
        Credit_Report_Detail__c dataMerchReport = DataMerch.createDataMerchReportDetail(accountDetail.Id, accountDataMerch, application.Id, existingCreditReportByAccountId);
        Test.stopTest();

        System.assertEquals('FLASH DRONE', dataMerchReport.Legal_Name__c);
        System.assertEquals(accountDetail.Id, dataMerchReport.Account__c);
        System.assertEquals(application.Id, dataMerchReport.Application__c);
    }

    @isTest
    private static void checkDataMerchVerified() {
        Map<String, UnderWriter_Task__c> underWriterList = new Map<String, UnderWriter_Task__c>();

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-0000000002", "Business_Type__c" : "Corporation"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        UnderWriter_Task__c underWriterTask = new UnderWriter_Task__c();
        underWriterTask.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        underWriterTask.Application__c = application.Id;
        underWriterTask.IsCompleted__c = false;
        underWriterTask.Task_Name__c = DataMerch.TASK_TYPE_DATA_MERCH;

        underWriterList.put(application.Id + underWriterTask.Task_Name__c, underWriterTask);

        Test.startTest();
        DataMerch.checkDataMerchVerified(underWriterList, application.Id, true);
        Test.stopTest();

        System.assertEquals(underWriterList.get(application.Id + underWriterTask.Task_Name__c).IsCompleted__c, true);
        System.assertEquals(underWriterList.get(application.Id + underWriterTask.Task_Name__c).Verification_Type__c, DataMerch.VERIFICATION_TYPE_AUTOMATED);
    }

    @isTest
    private static void createDataMerchNotesWithoutExistinNotes() {
        Map<String, Object> accountDataMerch = new Map<String, Object>();
        Map<String, Object> dataMerchNote = new Map<String, Object>();
        Map<String, Object> dataMerchNoteDetail = new Map<String, Object>();
        List<Object> dataMerchNoteList = new List<Object>();

        Map<String, Data_Merch_Note__c> existingDataMerchNoteByAccountId = new Map<String, Data_Merch_Note__c>();

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-0000000002", "Business_Type__c" : "Corporation"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        Account accountDetail = new Account();
        accountDetail.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountDetail.Legacy_Negative_CAN_History__c = false;
        accountDetail.Legal_Name__c = 'FLASH DRONE';

        accountDataMerch.put('fein', '123456789');
        accountDataMerch.put('legal_name', 'FLASH DRONE');
        accountDataMerch.put('address', '1st Address');
        accountDataMerch.put('street1', 'Street address 1');
        accountDataMerch.put('street2', 'Street address 2');
        accountDataMerch.put('city', 'Beach City');
        accountDataMerch.put('state', 'MI');

        dataMerchNote.put('created_at', '2022-03-02T20:32:37.494Z');
        dataMerchNote.put('added_by', 'Reporter Name');
        dataMerchNote.put('category', 'Stacking History');
        dataMerchNote.put('note', 'Note from reporter');

        dataMerchNoteDetail.put('note', dataMerchNote);

        dataMerchNoteList.add(dataMerchNoteDetail);

        accountDataMerch.put('notes', dataMerchNoteList);

        Test.startTest();
        List<Data_Merch_Note__c> notesResultList = DataMerch.createDataMerchNotes(accountDetail.Id, accountDataMerch, application.Id, existingDataMerchNoteByAccountId);
        Test.stopTest();

        System.assertEquals(notesResultList[0].FEIN__c, accountDataMerch.get('fein'));
        System.assertEquals(notesResultList[0].Account__c, accountDetail.Id);
        System.assertEquals(notesResultList[0].Application__c, application.Id);
    }

    @isTest
    private static void createDataMerchNotesWithExistinNotes() {
        Map<String, Object> accountDataMerch = new Map<String, Object>();
        Map<String, Object> dataMerchNote = new Map<String, Object>();
        Map<String, Object> dataMerchNoteDetail = new Map<String, Object>();
        List<Object> dataMerchNoteList = new List<Object>();

        Map<String, Data_Merch_Note__c> existingDataMerchNoteByAccountId = new Map<String, Data_Merch_Note__c>();

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-0000000002", "Business_Type__c" : "Corporation"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        Account accountDetail = new Account();
        accountDetail.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountDetail.Legacy_Negative_CAN_History__c = false;
        accountDetail.Legal_Name__c = 'FLASH DRONE';

        accountDataMerch.put('fein', '123456789');
        accountDataMerch.put('legal_name', 'FLASH DRONE');
        accountDataMerch.put('address', '1st Address');
        accountDataMerch.put('street1', 'Street address 1');
        accountDataMerch.put('street2', 'Street address 2');
        accountDataMerch.put('city', 'Beach City');
        accountDataMerch.put('state', 'MI');

        dataMerchNote.put('created_at', '2022-03-02T20:32:37.494Z');
        dataMerchNote.put('added_by', 'Reporter Name');
        dataMerchNote.put('category', 'Stacking History');
        dataMerchNote.put('note', 'Note from reporter');

        dataMerchNoteDetail.put('note', dataMerchNote);

        dataMerchNoteList.add(dataMerchNoteDetail);

        accountDataMerch.put('notes', dataMerchNoteList);

        Data_Merch_Note__c existingNote = new Data_Merch_Note__c();
        existingNote.Id = TestUtility.getFakeId(Data_Merch_Note__c.getSObjectType());
        existingNote.Account__c = accountDetail.Id;
        existingNote.Application__c = application.Id;
        existingNote.Added_at__c = Date.valueOf('2022-03-02');
        existingNote.Note_Category__c = 'Stacking History';

        existingDataMerchNoteByAccountId.put(accountDetail.Id + '-' + existingNote.Id, existingNote);

        Test.startTest();
        List<Data_Merch_Note__c> notesResultList = DataMerch.createDataMerchNotes(accountDetail.Id, accountDataMerch, application.Id, existingDataMerchNoteByAccountId);
        Test.stopTest();

        System.assertEquals(notesResultList[0].FEIN__c, accountDataMerch.get('fein'));
        System.assertEquals(notesResultList[0].Account__c, accountDetail.Id);
        System.assertEquals(notesResultList[0].Application__c, application.Id);
    }

}