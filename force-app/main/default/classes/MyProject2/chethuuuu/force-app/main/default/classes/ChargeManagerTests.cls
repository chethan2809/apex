@isTest(isParallel = true)
private class ChargeManagerTests {

    @isTest
    private static void createInitialChargesOriginationFee() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 02, 14);
        Date lateFeeDate = GeneralHelper.currentSystemDate;
        Date lateFeePreviousMonthDate = GeneralHelper.currentSystemDate.addDays(-30);
        Decimal originalAmount = 1000;

        loan__Fee__c loanFee = new loan__Fee__c();
        loanFee.Name = 'Origination Fee';
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

        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c();
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loanAccount.Origination_Fee__c = 10;
        loanAccount.loan__Fee_Set__c = feeSet.Id;
        loanAccount.loan__Last_Disbursal_Amount__c = 1000;
        loanAccount.Origination_Fee_Percentage__c = 10;

        List<loan__Charge__c> chargeList = new List<loan__Charge__c>();

        Test.startTest();
            ChargeManager.createInitialCharges(loanAccount, chargeList);
        Test.stopTest();

        System.assertEquals(1, chargeList.size());
        System.assertEquals(loanAccount.Id, chargeList[0].loan__Loan_Account__c);
    }

    @isTest
    private static void createConcurrentOriginationFee() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 02, 14);
        Date lateFeeDate = GeneralHelper.currentSystemDate;
        Date lateFeePreviousMonthDate = GeneralHelper.currentSystemDate.addDays(-30);
        Decimal originalAmount = 1000;

        loan__Fee__c loanFee = new loan__Fee__c();
        loanFee.Name = 'Origination Fee';
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

        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c();
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loanAccount.loan__Expected_Disbursal_Date__c = lateFeePreviousMonthDate;
        loanAccount.loan__Fee_Set__c = feeSet.Id;
        loanAccount.loan__Last_Disbursal_Amount__c = 1000;
        loanAccount.Origination_Fee_Percentage__c = 10;

        loan__Loan_Account__c oldLoanAccount = new loan__Loan_Account__c();
        oldLoanAccount.Id = loanAccount.Id;
        oldLoanAccount.loan__Last_Disbursal_Date__c = lateFeeDate;
        loanAccount.Origination_Fee__c = 10;
        loanAccount.loan__Fee_Set__c = feeSet.Id;
        loanAccount.loan__Last_Disbursal_Amount__c = 2000;
        loanAccount.Origination_Fee_Percentage__c = 10;

        List<loan__Charge__c> chargeList = new List<loan__Charge__c>();

        Test.startTest();
            ChargeManager.createConcurrentOriginationFee(loanAccount, oldLoanAccount, chargeList);
        Test.stopTest();

        System.assertEquals(1, chargeList.size());
        System.assertEquals(loanAccount.Id, chargeList[0].loan__Loan_Account__c);
    }

    @isTest
    private static void donotCreateConcurrentOriginationFee() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 02, 14);
        Date lateFeeDate = GeneralHelper.currentSystemDate;
        Date lateFeePreviousMonthDate = GeneralHelper.currentSystemDate.addDays(-30);
        Decimal originalAmount = 1000;

        loan__Fee__c loanFee = new loan__Fee__c();
        loanFee.Name = 'Origination Fee';
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

        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c();
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loanAccount.loan__Expected_Disbursal_Date__c = lateFeePreviousMonthDate;
        loanAccount.loan__Last_Disbursal_Date__c = lateFeePreviousMonthDate;
        loanAccount.loan__Fee_Set__c = feeSet.Id;
        loanAccount.loan__Last_Disbursal_Amount__c = 2000;
        loanAccount.Origination_Fee_Percentage__c = 10;

        loan__Loan_Account__c oldLoanAccount = new loan__Loan_Account__c();
        oldLoanAccount.Id = loanAccount.Id;
        oldLoanAccount.loan__Last_Disbursal_Date__c = lateFeeDate;
        loanAccount.Origination_Fee__c = 10;
        loanAccount.loan__Fee_Set__c = feeSet.Id;
        loanAccount.loan__Last_Disbursal_Amount__c = 2000;
        loanAccount.Origination_Fee_Percentage__c = 10;

        List<loan__Charge__c> chargeList = new List<loan__Charge__c>();

        Test.startTest();
            ChargeManager.createConcurrentOriginationFee(loanAccount, oldLoanAccount, chargeList);
        Test.stopTest();

        System.assert(chargeList.isEmpty());
    }

    @isTest
    private static void createInitialChargesFloridaStateFee() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 02, 14);
        Date lateFeeDate = GeneralHelper.currentSystemDate;
        Date lateFeePreviousMonthDate = GeneralHelper.currentSystemDate.addDays(-30);
        Decimal originalAmount = 1000;

        loan__Fee__c loanFee = new loan__Fee__c();
        loanFee.Name = 'Florida Fee';
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

        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c();
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loanAccount.Florida_State_Fee__c = 10;
        loanAccount.loan__Fee_Set__c = feeSet.Id;

        List<loan__Charge__c> chargeList = new List<loan__Charge__c>();

        Test.startTest();
            ChargeManager.createInitialCharges(loanAccount, chargeList);
        Test.stopTest();

        System.assertEquals(1, chargeList.size());
        System.assertEquals(loanAccount.Id, chargeList[0].loan__Loan_Account__c);
    }

    @isTest
    private static void donotCreateInitialCharges() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 02, 14);
        Date lateFeeDate = GeneralHelper.currentSystemDate;
        Date lateFeePreviousMonthDate = GeneralHelper.currentSystemDate.addDays(-30);
        Decimal originalAmount = 1000;

        loan__Fee__c loanFee = new loan__Fee__c();
        loanFee.Name = 'Florida Fee';
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

        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c();
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loanAccount.Florida_State_Fee__c = 0;
        loanAccount.loan__Fee_Set__c = feeSet.Id;

        List<loan__Charge__c> chargeList = new List<loan__Charge__c>();

        Test.startTest();
            ChargeManager.createInitialCharges(loanAccount, chargeList);
        Test.stopTest();

        System.assert(chargeList.isEmpty());
    }

    @isTest
    private static void createReturnChargesReturnACHFee() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 02, 14);
        Date lateFeeDate = GeneralHelper.currentSystemDate;
        Date lateFeePreviousMonthDate = GeneralHelper.currentSystemDate.addDays(-30);
        Decimal originalAmount = 1000;

        loan__Fee__c loanFee = new loan__Fee__c();
        loanFee.Name =  'Returned ACH Fee';
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

        loan__Loan_Account__c oldLoanAccount = new loan__Loan_Account__c();
        oldLoanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        oldLoanAccount.Return_ACH_Fee_Count__c = 10;
        oldLoanAccount.Return_ACH_Fee_Applied_Date__c = GeneralHelper.currentSystemDate.addDays(-3);
        oldLoanAccount.loan__Fee_Set__c = feeSet.Id;

        loan__Loan_Account__c loanAccount = (loan__Loan_Account__c) JSON.deserialize(
            '{"Account_StateID__c" : "OH"}' , loan__Loan_Account__c.class
        );
        loanAccount.Id = oldLoanAccount.Id;
        loanAccount.Return_ACH_Fee_Count__c = 20;
        loanAccount.Return_ACH_Fee_Applied_Date__c = GeneralHelper.currentSystemDate;
        loanAccount.loan__Fee_Set__c = feeSet.Id;

        List<loan__Charge__c> chargeList = new List<loan__Charge__c>();

        Test.startTest();
            ChargeManager.createReturnCharges(loanAccount, oldLoanAccount, chargeList);
        Test.stopTest();

        System.assertEquals(1, chargeList.size());
        System.assertEquals(loanAccount.Id, chargeList[0].loan__Loan_Account__c);
    }

    @isTest
    private static void createReturnChargesBlockedAccountFee() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 02, 14);
        Date lateFeeDate = GeneralHelper.currentSystemDate;
        Date lateFeePreviousMonthDate = GeneralHelper.currentSystemDate.addDays(-30);
        Decimal originalAmount = 1000;

        loan__Fee__c loanFee = new loan__Fee__c();
        loanFee.Name = 'Blocked Account Fee';
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

        loan__Loan_Account__c oldLoanAccount = new loan__Loan_Account__c();
        oldLoanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        oldLoanAccount.Return_Blocked_Account_Fee_Count__c = 10;
        oldLoanAccount.Return_Blocked_Account_Fee_Applied_Date__c = GeneralHelper.currentSystemDate.addDays(-3);
        oldLoanAccount.loan__Fee_Set__c = feeSet.Id;

        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c();
        loanAccount.Id = oldLoanAccount.Id;
        loanAccount.Return_Blocked_Account_Fee_Count__c = 20;
        loanAccount.Return_Blocked_Account_Fee_Applied_Date__c = GeneralHelper.currentSystemDate;
        loanAccount.loan__Fee_Set__c = feeSet.Id;

        List<loan__Charge__c> chargeList = new List<loan__Charge__c>();

        Test.startTest();
            ChargeManager.createReturnCharges(loanAccount, oldLoanAccount, chargeList);
        Test.stopTest();

        System.assertEquals(1, chargeList.size());
        System.assertEquals(loanAccount.Id, chargeList[0].loan__Loan_Account__c);
    }
}