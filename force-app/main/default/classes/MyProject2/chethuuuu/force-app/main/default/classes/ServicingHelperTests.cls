@isTest
private class ServicingHelperTests {

    @isTest
    private static void paymentModeIdByName() {
        loan__Payment_Mode__c paymentModeACH = new loan__Payment_Mode__c();
        paymentModeACH.Name = GeneralConstants.PAYMENT_MODE_ACH;
        paymentModeACH.Id = TestUtility.getFakeId(loan__Payment_Mode__c.getSObjectType());

        DBManagerTestsStub paymentModeDBStubInstance = new DBManagerTestsStub();
        paymentModeDBStubInstance.genericReturnObject = new List<loan__Payment_Mode__c>{paymentModeACH};
        ServicingHelper.paymentModeDBInstance = (PaymentModeDB) Test.createStub(PaymentModeDB.class, paymentModeDBStubInstance);

        Test.startTest();
            Map<String, Id> paymentModeIdName = ServicingHelper.paymentModeIdByName;
        Test.stopTest();

        System.assertEquals(1, paymentModeIdName.size());
        System.assertEquals(paymentModeACH.Id, paymentModeIdName.get(GeneralConstants.PAYMENT_MODE_ACH));
    }

    @isTest
    private static void allActiveFeesMap(){
        loan__Fee__c loanFee = new loan__Fee__c();
        loanFee.Id = TestUtility.getFakeId(loan__Fee__c.getSObjectType());

        DBManagerTestsStub feeDBStubInstance = new DBManagerTestsStub();
        feeDBStubInstance.genericReturnObject = new List<loan__Fee__c> {loanFee};
        ServicingHelper.feeDBInstance = (FeeDB) Test.createStub(FeeDB.class, feeDBStubInstance);

        Test.startTest();
            Map<Id, loan__Fee__c> loanFeeMap = ServicingHelper.allActiveFeesMap;
        Test.stopTest();

        System.assertEquals(1, loanFeeMap.size());
        System.assertEquals(loanFee, loanFeeMap.get(loanFee.Id));
    }

    @isTest
    private static void feeSetIdToFeesByName(){
        loan__Fee__c loanFee = new loan__Fee__c();
        loanFee.Name = 'DummyFee';
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

        Test.startTest();
            Map<Id, Map<String, loan__Fee__c>> feeJunctionMap = ServicingHelper.feeSetIdToFeesByName;
        Test.stopTest();

        System.assertEquals(1, feeJunctionMap.size());
        System.assertEquals(loanFee, feeJunctionMap.get(feeSet.Id).get(loanFee.Name));
    }

    @isTest
    private static void brokerCommissionPlans() {
        loan__Commission_Plan__c commissionPlan = new loan__Commission_Plan__c();
        commissionPlan.Id = TestUtility.getFakeId(loan__Commission_Plan__c.getSObjectType());

        DBManagerTestsStub commissionPlanDBStubInstance = new DBManagerTestsStub();
        commissionPlanDBStubInstance.genericReturnObject = new List<loan__Commission_Plan__c> {commissionPlan};
        ServicingHelper.commissionPlanDBInstance = (commissionPlanDB) Test.createStub(commissionPlanDB.class, commissionPlanDBStubInstance);

        Test.startTest();
            List<loan__Commission_Plan__c> loanCommissionPlanList = ServicingHelper.BrokerCommissionPlans;
        Test.stopTest();

        System.assertEquals(1, loanCommissionPlanList.size());
        System.assertEquals(commissionPlan.Id, loanCommissionPlanList.get(0).Id);
    }

    @isTest
    private static void conditionsOnSpreadId() {
        loan__Conditions_On_Spread__c spreadCondition = new loan__Conditions_On_Spread__c();
        spreadCondition.Id = TestUtility.getFakeId(loan__Conditions_On_Spread__c.getSObjectType());

        Id conditionSpreadId = spreadCondition.Id;

        DBManagerTestsStub conditionsOnSpreadDBStubInstance = new DBManagerTestsStub();
        conditionsOnSpreadDBStubInstance.genericReturnObject = new List<loan__Conditions_On_Spread__c> {spreadCondition};
        ServicingHelper.conditionsOnSpreadDBInstance = (ConditionsOnSpreadDB) Test.createStub(ConditionsOnSpreadDB.class, conditionsOnSpreadDBStubInstance);

        Test.startTest();
            Id actualConditionsOnSpreadId = ServicingHelper.conditionsOnSpreadId;
        Test.stopTest();

        System.assert(actualConditionsOnSpreadId != null);
        System.assertEquals(spreadCondition.Id, actualConditionsOnSpreadId);
    }

