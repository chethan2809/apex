@isTest(isParallel=true)
private class QueueContractDBTests {

    private static QueueContractDB queueContractDBInstance = new QueueContractDB();

    @isTest
    private static void getCollectorsByLoanAccounts() {
        Set<String> loanAccountNames = new Set<String>();
        loan__Loan_Account__c loanAccount = (loan__Loan_Account__c) JSON.deserialize(
            '{ "Name" : "LAI-000000"}' ,
            loan__Loan_Account__c.class
        );
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loanAccountNames.add(loanAccount.Name);

        Test.startTest();
            List<collect__Queue_Contract__c> queueContractList = queueContractDBInstance.getCollectorsByLoanAccounts(loanAccountNames);
        Test.stopTest();

        System.assert(queueContractList != null);
        System.assert(queueContractList.isEmpty());
    }
}