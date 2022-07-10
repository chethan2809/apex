@isTest
private class CollectionCaseDBTests {

    private static CollectionCaseDB collectionCaseDBInstance = new CollectionCaseDB();

    @isTest
    private static void getCollectionCases() {

        Collection_Case__c collectionCase = new Collection_Case__c();
        Id collectionCaseId = TestUtility.getFakeId(Collection_Case__c.getSObjectType());

        Test.startTest();
            List<Collection_Case__c> collectionList = collectionCaseDBInstance.getCollectionCases();
            List<Collection_Case__c> collectionCaseList = collectionCaseDBInstance.getActiveCollectionCases();
        Test.stopTest();

        System.assert(collectionList != null);
        System.assert(collectionList.isEmpty());
        System.assert(collectionCaseList != null);
        System.assert(collectionCaseList.isEmpty());
    }

    @isTest
    private static void getCLLoanBills() {

        loan__Loan_account_Due_Details__c loanAccountDueDetails = new loan__Loan_account_Due_Details__c();
        Id loanAccountDueDetailsId = TestUtility.getFakeId(loan__Loan_account_Due_Details__c.getSObjectType());

        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c();
        Id loanAccountId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        Test.startTest();
            List<loan__Loan_account_Due_Details__c> loanAccountDueDetailsList = CollectionCaseDB.getCLLoanBills(loanAccountId, 1, 1,' ', false);
        Test.stopTest();

        System.assert(loanAccountDueDetailsList != null);
        System.assert(loanAccountDueDetailsList.isEmpty());
    }

    @isTest
    private static void getCLLoanPayments() {

        loan__Loan_Payment_Transaction__c loanPaymentTransaction = new loan__Loan_Payment_Transaction__c();
        Id loanPaymentTransactionId = TestUtility.getFakeId(loan__Loan_Payment_Transaction__c.getSObjectType());

        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c();
        Id loanAccountId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        Test.startTest();
            List<loan__Loan_Payment_Transaction__c> loanPaymentTransactionList = CollectionCaseDB.getCLLoanPayments(loanAccountId, 1, 1,' ');
        Test.stopTest();

        System.assert(loanPaymentTransactionList != null);
        System.assert(loanPaymentTransactionList.isEmpty());
    }

    @isTest
    private static void getCLLoanCharges() {

        loan__Charge__c loanCharge = new loan__Charge__c();
        Id loanChargeId = TestUtility.getFakeId(loan__Charge__c.getSObjectType());

        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c();
        Id loanAccountId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        Test.startTest();
            List<loan__Charge__c> loanChargeList = CollectionCaseDB.getCLLoanCharges(loanAccountId, 1, 1,' ', false);
        Test.stopTest();

        System.assert(loanChargeList != null);
        System.assert(loanChargeList.isEmpty());
    }

    @isTest
    private static void getChargesSummaryByFeeType() {

        loan__Charge__c loanCharge = new loan__Charge__c();
        Id loanChargeId = TestUtility.getFakeId(loan__Charge__c.getSObjectType());

        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c();
        Id loanAccountId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        Test.startTest();
            List<AggregateResult> AggregateResultList = CollectionCaseDB.getChargesSummaryByFeeType(loanAccountId);
        Test.stopTest();

        System.assert(AggregateResultList != null);
        System.assert(AggregateResultList.isEmpty());
    }

    @isTest
    private static void getRelatedPartiesByApplicationIds() {

        clcommon__party__c party = new clcommon__party__c();
        Id partyId = TestUtility.getFakeId(clcommon__party__c.getSObjectType());

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        List<Id> appList = new List<Id>();
        appList.add(application.Id);

        Test.startTest();
            List<clcommon__party__c> partyList = CollectionCaseDB.getRelatedPartiesByApplicationIds(appList);
        Test.stopTest();

        System.assert(partyList != null);
        System.assert(partyList.isEmpty());
    }

    @isTest
    private static void geAlltWasabiFileFromCollectionCase() {

        clcommon__Category_Attachment_Association__c categoryAttchAsso = new clcommon__Category_Attachment_Association__c();
        Id categoryAttchAssoId = TestUtility.getFakeId(clcommon__Category_Attachment_Association__c.getSObjectType());

        Collection_Case__c collectionCase = new Collection_Case__c();
        Id collectionCaseId = TestUtility.getFakeId(Collection_Case__c.getSObjectType());

        List<String> collectionCaseList = new List<String>{'Test', 'Test1'};
        List<String> applicationNameList = new List<String>{'Test', 'Test1'};

        Test.startTest();
            List<clcommon__Category_Attachment_Association__c> categoryAttchAssoList = CollectionCaseDB.getAllWasabiFileFromCollectionCase(
                collectionCaseList, applicationNameList, true
            );
        Test.stopTest();

        System.assert(categoryAttchAssoList != null);
        System.assert(categoryAttchAssoList.isEmpty());
    }

     @isTest
    private static void getAllFeeTypes() {

        loan__Fee__c loanFees = new loan__Fee__c();
        loanFees.Id = TestUtility.getFakeId(loan__Fee__c.getSObjectType());

        Test.startTest();
        List<loan__Fee__c> loanFee = CollectionCaseDB.getAllFeeTypes();
        Test.stopTest();

        System.assert(loanFee != null);
    }

