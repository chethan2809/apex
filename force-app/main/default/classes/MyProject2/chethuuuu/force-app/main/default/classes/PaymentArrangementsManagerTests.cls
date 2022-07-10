@isTest
private class PaymentArrangementsManagerTests {

    @isTest
    private static void updateAPSRecordTest() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 02, 14);
        Date achTurnedDate = GeneralHelper.currentSystemDate;

        loan__Loan_Account__c clContract = new loan__Loan_Account__c();
        clContract.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        clContract.ACH_Turned_off_Date__c = achTurnedDate;

        List<loan__Automated_Payment_Setup__c> newAPSList = new List<loan__Automated_Payment_Setup__c>();
        loan__Automated_Payment_Setup__c testAPSRecord = new loan__Automated_Payment_Setup__c();
        testAPSRecord.loan__Type__c = 'RECURRING';
        testAPSRecord.loan__CL_Contract__c = clContract.Id;

        Map<String, Object> apsObject = new Map<String, Object>{'' => testAPSRecord};

        String apsId;
        Exception ex;
        Test.startTest();
            try {
                apsId = PaymentArrangementsManager.updateAPSRecord(apsObject);
            } catch (Exception e) {
                ex = e;
            }
        Test.stopTest();

        System.assert(apsId != null);
    }

    @isTest
    private static void createChargeRecordTest() {
        loan__Charge__c testChargeRecord = new loan__Charge__c();
        Map<String, Object> chargeObject = new Map<String, Object>{'' => testChargeRecord};

        Test.startTest();
            PaymentArrangementsManager.createChargeRecord(chargeObject);
        Test.stopTest();

        System.assert(chargeObject != null);
    }

    @isTest
    private static void updatePaymentArrangementApsTest() {
        Id paymentArrangementId = TestUtility.getFakeId(Payment_Arrangements__c.getSObjectType());
        Id apsId = TestUtility.getFakeId(loan__Automated_Payment_Setup__c.getSObjectType());

        String updatedResult;
        Test.startTest();
        updatedResult = PaymentArrangementsManager.updatePaymentArrangement(paymentArrangementId, apsId);
        Test.stopTest();

        System.assert(updatedResult != '');
    }

    @isTest
    private static void createAPSRecord() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 02, 14);
        Date achTurnedDate = GeneralHelper.currentSystemDate;

        loan__Loan_Account__c clContract = new loan__Loan_Account__c();
        clContract.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        clContract.ACH_Turned_off_Date__c = achTurnedDate;

        List<loan__Automated_Payment_Setup__c> newAPSList = new List<loan__Automated_Payment_Setup__c>();
        loan__Automated_Payment_Setup__c testAPSRecord = new loan__Automated_Payment_Setup__c();
        testAPSRecord.loan__Type__c = 'RECURRING';
        testAPSRecord.loan__CL_Contract__c = clContract.Id;

        Map<String, Object> apsObject = new Map<String, Object>{'' => testAPSRecord};

        String apsId;
        Exception ex;
        Test.startTest();
            try {
                apsId = PaymentArrangementsManager.createAPSRecord(apsObject);
            } catch (Exception e) {
                ex = e;
            }
        Test.stopTest();

        System.assert(apsId != null);
    }

    @isTest
    private static void updateActivePaymentArrangementOnAccount() {
        String activePaymentArrangementType = 'Promise to Pay';
        Boolean activePaymentArrangement = false;
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());

        Account account = new Account();

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{account};
        PaymentArrangementsManager.accountDBInstance =
            (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        String returnString;
        Exception ex;
        Test.startTest();
            try {
                returnString = PaymentArrangementsManager.updateActivePaymentArrangementOnAccount(
                    accountId, activePaymentArrangementType, activePaymentArrangement
                );
            } catch (Exception e) {
                ex = e;
            }
        Test.stopTest();

        System.assert(returnString != null);
        System.assertEquals('Success', returnString);
    }

    @isTest
    private static void updateCollectionCaseStatusAndSubStatus() {
        String collectionCaseStatus = 'Accommodation';
        String collectionCaseSubStatus = 'Accommodation';
        Id collectionCaseId = TestUtility.getFakeId(Collection_Case__c.getSObjectType());

        Collection_Case__c collectionCase = new Collection_Case__c();

        DBManagerTestsStub collectionCaseDBStubInstance = new DBManagerTestsStub();
        collectionCaseDBStubInstance.genericReturnObject = new List<Collection_Case__c>{collectionCase};
        PaymentArrangementsManager.collectionCaseDBInstance =
            (CollectionCaseDB) Test.createStub(CollectionCaseDB.class, collectionCaseDBStubInstance);

        String returnString;
        Exception ex;
        Test.startTest();
            try {
                returnString = PaymentArrangementsManager.updateCollectionCaseStatusAndSubStatus(
                    collectionCaseId, collectionCaseStatus, collectionCaseSubStatus
                );
            } catch (Exception e) {
                ex = e;
            }
        Test.stopTest();

        System.assert(returnString != null);
        System.assertEquals('Success', returnString);
    }

    @isTest
    private static void calculatePaymentOccurrenceDailyTest() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 02, 14);
        Date startDate = GeneralHelper.currentSystemDate;
        Date endDate = GeneralHelper.currentSystemDate;
        Date debitDate = GeneralHelper.currentSystemDate;

        Integer occurrenceData;
        Test.startTest();
            occurrenceData = PaymentArrangementsManager.calculatePaymentOccurrence(100, 'Daily', startDate, endDate, debitDate);
        Test.stopTest();

        System.assert(occurrenceData != null);
    }

    @isTest
    private static void calculatePaymentOccurrenceWeeklyTest() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 02, 14);
        Date startDate = GeneralHelper.currentSystemDate;
        Date endDate = GeneralHelper.currentSystemDate;
        Date debitDate = GeneralHelper.currentSystemDate;

        Integer occurrenceData;
        Test.startTest();
            occurrenceData = PaymentArrangementsManager.calculatePaymentOccurrence(100, 'Weekly', startDate, endDate, debitDate);
        Test.stopTest();

        System.assert(occurrenceData != null);
    }

    @isTest
    private static void calculatePaymentOccurrenceBiWeeklyTest() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 02, 14);
        Date startDate = GeneralHelper.currentSystemDate;
        Date endDate = GeneralHelper.currentSystemDate;
        Date debitDate = GeneralHelper.currentSystemDate;

        Integer occurrenceData;
        Test.startTest();
            occurrenceData = PaymentArrangementsManager.calculatePaymentOccurrence(100, 'Bi-weekly', startDate, endDate, debitDate);
            occurrenceData = PaymentArrangementsManager.calculatePaymentOccurrence(100, 'Monthly', startDate, endDate, debitDate);
            Test.stopTest();

        System.assert(occurrenceData != null);
    }
}