@isTest
private class CLContractButtonControllerTests {

    @isTest
    static void createPreClosureCharge() {

        GeneralHelper.currentSystemDate = Date.newInstance(2020, 02, 14);

        loan__Fee__c loanFee = new loan__Fee__c();
        loanFee.Name = GeneralConstants.PRE_CLOSURE_FEE;
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

        loan__Loan_Account__c loanAccount = (loan__Loan_Account__c) JSON.deserialize('{"Pre_Closure_Penalty_Amount__c" : 100}', loan__Loan_Account__c.class);
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loanAccount.loan__Fee_Set__c = feeSet.Id;

        DBManagerTestsStub chargeDBInstanceStubInstance = new DBManagerTestsStub();
        CLContractButtonController.chargeDBInstance = (ChargeDB) Test.createStub(ChargeDB.class, chargeDBInstanceStubInstance);

        List<loan__Charge__c> chargeList = new List<loan__Charge__c>();

        Test.startTest();
            String result = CLContractButtonController.createPreClosureCharge(loanAccount);
        Test.stopTest();

        System.assertEquals('Success', result);
        System.assertEquals(1, chargeDBInstanceStubInstance.forInsertSObjects.size());

        loan__Charge__c actualCharge = (loan__Charge__c) chargeDBInstanceStubInstance.forInsertSObjects.get(0);
        System.assertEquals(100, actualCharge.loan__Original_Amount__c);
    }

    @isTest
    static void createPreClosureChargeException() {

        GeneralHelper.currentSystemDate = Date.newInstance(2020, 02, 14);

        loan__Loan_Account__c loanAccount = (loan__Loan_Account__c) JSON.deserialize('{"Pre_Closure_Penalty_Amount__c" : 100}', loan__Loan_Account__c.class);
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        DBManagerTestsStub chargeDBInstanceStubInstance = new DBManagerTestsStub();
        CLContractButtonController.chargeDBInstance = (ChargeDB) Test.createStub(ChargeDB.class, chargeDBInstanceStubInstance);

        List<loan__Charge__c> chargeList = new List<loan__Charge__c>();

        Test.startTest();
            String result = CLContractButtonController.createPreClosureCharge(loanAccount);
        Test.stopTest();

        System.assertNotEquals('Success', result);
        System.assertEquals(0, chargeDBInstanceStubInstance.forInsertSObjects.size());
    }
}