@isTest
private class ChargesTests {

    @isTest
    static void createCharge() {
        Decimal originalAmount = 1000;
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Date chargeDate = GeneralHelper.currentSystemDate.addDays(10);
        Id loanAccountId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Id feeId = TestUtility.getFakeId(loan__Fee__c.getSObjectType());

        Test.startTest();
            loan__Charge__c actualCharges = Charges.createCharge(loanAccountId, feeId, chargeDate, originalAmount);
        Test.stopTest();

        System.assert(actualCharges != null);
        System.assertEquals(loanAccountId, actualCharges.loan__Loan_Account__c);
        System.assertEquals(feeId, actualCharges.loan__Fee__c);
        System.assertEquals(chargeDate, actualCharges.loan__Date__c);
    }
}