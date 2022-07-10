@isTest
private class TestCCMPSSPInterestStatements {

    @testSetup
    private static void dataSetup() {
        TestUtility.runSetupData();
        loan__Loan_Account__c  clContract = TestUtility.createContract();
    }

    @isTest
    private static void invokeAction(){
        loan__Loan_Account__c  clContract = [SELECT Id FROM loan__Loan_Account__c LIMIT 1];
        clContract.loan__Loan_Balance__c = 2000.00;
        clContract.loan__Disbursal_Date__c = Date.newInstance(2018, 6, 6);
        update clContract;

        loan__Payment_Mode__c pmtMode = TestUtility.createPaymentMode('ACH');
        loan__Loan_Payment_Transaction__c lpt = TestUtility.generateLoanPaymentTransaction(clContract.Id, 100.00, pmtMode.Id);

        Test.startTest();
            clcommon.Response response = new CCMPSSPInterestStatements().invokeAction('', null, new Map<String, Object>{
                'fromMonth' => '5-5',
                'toMonth' => '6-6',
                'startDate' => '5-5',
                'endDate' => '6-6',
                'fromYear' => '2018',
                'toYear' => '2020',
                'contractId' => clContract.Id
            });
        Test.stopTest();

        System.assert(response != null);
        System.assertEquals('SUCCESS', response.Status);
    }

    @isTest
    private static void invokeActionNotEqualsToContractId(){

        Test.startTest();
            clcommon.Response response = new CCMPSSPInterestStatements().invokeAction('', null, new Map<String, Object>{
                'fromMonth' => '5-5',
                'toMonth' => '6-6',
                'startDate' => '5-5',
                'endDate' => '6-6',
                'fromYear' => '2018',
                'toYear' => '2020',
                'contractId1' => ''
            });
        Test.stopTest();

        System.assert(response != null);
        System.assertEquals('Failed', response.Status);
    }

    @isTest
    private static void invokeActionContractListEmpty(){
        loan__Loan_Account__c  clContract = [SELECT Id FROM loan__Loan_Account__c LIMIT 1];
        clContract.loan__Loan_Balance__c = 2000.00;
        clContract.loan__Disbursal_Date__c = Date.newInstance(2018, 6, 6);
        update clContract;

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        CCMPSSPInterestStatements.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        CCMPSSPInterestStatements.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Test.startTest();
            clcommon.Response response = new CCMPSSPInterestStatements().invokeAction('', null, new Map<String, Object>{
                'fromMonth' => '5-5',
                'toMonth' => '6-6',
                'startDate' => '5-5',
                'endDate' => '6-6',
                'fromYear' => '2018',
                'toYear' => '2020',
                'contractId' => clContract.Id
            });
        Test.stopTest();

        System.assert(response != null);
        System.assertEquals('API_EXCEPTION', response.Status);
        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void invokeActionException(){
        loan__Loan_Account__c  clContract = [SELECT Id, loan__Account__c FROM loan__Loan_Account__c LIMIT 1];

        clContract.loan__Loan_Balance__c = 2000.00;
        clContract.loan__Disbursal_Date__c = Date.newInstance(2018, 6, 6);
        update clContract;

        loan__Payment_Mode__c pmtMode = TestUtility.createPaymentMode('ACH');
        loan__Loan_Payment_Transaction__c lpt = TestUtility.generateLoanPaymentTransaction(clContract.Id, 100.00, pmtMode.Id);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        CCMPSSPInterestStatements.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{clContract};
        CCMPSSPInterestStatements.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        DBManagerTestsStub loanPaymentTransactionDBStubInstance = new DBManagerTestsStub();
        loanPaymentTransactionDBStubInstance.genericReturnObject = new List<loan__Loan_Payment_Transaction__c>{lpt};
        CCMPSSPInterestStatements.loanPaymentTransactionDBInstance = (LoanPaymentTransactionDB) Test.createStub(LoanPaymentTransactionDB.class, loanPaymentTransactionDBStubInstance);

        Exception ex;
        clcommon.Response response;
        Test.startTest();
        try{
                response = new CCMPSSPInterestStatements().invokeAction('', null, new Map<String, Object>{
                'fromMonth' => '5-5',
                'toMonth' => '6-6',
                'startDate' => '5-5',
                'endDate' => '6-6',
                'fromYear' => '2018',
                'toYear' => '2020',
                'contractId' => clContract.Id
            });
        }catch(Exception e){
            ex = e;
        }
        Test.stopTest();

        TestUtility.assertException(Ex);
        System.assert(ex.getMessage() != null);
        System.assert(response == null);
        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
    }
}