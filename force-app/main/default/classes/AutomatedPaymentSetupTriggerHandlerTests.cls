@isTest
private class AutomatedPaymentSetupTriggerHandlerTests {

    private static AutomatedPaymentSetupTriggerHandler apsTriggerHandler = new AutomatedPaymentSetupTriggerHandler();

    @isTest
    private static void beforeInsert(){
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 02, 14);
        Date achTurnedDate = GeneralHelper.currentSystemDate;

        loan__Loan_Account__c clContract = new loan__Loan_Account__c();
        clContract.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        clContract.ACH_Turned_off_Date__c = achTurnedDate;

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{clContract};
        AutomatedPaymentSetupTriggerHandler.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        List<loan__Automated_Payment_Setup__c> newAPSList = new List<loan__Automated_Payment_Setup__c>();
        loan__Automated_Payment_Setup__c oldAPSRecord = new loan__Automated_Payment_Setup__c();
        oldAPSRecord.loan__Type__c = 'RECURRING';
        oldAPSRecord.loan__CL_Contract__c = clContract.Id;
        oldAPSRecord.Id = TestUtility.getFakeId(loan__Automated_Payment_Setup__c.getSObjectType());
        newAPSList.add(oldAPSRecord);

        DBManagerTestsStub apsDBStubInstance = new DBManagerTestsStub();
        apsDBStubInstance.genericReturnObject = new List<loan__Automated_Payment_Setup__c>{oldAPSRecord};
        AutomatedPaymentSetupTriggerHandler.automatedPaymentSetupDBInstance = (AutomatedPaymentSetupDB) Test.createStub(AutomatedPaymentSetupDB.class, apsDBStubInstance);

        Test.startTest();
            apsTriggerHandler.beforeInsert(newAPSList);
        Test.stopTest();

