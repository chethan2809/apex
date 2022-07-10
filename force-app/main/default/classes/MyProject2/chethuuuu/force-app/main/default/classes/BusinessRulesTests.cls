@isTest
private class BusinessRulesTests {

    @isTest
    private static void generalDeclineRulesWithAppTypeNew() {
        Account accountDetail = new Account();
        accountDetail.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountDetail.Legacy_Negative_CAN_History__c = true;

        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Status__c = 'NEW ENTERED';
        application.Type__c = 'New';
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Confirmed_Fraud_Flag__c = true;

        loan__Loan_Account__c clContract = new loan__Loan_Account__c();
        clContract.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        Test.startTest();
            BusinessRules.generalDeclineRules(application, clContract, accountDetail);
        Test.stopTest();

        System.assertEquals('New', application.Type__c);
    }

    @isTest
    private static void generalDeclineRulesAppTypeRenewalDaily() {
        Account accountDetail = new Account();
        accountDetail.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountDetail.Legacy_Negative_CAN_History__c = true;

        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Status__c = 'NEW ENTERED';
        application.Type__c = 'Renewal';
        application.Auto_Renewed__c = true;
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        loan__Loan_Account__c clContract = (loan__Loan_Account__c) JSON.deserialize(
            '{ "Percentage_Paid__c" : "45"}' , loan__Loan_Account__c.class
        );
        clContract.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        clContract.loan__Principal_Paid__c = 1000;
        clContract.loan__Interest_Paid__c = 50;
        clContract.loan__Disbursed_Amount__c = 1500;
        clContract.loan__Loan_Status__c = 'Active - Good Standing';
        clContract.loan__Product_Type__c = 'LOAN';
        clContract.Latest_Number_Of_Missed_Payments__c = 25;
        clContract.Max_Number_Of_Missed_Payments__c = 25;
        clContract.loan__Frequency_of_Loan_Payment__c = 'DAILY';

        Test.startTest();
            BusinessRules.generalDeclineRules(application, clContract, accountDetail);
        Test.stopTest();

        System.assertEquals(true, application.Auto_Renewed__c);
    }

    @isTest
    private static void generalDeclineRulesAppTypeRenewalWeekly() {
        Account accountDetail = new Account();
        accountDetail.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountDetail.Legacy_Negative_CAN_History__c = true;

        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Status__c = 'NEW ENTERED';
        application.Type__c = 'Renewal';
        application.Auto_Renewed__c = true;
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        loan__Loan_Account__c clContract = (loan__Loan_Account__c) JSON.deserialize(
            '{ "Percentage_Paid__c" : "45"}' , loan__Loan_Account__c.class
        );
        clContract.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        clContract.loan__Principal_Paid__c = 1000;
        clContract.loan__Interest_Paid__c = 50;
        clContract.loan__Disbursed_Amount__c = 1500;
        clContract.loan__Loan_Status__c = 'Closed - Refinanced';
        clContract.loan__Product_Type__c = 'LOAN';
        clContract.Latest_Number_Of_Missed_Payments__c = 25;
        clContract.Max_Number_Of_Missed_Payments__c = 25;
        clContract.loan__Frequency_of_Loan_Payment__c = 'WEEKLY';

        Test.startTest();
            BusinessRules.generalDeclineRules(application, clContract, accountDetail);
        Test.stopTest();

        System.assertEquals(true, application.Auto_Renewed__c);
    }

    @isTest
    private static void generalDeclineRulesAppTypeRenewalException() {
        Account accountDetail = new Account();
        accountDetail.Id = TestUtility.getFakeId(Account.getSObjectType());

        genesis__Applications__c application = new genesis__Applications__c();
        application.Type__c = 'Renewal';
        application.Auto_Renewed__c = true;
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        loan__Loan_Account__c clContract = new loan__Loan_Account__c();

        Exception ex;
        Test.startTest();
                BusinessRules.generalDeclineRules(application, clContract, accountDetail);
        Test.stopTest();

        System.assertEquals(null, ex);
    }

