@isTest
private class LateFeeCreationManagerTests {

    @isTest
    private static void processLateFeeCreation() {

        GeneralHelper.currentSystemDate = Date.newInstance(2020, 02, 14);
        Date lateFeeDate = GeneralHelper.currentSystemDate;
        Decimal originalAmount = 1000;

        loan__Fee__c loanFee = new loan__Fee__c();
        loanFee.Name = 'Late Fee';
        loanFee.Id = TestUtility.getFakeId(loan__Fee__c.getSObjectType());

        DBManagerTestsStub feeDBStubInstance = new DBManagerTestsStub();
        feeDBStubInstance.genericReturnObject = new List<loan__Fee__c> {loanFee};
        ServicingHelper.feeDBInstance = (FeeDB) Test.createStub(FeeDB.class, feeDBStubInstance);

        loan__Fee_Set__c feeSet = new loan__Fee_Set__c();
        feeSet.Id = TestUtility.getFakeId(loan__Fee_Set__c.getSObjectType());

        loan__Fee_Junction__c feeJunction = new loan__Fee_Junction__c();
        feeJunction.loan__Fee_Set__c = feeSet.Id;
        feeJunction.loan__Fee__c = loanFee.Id;
        feeJunction.Id = TestUtility.getFakeId(loan__Fee_Junction__c.getSObjectType());

        DBManagerTestsStub feeJunctionDBStubInstance = new DBManagerTestsStub();
        feeJunctionDBStubInstance.genericReturnObject = new List<loan__Fee_Junction__c> {feeJunction};
        ServicingHelper.feeJunctionDBInstance = (FeeJunctionDB) Test.createStub(FeeJunctionDB.class, feeJunctionDBStubInstance);

        List<loan__Loan_Account__c> loanAccountList = new List<loan__Loan_Account__c>();
        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c();
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loanAccount.loan__Fee_Set__c = feeSet.Id;
        loanAccount.Late_fee_Applied_Date__c = null;
        loanAccountList.add(loanAccount);

        loan__Loan_Account__c loanAccount1 = new loan__Loan_Account__c();
        loanAccount1.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loanAccount1.loan__Fee_Set__c = feeSet.Id;
        loanAccount1.Late_fee_Applied_Date__c = Date.newInstance(2019, 02, 14);
        loanAccountList.add(loanAccount1);

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{loanAccount};
        LateFeeCreationManager.contractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        List<loan__Charge__c> chargeList = new List<loan__Charge__c>();
        loan__Charge__c charge = new loan__Charge__c();
        charge.Id = TestUtility.getFakeId(loan__Charge__c.getSObjectType());
        chargeList.add(charge);

        DBManagerTestsStub chargeDBStubInstance = new DBManagerTestsStub();
        chargeDBStubInstance.genericReturnObject = new List<loan__Charge__c>{charge};
        LateFeeCreationManager.chargeDBInstance = (chargeDB) Test.createStub(chargeDB.class, chargeDBStubInstance);

        Test.startTest();
            LateFeeCreationManager.processLateFeeCreation(loanAccountList);
        Test.stopTest();

        System.assertEquals(2, chargeDBStubInstance.forInsertSObjects.size());
    }
}