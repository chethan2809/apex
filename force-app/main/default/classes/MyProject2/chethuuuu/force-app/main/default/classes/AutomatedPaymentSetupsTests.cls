@isTest
private class AutomatedPaymentSetupsTests {

    @isTest
    static void createRecurringAPSSetup() {

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Id bankAccountId = TestUtility.getFakeId(loan__Bank_Account__c.getSObjectType());
        Id loanAccountId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Date debitDate = GeneralHelper.currentSystemDate.addDays(10);

        loan__Loan_Account__c loanAccount = new loan__loan_Account__c();
        loanAccount.Bank_Account__c = bankAccountId;
        loanAccount.loan__Next_Installment_Date__c = debitDate;
        loanAccount.loan__Last_Installment_Date__c = debitDate.addDays(30);
        loanAccount.Id = loanAccountId;
        loanAccount.loan__Frequency_of_Loan_Payment__c = 'Daily';

        Test.startTest();
            loan__Automated_Payment_Setup__c actualApsSetup = AutomatedPaymentSetups.createRecurringAutomatedPaymentSetup(loanAccount);
        Test.stopTest();

        System.assert(actualApsSetup != null);
        System.assertEquals(bankAccountId, actualApsSetup.loan__Bank_Account__c);
        System.assertEquals(debitDate, actualApsSetup.loan__Debit_Date__c);
        System.assertEquals(loanAccountId, actualApsSetup.loan__CL_Contract__c);
        System.assertEquals('Daily', actualApsSetup.loan__Frequency__c);
    }
}