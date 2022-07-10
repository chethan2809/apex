@isTest
private class TestCLXSSPTransactionSummaryAPI{

    @isTest
    private static void testTransactionAPI() {
        TestUtility.runSetupData();
        loan__Loan_Account__c  clContract = TestUtility.createContract();

        loan__Payment_Mode__c mode = new loan__Payment_Mode__c();
        mode.Name ='test';
        insert mode;

        loan__Loan_Payment_Transaction__c loanPayment = TestUtility.generateLoanPaymentTransaction(clContract.Id, 1200, mode.Id);
        insert loanPayment;

        List<loan__Loan_Payment_Transaction__c> loanPaymentList = new List<loan__Loan_Payment_Transaction__c>();
        loanPaymentList.add(loanPayment);

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{clContract};
        CLXSSPTransactionSummaryAPI.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Date startDate = GeneralHelper.currentSystemDate;
        Date endDate = GeneralHelper.currentSystemDate.addDays(20);

        Test.startTest();
            clcommon.Response response = new CLXSSPTransactionSummaryAPI().invokeAction('', null, new Map<String, Object>{
                'orderBy' => 'loan__Transaction_Date__c desc',
                'loanId' => clContract.Id,
                'recentTransaction' => 'LAST_WEEK',
                'range' => '10',
                'fromDate' => startDate,
                'endDate' => endDate
            });
            Date dateLiterals1 = new CLXSSPTransactionSummaryAPI().computeDateValue('LAST_MONTH', startDate);
            Date dateLiterals2 = new CLXSSPTransactionSummaryAPI().computeDateValue('LAST_90_DAYS', startDate);
            Date dateLiterals3 = new CLXSSPTransactionSummaryAPI().computeDateValue('LAST_30_DAYS', startDate);
            Date dateLiterals4 = new CLXSSPTransactionSummaryAPI().computeDateValue('LAST_180_DAYS', startDate);
            List<clcommon.PortalCustomRemoteActionRecord> actualPortalResponseList = new CLXSSPTransactionSummaryAPI().getResponseList(loanPaymentList);
        Test.stopTest();

        System.assert(actualPortalResponseList != null);
        System.assertEquals('SUCCESS', response.Status);
    }

    @isTest
    private static void testTransactionAPIRangeNotNull() {
        TestUtility.runSetupData();
        loan__Loan_Account__c  clContract = TestUtility.createContract();
        Contact contact = TestUtility.createContact();

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{clContract};
        CLXSSPTransactionSummaryAPI.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Date startDate = GeneralHelper.currentSystemDate;
        Date endDate = GeneralHelper.currentSystemDate.addDays(20);

        Test.startTest();
            clcommon.Response response = new CLXSSPTransactionSummaryAPI().invokeAction('', null, new Map<String, Object>{
                'orderBy' => 'loan__Transaction_Date__c desc',
                'loanId' => clContract.Id,
                'recentTransaction' => null,
                'range' => '10',
                'fromDate' => startDate,
                'endDate' => endDate
            });
        Test.stopTest();

        System.assertEquals('SUCCESS', response.Status);
    }

    @isTest
    private static void testTransactionAPIRangeNotNullException() {
        TestUtility.runSetupData();
        loan__Loan_Account__c  clContract = TestUtility.createContract();
        Contact contact = TestUtility.createContact();

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{clContract};
        CLXSSPTransactionSummaryAPI.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Date startDate = GeneralHelper.currentSystemDate;
        Date endDate = GeneralHelper.currentSystemDate.addDays(20);

        Exception ex;
        clcommon.Response response;
        Test.startTest();
        try{
            response = new CLXSSPTransactionSummaryAPI().invokeAction('', null, new Map<String, Object>{
                'orderBy' => 'loan__Transaction_Date__c desc',
                'loanId' => clContract.Id,
                'recentTransaction' => null,
                'range' => '10',
                'fromDate' => '',
                'endDate' => ''
            });
        }catch(Exception e){
            ex = e;
        }
        Test.stopTest();

        System.assertEquals('ERROR', response.Status);
    }

    @isTest
    private static void testTransactionAPIRangeAndRecentTransactionNull() {
        TestUtility.runSetupData();
        loan__Loan_Account__c  clContract = TestUtility.createContract();
        Contact contact = TestUtility.createContact();

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{clContract};
        CLXSSPTransactionSummaryAPI.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Date startDate = GeneralHelper.currentSystemDate;
        Date endDate = GeneralHelper.currentSystemDate.addDays(20);

        Test.startTest();
            clcommon.Response response = new CLXSSPTransactionSummaryAPI().invokeAction('', null, new Map<String, Object>{
                'orderBy' => 'loan__Transaction_Date__c desc',
                'loanId' => clContract.Id,
                'recentTransaction' => null,
                'range' => null,
                'fromDate' => '',
                'endDate' => ''
            });
        Test.stopTest();

        System.assertEquals('SUCCESS', response.Status);
    }
}