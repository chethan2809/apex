@isTest(isParallel=true)
private class BrokerDBTests {

    private static BrokerDB brokerDBInstance = new BrokerDB();

    @isTest
    private static void getBrokerListByLoanAccountIds() {
        Id loanBrokerId = TestUtility.getFakeId(loan__Broker__c.getSObjectType());
        Set<Id> loanBrokerIds = new Set<Id>();
        loanBrokerIds.add(loanBrokerId);

        Test.startTest();
            List<loan__Broker__c> loanBrokerList = brokerDBInstance.getBrokerListByLoanAccountIds(loanBrokerIds);
        Test.stopTest();

        System.assert(loanBrokerList != null);
        System.assert(loanBrokerList.isEmpty());
    }

    @isTest
    private static void getBrokerListByCustomerAccountIds() {
        Id customerAccountId = TestUtility.getFakeId(Account.getSObjectType());
        Set<Id> customerAccountIds = new Set<Id>();
        customerAccountIds.add(customerAccountId);

        Test.startTest();
            List<loan__Broker__c> loanBrokerList = brokerDBInstance.getBrokerListByCustomerAccountIds(customerAccountIds);
        Test.stopTest();

        System.assert(loanBrokerList != null);
        System.assert(loanBrokerList.isEmpty());
    }

    @isTest
    private static void getBrokerListByLoanAccountIdsAndBrokerAccountIds() {
        Id brokerAccountId = TestUtility.getFakeId(Account.getSObjectType());
        Set<Id> brokerAccountIds = new Set<Id>();
        brokerAccountIds.add(brokerAccountId);

        Id loanBrokerId = TestUtility.getFakeId(loan__Broker__c.getSObjectType());
        Set<Id> loanBrokerIds = new Set<Id>();
        loanBrokerIds.add(loanBrokerId);

        Test.startTest();
            List<loan__Broker__c> loanBrokerList = brokerDBInstance.getBrokerListByLoanAccountIdsAndBrokerAccountIds(brokerAccountIds, loanBrokerIds);
        Test.stopTest();

        System.assert(loanBrokerList != null);
        System.assert(loanBrokerList.isEmpty());
    }
}