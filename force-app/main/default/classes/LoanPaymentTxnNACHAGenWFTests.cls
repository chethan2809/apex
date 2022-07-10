@isTest
public class LoanPaymentTxnNACHAGenWFTests {
    public static Id getAutomatedPaymentSetupId(String apsType,String paymentName) {
        Id apsId= [SELECT Id
                   FROM loan__Automated_Payment_Setup__c
                   WHERE loan__Type__c = :apsType
                   AND loan__Payment_Mode__c IN (SELECT Id
                                          FROM loan__Payment_Mode__c
                                          WHERE name = :paymentName) LIMIT 1].Id;
        return apsId;
    }

    public static Id getPaymentId(String paymentName) {
        Id paymentId= [SELECT Id
                       FROM loan__Payment_Mode__c
                       WHERE name = :paymentName].Id;
        return paymentId;
    }

    public static loan__Loan_account__c getLoanAccount() {
        loan__Loan_Account__c la = [select Id,
                                    loan__Loan_Status__c,
                                    loan__Loan_Balance__c,
                                    loan__Principal_Remaining__c
                              FROM loan__Loan_Account__c];
        return la;
    }

    @testSetup
    static void setup(){
        Loan.TestHelper.systemDate = Date.today();
        Loan.TestHelper.createSeedDataForTesting();
        Loan.TestHelper.setupApprovalProcessForTxn(); // 3 day lock period
        List<filegen__File_Metadata__c> metadata = Test.loadData(filegen__File_Metadata__c.sObjectType,'FileGenTestMetaData'); 
        Loan.TestHelper.setupACHParameters();
        Loan.TestHelper2.createFileGenMetaData();
        Loan.TestHelper2.createOrgBankAccounts();
        loan__Transaction_Approval_Config__c c = Loan.CustomSettingsUtil.getApprovalConfig();
        c.loan__Payment__c = false;
        upsert c;
        loan__ACH_Parameters__c ach = Loan.CustomSettingsUtil.getACHParameters();
        ach.loan__Days_In_Advance_To_Create_File__c = 0;
        ach.loan__Multiple_Payment_Method_Support__c =true;
        upsert ach;

        loan__Currency__c curr = Loan.TestHelper.createCurrency();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = Loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = Loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        loan__Payment_Mode__c pMode = [select id from loan__Payment_Mode__c where Name= 'ACH'];
        loan__Payment_Mode__c pMode1 = [select id from loan__Payment_Mode__c where Name = 'Cash'];
        loan__Payment_Mode__c pMode2 = [select id from loan__Payment_Mode__c where Name = 'RCC'];
        loan__Bank_Account__c bank = [select id from loan__Bank_Account__c where loan__Account_usage__c=:Loan.FractionalizationConstants.COLLECTIONS_TRUST_ACCOUNT limit 1];
        Loan.TestHelper2.createAutomatedPaymentConfiguration(Loan.LoanConstants.LOAN_PAYMENT,pMode,bank,'LoanPaymentTxnNACHAGenWF');
        Loan.TestHelper2.createAutomatedPaymentConfiguration(Loan.LoanConstants.LOAN_PAYMENT,pMode1,bank,'LoanPaymentTxnNACHAGenWF');
        Loan.TestHelper2.createAutomatedPaymentConfiguration(Loan.LoanConstants.LOAN_PAYMENT,pMode2,bank,'LoanPaymentTxnRCCGen');
        //Create a Fee Set
        loan__Fee__c dummyFee = Loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        loan__Fee_Set__c dummyFeeSet = Loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = Loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        loan__Office_Name__c dummyOffice = Loan.TestHelper.createOffice();

        //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP = Loan.TestHelper.createLoanProduct(dummyOffice,
                            dummyAccount,
                            curr,
                            dummyFeeSet);

