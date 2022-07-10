@isTest
public class FundingStatementManagerTests {

    @isTest
    private static void uploadFundingStatementTest() {

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());
        account.Merchant_ID__c = 'AVDGO234';
        account.Name = 'DUMMY';

        Contact contact = new Contact();
        contact.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contact.AccountId = account.Id;

        loan__Bank_Account__c bankAccount = new loan__Bank_Account__c();
        bankAccount.loan__Account__c = account.Id;
        bankAccount.Id = TestUtility.getFakeId(loan__Bank_Account__c.getSObjectType());

        genesis__Applications__c application = new genesis__Applications__c();
        application.Primary_Guarantor__c = contact.Id;
        application.Primary_Guarantor__r = contact;
        application.Underwriter__c = TestUtility.getFakeId(User.getSObjectType());
        application.Annual_Volume__c = 20000;
        application.OwnerId = TestUtility.getFakeId(User.getSObjectType());
        application.Type__c = 'New';
        application.Sales_Rep__c = TestUtility.getFakeId(User.getSObjectType());
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        loan__Loan_Account__c loanAccountRec = new loan__Loan_Account__c();
        loanAccountRec.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loanAccountRec.Bank_Account__c = bankAccount.Id;
        loanAccountRec.loan__Account__c = bankAccount.loan__Account__c;
        loanAccountRec.loan__Account__r = account;
        loanAccountRec.Type__c = 'New';
        loanAccountRec.Application__c = application.Id;
        loanAccountRec.Application__r = application;
        loanAccountRec.loan__Frequency_of_Loan_Payment__c = 'Weekly';
        loanAccountRec.Latest_Missed_Payment_Date__c = date.newInstance(2020, 1, 1);
        loanAccountRec.Broker_Contact__c = contact.id;
        loanAccountRec.Broker_Contact__r = contact;
        loanAccountRec.loan__Interest_Paid__c = 500;
        loanAccountRec.loan__Principal_Paid__c = 2000;
        loanAccountRec.loan__Fees_Paid__c = 100;
        loanAccountRec.loan__Penalty_Paid__c = 1000;
        loanAccountRec.loan__Principal_Remaining__c = 50;
        loanAccountRec.loan__Interest_Accrued_Not_Due__c = 200;
        loanAccountRec.loan__Fees_Remaining__c = 20;

        loan__Payment_Mode__c paymentMode = new loan__Payment_Mode__c();
        paymentMode.Id = TestUtility.getFakeId(loan__Payment_Mode__c.getSObjectType());
        paymentMode.loan__Archived__c = false;
        paymentMode.Name = 'Test Payment';

        loan__Loan_Disbursal_Transaction__c disbursal = new loan__Loan_Disbursal_Transaction__c();
        disbursal.Id = TestUtility.getFakeId(loan__Loan_Disbursal_Transaction__c.getSObjectType());
        disbursal.loan__Loan_Account__r = loanAccountRec;
        disbursal.loan__Mode_of_Payment__c = paymentMode.Id;
        disbursal.loan__Mode_of_Payment__r = paymentMode;
        disbursal.loan__Disbursal_Date__c = Date.newInstance(2019, 1, 1);

        List<loan__Disbursal_Txn_Distribution__c> disbursalTransactionDistributionList = new List<loan__Disbursal_Txn_Distribution__c>();

        loan__Disbursal_Txn_Distribution__c disbursalTxn = new loan__Disbursal_Txn_Distribution__c();
        disbursalTxn.Id = TestUtility.getFakeId(loan__Disbursal_Txn_Distribution__c.getSObjectType());
        disbursalTxn.loan__Loan_Disbursal_Transaction__r = disbursal;
        disbursalTxn.Funded_Source__c = 'Merchant';
        disbursalTxn.loan__Distribution_Amount__c = 70000;
        disbursalTransactionDistributionList.add(disbursalTxn);

        GeneralHelper.currentSystemDate = Date.newInstance(2021, 1, 1);

        Test.startTest();
            FundingStatementManager.uploadFundingStatement(disbursalTransactionDistributionList);
        Test.stopTest();