    @isTest
    private static void conditionsOnSpreadIdException() {

        Exception ex;
        Test.startTest();
            try{
                Id actualConditionsOnSpreadId = ServicingHelper.conditionsOnSpreadId;
            }catch (Exception e){
                ex = e;
            }
        Test.stopTest();

        String exceptionMessage = 'Conditions On Spread is not found in the system';
        System.assertEquals(exceptionMessage, ex.getMessage());
    }

    @isTest
    private static void defaultPaymentSpreadId() {
        loan__Loan_Payment_Spread__c paymentSpread = new loan__Loan_Payment_Spread__c();
        paymentSpread.Id = TestUtility.getFakeId(loan__Loan_Payment_Spread__c.getSObjectType());

        Id paymentSpreadId = paymentSpread.Id;

        DBManagerTestsStub loanPaymentSpreadDBStubInstance = new DBManagerTestsStub();
        loanPaymentSpreadDBStubInstance.genericReturnObject = new List<loan__Loan_Payment_Spread__c> {paymentSpread};
        ServicingHelper.loanPaymentSpreadDBInstance = (LoanPaymentSpreadDB) Test.createStub(LoanPaymentSpreadDB.class, loanPaymentSpreadDBStubInstance);

        Test.startTest();
            Id actualDefaultPaymentSpreadId = ServicingHelper.defaultPaymentSpreadId;
        Test.stopTest();

        System.assert(actualDefaultPaymentSpreadId != null);
        System.assertEquals(paymentSpread.Id, actualDefaultPaymentSpreadId);
    }

    @isTest
    private static void defaultPaymentSpreadIdException() {

        Exception ex;
        Test.startTest();
            try{
                Id actualDefaultPaymentSpreadId = ServicingHelper.defaultPaymentSpreadId;
            }catch (Exception e){
                ex = e;
            }
        Test.stopTest();

        String exceptionMessage = 'CAN Payment Spread is not found in the system';
        System.assertEquals(exceptionMessage, ex.getMessage());
    }

    @isTest
    private static void canBankAccount() {

        loan__Bank_Account__c bankAccount = new loan__Bank_Account__c();
        bankAccount.Id = TestUtility.getFakeId(loan__Bank_Account__c.getSObjectType());

        DBManagerTestsStub bankAccountDBStubInstance = new DBManagerTestsStub();
        bankAccountDBStubInstance.genericReturnObject = new List<loan__Bank_Account__c>{bankAccount};
        ServicingHelper.bankAccountDBInstance = (BankAccountDB) Test.createStub(BankAccountDB.class, bankAccountDBStubInstance);

        Exception ex;
        Test.startTest();
        loan__Bank_Account__c actualBankAccount;
            try {
                actualBankAccount = ServicingHelper.canBankAccount;
            } catch (Exception e){
                ex = e;
            }
        Test.stopTest();

        TestUtility.assertNullException(ex);
        System.assertEquals(bankAccount.Id, actualBankAccount.Id);
    }

    @isTest
    private static void canBankAccountException() {

        DBManagerTestsStub bankAccountDBStubInstance = new DBManagerTestsStub();
        bankAccountDBStubInstance.genericReturnObject = new List<loan__Bank_Account__c>();
        ServicingHelper.bankAccountDBInstance = (BankAccountDB) Test.createStub(BankAccountDB.class, bankAccountDBStubInstance);

        Exception ex;
        Test.startTest();
            try {
                loan__Bank_Account__c actualBankAccount = ServicingHelper.canBankAccount;
            } catch (Exception e){
                ex = e;
            }
        Test.stopTest();

        TestUtility.assertException(ex);
        System.assert(ex.getMessage().contains('There was no active bank account found for CAN Capital'));
    }
}