        loan__Loan_Purpose__c dummyLoanPurpose = Loan.TestHelper.createLoanPurpose();
        //Account a1 = Loan.TestHelper2.createInvestor('Bull', 1000);
        Account b1 = Loan.TestHelper2.createBorrower('ShoeString');
        loan__Bank_Account__c ba = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12',
                                                 loan__Bank_Name__c = 'Some Bank',
                                                 loan__Routing_Number__c = '999999999',
                                                 loan__Account_Type__c = 'Checking',
                                                 loan__Account__c = b1.id);
        insert ba;

        loan__Loan_Account__c dummylaMonthly = Loan.TestHelper.createLoanAccountForAccountObj(dummyLP,
                                        b1,
                                        dummyFeeSet,
                                        dummyLoanPurpose,
                                        dummyOffice);
        dummylaMonthly.Bank_Account__c = ba.Id;
        update dummylaMonthly;

        loan__Loan_Disbursal_Transaction__c disbTxn = new loan__Loan_Disbursal_Transaction__c();
        disbTxn.loan__Disbursal_Date__c = Loan.TestHelper.systemDate;
        disbTxn.loan__Disbursed_Amt__c = dummylaMonthly.loan__Loan_Amount__c;
        disbTxn.loan__Loan_Account__c = dummylaMonthly.id;
        disbTxn.loan__Mode_of_Payment__c =  pMode.id;

        insert disbTxn;
        disbTxn.loan__Cleared__c =true;
        update disbTxn;
        loan__Automated_Payment_Setup__c aPS = Loan.TestHelper2.createAutomatedPaymentSetup(Loan.LoanConstants.RECURRING,Loan.LoanConstants.FIXED_AMOUNT,ba,dummylaMonthly,'Monthly',pMode);
        loan__Automated_Payment_Setup__c aPS1 = Loan.TestHelper2.createAutomatedPaymentSetup(Loan.LoanConstants.ONE_TIME,Loan.LoanConstants.FIXED_AMOUNT,ba,dummylaMonthly,'Monthly',pMode1);
        loan__Automated_Payment_Setup__c aPS2 = Loan.TestHelper2.createAutomatedPaymentSetup(Loan.LoanConstants.ONE_TIME,Loan.LoanConstants.FIXED_AMOUNT,ba,dummylaMonthly,'Monthly',pMode2);

    }
 
    testMethod static void testLoanPaymentFilegenJobRCC(){
        Loan.TestHelper.systemDate = Date.today();
        Test.startTest();
        loan__Loan_Payment_Transaction__c dummyPmt = new loan__Loan_Payment_Transaction__c();
        dummyPmt.loan__Cleared__c = false;
        dummyPmt.loan__Payment_Mode__c = getPaymentId('ACH');
        dummyPmt.loan__Transaction_Amount__c  = 100;
        dummyPmt.loan__Transaction_Date__c = Loan.TestHelper.systemDate;
        dummyPmt.loan__Loan_Account__c  = getLoanAccount().id;
        dummyPmt.loan__Automated_Payment_Setup__c = getAutomatedPaymentSetupId(Loan.LoanConstants.RECURRING,Loan.LoanConstants.LOAN_PAYMENT_MODE_ACH);
        insert dummyPmt;

        Loan.LoanPaymentFilegenJob lpJob = new Loan.LoanPaymentFilegenJob(false);
        Database.executeBatch(lpJob, 200);
        Test.stopTest();
        system.assertEquals([select Id from loan__Loan_Payment_Transaction__c].size(),1);
        system.assertEquals([select Id from Document].size(),1);
    }

    testMethod static void testLoanPaymentFilegenJobforRCCAndNACHA(){
        Loan.TestHelper.systemDate = Date.today();
        Test.startTest();
        loan__Loan_Payment_Transaction__c dummyPmtRCC = new loan__Loan_Payment_Transaction__c();
        dummyPmtRCC.loan__Cleared__c = false;
        dummyPmtRCC.loan__Payment_Mode__c = getPaymentId('RCC');
        dummyPmtRCC.loan__Transaction_Amount__c  = 100;
        dummyPmtRCC.loan__Transaction_Date__c = Loan.TestHelper.systemDate;
        dummyPmtRCC.loan__Loan_Account__c  = getLoanAccount().id;
        dummyPmtRCC.loan__Automated_Payment_Setup__c = getAutomatedPaymentSetupId(Loan.LoanConstants.ONE_TIME,'RCC');
        insert dummyPmtRCC;

        loan__Loan_Payment_Transaction__c dummyPmtACH = new loan__Loan_Payment_Transaction__c();
        dummyPmtACH.loan__Cleared__c = false;
        dummyPmtACH.loan__Payment_Mode__c = getPaymentId('ACH');
        dummyPmtACH.loan__Transaction_Amount__c  = 100;
        dummyPmtACH.loan__Transaction_Date__c = Loan.TestHelper.systemDate;
        dummyPmtACH.loan__Loan_Account__c  = getLoanAccount().id;
        dummyPmtACH.loan__Automated_Payment_Setup__c = getAutomatedPaymentSetupId(Loan.LoanConstants.RECURRING, Loan.LoanConstants.LOAN_PAYMENT_MODE_ACH);
        insert dummyPmtACH;
        Loan.LoanPaymentFilegenJob lpJob = new Loan.LoanPaymentFilegenJob(false);
        Database.executeBatch(lpJob, 200);
        Test.stopTest();
        system.assertEquals([select Id from loan__Loan_Payment_Transaction__c].size(),2);
        system.assertEquals([select Id from Document].size(),2);
    }
}