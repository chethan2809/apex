@isTest
private class FundingStatementsTests {

    @isTest
    private static void buildFundingStatementForNewAndRefinance(){
        String ACH_PROCESSOR_NAME = 'ACH (EFT Network)';

        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c();
        loanAccount.Type__c = 'New';
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        loan__Loan_Disbursal_Transaction__c disbursal = new loan__Loan_Disbursal_Transaction__c();
        disbursal.loan__Loan_Account__c = loanAccount.Id;
        disbursal.loan__Mode_of_Payment__c = TestUtility.getFakeId(loan__Payment_Mode__c.getSObjectType());
        disbursal.Id = TestUtility.getFakeId(loan__Loan_Disbursal_Transaction__c.getSObjectType());

        loan__Disbursal_Txn_Distribution__c disbursalTxn = new loan__Disbursal_Txn_Distribution__c();
        disbursalTxn.loan__Loan_Disbursal_Transaction__c = disbursal.Id;
        disbursalTxn.Funded_Source__c = 'Merchant';
        disbursalTxn.loan__Distribution_Amount__c = 70000;
        disbursalTxn.Id = TestUtility.getFakeId(loan__Disbursal_Txn_Distribution__c.getSObjectType());

        Test.startTest();
            String actualNew = FundingStatements.buildFundingStatementForNew(disbursalTxn);
            String actualRefinance = FundingStatements.buildFundingStatementForRefinance(disbursalTxn);
        Test.stopTest();

        String expectedValueNew = ',,,'+ACH_PROCESSOR_NAME+',,'+disbursalTxn.Funded_Source__c+','+disbursalTxn.loan__Distribution_Amount__c+',,,,,';
        System.assertEquals(expectedValueNew, actualNew);
    }

    @isTest
    private static void buildFundingStatementForConcurrent(){
        String ACH_PROCESSOR_NAME = 'ACH (EFT Network)';

        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c();
        loanAccount.Type__c = 'New';
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        loan__Loan_Disbursal_Transaction__c disbursal = new loan__Loan_Disbursal_Transaction__c();
        disbursal.loan__Loan_Account__c = loanAccount.Id;
        disbursal.loan__Mode_of_Payment__c = TestUtility.getFakeId(loan__Payment_Mode__c.getSObjectType());
        disbursal.Id = TestUtility.getFakeId(loan__Loan_Disbursal_Transaction__c.getSObjectType());

        loan__Disbursal_Txn_Distribution__c disbursalTxn = new loan__Disbursal_Txn_Distribution__c();
        disbursalTxn.loan__Loan_Disbursal_Transaction__c = disbursal.Id;
        disbursalTxn.Funded_Source__c = 'Merchant';
        disbursalTxn.loan__Distribution_Amount__c = 70000;
        disbursalTxn.Id = TestUtility.getFakeId(loan__Disbursal_Txn_Distribution__c.getSObjectType());

        Test.startTest();
            String actualConcurrent = FundingStatements.buildFundingStatementForConcurrent(disbursalTxn);
        Test.stopTest();

        String expectedValueNew = ',,,'+ACH_PROCESSOR_NAME+',,'+disbursalTxn.Funded_Source__c+','+disbursalTxn.loan__Distribution_Amount__c+',,Concurrent,,,';
        System.assertEquals(expectedValueNew, actualConcurrent);
    }
}