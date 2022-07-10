@isTest
private class CollectionCaseStrategiesTests {

    @TestSetup
    static void makeData() {
        Collection_Criteria__c collectionCriteria = new Collection_Criteria__c();
        collectionCriteria.Queue_Value__c = 1;
        collectionCriteria.Active__c = true;
        collectionCriteria.Evaluation_Criteria__c = 'SELECT Id FROM loan__Loan_Account__c';
        insert collectionCriteria;
    }

    @isTest
    private static void setCollectionCaseFields() {

        Collection_Case__c collectionCase = new Collection_Case__c();

        loan__Loan_Account__c clContract = (loan__Loan_Account__c) JSON.deserialize(
            '{"Name" : "LAI-00000018", "Total_Outstanding_Repayment_Amount__c" : "49000"}', loan__Loan_Account__c.class
        );
        clContract.loan__Frequency_of_Loan_Payment__c = 'Daily';
        clContract.Return_Reason_Code__c = 'R02';

        Test.startTest();
            Collection_Case__c clCase = CollectionCaseStrategies.setCollectionCaseFields(clContract, collectionCase);
        Test.stopTest();

        System.assertEquals(clContract.Total_Outstanding_Repayment_Amount__c, clCase.Total_Outstanding_Repayment_Amount__c);
    }

    @isTest
    private static void collectionQueueLowBalanceQueue() {

        loan__Loan_Account__c clContract = (loan__Loan_Account__c) JSON.deserialize(
            '{"Name" : "LAI-00000018", "Total_Outstanding_Repayment_Amount__c" : "39000"}', loan__Loan_Account__c.class
        );
        clContract.loan__Frequency_of_Loan_Payment__c = 'Daily';
        clContract.Return_Reason_Code__c = 'R02';

        Test.startTest();
            String result = CollectionCaseStrategies.collectionQueue(clContract);
        Test.stopTest();

        System.assertEquals(CollectionCaseConstants.HIGH_BALANCE_QUEUE, result);
    }

    @isTest
    private static void collectionQueueHighBalanceQueue() {

        loan__Loan_Account__c clContract = (loan__Loan_Account__c) JSON.deserialize(
            '{"Name" : "LAI-00000015", "Total_Outstanding_Repayment_Amount__c" : "59000"}', loan__Loan_Account__c.class
        );
        clContract.loan__Frequency_of_Loan_Payment__c = 'Daily';
        clContract.Return_Reason_Code__c = 'R02';

        Test.startTest();
            String result = CollectionCaseStrategies.collectionQueue(clContract);
        Test.stopTest();

        System.assertEquals(CollectionCaseConstants.HIGH_BALANCE_QUEUE, result);
    }

    @isTest
    private static void collectionQueueHighBalanceQueueWeekly() {

        loan__Loan_Account__c clContract = (loan__Loan_Account__c) JSON.deserialize(
            '{"Name" : "LAI-00000018", "Total_Outstanding_Repayment_Amount__c" : "59000"}', loan__Loan_Account__c.class
        );
        clContract.loan__Frequency_of_Loan_Payment__c = 'Weekly';
        clContract.Return_Reason_Code__c = 'R02';
        clContract.Latest_Number_Of_Missed_Payments__c = 3;

        Test.startTest();
            String actualValue = CollectionCaseStrategies.collectionQueue(clContract);
        Test.stopTest();

        System.assertEquals(CollectionCaseConstants.HIGH_BALANCE_QUEUE, actualValue);
    }
}