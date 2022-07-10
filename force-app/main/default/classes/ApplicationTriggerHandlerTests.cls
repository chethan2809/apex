@isTest
private class ApplicationTriggerHandlerTests {
    @isTest
    private static void beforeInsert() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Expected_Close_Date__c = TestUtility.currentSystemDate.addDays(1);
        application.genesis__Expected_Start_Date__c = TestUtility.currentSystemDate;
        application.genesis__Expected_First_Payment_Date__c = TestUtility.currentSystemDate.addDays(10);
        application.genesis__Maturity_Date__c = TestUtility.currentSystemDate.addMonths(12);
        application.genesis__Loan_Amount__c = 10000;
        application.genesis__Other_Financed_fees__c = 0;
        application.genesis__Payment_Frequency__c = 'WEEKLY';
        application.genesis__Product_Type__c = 'LOAN';
        application.genesis__Sales_Division__c = 'DIRECT';
        application.genesis__Status__c = Applications.STATUS_NEW_ENTERED;
        application.SIC_Code__c = '073';
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.Primary_Guarantor__c = TestUtility.getFakeId(Contact.getSObjectType());
        application.genesis__Account__c = TestUtility.getFakeId(Account.getSObjectType());

        Account accountRecord = new Account();
        accountRecord.Id = application.genesis__Account__c;
        accountRecord.Legacy_Active_Contract__c = true;

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {accountRecord};
        ApplicationTriggerHandler.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        ApplicationTriggerHandler applicationTriggerHandlerInstance = new ApplicationTriggerHandler();

        Test.startTest();
            applicationTriggerHandlerInstance.beforeInsert(new List<genesis__Applications__c> {application});
        Test.stopTest();

