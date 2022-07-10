@isTest
private class LoanConcurrentEligibilityJobTests {

    @TestSetup
    static void makeData(){
        TestUtility.runSetupData();
        loan__Loan_Account__c loanAccount = TestUtility.createContract();
    }

    @isTest
    private static void loanConcurrentEligibilityJob(){
        loan__Loan_Account__c loanAccount = [
            SELECT Id,loan__Loan_Status__c,loan__Disbursal_Date__c, loan__Account__c
            FROM loan__Loan_Account__c
        ];

        loanAccount.loan__Disbursal_Date__c = GeneralHelper.currentSystemDate.addDays(-45);
        loanAccount.loan__Loan_Status__c = 'Active - Good Standing';
        update loanAccount;

        Account account = [
            SELECT Id, Concurrent_Eligible_Amount__c, Concurrent_Eligible__c
            FROM Account where id = :loanAccount.loan__Account__c
        ];

        account.Concurrent_Eligible_Amount__c = 7000;
        account.Concurrent_Eligible__c = false;
        update account;

        Exception ex;

        Test.startTest();
        try{
            LoanConcurrentEligibilityJob.execute();
        }
        catch(Exception e) {
            ex = e;
        }
        Test.stopTest();

        TestUtility.assertNullException(ex);

        list<loan__Loan_Account__c> updatedloanAccounts = [
            SELECT Id, loan__Account__c
            FROM loan__Loan_Account__c
            WHERE Id = :loanAccount.Id
        ];

        System.assertEquals(1, updatedloanAccounts.size());
        System.assertEquals(loanAccount.loan__Account__c, updatedloanAccounts.get(0).loan__Account__c);

        list<opportunity> insertedOpportunity = [
            SELECT Id
            FROM Opportunity
            WHERE AccountId = :loanAccount.loan__Account__c];

        System.assertEquals(1, insertedOpportunity.size());
    }

    @isTest
    private static void loanConcurrentEligibilityJobCheckBatchSizeException() {

        Origination_Settings__mdt originationSettings = new Origination_Settings__mdt();
        originationSettings.Loan_Concurrent_Batch_Size__c = null;
        CustomMetaDataHelper.defaultOriginationSetting = originationSettings;
        Exception ex;

        Test.startTest();
            try {
                loanConcurrentEligibilityJob.execute();
            }
            catch(Exception e){
                ex = e;
            }
        Test.stopTest();

        TestUtility.assertException(ex);
        System.assertEquals(ex.getMessage(), 'Loan_Concurrent_Batch_Size__c is null');
    }

}