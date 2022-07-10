@isTest
private class AutoWriteOffManagerTests {
    @isTest
    static void setContractFieldsWhenAutoWriteOffEligible() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c ();
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        loan__Office_Name__c officeName = new loan__Office_Name__c();
        officeName.Id = TestUtility.getFakeId(loan__Office_Name__c.getSObjectType());
        officeName.loan__Write_Off_Suggestion_Days__c = 90;

        loan__Office_Name__c loanOfficeName = new loan__Office_Name__c();
        loanOfficeName.Id = TestUtility.getFakeId(loan__Office_Name__c.getSObjectType());
        loanOfficeName.loan__Current_System_Date__c = GeneralHelper.currentSystemDate;
        loanOfficeName.loan__Write_Off_Suggestion_Days__c = 900;
        List<loan__Office_Name__c> loanOfficeNameList = new List<loan__Office_Name__c> {loanOfficeName};

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        AutoWriteOffManager.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        DBManagerTestsStub loanOfficeNameDBStubInstance = new DBManagerTestsStub();
        loanOfficeNameDBStubInstance.genericReturnObject = new List<loan__Office_Name__c> {officeName};
        AutoWriteOffManager.loanOfficeNameDBInstance = (LoanOfficeNameDB) Test.createStub(LoanOfficeNameDB.class, loanOfficeNameDBStubInstance);

        Test.startTest();
            AutoWriteOffManager.setContractFieldsWhenAutoWriteOffEligible(
                new List<loan__Loan_Account__c> {loanAccount});
        Test.stopTest();

        System.assertEquals(1, clContractDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    static void handleAutoWriteOff() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        loan__Automated_Payment_Setup__c apsRecord = new loan__Automated_Payment_Setup__c();
        apsRecord.Id = TestUtility.getFakeId(loan__Automated_Payment_Setup__c.getSObjectType());

        CAN_General_Settings__c generalSetting = new CAN_General_Settings__c();
        generalSetting.Id = TestUtility.getFakeId(CAN_General_Settings__c.getSObjectType());
        CustomSettingsHelper.generalSettings = generalSetting;

        loan__Fee__c loanFee = new loan__Fee__c();
        loanFee.Name = GeneralConstants.PRE_CLOSURE_FEE;
        loanFee.Id = TestUtility.getFakeId(loan__Fee__c.getSObjectType());

        loan__Fee_Set__c feeSet = new loan__Fee_Set__c();
        feeSet.Id = TestUtility.getFakeId(loan__Fee_Set__c.getSObjectType());

        loan__Fee_Junction__c feeJunction = new loan__Fee_Junction__c();
        feeJunction.loan__Fee_Set__c = feeSet.Id;
        feeJunction.Id = TestUtility.getFakeId(loan__Fee_Junction__c.getSObjectType());

        loan__Loan_Account__c loanAccount = (loan__Loan_Account__c) JSON.deserialize(
            '{"Future_Payable_Interest_Amount__c" :' + 1000 + ' }', loan__Loan_Account__c.class
        );
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loanAccount.loan__Fee_Set__c = feeSet.Id;
        loanAccount.Auto_WriteOff_Date__c = GeneralHelper.currentSystemDate.addDays(-90);
        loanAccount.Write_off_Applicable__c = true;
        loanAccount.loan__Last_Installment_Date__c = GeneralHelper.currentSystemDate.addDays(90);

        Map<String, loan__Fee__c> loanFeeNameToLoanFee = new Map<String, loan__Fee__c>();
        loanFeeNameToLoanFee.put(loanFee.Name, loanFee);

        ServicingHelper.feeSetIdToFeesByName.put(feeJunction.loan__Fee_Set__c, loanFeeNameToLoanFee);

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c> {loanAccount};
        AutoWriteOffManager.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        DBManagerTestsStub chargeDBStubInstance = new DBManagerTestsStub();
        AutoWriteOffManager.chargeDBInstance = (ChargeDB) Test.createStub(ChargeDB.class, chargeDBStubInstance);

        Test.startTest();
            AutoWriteOffManager.handleAutoWriteOff(new List<loan__Loan_Account__c> {loanAccount});
        Test.stopTest();

        System.assertEquals(1, clContractDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    static void recheckAndSetCLContractFieldsWhenAutoWriteOffEligible() {

        CAN_General_Settings__c canGeneralSettings = new CAN_General_Settings__c();
        canGeneralSettings.Id = TestUtility.getFakeId(CAN_General_Settings__c.getSObjectType());
        canGeneralSettings.Missed_Payments_For_Daily_Auto_WriteOff__c = 3;
        CustomSettingsHelper.generalSettings = canGeneralSettings;

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c ();
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loanAccount.Latest_Number_Of_Missed_Payments__c = 1;
        loanAccount.loan__Frequency_of_Loan_Payment__c = GeneralConstants.FREQUENCY_DAILY;
        loanAccount.Auto_WriteOff_Date__c = GeneralHelper.currentSystemDate.addDays(5);

        loan__Office_Name__c officeName = new loan__Office_Name__c();
        officeName.Id = TestUtility.getFakeId(loan__Office_Name__c.getSObjectType());
        officeName.loan__Write_Off_Suggestion_Days__c = 90;

        loan__Office_Name__c loanOfficeName = new loan__Office_Name__c();
        loanOfficeName.Id = TestUtility.getFakeId(loan__Office_Name__c.getSObjectType());
        loanOfficeName.loan__Current_System_Date__c = GeneralHelper.currentSystemDate;
        loanOfficeName.loan__Write_Off_Suggestion_Days__c = 900;
        List<loan__Office_Name__c> loanOfficeNameList = new List<loan__Office_Name__c> {loanOfficeName};

        DBManagerTestsStub loanOfficeNameDBStubInstance = new DBManagerTestsStub();
        loanOfficeNameDBStubInstance.genericReturnObject = new List<loan__Office_Name__c> {officeName};
        AutoWriteOffManager.loanOfficeNameDBInstance = (LoanOfficeNameDB) Test.createStub(LoanOfficeNameDB.class, loanOfficeNameDBStubInstance);

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c> {loanAccount};
        AutoWriteOffManager.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        Test.startTest();
            AutoWriteOffManager.setContractFieldsWhenAutoWriteOffEligible(
                new List<loan__Loan_Account__c> {loanAccount});
        Test.stopTest();

        System.assertEquals(1, clContractDBStubInstance.forUpdateSObjects.size());
    }
}