        System.assertEquals(application.genesis__Loan_Amount__c, application.genesis__Requested_Loan_Amount__c);
    }

    @isTest
    private static void afterInsert() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>();
        clcommon__Document_Definition__c documentDefinition = new clcommon__Document_Definition__c();
        documentDefinition.Id = TestUtility.getFakeId(clcommon__Document_Definition__c.getSObjectType());
        documentDefinition.Name = 'Bank Statements';
        documentDefinition.clcommon__Show_In_Portal__c = 'DELIVERED';
        documentDefinition.clcommon__Active__c = true;
        documentDefinition.Document_Category__c = 'Application';

        genesis__Applications__c newApplication = new genesis__Applications__c();
        newApplication.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        newApplication.genesis__Expected_Close_Date__c = TestUtility.currentSystemDate.addDays(1);
        newApplication.genesis__Expected_Start_Date__c = TestUtility.currentSystemDate;
        newApplication.genesis__Expected_First_Payment_Date__c = TestUtility.currentSystemDate.addDays(10);
        newApplication.genesis__Maturity_Date__c = TestUtility.currentSystemDate.addMonths(12);
        newApplication.genesis__Loan_Amount__c = 10000;
        newApplication.genesis__Other_Financed_fees__c = 0;
        newApplication.genesis__Payment_Frequency__c = 'WEEKLY';
        newApplication.genesis__Product_Type__c = 'LOAN';
        newApplication.genesis__Sales_Division__c = 'DIRECT';
        newApplication.genesis__Status__c = Applications.STATUS_NEW_ENTERED;
        newApplication.SIC_Code__c = '073';
        newApplication.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        newApplication.Primary_Guarantor__c = TestUtility.getFakeId(Contact.getSObjectType());
        newApplication.genesis__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        newApplication.Opportunity__c = TestUtility.getFakeId(Opportunity.getSObjectType());

        Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.Id = newApplication.Opportunity__c;
        opportunityRecord.StageName = 'App Submitted';
        opportunityRecord.Sub_Status__c = 'Bank Statement Processing';

        applicationMap.put(newApplication.Id, newApplication);

        OriginationHelper.documentDefinitionList = new List<clcommon__Document_Definition__c> {documentDefinition};

        ApplicationTriggerHandler applicationTriggerHandlerInstance = new ApplicationTriggerHandler();

        DBManagerTestsStub opportunityDBInstanceStubInstance = new DBManagerTestsStub();
        opportunityDBInstanceStubInstance.genericReturnObject = new List<Opportunity> {opportunityRecord};
        ApplicationTriggerHandler.opportunityDBInstance = (OpportunityDB) Test.createStub(OpportunityDB.class, opportunityDBInstanceStubInstance);

        DBManagerTestsStub stipsChecklistDBStubInstance = new DBManagerTestsStub();
        ApplicationTriggerHandler.stipsChecklistDBInstance = (STIPSChecklistDB) Test.createStub(STIPSChecklistDB.class, stipsChecklistDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        ApplicationTriggerHandler.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub documentCategoryDBStubInstance = new DBManagerTestsStub();
        ApplicationTriggerHandler.documentCategoryDBInstance = (DocumentCategoryDB) Test.createStub(DocumentCategoryDB.class, documentCategoryDBStubInstance);

        Test.startTest();
            applicationTriggerHandlerInstance.afterInsert(applicationMap);
        Test.stopTest();
        System.assertEquals(1, documentCategoryDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void beforeUpdate() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Map<Id, genesis__Applications__c> newApplicationMap = new Map<Id, genesis__Applications__c>();
        Map<Id, genesis__Applications__c> oldApplicationMap = new Map<Id, genesis__Applications__c>();

        genesis__Applications__c newApplication = new genesis__Applications__c();
        newApplication.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        newApplication.genesis__Loan_Amount__c = 10000;
        newApplication.genesis__Other_Financed_fees__c = 0;
        newApplication.genesis__Payment_Frequency__c = 'WEEKLY';
        newApplication.genesis__Product_Type__c = 'LOAN';
        newApplication.genesis__Sales_Division__c = 'DIRECT';
        newApplication.genesis__Status__c = Applications.STATUS_GUARANTOR_CREDIT_CHECK;
        newApplication.SIC_Code__c = '073';
        newApplication.Business_Start_Date__c = TestUtility.currentSystemDate;
        newApplication.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        newApplication.Primary_Guarantor__c = TestUtility.getFakeId(Contact.getSObjectType());
        newApplication.genesis__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        newApplication.Opportunity__c = TestUtility.getFakeId(Opportunity.getSObjectType());
        newApplication.Credit_Check_Consent__c = true;
        newApplication.Partner_Pricing_Secure_Link__c = 'www.example.com';

        newApplicationMap.put(newApplication.Id, newApplication);

        genesis__Applications__c oldApplication = new genesis__Applications__c();
        oldApplication.Id = newApplication.Id;
        oldApplication.genesis__Loan_Amount__c = 10000;
        oldApplication.genesis__Other_Financed_fees__c = 0;
        oldApplication.genesis__Payment_Frequency__c = 'DAILY';
        oldApplication.genesis__Product_Type__c = 'LOAN';
        oldApplication.genesis__Sales_Division__c = 'DIRECT';
        oldApplication.genesis__Status__c = Applications.STATUS_NEW_ENTERED;
        oldApplication.SIC_Code__c = '073';
        oldApplication.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        oldApplication.Primary_Guarantor__c = newApplication.Primary_Guarantor__c;
        oldApplication.genesis__Account__c = newApplication.genesis__Account__c;
        oldApplication.Credit_Check_Consent__c = false;
        oldApplication.Business_Start_Date__c = TestUtility.currentSystemDate;

        oldApplicationMap.put(oldApplication.Id, oldApplication);

        Account accountRecord = new Account();
        accountRecord.Id = newApplication.genesis__Account__c;
        accountRecord.Legacy_Negative_CAN_History__c = false;

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {accountRecord};
        BusinessRuleManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub underWriterTaskDBStubInstance = new DBManagerTestsStub();
        UnderWriterTaskManager.underWriterTaskDBInstance = (UnderWriterTaskDB) Test.createStub(UnderWriterTaskDB.class, underWriterTaskDBStubInstance);

        ApplicationTriggerHandler applicationTriggerHandlerInstance = new ApplicationTriggerHandler();

        Test.startTest();
            applicationTriggerHandlerInstance.beforeUpdate(newApplicationMap, oldApplicationMap);
        Test.stopTest();

        System.assertEquals(true, newApplication.Credit_Check_Consent__c);
    }

    @isTest
    private static void beforeUpdateSetConcurrentFieldOnLoanAmountChange() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Map<Id, genesis__Applications__c> newApplicationMap = new Map<Id, genesis__Applications__c>();
        Map<Id, genesis__Applications__c> oldApplicationMap = new Map<Id, genesis__Applications__c>();

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{"Max_Broker_Commission__c" : 10, "Origination_Fee_Amount__c" : "299", "Business_Type__c" : "Sole Proprietorship", ' +
                '"Time_In_Business__c" : "1"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Loan_Amount__c = 10000;
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        application.genesis__Product_Type__c = GeneralConstants.PRODUCT_TYPE_LOAN;
        application.genesis__Expected_Close_Date__c = TestUtility.currentSystemDate.addDays(1);
        application.genesis__Expected_Start_Date__c = TestUtility.currentSystemDate;
        application.genesis__Expected_First_Payment_Date__c = TestUtility.currentSystemDate.addDays(10);
        application.genesis__Maturity_Date__c = TestUtility.currentSystemDate.addMonths(12);
        application.genesis__Term__c = 12;
        application.SIC_Code__c = '073';
        application.Maximum_Funding_Amount__c = 12000;
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.Total_Repayment_Amount__c = 12500;
        application.genesis__Requested_Loan_Amount__c = 1009;
        application.Pricing_Factor__c = 1.33;
        application.Type__c = GeneralConstants.LOAN_TYPE_CONCURRENT;
        application.Partner_Pricing_Secure_Link__c = 'www.example.com';
        newApplicationMap.put(application.Id, application);

        loan__Loan_Account__c contract = (loan__Loan_Account__c) JSON.deserialize(
            '{"Remaining_Number_of_Payments__c" : 10}' , loan__Loan_Account__c.class
        );
        contract.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        contract.loan__Disbursed_Amount__c = 1000;
        contract.loan__Interest_Rate__c = 33;
        contract.Application__c = application.Id;
        contract.Application__r = application;
        contract.loan__Loan_Amount__c = 10000;
        contract.loan__Payment_Amount__c = 860.52;
        application.Renewal_Concurrent_LoanAccount__c = contract.Id;

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{contract};
        ApplicationManager.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        LoanCalculatorManagerTestStub loanCalculatorManagerTestStubInstance = new LoanCalculatorManagerTestStub();
        Applications.loanCalculatorManagerInstance = (LoanCalculatorManager) Test.createStub(
            LoanCalculatorManager.class, loanCalculatorManagerTestStubInstance
        );

        genesis__Applications__c oldApplication = new genesis__Applications__c();
        oldApplication.Id = application.Id;
        oldApplication.genesis__Loan_Amount__c = 15000;
        oldApplicationMap.put(oldApplication.Id, oldApplication);

        ApplicationTriggerHandler applicationTriggerHandlerInstance = new ApplicationTriggerHandler();

        Test.startTest();
            applicationTriggerHandlerInstance.beforeUpdate(newApplicationMap, oldApplicationMap);
        Test.stopTest();

        System.assertEquals(contract.loan__Disbursed_Amount__c + application.genesis__Loan_Amount__c, application.Concurrent_Principal_Amount__c);
    }

    @isTest
    private static void afterUpdate() {
        Map<Id, genesis__Applications__c> newApplicationMap = new Map<Id, genesis__Applications__c>();
        Map<Id, genesis__Applications__c> oldApplicationMap = new Map<Id, genesis__Applications__c>();
        genesis__Applications__c newApplication = new genesis__Applications__c();
        newApplication.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        newApplication.genesis__Expected_Close_Date__c = TestUtility.currentSystemDate.addDays(1);
        newApplication.genesis__Expected_Start_Date__c = TestUtility.currentSystemDate;
        newApplication.genesis__Expected_First_Payment_Date__c = TestUtility.currentSystemDate.addDays(10);
        newApplication.genesis__Maturity_Date__c = TestUtility.currentSystemDate.addMonths(12);
        newApplication.genesis__Loan_Amount__c = 10000;
        newApplication.genesis__Other_Financed_fees__c = 0;
        newApplication.genesis__Payment_Frequency__c = 'WEEKLY';
        newApplication.genesis__Product_Type__c = 'LOAN';
        newApplication.genesis__Sales_Division__c = 'DIRECT';
        newApplication.genesis__Status__c = Applications.STATUS_NEW_ENTERED;
        newApplication.SIC_Code__c = '073';
        newApplication.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        newApplication.Primary_Guarantor__c = TestUtility.getFakeId(Contact.getSObjectType());
        newApplication.genesis__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        newApplication.Opportunity__c = TestUtility.getFakeId(Opportunity.getSObjectType());
        newApplication.Sales_Rep__c = TestUtility.getFakeId(User.getSObjectType());
        newApplication.Confirmed_Fraud_Flag__c = true;

        newApplicationMap.put(newApplication.Id, newApplication);

        genesis__Applications__c oldApplication = new genesis__Applications__c();
        oldApplication.Id = newApplication.Id;
        oldApplication.genesis__Expected_Close_Date__c = TestUtility.currentSystemDate.addDays(1);
        oldApplication.genesis__Expected_Start_Date__c = TestUtility.currentSystemDate;
        oldApplication.genesis__Expected_First_Payment_Date__c = TestUtility.currentSystemDate.addDays(10);
        oldApplication.genesis__Maturity_Date__c = TestUtility.currentSystemDate.addMonths(12);
        oldApplication.genesis__Loan_Amount__c = 10000;
        oldApplication.genesis__Other_Financed_fees__c = 0;
        oldApplication.genesis__Payment_Frequency__c = 'WEEKLY';
        oldApplication.genesis__Product_Type__c = 'LOAN';
        oldApplication.genesis__Sales_Division__c = 'DIRECT';
        oldApplication.genesis__Status__c = Applications.STATUS_CAN_SCORING;
        oldApplication.SIC_Code__c = '073';
        oldApplication.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        oldApplication.Primary_Guarantor__c = newApplication.Primary_Guarantor__c;
        oldApplication.genesis__Account__c = newApplication.genesis__Account__c;
        oldApplication.Sales_Rep__c = TestUtility.getFakeId(User.getSObjectType());

        oldApplicationMap.put(oldApplication.Id, oldApplication);

        Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.Id = newApplication.Opportunity__c;
        opportunityRecord.StageName = 'App Submitted';
        opportunityRecord.Sub_Status__c = 'Bank Statement Processing';

        DBManagerTestsStub opportunityDBInstanceStubInstance = new DBManagerTestsStub();
        opportunityDBInstanceStubInstance.genericReturnObject = new List<Opportunity> {opportunityRecord};
        ApplicationTriggerHandler.opportunityDBInstance = (OpportunityDB) Test.createStub(OpportunityDB.class, opportunityDBInstanceStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        ApplicationTriggerHandler.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        ApplicationTriggerHandler applicationTriggerHandlerInstance = new ApplicationTriggerHandler();

        Test.startTest();
            applicationTriggerHandlerInstance.afterUpdate(newApplicationMap, oldApplicationMap);
        Test.stopTest();

        System.assertEquals(1, opportunityDBInstanceStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void beforeUpdateCreditCheck() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Map<Id, genesis__Applications__c> newApplicationMap = new Map<Id, genesis__Applications__c>();
        Map<Id, genesis__Applications__c> oldApplicationMap = new Map<Id, genesis__Applications__c>();

        genesis__Applications__c newApplication = new genesis__Applications__c();
        newApplication.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        newApplication.genesis__Status__c = Applications.STATUS_GUARANTOR_CREDIT_CHECK;
        newApplication.Partner_Pricing_Secure_Link__c = 'www.example.com';

        newApplicationMap.put(newApplication.Id, newApplication);

        genesis__Applications__c oldApplication = new genesis__Applications__c();
        oldApplication.Id = newApplication.Id;
        oldApplication.genesis__Status__c = Applications.STATUS_NEW_ENTERED;
        oldApplication.Credit_Check_Consent__c = false;

        oldApplicationMap.put(oldApplication.Id, oldApplication);

        ApplicationTriggerHandler applicationTriggerHandlerInstance = new ApplicationTriggerHandler();
        Exception ex;

        Test.startTest();
            try {
                applicationTriggerHandlerInstance.beforeUpdate(newApplicationMap, oldApplicationMap);
            }
            catch(Exception e){
                ex = e;
            }
        Test.stopTest();

        System.assert(ex.getMessage().contains('Credit Consent is not Checked'));
    }
}