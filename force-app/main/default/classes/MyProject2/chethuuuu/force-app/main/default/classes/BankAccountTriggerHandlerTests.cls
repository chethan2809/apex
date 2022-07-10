@isTest
private class BankAccountTriggerHandlerTests {

    private static BankAccountTriggerHandler bankAccountTriggerHandlerInstance = new BankAccountTriggerHandler();

    @isTest
    private static void afterInsert(){
        loan__Bank_Account__c bankAccount = new loan__Bank_Account__c();
        bankAccount.Id = TestUtility.getFakeId(loan__Bank_Account__c.getSObjectType());

        Map<Id, loan__Bank_Account__c> newBankAccountMap = new Map<Id, loan__Bank_Account__c>();
        newBankAccountMap.put(bankAccount.Id, bankAccount);

        Test.startTest();
            BankAccountTriggerHandlerInstance.afterInsert(newBankAccountMap);
        Test.stopTest();

        System.assert(newBankAccountMap != null);
    }
}