    @isTest
    private static void getCollectionsQueueUsers() {

        User user = new User();
        Id userId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        Test.startTest();
            List<User> userList = CollectionCaseDB.getCollectionsQueueUsers(' ');
        Test.stopTest();

        System.assert(userList != null);
        System.assert(userList.isEmpty());
    }

    @isTest
    private static void getPaymentTypes() {

        loan__Payment_Mode__c loanPaymentMode = new loan__Payment_Mode__c();
        Id loanPaymentModeId = TestUtility.getFakeId(loan__Payment_Mode__c.getSObjectType());

        Test.startTest();
            List<loan__Payment_Mode__c> loanPaymentModeList = CollectionCaseDB.getPaymentTypes();
        Test.stopTest();

        System.assert(loanPaymentModeList != null);
        System.assert(loanPaymentModeList.isEmpty());
    }

    @isTest
    private static void getWasabiFileFromCollectionCaseTest() {
        Collection_Case__c collectionCase = new Collection_Case__c();
        Id collectionCaseId = TestUtility.getFakeId(Collection_Case__c.getSObjectType());
        String documentCategory = 'Collections';

        List<String> collectionCaseList = new List<String>{'Test', 'Test1'};
        List<String> applicationNameList = new List<String>{'Test', 'Test1'};
        Test.startTest();
            List<clcommon__Category_Attachment_Association__c> docList = CollectionCaseDB.getWasabiFileFromCollectionCase(
                documentCategory, collectionCaseList, applicationNameList, true
            );
        Test.stopTest();
        System.assert(docList != null);
        System.assert(docList.isEmpty());
    }

    @isTest
    private static void getCollectionCasesByIdsTest() {
        Id collectionCaseId = TestUtility.getFakeId(Collection_Case__c.getSObjectType());
        Test.startTest();
            List<Collection_Case__c> collectionCaseList = collectionCaseDBInstance.getCollectionCasesByIds(
                new Set<Id> {collectionCaseId}
            );
        Test.stopTest();

        System.assert(collectionCaseList != null);
    }

    @isTest
    private static void getAPSRecordsTest() {
        Id loanAccountId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Test.startTest();
            List<loan__Automated_Payment_Setup__c> apsList = CollectionCaseDB.getAPSRecords(
                loanAccountId, 1, 1, false
            );
        Test.stopTest();
        System.assert(apsList != null);
    }

    @isTest
    private static void getChargesSummaryTest() {
        Id loanAccountId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Test.startTest();
            AggregateResult aggregateResult = CollectionCaseDB.getChargesSummary(loanAccountId);
        Test.stopTest();

        System.assert(aggregateResult != null);
    }

    @isTest
    private static void getRelatedContactsFromBorrowerAccountIdsTest() {
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Test.startTest();
            List<AccountContactRelation> accountContactRelationList = CollectionCaseDB.getRelatedContactsFromBorrowerAccountIds(new List<Id> {accountId});
        Test.stopTest();

        System.assert(accountContactRelationList != null);
    }

    @isTest
    private static void getDocumentDefinitionsTest() {
        Test.startTest();
            List<clcommon__Document_Definition__c> documentDefinationList = CollectionCaseDB.getDocumentDefinitions();
        Test.stopTest();

        System.assert(documentDefinationList != null);
    }

    @isTest
    private static void getAllPaymentTypesTest() {
        Test.startTest();
            List<String> paymentTypes = CollectionCaseDB.getAllPaymentTypes();
        Test.stopTest();

        System.assert(paymentTypes != null);
    }

    @isTest
    private static void getAllConstantsTest() {
        Test.startTest();
        CollectionCaseConstants collectionCaseConstants = CollectionCaseDB.getAllConstants();
        Test.stopTest();

        System.assert(collectionCaseConstants != null);
    }

    @isTest
    private static void getPaymentArrangementByApsIdsTest() {
        Id apsId = TestUtility.getFakeId(loan__Automated_Payment_Setup__c.getSObjectType());
        Test.startTest();
            List<Payment_Arrangements__c> paymentArrangements = collectionCaseDBInstance.getPaymentArrangementByApsIds(new Set<Id> {apsId});
        Test.stopTest();

        System.assert(paymentArrangements != null);
    }

    @isTest
    private static void getCollectionCaseDetailsTest() {
        Id collectionCaseId = TestUtility.getFakeId(Collection_Case__c.getSObjectType());
        Test.startTest();
            List<Collection_Case__c> collectionCaseList = CollectionCaseDB.getCollectionCaseDetails(collectionCaseId);
        Test.stopTest();

        System.assert(collectionCaseList != null);
    }

    @isTest
    private static void getAccountByIdsTest() {
        Id accountIds = TestUtility.getFakeId(Account.getSObjectType());
        Test.startTest();
            List<Account> accList = collectionCaseDBInstance.getAccountByIds(new Set<Id> {accountIds});
        Test.stopTest();

        System.assert(accList != null);
    }
}