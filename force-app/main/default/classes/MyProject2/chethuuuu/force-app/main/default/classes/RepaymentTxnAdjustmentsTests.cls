@isTest(isParallel=true)
private class RepaymentTxnAdjustmentsTests {

    @isTest
    private static void buildEmailBodyByRepaymentTransactionDetails() {
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Contact primaryContact = (Contact) JSON.deserialize(
            '{ "Name" : "Test Primary"}' ,
            Contact.class
        );
        primaryContact.Id = TestUtility.getFakeId(Contact.getSObjectType());
        primaryContact.FirstName = 'Test First';
        primaryContact.LastName = 'Test Last';

        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c();
        loanAccount.Primary_Contact__c = primaryContact.Id;
        loanAccount.Primary_Contact__r = primaryContact;

        loan__Loan_Payment_Transaction__c loanPayment = new loan__Loan_Payment_Transaction__c();
        loanPayment.loan__Transaction_Amount__c = 5000;
        loanPayment.loan__Loan_Account__r  = loanAccount;

        loan__Repayment_Transaction_Adjustment__c repaymentTransaction = new loan__Repayment_Transaction_Adjustment__c();
        repaymentTransaction.loan__Adjustment_Txn_Date__c = GeneralHelper.currentSystemDate;
        repaymentTransaction.loan__Loan_Payment_Transaction__r = loanPayment;

        String body = '{{CONTACT_NAME}}';

        Test.startTest();
            body = RepaymentTxnAdjustments.buildEmailBodyByRepaymentTransactionDetails(repaymentTransaction, body);
        Test.stopTest();

        System.assert(body.contains(primaryContact.Name));
    }

    @isTest
    private static void buildEmailBodyWithoutRepaymentTransactionDetails() {

        loan__Repayment_Transaction_Adjustment__c repaymentTransaction = new loan__Repayment_Transaction_Adjustment__c();

        String body = '{{TRANSACTION_AMOUNT}}';

        Test.startTest();
            body = RepaymentTxnAdjustments.buildEmailBodyByRepaymentTransactionDetails(repaymentTransaction, body);
        Test.stopTest();

        System.assertNotEquals(null, body);
    }

    @isTest
    private static void buildEmailBodyByQueContractDetails() {
        User queueCollector = new User();
        queueCollector.Id = TestUtility.getFakeId(User.getSObjectType());
        queueCollector.FirstName = 'Test';
        queueCollector.LastName = 'Collector';
        queueCollector.Email = 'collector@collector.com';
        queueCollector.Title = 'Collection Manager';
        queueCollector.Phone = '9876543210';

        collect__Queue_Contract__c queueContract = (collect__Queue_Contract__c) JSON.deserialize(
            '{"collect__Collector__c" : "Test Collector"}' ,
            collect__Queue_Contract__c.class
        );
        queueContract.collect__User__c = queueCollector.Id;
        queueContract.collect__User__r = queueCollector;

        String body = '{{CAN_CAPITAL_EMPLOYEE_PHONE}}';

        Test.startTest();
            body = RepaymentTxnAdjustments.buildEmailBodyByQueContractDetails(queueContract, body);
        Test.stopTest();

        System.assert(body.contains(queueCollector.Phone));
    }

    @isTest
    private static void buildEmailBodyWithoutQueContractDetails() {
        collect__Queue_Contract__c queueContract = new collect__Queue_Contract__c();

        String body = '{{CAN_CAPITAL_EMPLOYEE_PHONE}}';

        Test.startTest();
            body = RepaymentTxnAdjustments.buildEmailBodyByQueContractDetails(queueContract, body);
        Test.stopTest();

        System.assertNotEquals(null, body);
    }

    @isTest
    private static void buildEmailBodyByDerronHardyDetails() {
        User derronHardy = new User();
        derronHardy.Id = TestUtility.getFakeId(User.getSObjectType());
        derronHardy.FirstName = 'Dorren';
        derronHardy.LastName = 'Hardy';
        derronHardy.Email = 'dhardy@cancapital.com';
        derronHardy.Title = 'Collection manager';
        derronHardy.Phone = '9876543210';

        String body = '{{CAN_CAPITAL_EMPLOYEE_PHONE}}';

        Test.startTest();
            body = RepaymentTxnAdjustments.buildEmailBodyByDerronHardyDetails(derronHardy, body);
        Test.stopTest();

        System.assert(body.contains(derronHardy.Phone));
    }

    @isTest
    private static void buildEmailBodyWithoutDerronHardyDetails() {
        User derronHardy = new User();

        String body = '{{CAN_CAPITAL_EMPLOYEE_PHONE}}';

        Test.startTest();
            body = RepaymentTxnAdjustments.buildEmailBodyByDerronHardyDetails(derronHardy, body);
        Test.stopTest();

        System.assertNotEquals(null, body);
    }

}