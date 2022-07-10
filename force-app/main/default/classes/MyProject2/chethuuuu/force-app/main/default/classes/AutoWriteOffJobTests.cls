@isTest
private class AutoWriteOffJobTests {

    @TestSetup
    static void makeData(){
        TestUtility.runSetupData();
        loan__Loan_Account__c loanAccount = TestUtility.createContract();
    }

    @isTest
    private static void autoWriteOffJob() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        loan__Loan_Account__c loanAccount = [
            SELECT Id, Name, loan__Fee_Set__c
            FROM loan__Loan_Account__c
        ];

        loan__Fee__c loanFee = new loan__Fee__c();
        loanFee.Name = GeneralConstants.PRE_CLOSURE_FEE;
        loanFee.loan__Fee_Category__c = 'Loan';
        loanFee.loan__Time_of_charge__c = 'Other';
        loanFee.loan__Amount__c =  0.00;
        loanFee.loan__Fee_Calculation_Method__c = 'Fixed';
        insert loanFee;

        loan__Repayment_Schedule__c repaymentSchedule = new loan__Repayment_Schedule__c();
        repaymentSchedule.loan__Due_Interest__c = 100;
        repaymentSchedule.loan__Loan_Account__c = loanAccount.Id;
        repaymentSchedule.loan__Is_Archived__c = false;
        repaymentSchedule.loan__Due_Date__c = GeneralHelper.currentSystemDate;
        insert repaymentSchedule;

        loanAccount.Auto_WriteOff_Date__c = GeneralHelper.currentSystemDate.addDays(-12);
        loanAccount.Write_off_Applicable__c = true;
        update loanAccount;

        Map<String, loan__Fee__c> loanFeeNameToLoanFee = new Map<String, loan__Fee__c>();
        loanFeeNameToLoanFee.put(loanFee.Name, loanFee);

        ServicingHelper.feeSetIdToFeesByName.put(loanAccount.loan__Fee_Set__c, loanFeeNameToLoanFee);

        loan__Office_Name__c loanOfficeName = new loan__Office_Name__c();
        loanOfficeName.Id = TestUtility.getFakeId(loan__Office_Name__c.getSObjectType());
        loanOfficeName.loan__Current_System_Date__c = GeneralHelper.currentSystemDate;
        loanOfficeName.loan__Write_Off_Suggestion_Days__c = 900;

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        AutoWriteOffManager.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        DBManagerTestsStub chargeDBStubInstance = new DBManagerTestsStub();
        AutoWriteOffManager.chargeDBInstance = (ChargeDB) Test.createStub(ChargeDB.class, chargeDBStubInstance);

        DBManagerTestsStub automatedPaymentSetupDBStubInstance = new DBManagerTestsStub();
        AutoWriteOffManager.automatedPaymentSetupDBInstance =
            (automatedPaymentSetupDB) Test.createStub(automatedPaymentSetupDB.class, automatedPaymentSetupDBStubInstance);

        DBManagerTestsStub loanOfficeNameDBStubInstance = new DBManagerTestsStub();
        loanOfficeNameDBStubInstance.genericReturnObject = new List<loan__Office_Name__c> {loanOfficeName};
        AutoWriteOffManager.loanOfficeNameDBInstance = (LoanOfficeNameDB) Test.createStub(LoanOfficeNameDB.class, loanOfficeNameDBStubInstance);

        Exception ex;

        Test.startTest();
        try{
            AutoWriteOffJob.execute();
        }
        catch(Exception e) {
            ex = e;
        }
        Test.stopTest();

        List<loan__Loan_Account__c> updatedAccount = [
            SELECT Id, loan__Account__c
            FROM loan__Loan_Account__c
            WHERE Id = :loanAccount.Id
        ];

        System.assertEquals(1, updatedAccount.size());
    }

    @isTest
    private static void autoWriteOffJobException() {
        Origination_Settings__mdt originationSettings = new Origination_Settings__mdt();
        originationSettings.Auto_WriteOff_Job_Size__c = null;
        CustomMetaDataHelper.defaultOriginationSetting = originationSettings;
        Exception ex;

        Test.startTest();
            try {
                AutoWriteOffJob.execute();
            }
            catch(Exception e){
                ex = e;
            }
        Test.stopTest();

        TestUtility.assertException(ex);
        System.assertEquals(ex.getMessage(), 'Auto_WriteOff_Job_Size__c is null');
    }
}