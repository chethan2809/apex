@istest
private class FundingStatementJobTests {
    @testsetup
    static void makeData(){
        TestUtility.runSetupData();
        Account account = TestUtility.createAccount();
        Contact contact = TestUtility.createContact();
        Contact.AccountId = account.id;
        update Contact;

 		Decimal amount = 1250;
        Id bankAccountId = TestUtility.getFakeId(loan__Bank_Account__c.getSObjectType());
        Id paymentModeId = TestUtility.getFakeId(loan__Payment_Mode__c.getSObjectType());
        Id loanAccountId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Date disbursalDate = GeneralHelper.currentSystemDate;

        Id disbursalTransactionId = TestUtility.getFakeId(loan__Loan_Disbursal_Transaction__c.getSObjectType());
        Set<Id> disbursalTransactionIds = new Set<Id>();
        disbursalTransactionIds.add(disbursalTransactionId);
    }

    @istest
    private static void FundingStatementJob(){
      list<loan__Disbursal_Txn_Distribution__c> distribution = [SELECT Id, Name, loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Application__r.Owner.Name, loan__Transaction_Date__c, loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Broker_Contact__c,
                loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Broker_Contact__r.Account.Name, loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Type__c, loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Loan_Amount__c,
                loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__c, Funded_Source__c, loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__account__r.Merchant_ID__c,
                loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__account__r.name, loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Name, loan__Distribution_Amount__c, loan__Loan_Disbursal_Transaction__r.loan__Mode_of_Payment__r.name
            FROM loan__Disbursal_Txn_Distribution__c LIMIT 1];

         Exception ex;

        Test.startTest();
        try{
            FundingStatementJob.execute();
        }
        catch(Exception e) {
            ex = e;
        }
        Test.stopTest();
    }

    @isTest
    private static void aanNotificationJobCheckBatchSizeException() {

        Origination_Settings__mdt originationSettings = new Origination_Settings__mdt();
        originationSettings.Funding_Statement_Batch_Size__c = null;
        CustomMetaDataHelper.defaultOriginationSetting = originationSettings;
        Exception ex;

        System.Test.startTest();
            try {
                FundingStatementJob.execute();
            }
            catch(Exception e) {
                ex = e;
            }
        System.Test.stopTest();

        TestUtility.assertException(ex);
        System.assertEquals(ex.getMessage(), 'Funding_Statement_Batch_Size__c is null');

    }
}