    @isTest
    private static void experianConsumerDeclineRules() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Type__c = 'New';
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        Credit_Report_Detail__c consumerCreditReport = new Credit_Report_Detail__c();
        consumerCreditReport.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        consumerCreditReport.Personal_FICO_Score__c = 550;
        consumerCreditReport.No_Of_Open_Trades__c = 0;
        consumerCreditReport.Total_No_Trades_Count__c = 2;
        consumerCreditReport.Bankruptcy_Risk_Score__c = 500;
        consumerCreditReport.Total_No_Late_Mortgage_Count__c = 4;
        consumerCreditReport.Is_Recent_Bankruptcy__c = true;
        consumerCreditReport.Is_Open_Bankruptcy__c = true;

        Test.startTest();
            BusinessRules.experianConsumerDeclineRules(application, consumerCreditReport);
        Test.stopTest();

        System.assertEquals(true, consumerCreditReport.Is_Recent_Bankruptcy__c);
    }

    @isTest
    private static void experianBusinessDeclineRules() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Type__c = 'New';
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        Credit_Report_Detail__c businessCreditReport = new Credit_Report_Detail__c();
        businessCreditReport.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        businessCreditReport.Tax_Liens__c = 275000;
        businessCreditReport.Judgement_Liens__c = 270000;
        businessCreditReport.Competitor_Judgement__c = true;
        businessCreditReport.Is_Recent_Bankruptcy__c = true;
        businessCreditReport.Is_Open_Bankruptcy__c = true;

        Test.startTest();
            BusinessRules.experianBusinessDeclineRules(application, businessCreditReport);
        Test.stopTest();

        System.assertEquals(true, businessCreditReport.Is_Recent_Bankruptcy__c);
    }

    @isTest
    private static void canScoringDeclineRulesForApplicationTypeNew() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Type__c = 'New';
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        Credit_Report_Detail__c canScoringCreditReport = new Credit_Report_Detail__c();
        canScoringCreditReport.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        canScoringCreditReport.CAN_Scoring__c = 17.50;

        Test.startTest();
            BusinessRules.canScoringDeclineRules(application, canScoringCreditReport);
        Test.stopTest();

        System.assertEquals(17.50, canScoringCreditReport.CAN_Scoring__c);
    }

    @isTest
    private static void canScoringDeclineRulesForApplicaitonTypeRenewal() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Type__c = 'Renewal';
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        Credit_Report_Detail__c canScoringCreditReport = new Credit_Report_Detail__c();
        canScoringCreditReport.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        canScoringCreditReport.CAN_Scoring__c = 29.2;

        Test.startTest();
            BusinessRules.canScoringDeclineRules(application, canScoringCreditReport);
        Test.stopTest();

        System.assertEquals(29.2, canScoringCreditReport.CAN_Scoring__c);
    }

    @isTest
    private static void industryDeclineRulesAndUWTaskForApplicationTypeNew() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Type__c = 'New';
        application.Industry_Rating__c = 'Prohibited';
        application.Business_Start_Date__c = TestUtility.currentSystemDate;

        Test.startTest();
            genesis__Applications__c actualApplication = BusinessRules.industryDeclineRulesAndUWTask(application);
        Test.stopTest();

        System.assertEquals(Applications.STATUS_DECLINED, actualApplication.genesis__Status__c);
        System.assertEquals(BusinessRules.DENIAL_REASON_PROHIBITED_INDUSTRY, actualApplication.Decline_Reasons__c);
    }

    @isTest
    private static void industryDeclineRulesAndUWTaskForApplicationTypeRenewal() {
        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Time_In_Business__c" : "2"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Type__c = 'Renewal';
        application.Industry_Rating__c = 'B';

        Test.startTest();
            genesis__Applications__c actualApplication = BusinessRules.industryDeclineRulesAndUWTask(application);
        Test.stopTest();

        System.assertEquals(Applications.STATUS_DECLINED, actualApplication.genesis__Status__c);
        System.assertEquals(BusinessRules.DENIAL_REASON_TIME_IN_BUSINESS, actualApplication.Decline_Reasons__c);
    }

    @isTest
    private static void ocrolusDeclineRulesNewApp() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Type__c = 'New';
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Number_Of_Competitors__c = 3;
        ocrolusReport.Number_Of_Deposits__c = 2;
        ocrolusReport.Is_Debt_Consolidator__c = true;
        ocrolusReport.Max_Daily_Payment__c = 7;
        ocrolusReport.Offer_GAV_Amount__c = 0;

        Test.startTest();
            BusinessRules.ocrolusDeclineRules(application, ocrolusReport);
        Test.stopTest();

        System.assertEquals(Applications.STATUS_DECLINED,  application.genesis__Status__c);
        System.assert(application.Decline_Reasons__c.contains(BusinessRules.DENIAL_REASON_NOT_ELIGIBLE_FOR_MINIMUM_FUNDING));
        System.assert(application.Decline_Reasons__c.contains(BusinessRules.DENIAL_REASON_DEBT_CONSOLIDATOR_PRESENT));
        System.assert(application.Decline_Reasons__c.contains(BusinessRules.DENIAL_REASON_BANK_DEPOSITS));
        System.assert(application.Decline_Reasons__c.contains(BusinessRules.DENIAL_REASON_COMPETITOR_STACKING));
        System.assert(application.Decline_Reasons__c.contains(BusinessRules.DENIAL_REASON_BANK_BALANCES));
    }

    @isTest
    private static void pricingGenerationDeclineRules() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Type__c = 'New';
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Id = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());
        pricingDetail.Maximum_Amount__c = 2000;

        Test.startTest();
            BusinessRules.pricingGenerationDeclineRules(application, pricingDetail);
        Test.stopTest();

        System.assertEquals(2000, pricingDetail.Maximum_Amount__c);
    }

    @isTest
    private static void setUnderWriterTasksVerificationWhenPotentialFraud() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Type__c = 'New';
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Is_Potential_Fraud__c = true;

        Credit_Report_Detail__c consumerCreditReport = new Credit_Report_Detail__c();
        consumerCreditReport.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        consumerCreditReport.Credit_Statement__c = 'FRAUD VICTIM ALERT FRAUDULENT';

        Map<String, UnderWriter_Task__c> underWriterTaskByApplicationIdTaskName = new Map<String, UnderWriter_Task__c>();

        UnderWriter_Task__c underWriterTaskOCRFraudAlert = new UnderWriter_Task__c();
        underWriterTaskOCRFraudAlert.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());

        UnderWriter_Task__c underWriterTaskExperianFraudAlert = new UnderWriter_Task__c();
        underWriterTaskExperianFraudAlert.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());

        underWriterTaskByApplicationIdTaskName.put(application.Id + 'OCR Fraud Alert', underWriterTaskOCRFraudAlert);
        underWriterTaskByApplicationIdTaskName.put(application.Id + 'Experian Fraud Alert', underWriterTaskExperianFraudAlert);

        Test.startTest();
            BusinessRules.setUnderWriterTasksVerification(
                underWriterTaskByApplicationIdTaskName, ocrolusReport, consumerCreditReport, application
            );
        Test.stopTest();

        System.assertEquals(BusinessRules.VERIFICATION_TYPE_MANUAL, underWriterTaskOCRFraudAlert.Verification_Type__c);
        System.assert(!underWriterTaskOCRFraudAlert.IsCompleted__c);
        System.assertEquals(BusinessRules.VERIFICATION_TYPE_MANUAL, underWriterTaskExperianFraudAlert.Verification_Type__c);
        System.assert(!underWriterTaskExperianFraudAlert.IsCompleted__c);
    }

    @isTest
    private static void setUnderWriterTasksVerificationWhenNoPotentialFraud() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Type__c = 'Renewal';
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Is_Potential_Fraud__c = false;

        Credit_Report_Detail__c consumerCreditReport = new Credit_Report_Detail__c();
        consumerCreditReport.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        consumerCreditReport.Credit_Statement__c = null;

        Map<String, UnderWriter_Task__c> underWriterTaskByApplicationIdTaskName = new Map<String, UnderWriter_Task__c>();

        UnderWriter_Task__c underWriterTaskOCRFraudAlert = new UnderWriter_Task__c();
        underWriterTaskOCRFraudAlert.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());

        UnderWriter_Task__c underWriterTaskExperianFraudAlert = new UnderWriter_Task__c();
        underWriterTaskExperianFraudAlert.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());

        underWriterTaskByApplicationIdTaskName.put(application.Id + 'OCR Fraud Alert', underWriterTaskOCRFraudAlert);
        underWriterTaskByApplicationIdTaskName.put(application.Id + 'Experian Fraud Alert', underWriterTaskExperianFraudAlert);

        Test.startTest();
            BusinessRules.setUnderWriterTasksVerification(
                underWriterTaskByApplicationIdTaskName, ocrolusReport, consumerCreditReport, application
            );
        Test.stopTest();

        System.assertEquals(BusinessRules.VERIFICATION_TYPE_AUTOMATED, underWriterTaskOCRFraudAlert.Verification_Type__c);
        System.assert(underWriterTaskOCRFraudAlert.IsCompleted__c);
        System.assertEquals(BusinessRules.VERIFICATION_TYPE_AUTOMATED, underWriterTaskExperianFraudAlert.Verification_Type__c);
        System.assert(underWriterTaskExperianFraudAlert.IsCompleted__c);
    }

    @isTest
    private static void runAutoAcceptExceptionEligibleForApplicationTypeNew() {
        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Time_In_Business__c" : "8"}' , genesis__Applications__c.class
        );
        application.Type__c = 'New';
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        Account accountDetail = new Account();
        accountDetail.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountDetail.Number_Of_Bounces_in_Last_60_Days__c = 2;

        Credit_Report_Detail__c consumerCreditReport = new Credit_Report_Detail__c();
        consumerCreditReport.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        consumerCreditReport.Personal_FICO_Score__c = 750;
        consumerCreditReport.Past_Due_Amount__c = 4000;

        Credit_Report_Detail__c businessCreditReport = new Credit_Report_Detail__c();
        businessCreditReport.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        businessCreditReport.Total_Collection_Amount__c = 4000;

        CAN_General_Settings__c canGeneralSettings = new CAN_General_Settings__c();
        canGeneralSettings.Id = TestUtility.getFakeId(CAN_General_Settings__c.getSObjectType());
        canGeneralSettings.FICO_Auto_Accept_Excptn_Eligible__c = 675;
        CustomSettingsHelper.generalSettings = canGeneralSettings;

        Test.startTest();
            BusinessRules.runAutoAcceptExceptionEligible(application, accountDetail, businessCreditReport, consumerCreditReport);
        Test.stopTest();

        System.assertEquals(4000, businessCreditReport.Total_Collection_Amount__c);
    }

    @isTest
    private static void runAutoAcceptExceptionEligibleForApplicationTypeRenewal() {
        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Time_In_Business__c" : "8"}' , genesis__Applications__c.class
        );
        application.Type__c = 'Renewal';
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        Account accountDetail = new Account();
        accountDetail.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountDetail.Number_Of_Bounces_in_Last_60_Days__c = null;

        Credit_Report_Detail__c consumerCreditReport = new Credit_Report_Detail__c();
        consumerCreditReport.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        consumerCreditReport.Personal_FICO_Score__c = 750;
        consumerCreditReport.Past_Due_Amount__c = 4000;

        Credit_Report_Detail__c businessCreditReport = new Credit_Report_Detail__c();
        businessCreditReport.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        businessCreditReport.Total_Collection_Amount__c = 4000;

        CAN_General_Settings__c canGeneralSettings = new CAN_General_Settings__c();
        canGeneralSettings.Id = TestUtility.getFakeId(CAN_General_Settings__c.getSObjectType());
        canGeneralSettings.FICO_Auto_Accept_Excptn_Eligible__c = 675;
        CustomSettingsHelper.generalSettings = canGeneralSettings;

        Test.startTest();
            BusinessRules.runAutoAcceptExceptionEligible(application, accountDetail, businessCreditReport, consumerCreditReport);
        Test.stopTest();

        System.assertEquals(4000, businessCreditReport.Total_Collection_Amount__c);
    }

    @isTest
    private static void generalDeclineRulesAppTypeRenewalNotDeclined() {
        Account accountDetail = new Account();
        accountDetail.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountDetail.Legacy_Negative_CAN_History__c = false;

        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Status__c = 'NEW ENTERED';
        application.Type__c = 'Renewal';
        application.Auto_Renewed__c = true;
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        loan__Loan_Account__c clContract = (loan__Loan_Account__c) JSON.deserialize(
            '{ "Percentage_Paid__c" : "45"}' , loan__Loan_Account__c.class
        );
        clContract.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        clContract.loan__Principal_Paid__c = 1000;
        clContract.loan__Interest_Paid__c = 50;
        clContract.loan__Disbursed_Amount__c = 1500;
        clContract.loan__Loan_Status__c = 'Closed - Refinanced';
        clContract.loan__Product_Type__c = 'LOAN';
        clContract.Latest_Number_Of_Missed_Payments__c = 0;
        clContract.Max_Number_Of_Missed_Payments__c = 0;
        clContract.loan__Frequency_of_Loan_Payment__c = 'DAILY';

        Test.startTest();
            BusinessRules.generalDeclineRules(application, clContract, accountDetail);
        Test.stopTest();

        System.assertEquals(null, application.Decline_Reasons__c);
    }

    @isTest
    private static void dataMerchDeclineRules() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Type__c = 'New';
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        GeneralHelper.currentSystemDate = Date.newInstance(2022, 06, 01);

        Data_Merch_Note__c dataMerchNote = new Data_Merch_Note__c();
        dataMerchNote.Id = TestUtility.getFakeId(Data_Merch_Note__c.getSObjectType());
        dataMerchNote.Application__c = application.Id;
        dataMerchNote.Added_at__c = GeneralHelper.currentSystemDate.addDays(-20);
        dataMerchNote.Note_Category__c = 'Suspicious Activity';
        Test.startTest();
            BusinessRules.dataMerchDeclineRules(application, new List<Data_Merch_Note__c>{dataMerchNote});
        Test.stopTest();

        System.assertEquals(BusinessRules.DENIAL_REASON_NEGATIVE_HISTORY_WITH_COMPETITOR, application.Decline_Reasons__c);
    }

    @isTest
    private static void generalDeclineRulesEISRenewalLowPctPaid() {
        Account accountDetail = new Account();
        accountDetail.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountDetail.Legacy_Negative_CAN_History__c = false;
        accountDetail.Legacy_Percent_Paid__c = 40;

        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Status__c = 'NEW ENTERED';
        application.Type__c = 'Renewal';
        application.Auto_Renewed__c = true;
        application.Is_EIS_Renewal__c = true;
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        loan__Loan_Account__c clContract = (loan__Loan_Account__c) JSON.deserialize(
            '{ "Percentage_Paid__c" : "45"}' , loan__Loan_Account__c.class
        );
        clContract.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        clContract.loan__Principal_Paid__c = 1000;
        clContract.loan__Interest_Paid__c = 50;
        clContract.loan__Disbursed_Amount__c = 1500;
        clContract.loan__Loan_Status__c = 'Closed - Refinanced';
        clContract.loan__Product_Type__c = 'LOAN';
        clContract.Latest_Number_Of_Missed_Payments__c = 0;
        clContract.Max_Number_Of_Missed_Payments__c = 0;
        clContract.loan__Frequency_of_Loan_Payment__c = 'DAILY';

        Test.startTest();
            BusinessRules.generalDeclineRules(application, clContract, accountDetail);
        Test.stopTest();

        System.assert(application.Decline_Reasons__c.contains('Not Eligible For Renewal Funding'));
    }
}