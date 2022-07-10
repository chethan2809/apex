@isTest
private class CCMPPaymentScheduleTests {
    @TestSetup
    static void makeData(){
        TestUtility.runSetupData();
        loan__Loan_Account__c loanAccount = TestUtility.createContract();
    }

    @isTest
    private static void createDocumentTest() {
        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        loan__Loan_Account__c loanAccount = [
            SELECT Id, loan__Account__c, loan__Frequency_of_Loan_Payment__c, Latest_Missed_Payment_Date__c,
                loan__Interest_Paid__c, loan__Principal_Paid__c, loan__Fees_Paid__c, loan__Penalty_Paid__c,
                loan__Principal_Remaining__c, loan__Interest_Accrued_Not_Due__c, loan__Fees_Remaining__c,
            	loan__Disbursed_Amount__c, loan__Total_Interest_Amortization_Based__c, Percentage_Paid__c
            FROM loan__Loan_Account__c
        ];

        loanAccount.loan__Frequency_of_Loan_Payment__c = 'Daily';
        loanAccount.Latest_Missed_Payment_Date__c = GeneralHelper.currentSystemDate.addDays(-12);
        loanAccount.loan__Interest_Paid__c = 2000;
        loanAccount.loan__Principal_Paid__c = 6000;
        loanAccount.loan__Fees_Paid__c = 9000;
        loanAccount.loan__Penalty_Paid__c = 1000;
        loanAccount.loan__Principal_Remaining__c = 4000;
        loanAccount.loan__Interest_Accrued_Not_Due__c = 2000;
        loanAccount.loan__Fees_Remaining__c = 5350;
        loanAccount.Auto_Renewed__c = false;
        loanAccount.loan__Disbursed_Amount__c = 10000;
        loanAccount.Latest_Number_Of_Missed_Payments__c = 1;
        loanAccount.loan__Loan_Status__c = CLContracts.LOAN_STATUS_ACTIVE_GOOD_STANDING;
        update loanAccount;

        loan__Repayment_Schedule__c repaymentSchedule = new loan__Repayment_Schedule__c();
        repaymentSchedule.loan__Due_Interest__c = 10;
        repaymentSchedule.loan__Loan_Account__c = loanAccount.Id;
        repaymentSchedule.loan__Is_Archived__c = false;
        repaymentSchedule.loan__Due_Date__c = GeneralHelper.currentSystemDate;
        insert repaymentSchedule;

        Map<String, Object> paramsMap = new Map<String, Object>();
        paramsMap.put('contractId', loanAccount.Id);
        paramsMap.put('delete', false);

        Test.startTest();
            clcommon.Response response = new CCMPPaymentSchedule().invokeAction('', null, paramsMap);
        Test.stopTest();

        System.assertEquals(0, errorLogDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void deleteDocumentTest() {
        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();

        Id contractId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loan__Loan_Account__c clContractId = new loan__Loan_Account__c();
        clContractId.Id = contractId;

        Map<String, Object> paramsMap = new Map<String, Object>();
        paramsMap.put('contractId', clContractId.Id);
        paramsMap.put('delete', true);

        Test.startTest();
            clcommon.Response response = new CCMPPaymentSchedule().invokeAction('', null, paramsMap);
        Test.stopTest();

        System.assertEquals(0, errorLogDBStubInstance.forInsertSObjects.size());
    }


}