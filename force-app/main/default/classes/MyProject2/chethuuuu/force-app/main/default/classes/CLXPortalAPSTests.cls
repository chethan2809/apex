@isTest
private class CLXPortalAPSTests {

    @TestSetup
    private static void makeData(){

        TestUtility.runSetupData();
        loan__Loan_Payment_Spread__c canPaymentSpread =  new loan__Loan_Payment_Spread__c();
        canPaymentSpread.Name = 'CAN Payment Spread';
        insert canPaymentSpread;

        loan__Loan_Account__c contract = TestUtility.createContract();
        contract.loan__Loan_Status__c = 'Active - Good Standing';
        contract.loan__Pay_Off_Amount_As_Of_Today__c = 5000;
        update contract;
    }

    @isTest
    private static void createAdhocPaymentTestMethod(){
        loan__Loan_Account__c contractRec = [SELECT Id,loan__Loan_Status__c,loan__Pay_Off_Amount_As_Of_Today__c,loan__Account__c,
                                            		Application__c,Application__r.Primary_Guarantor__c,Bank_Account__c
                                        	FROM loan__Loan_Account__c
                                            LIMIT 1];
        Test.startTest();
        CLXPortalAPS.createAdhocPayment(contractRec.Id, 0, true);
        CLXPortalAPS.createAdhocPayment(contractRec.Id, 0, false);

        loan__Payment_Mode__c loanPayMode = new loan__Payment_Mode__c(Name='ACH');
		insert loanPayMode;

        loan__Automated_Payment_Setup__c portalAPS = new loan__Automated_Payment_Setup__c();
		portalAPS.loan__Active__c = true;
		portalAPS.loan__Actual_Date__c = date.Today();
		portalAPS.loan__Amount_Type_Split_Factor__c = 1;
		portalAPS.loan__Bank_Account__c = contractRec.Bank_Account__c;
		portalAPS.loan__CL_Contract__c = contractRec.id;
		portalAPS.loan__Debit_Date__c = date.Today();
		portalAPS.loan__Payment_Mode__c = loanPayMode.id;
		portalAPS.loan__Type__c = 'ONE TIME';
		portalAPS.loan__Setup_Date__c = date.Today();
		portalAPS.loan__Transaction_Amount__c = 10000;
		insert portalAPS;

        CLXPortalAPS.createAdhocPayment(contractRec.id, 10000, true);
        CLXPortalAPS.createAdhocPayment(contractRec.id, 15000, true);
        CLXPortalAPS.createAdhocPayment(contractRec.id, 10000, false);
        delete PortalAPS;

        contractRec.loan__Loan_Status__c = 'Active - Matured';
        update contractRec;

        CLXPortalAPS.createAdhocPayment(contractRec.id, 10000, false);
        contractRec.loan__Loan_Status__c = 'Active - Good Standing';
        update contractRec;

        CLXPortalAPS.createAdhocPayment(contractRec.id, 10000, false);

        loan__Bank_Account__c loanBankAcc = [SELECT id,loan__Account__c 
                                             FROM loan__Bank_Account__c 
                                             WHERE id =:contractRec.Bank_Account__c 
                                             LIMIT 1];
        loanBankAcc.loan__Account__c = contractRec.loan__Account__c;
        loanBankAcc.loan__Active__c = true;
        update loanBankAcc;

        CLXPortalAPS.createAdhocPayment(contractRec.id, 10000, false);
        CLXPortalAPS.createAdhocPayment(contractRec.id, 10000, true);

        Date dt;
        try{
            dt = CLXPortalAPS.getPaymentCutOffDate();
        }
        catch(Exception e){}
        Test.stopTest();

        System.assertEquals(true, loanBankAcc.loan__Active__c);
    }
}