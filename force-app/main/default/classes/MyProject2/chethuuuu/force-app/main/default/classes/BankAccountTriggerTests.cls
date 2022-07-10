@isTest
private class BankAccountTriggerTests {

    @isTest
    private static void  insertLoanBankAccount() {
        loan__Bank_Account__c loanBank  = new loan__Bank_Account__c();
        loanBank.loan__Bank_Account_Number__c = '45278345';
        loanBank.loan__Bank_Name__c = 'Union';
        loanBank.loan__Routing_Number__c = '123456789';

        Exception ex;
        Test.startTest();
        try {
            insert loanBank;
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

        list<loan__Bank_Account__c> actualBankAccount=[
            SELECT Id, loan__Bank_Account_Number__c,loan__Bank_Name__c
            FROM loan__Bank_Account__c
        ];

        System.assert(loanBank.Id != null);
        System.assertEquals(1, actualBankAccount.size());
        System.assertEquals('45278345', actualBankAccount[0].loan__Bank_Account_Number__c);
        System.assertEquals('Union', actualBankAccount[0].loan__Bank_Name__c);
    }
}