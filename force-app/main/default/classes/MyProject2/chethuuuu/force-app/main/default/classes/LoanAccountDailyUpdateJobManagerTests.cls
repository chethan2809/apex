@isTest
private class LoanAccountDailyUpdateJobManagerTests {
    @isTest
    private static void calculateConcurrentInterestRate(){
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        List<loan__Loan_Account__c> loanAccountList = new List<loan__Loan_Account__c>();

        loan__Loan_Account__c loanAccount = (loan__Loan_Account__c) JSON.deserialize(
            '{"Disbursement_Count__c" : "1.0", "Remaining_Number_of_Payments__c" : "24", "Concurrent_Eligible_Amount__c" : "5000"}',
            loan__Loan_Account__c.class
        );
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loanAccount.Pricing_Factor__c = 1.45;
        loanAccount.loan__Frequency_of_Loan_Payment__c = 'Daily';

        loanAccountList.add(loanAccount);

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c> {loanAccount};
        LoanAccountDailyUpdateJobManager.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        LoanAccountDailyUpdateJobManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Test.startTest();
            LoanAccountDailyUpdateJobManager.calculateConcurrentInterestRate(loanAccountList);
        Test.stopTest();

        System.assertEquals(1, clContractDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void calculateConcurrentInterestRateCheckException(){
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        List<loan__Loan_Account__c> loanAccountList = new List<loan__Loan_Account__c>();

        loan__Loan_Account__c loanAccount = (loan__Loan_Account__c) JSON.deserialize(
            '{"Disbursement_Count__c" : "1.0", "Remaining_Number_of_Payments__c" : "24", "Concurrent_Eligible_Amount__c" : "5000"}',
            loan__Loan_Account__c.class
        );
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loanAccount.Pricing_Factor__c = 1.45;

        loanAccountList.add(loanAccount);

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c> {loanAccount};
        LoanAccountDailyUpdateJobManager.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        LoanAccountDailyUpdateJobManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Test.startTest();
            LoanAccountDailyUpdateJobManager.calculateConcurrentInterestRate(loanAccountList);
        Test.stopTest();

        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void calculateConcurrentInterestRateDataIssue(){
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        List<loan__Loan_Account__c> loanAccountList = new List<loan__Loan_Account__c>();

        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c();
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loanAccount.Pricing_Factor__c = 1.45;

        loanAccountList.add(loanAccount);

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c> {loanAccount};
        LoanAccountDailyUpdateJobManager.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        LoanAccountDailyUpdateJobManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Test.startTest();
            LoanAccountDailyUpdateJobManager.calculateConcurrentInterestRate(loanAccountList);
        Test.stopTest();

        System.assertEquals(0, clContractDBStubInstance.forUpdateSObjects.size());
        System.assertEquals(0, errorLogDBStubInstance.forInsertSObjects.size());
    }
}