        System.assertEquals(1, clContractDBStubInstance.forUpdateSObjects.size());
        System.assertEquals(null, ((loan__Loan_Account__c)clContractDBStubInstance.forUpdateSObjects.get(0)).ACH_Turned_off_Date__c);
    }

    @isTest
    private static void beforeUpdate(){

        GeneralHelper.currentSystemDate = Date.newInstance(2020, 02, 14);
        Date achTurnedDate = GeneralHelper.currentSystemDate;

        loan__Loan_Account__c clContract = new loan__Loan_Account__c();
        clContract.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        clContract.ACH_Turned_off_Date__c = achTurnedDate;

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{clContract};
        AutomatedPaymentSetupTriggerHandler.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        List<loan__Automated_Payment_Setup__c> newAPSList = new List<loan__Automated_Payment_Setup__c>();
        loan__Automated_Payment_Setup__c oldAPSRecord = new loan__Automated_Payment_Setup__c();
        oldAPSRecord.loan__Type__c = 'RECURRING';
        oldAPSRecord.Id = TestUtility.getFakeId(loan__Automated_Payment_Setup__c.getSObjectType());
        newAPSList.add(oldAPSRecord);

        DBManagerTestsStub apsDBStubInstance = new DBManagerTestsStub();
        apsDBStubInstance.genericReturnObject = new List<loan__Automated_Payment_Setup__c>{oldAPSRecord};
        AutomatedPaymentSetupTriggerHandler.automatedPaymentSetupDBInstance = (AutomatedPaymentSetupDB) Test.createStub(AutomatedPaymentSetupDB.class, apsDBStubInstance);

        Exception ex;
        Test.startTest();
        try{
            apsTriggerHandler.beforeUpdate(newAPSList);
        }catch(Exception e){
            ex = e;
        }
        Test.stopTest();

        System.assertEquals(0, clContractDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void afterUpdate() {

        loan__Loan_Account__c clContract = new loan__Loan_Account__c();
        clContract.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 02, 14);
        clContract.ACH_Turned_off_Date__c = GeneralHelper.currentSystemDate;
        clContract.loan__la_matured_flag__c = false;
        clContract.loan__Loan_Status__c = 'Active - Good Standing';
        clContract.loan__Next_Installment_Date__c = GeneralHelper.currentSystemDate.addMonths(1);
        clContract.loan__Maturity_Date_Current__c = GeneralHelper.currentSystemDate.addMonths(1);
        clContract.loan__Frequency_of_Loan_Payment__c = 'Daily';
        clContract.loan__Disbursal_Date__c = GeneralHelper.currentSystemDate;
        clContract.loan__Last_Installment_Date__c = GeneralHelper.currentSystemDate.addDays(10);

        loan__Payment_Mode__c paymentMode = new loan__Payment_Mode__c();
        paymentMode.Id = TestUtility.getFakeId(loan__Payment_Mode__c.getSObjectType());

        List<loan__Automated_Payment_Setup__c> newAPSList = new List<loan__Automated_Payment_Setup__c>();
        loan__Automated_Payment_Setup__c oldAPSRecord = new loan__Automated_Payment_Setup__c();
        oldAPSRecord.Id = TestUtility.getFakeId(loan__Automated_Payment_Setup__c.getSObjectType());
        oldAPSRecord.loan__CL_Contract__c = clContract.Id;
        oldAPSRecord.loan__CL_Contract__r = clContract;
        oldAPSRecord.loan__Type__c = 'RECURRING';
        oldAPSRecord.loan__Amount_Type__c = 'OLDEST UNPAID BILL AMOUNT';
        oldAPSRecord.loan__Payment_Mode__c = paymentMode.Id;
        oldAPSRecord.loan__Active__c = true;
        oldAPSRecord.loan__Setup_Date__c = GeneralHelper.currentSystemDate;
        oldAPSRecord.loan__Retry__c = 'Enabled';
        oldAPSRecord.loan__Return_Codes_for_Retry__c = 'R01; R09';
        oldAPSRecord.loan__Apply_NSF_on_Attempt__c = '0';
        oldAPSRecord.loan__Number_of_Retry_Attempts__c = 1;
        oldAPSRecord.loan__Retry_Attempt_Interval__c = 1;
        oldAPSRecord.loan__Frequency__c = 'Daily';
        oldAPSRecord.loan__Recurring_ACH_Start_Date__c = GeneralHelper.currentSystemDate.addYears(-1);
        oldAPSRecord.loan__Recurring_ACH_End_Date__c = GeneralHelper.currentSystemDate;

        loan__Automated_Payment_Setup__c newAPSRecord = new loan__Automated_Payment_Setup__c();
        newAPSRecord.Id = oldAPSRecord.Id;
        newAPSRecord.loan__Recurring_ACH_Start_Date__c = GeneralHelper.currentSystemDate.addYears(-1);
        newAPSRecord.loan__Recurring_ACH_End_Date__c = GeneralHelper.currentSystemDate;
        newAPSRecord.loan__Type__c =  'RECURRING';
        newAPSRecord.loan__Active__c = false;

        newAPSList.add(newAPSRecord);

        Map<Id, loan__Automated_Payment_Setup__c> oldAPSMap = new Map<Id, loan__Automated_Payment_Setup__c>();
        oldAPSMap.put(oldAPSRecord.Id, oldAPSRecord);

        DBManagerTestsStub apsDBStubInstance = new DBManagerTestsStub();
        apsDBStubInstance.genericReturnObject = new List<loan__Automated_Payment_Setup__c>{oldAPSRecord};
        AutomatedPaymentSetupTriggerHandler.automatedPaymentSetupDBInstance = (AutomatedPaymentSetupDB) Test.createStub(AutomatedPaymentSetupDB.class, apsDBStubInstance);

        Test.startTest();
            apsTriggerHandler.afterUpdate(newAPSList, oldAPSMap);
        Test.stopTest();

        System.assertEquals(1, apsDBStubInstance.forUpdateSObjects.size());
        System.assertEquals(oldAPSRecord.loan__Active__c, ((loan__Automated_Payment_Setup__c)apsDBStubInstance.forUpdateSObjects.get(0)).loan__Active__c);
    }
}