        System.assertEquals('New', loanAccountRec.Type__c);
    }

    @isTest
    private static void uploadFundingStatementTestForRefinance() {

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());
        account.Merchant_ID__c = 'AVDGO234';
        account.Name = 'DUMMY';

        Contact contact = new Contact();
        contact.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contact.AccountId = account.Id;

        loan__Bank_Account__c bankAccount = new loan__Bank_Account__c();
        bankAccount.loan__Account__c = account.Id;
        bankAccount.Id = TestUtility.getFakeId(loan__Bank_Account__c.getSObjectType());

        genesis__Applications__c application = new genesis__Applications__c();
        application.Primary_Guarantor__c = contact.Id;
        application.Primary_Guarantor__r = contact;
        application.Underwriter__c = TestUtility.getFakeId(User.getSObjectType());
        application.Annual_Volume__c = 20000;
        application.OwnerId = TestUtility.getFakeId(User.getSObjectType());
        application.Type__c = 'Renewal';
        application.Sales_Rep__c = TestUtility.getFakeId(User.getSObjectType());
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        loan__Loan_Account__c loanAccountRec = new loan__Loan_Account__c();
        loanAccountRec.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loanAccountRec.Bank_Account__c = bankAccount.Id;
        loanAccountRec.loan__Account__c = bankAccount.loan__Account__c;
        loanAccountRec.loan__Account__r = account;
        loanAccountRec.Type__c = 'Renewal';
        loanAccountRec.Application__c = application.Id;
        loanAccountRec.Application__r = application;
        loanAccountRec.loan__Frequency_of_Loan_Payment__c = 'Weekly';
        loanAccountRec.Latest_Missed_Payment_Date__c = date.newInstance(2020, 1, 1);
        loanAccountRec.Broker_Contact__c = contact.id;
        loanAccountRec.Broker_Contact__r = contact;
        loanAccountRec.loan__Interest_Paid__c = 500;
        loanAccountRec.loan__Principal_Paid__c = 2000;
        loanAccountRec.loan__Fees_Paid__c = 100;
        loanAccountRec.loan__Penalty_Paid__c = 1000;
        loanAccountRec.loan__Principal_Remaining__c = 50;
        loanAccountRec.loan__Interest_Accrued_Not_Due__c = 200;
        loanAccountRec.loan__Fees_Remaining__c = 20;

        loan__Payment_Mode__c paymentMode = new loan__Payment_Mode__c();
        paymentMode.Id = TestUtility.getFakeId(loan__Payment_Mode__c.getSObjectType());
        paymentMode.loan__Archived__c = false;
        paymentMode.Name = 'Test Payment';

        loan__Loan_Disbursal_Transaction__c disbursal = new loan__Loan_Disbursal_Transaction__c();
        disbursal.Id = TestUtility.getFakeId(loan__Loan_Disbursal_Transaction__c.getSObjectType());
        disbursal.loan__Loan_Account__r = loanAccountRec;
        disbursal.loan__Mode_of_Payment__c = paymentMode.Id;
        disbursal.loan__Mode_of_Payment__r = paymentMode;
        disbursal.loan__Disbursal_Date__c = Date.newInstance(2019, 1, 1);

        List<loan__Disbursal_Txn_Distribution__c> disbursalTransactionDistributionList = new List<loan__Disbursal_Txn_Distribution__c>();

        loan__Disbursal_Txn_Distribution__c disbursalTxn = new loan__Disbursal_Txn_Distribution__c();
        disbursalTxn.Id = TestUtility.getFakeId(loan__Disbursal_Txn_Distribution__c.getSObjectType());
        disbursalTxn.loan__Loan_Disbursal_Transaction__r = disbursal;
        disbursalTxn.Funded_Source__c = 'Merchant';
        disbursalTxn.loan__Distribution_Amount__c = 70000;
        disbursalTransactionDistributionList.add(disbursalTxn);

        GeneralHelper.currentSystemDate = Date.newInstance(2021, 1, 1);

        Test.startTest();
            FundingStatementManager.uploadFundingStatement(disbursalTransactionDistributionList);
        Test.stopTest();

        System.assertEquals('Renewal', loanAccountRec.Type__c);
    }

    @isTest
    private static void uploadFundingStatementTestForConcurrent() {

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());
        account.Merchant_ID__c = 'AVDGO234';
        account.Name = 'DUMMY';

        Contact contact = new Contact();
        contact.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contact.AccountId = account.Id;

        loan__Bank_Account__c bankAccount = new loan__Bank_Account__c();
        bankAccount.loan__Account__c = account.Id;
        bankAccount.Id = TestUtility.getFakeId(loan__Bank_Account__c.getSObjectType());

        genesis__Applications__c application = new genesis__Applications__c();
        application.Primary_Guarantor__c = contact.Id;
        application.Primary_Guarantor__r = contact;
        application.Underwriter__c = TestUtility.getFakeId(User.getSObjectType());
        application.Annual_Volume__c = 20000;
        application.OwnerId = TestUtility.getFakeId(User.getSObjectType());
        application.Type__c = 'Concurrent';
        application.Sales_Rep__c = TestUtility.getFakeId(User.getSObjectType());
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        loan__Loan_Account__c loanAccountRec = new loan__Loan_Account__c();
        loanAccountRec.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loanAccountRec.Bank_Account__c = bankAccount.Id;
        loanAccountRec.loan__Account__c = bankAccount.loan__Account__c;
        loanAccountRec.loan__Account__r = account;
        loanAccountRec.Type__c = 'Concurrent';
        loanAccountRec.Application__c = application.Id;
        loanAccountRec.Application__r = application;
        loanAccountRec.loan__Frequency_of_Loan_Payment__c = 'Weekly';
        loanAccountRec.Latest_Missed_Payment_Date__c = date.newInstance(2020, 1, 1);
        loanAccountRec.Broker_Contact__c = contact.id;
        loanAccountRec.Broker_Contact__r = contact;
        loanAccountRec.loan__Interest_Paid__c = 500;
        loanAccountRec.loan__Principal_Paid__c = 2000;
        loanAccountRec.loan__Fees_Paid__c = 100;
        loanAccountRec.loan__Penalty_Paid__c = 1000;
        loanAccountRec.loan__Principal_Remaining__c = 50;
        loanAccountRec.loan__Interest_Accrued_Not_Due__c = 200;
        loanAccountRec.loan__Fees_Remaining__c = 20;

        loan__Payment_Mode__c paymentMode = new loan__Payment_Mode__c();
        paymentMode.Id = TestUtility.getFakeId(loan__Payment_Mode__c.getSObjectType());
        paymentMode.loan__Archived__c = false;
        paymentMode.Name = 'Test Payment';

        loan__Loan_Disbursal_Transaction__c disbursal = new loan__Loan_Disbursal_Transaction__c();
        disbursal.Id = TestUtility.getFakeId(loan__Loan_Disbursal_Transaction__c.getSObjectType());
        disbursal.loan__Loan_Account__r = loanAccountRec;
        disbursal.loan__Mode_of_Payment__c = paymentMode.Id;
        disbursal.loan__Mode_of_Payment__r = paymentMode;
        disbursal.loan__Disbursal_Date__c = Date.newInstance(2019, 1, 1);

        List<loan__Disbursal_Txn_Distribution__c> disbursalTransactionDistributionList = new List<loan__Disbursal_Txn_Distribution__c>();

        loan__Disbursal_Txn_Distribution__c disbursalTxn = new loan__Disbursal_Txn_Distribution__c();
        disbursalTxn.Id = TestUtility.getFakeId(loan__Disbursal_Txn_Distribution__c.getSObjectType());
        disbursalTxn.loan__Loan_Disbursal_Transaction__r = disbursal;
        disbursalTxn.Funded_Source__c = 'Merchant';
        disbursalTxn.loan__Distribution_Amount__c = 70000;
        disbursalTransactionDistributionList.add(disbursalTxn);

        GeneralHelper.currentSystemDate = Date.newInstance(2021, 1, 1);

        Test.startTest();
            FundingStatementManager.uploadFundingStatement(disbursalTransactionDistributionList);
        Test.stopTest();

        System.assertEquals('Concurrent', loanAccountRec.Type__c);
    }

}