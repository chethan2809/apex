@isTest
private class CommissionCalculationUtilTests {

    @isTest
    private static void getInstanceTestMethod(){

        Test.startTest();
            CommissionCalculationUtil obj = CommissionCalculationUtil.getInstance();
        Test.stopTest();

        System.assert(obj != Null);
    }

    @isTest
    private static void calculateCommission(){

        Account acc = new Account();
        acc.loan__Broker__c = true;
        acc.Is_Broker_Active__c = true;
        acc.Commission_Eligible__c = true;
        acc.Commision_Based_On__c = Brokers.COMMISSION_CALC_METHOD_PERCENTAGE;
        acc.Default_Broker_Commission__c = 8;
        acc.New_Max_Broker_Commission__c = 10;
        acc.Total_Clawback_Amount__c = 100;
        acc.Id = TestUtility.getFakeId(Account.getSObjectType());

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{acc};
        CommissionCalculationUtil.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Contact con = new Contact();
        con.Id = TestUtility.getFakeId(Contact.getSObjectType());
        con.AccountId = acc.id;
        con.Account = acc;

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact>{con};
        CommissionCalculationUtil.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        loan__Loan_Account__c contract = new loan__Loan_Account__c();
        contract.Type__c = 'New';
        contract.loan__Loan_Amount__c = 10000;
        contract.loan__Expected_Repayment_Start_Date__c = Date.today();
        contract.Broker_Contact__c = con.Id;
        contract.id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        contract.loan__Funding_in_Tranches__c = true;
        contract.loan__Account__c = acc.Id;

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{contract};
        CommissionCalculationUtil.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        loan__Payment_Mode__c paymentModeId = new loan__Payment_Mode__c();
        paymentModeId.Id = TestUtility.getFakeId(loan__Payment_Mode__c.getSObjectType());

        loan__Commission_Plan__c commissionPlan = new loan__Commission_Plan__c();
        commissionPlan.Id = TestUtility.getFakeId(loan__Commission_Plan__c.getSObjectType());

        DBManagerTestsStub commissionPlanDBStubInstance = new DBManagerTestsStub();
        commissionPlanDBStubInstance.genericReturnObject = new List<loan__Commission_Plan__c>{commissionPlan};
        ServicingHelper.commissionPlanDBInstance = (CommissionPlanDB) Test.createStub(CommissionPlanDB.class, commissionPlanDBStubInstance);

        loan__Loan_Disbursal_Transaction__c disbursalTransaction = new loan__Loan_Disbursal_Transaction__c();
        disbursalTransaction.loan__Loan_Account__c = contract.id;
        disbursalTransaction.loan__Disbursal_Date__c = Date.today();
        disbursalTransaction.loan__Disbursed_Amt__c = contract.loan__Loan_Amount__c;
        disbursalTransaction.loan__Mode_of_Payment__c = paymentModeId.Id;
        disbursalTransaction.Id = TestUtility.getFakeId(loan__Loan_Disbursal_Transaction__c.getSObjectType());
        disbursalTransaction.loan__Loan_Account__r  = contract;

        DBManagerTestsStub disbursalTransactionDBStubInstance = new DBManagerTestsStub();
        disbursalTransactionDBStubInstance.genericReturnObject = new List<loan__Loan_Disbursal_Transaction__c>{disbursalTransaction};
        BrokerManager.disbursalTransactionDBInstance = (LoanDisbursalTransactionsDB) Test.createStub(LoanDisbursalTransactionsDB.class, disbursalTransactionDBStubInstance);

        list<loan__Broker__c> brokerList = new list<loan__Broker__c>();
        loan__Broker__c broker = new loan__Broker__c();
        broker.loan__Account__c = acc.Id;
        broker.loan__Contact__c = con.Id;
        broker.loan__Commission_Plan__c = commissionPlan.Id;
        broker.loan__Calculation_Method__c = acc.Commision_Based_On__c;
        broker.loan__Lending_Account__c = contract.Id;
        broker.loan__Lending_Account__r = contract;
        broker.Disbursal_Transaction__c = disbursalTransaction.Id;
        broker.Disbursal_Transaction__r = disbursalTransaction;
        broker.Id = TestUtility.getFakeId(loan__Broker__c.getSObjectType());
        brokerList.add(broker);

        DBManagerTestsStub brokerDBStubInstance = new DBManagerTestsStub();
        brokerDBStubInstance.genericReturnObject = brokerList;
        CommissionCalculationUtil.brokerDBInstance = (BrokerDB) Test.createStub(BrokerDB.class, brokerDBStubInstance);

        Test.startTest();
            acc.Commission_Eligible__c = false;
            new CommissionCalculationUtil().calculateCommission(brokerList);

            acc.Commission_Eligible__c = true;
            acc.Is_Broker_Active__c = false;
            new CommissionCalculationUtil().calculateCommission(brokerList);

            acc.Is_Broker_Active__c = true;
            new CommissionCalculationUtil().calculateCommission(brokerList);

            contract.loan__Closed_Date__c = Date.today().addDays(-100);
            contract.loan__Loan_Status__c = 'Closed - Premature';
            new CommissionCalculationUtil().calculateCommission(brokerList);

            contract.loan__Closed_Date__c = Date.today().addDays(-30);
            new CommissionCalculationUtil().calculateCommission(brokerList);

            acc.Default_Broker_Commission__c = 11;
            new CommissionCalculationUtil().calculateCommission(brokerList);

            acc.Commision_Based_On__c = Brokers.COMMISSION_CALC_METHOD_FLAT;
            new CommissionCalculationUtil().calculateCommission(brokerList);

            acc.Total_Clawback_Amount__c = 30;
            broker.Flat_Referral_Fee__c = 50;
            new CommissionCalculationUtil().calculateCommission(new List<loan__Broker__c>{broker});
        Test.stopTest();

        System.assertEquals('New', contract.Type__c);
        System.assertEquals(true, acc.Is_Broker_Active__c);
    }

    @isTest
    private static void calculateCommissionTestMethod2(){

        Account acc = new Account();
        acc.loan__Broker__c = true;
        acc.Is_Broker_Active__c = true;
        acc.Commission_Eligible__c = true;
        acc.Commision_Based_On__c = Brokers.COMMISSION_CALC_METHOD_PERCENTAGE;
        acc.Default_Broker_Commission__c = 8;
        acc.New_Max_Broker_Commission__c = 10;
        acc.Total_Clawback_Amount__c = 100;
        acc.Id = TestUtility.getFakeId(Account.getSObjectType());

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{acc};
        CommissionCalculationUtil.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Contact con = new Contact();
        con.Id = TestUtility.getFakeId(Contact.getSObjectType());
        con.AccountId = acc.id;
        con.Account = acc;

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact>{con};
        CommissionCalculationUtil.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        loan__Loan_Account__c contract = new loan__Loan_Account__c();
        contract.Type__c = 'New';
        contract.loan__Loan_Amount__c = 10000;
        contract.loan__Expected_Repayment_Start_Date__c = Date.today();
        contract.Broker_Contact__c = con.Id;
        contract.id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        contract.loan__Funding_in_Tranches__c = true;
        contract.loan__Account__c = acc.Id;

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{contract};
        CommissionCalculationUtil.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        loan__Payment_Mode__c paymentModeId = new loan__Payment_Mode__c();
        paymentModeId.Id = TestUtility.getFakeId(loan__Payment_Mode__c.getSObjectType());

        loan__Commission_Plan__c commissionPlan = new loan__Commission_Plan__c();
        commissionPlan.Id = TestUtility.getFakeId(loan__Commission_Plan__c.getSObjectType());

        DBManagerTestsStub commissionPlanDBStubInstance = new DBManagerTestsStub();
        commissionPlanDBStubInstance.genericReturnObject = new List<loan__Commission_Plan__c>{commissionPlan};
        ServicingHelper.commissionPlanDBInstance = (CommissionPlanDB) Test.createStub(CommissionPlanDB.class, commissionPlanDBStubInstance);

        loan__Loan_Disbursal_Transaction__c disbursalTransaction = new loan__Loan_Disbursal_Transaction__c();
        disbursalTransaction.loan__Loan_Account__c = contract.id;
        disbursalTransaction.loan__Disbursal_Date__c = Date.today();
        disbursalTransaction.loan__Disbursed_Amt__c = contract.loan__Loan_Amount__c;
        disbursalTransaction.loan__Mode_of_Payment__c = paymentModeId.Id;
        disbursalTransaction.Id = TestUtility.getFakeId(loan__Loan_Disbursal_Transaction__c.getSObjectType());
        disbursalTransaction.loan__Loan_Account__r  = contract;

        DBManagerTestsStub disbursalTransactionDBStubInstance = new DBManagerTestsStub();
        disbursalTransactionDBStubInstance.genericReturnObject = new List<loan__Loan_Disbursal_Transaction__c>{disbursalTransaction};
        BrokerManager.disbursalTransactionDBInstance = (LoanDisbursalTransactionsDB) Test.createStub(LoanDisbursalTransactionsDB.class, disbursalTransactionDBStubInstance);

        list<loan__Broker__c> brokerList = new list<loan__Broker__c>();
        loan__Broker__c broker = new loan__Broker__c();
        broker.loan__Account__c = acc.Id;
        broker.loan__Contact__c = con.Id;
        broker.loan__Commission_Plan__c = commissionPlan.Id;
        broker.loan__Calculation_Method__c = acc.Commision_Based_On__c;
        broker.loan__Lending_Account__c = contract.Id;
        broker.loan__Lending_Account__r = contract;
        broker.Disbursal_Transaction__c = disbursalTransaction.Id;
        broker.Disbursal_Transaction__r = disbursalTransaction;
        broker.Id = TestUtility.getFakeId(loan__Broker__c.getSObjectType());
        brokerList.add(broker);

        DBManagerTestsStub brokerDBStubInstance = new DBManagerTestsStub();
        brokerDBStubInstance.genericReturnObject = brokerList;
        CommissionCalculationUtil.brokerDBInstance = (BrokerDB) Test.createStub(BrokerDB.class, brokerDBStubInstance);

        Test.startTest();
            new CommissionCalculationUtil().calculateCommission(brokerList);

            broker.Flat_Referral_Fee__c = 0;
            broker.Commission_Point__c = 5;
            new CommissionCalculationUtil().calculateCommission(new List<loan__Broker__c>{broker});
        Test.stopTest();

        System.assertEquals(0, broker.Flat_Referral_Fee__c);
        System.assertEquals(10000,contract.loan__Loan_Amount__c);
    }

    @isTest
    private static void calculateRenewalTypeCommission(){

        Account acc = new Account();
        acc.loan__Broker__c = true;
        acc.Is_Broker_Active__c = true;
        acc.Commission_Eligible__c = true;
        acc.Commision_Based_On__c = Brokers.COMMISSION_CALC_METHOD_PERCENTAGE;
        acc.Default_Broker_Commission__c = 8;
        acc.New_Max_Broker_Commission__c = 10;
        acc.Total_Clawback_Amount__c = 100;
        acc.Renewal_Amount_Commission__c = 'Gross Amount';
        acc.Is_Flat_Renewal__c = true;
        acc.Flat_Renewal_Commission__c = 100;
        acc.Id = TestUtility.getFakeId(Account.getSObjectType());

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{acc};
        CommissionCalculationUtil.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Contact con = new Contact();
        con.Id = TestUtility.getFakeId(Contact.getSObjectType());
        con.AccountId = acc.id;
        con.Account = acc;

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact>{con};
        CommissionCalculationUtil.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        loan__Loan_Account__c contract = new loan__Loan_Account__c();
        contract.Type__c = 'RENEWAL';
        contract.loan__Loan_Amount__c = 10000;
        contract.loan__Expected_Repayment_Start_Date__c = Date.today();
        contract.Broker_Contact__c = con.Id;
        contract.id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        contract.loan__Funding_in_Tranches__c = true;
        contract.loan__Account__c = acc.Id;

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{contract};
        CommissionCalculationUtil.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        loan__Payment_Mode__c paymentModeId = new loan__Payment_Mode__c();
        paymentModeId.Id = TestUtility.getFakeId(loan__Payment_Mode__c.getSObjectType());

        loan__Commission_Plan__c commissionPlan = new loan__Commission_Plan__c();
        commissionPlan.Id = TestUtility.getFakeId(loan__Commission_Plan__c.getSObjectType());

        DBManagerTestsStub commissionPlanDBStubInstance = new DBManagerTestsStub();
        commissionPlanDBStubInstance.genericReturnObject = new List<loan__Commission_Plan__c>{commissionPlan};
        ServicingHelper.commissionPlanDBInstance = (CommissionPlanDB) Test.createStub(CommissionPlanDB.class, commissionPlanDBStubInstance);

        loan__Loan_Disbursal_Transaction__c disbursalTransaction = new loan__Loan_Disbursal_Transaction__c();
        disbursalTransaction.loan__Loan_Account__c = contract.id;
        disbursalTransaction.loan__Disbursal_Date__c = Date.today();
        disbursalTransaction.loan__Disbursed_Amt__c = contract.loan__Loan_Amount__c;
        disbursalTransaction.loan__Mode_of_Payment__c = paymentModeId.Id;
        disbursalTransaction.Id = TestUtility.getFakeId(loan__Loan_Disbursal_Transaction__c.getSObjectType());
        disbursalTransaction.loan__Loan_Account__r  = contract;

        DBManagerTestsStub disbursalTransactionDBStubInstance = new DBManagerTestsStub();
        disbursalTransactionDBStubInstance.genericReturnObject = new List<loan__Loan_Disbursal_Transaction__c>{disbursalTransaction};
        BrokerManager.disbursalTransactionDBInstance = (LoanDisbursalTransactionsDB) Test.createStub(LoanDisbursalTransactionsDB.class, disbursalTransactionDBStubInstance);

        list<loan__Broker__c> brokerList = new list<loan__Broker__c>();
        loan__Broker__c broker = new loan__Broker__c();
        broker.loan__Account__c = acc.Id;
        broker.loan__Contact__c = con.Id;
        broker.loan__Commission_Plan__c = commissionPlan.Id;
        broker.loan__Calculation_Method__c = acc.Commision_Based_On__c;
        broker.loan__Lending_Account__c = contract.Id;
        broker.loan__Lending_Account__r = contract;
        broker.Disbursal_Transaction__c = disbursalTransaction.Id;
        broker.Disbursal_Transaction__r = disbursalTransaction;
        broker.Id = TestUtility.getFakeId(loan__Broker__c.getSObjectType());
        broker.Flat_Referral_Fee__c = 100;
        brokerList.add(broker);

        DBManagerTestsStub brokerDBStubInstance = new DBManagerTestsStub();
        brokerDBStubInstance.genericReturnObject = brokerList;
        CommissionCalculationUtil.brokerDBInstance = (BrokerDB) Test.createStub(BrokerDB.class, brokerDBStubInstance);

        Test.startTest();
            new CommissionCalculationUtil().calculateCommission(brokerList);

            broker.Flat_Referral_Fee__c = 0;
            broker.Commission_Point__c = 5;
            new CommissionCalculationUtil().calculateCommission(new List<loan__Broker__c>{broker});

            acc.Renewal_Amount_Commission__c = 'Net Amount';
            new CommissionCalculationUtil().calculateCommission(new List<loan__Broker__c>{broker});

            acc.Renewal_Amount_Commission__c = '';
            new CommissionCalculationUtil().calculateCommission(new List<loan__Broker__c>{broker});

            acc.Is_Flat_Renewal__c = false;
            new CommissionCalculationUtil().calculateCommission(new List<loan__Broker__c>{broker});
        Test.stopTest();

        System.assertEquals('RENEWAL', contract.Type__c);
        System.assertEquals(false, acc.Is_Flat_Renewal__c);
    }

    @isTest
    private static void calculateConcurrentTypeCommission(){

        Account acc = new Account();
        acc.loan__Broker__c = true;
        acc.Is_Broker_Active__c = true;
        acc.Commission_Eligible__c = true;
        acc.Commision_Based_On__c = Brokers.COMMISSION_CALC_METHOD_PERCENTAGE;
        acc.Default_Broker_Commission__c = 8;
        acc.New_Max_Broker_Commission__c = 10;
        acc.Total_Clawback_Amount__c = 100;
        acc.Id = TestUtility.getFakeId(Account.getSObjectType());

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{acc};
        CommissionCalculationUtil.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Contact con = new Contact();
        con.Id = TestUtility.getFakeId(Contact.getSObjectType());
        con.AccountId = acc.id;
        con.Account = acc;

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact>{con};
        CommissionCalculationUtil.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        loan__Loan_Account__c contract = new loan__Loan_Account__c();
        contract.Type__c = 'New';
        contract.loan__Loan_Amount__c = 10000;
        contract.loan__Expected_Repayment_Start_Date__c = Date.today();
        contract.Broker_Contact__c = con.Id;
        contract.id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        contract.loan__Funding_in_Tranches__c = true;
        contract.loan__Account__c = acc.Id;
        contract.Broker_Standard_Commission__c = 6;

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{contract};
        CommissionCalculationUtil.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        loan__Payment_Mode__c paymentModeId = new loan__Payment_Mode__c();
        paymentModeId.Id = TestUtility.getFakeId(loan__Payment_Mode__c.getSObjectType());

        loan__Commission_Plan__c commissionPlan = new loan__Commission_Plan__c();
        commissionPlan.Id = TestUtility.getFakeId(loan__Commission_Plan__c.getSObjectType());

        DBManagerTestsStub commissionPlanDBStubInstance = new DBManagerTestsStub();
        commissionPlanDBStubInstance.genericReturnObject = new List<loan__Commission_Plan__c>{commissionPlan};
        ServicingHelper.commissionPlanDBInstance = (CommissionPlanDB) Test.createStub(CommissionPlanDB.class, commissionPlanDBStubInstance);

        loan__Loan_Disbursal_Transaction__c disbursalTransaction1 = new loan__Loan_Disbursal_Transaction__c();
        disbursalTransaction1.loan__Loan_Account__c = contract.id;
        disbursalTransaction1.loan__Disbursal_Date__c = system.today();
        disbursalTransaction1.loan__Disbursed_Amt__c = 3000;
        disbursalTransaction1.loan__Mode_of_Payment__c = paymentModeId.id;
        disbursalTransaction1.loan__Loan_Account__r  = contract;
        disbursalTransaction1.Id = TestUtility.getFakeId(loan__Loan_Disbursal_Transaction__c.getSObjectType());

        loan__Loan_Disbursal_Transaction__c disbursalTransaction2 = new loan__Loan_Disbursal_Transaction__c();
        disbursalTransaction2.loan__Loan_Account__c = contract.id;
        disbursalTransaction2.loan__Disbursal_Date__c = system.today();
        disbursalTransaction2.loan__Disbursed_Amt__c = 3000;
        disbursalTransaction2.loan__Mode_of_Payment__c = paymentModeId.Id;
        disbursalTransaction2.loan__Loan_Account__r  = contract;
        disbursalTransaction2.Id = TestUtility.getFakeId(loan__Loan_Disbursal_Transaction__c.getSObjectType());

        DBManagerTestsStub disbursalTransactionDBStubInstance = new DBManagerTestsStub();
        disbursalTransactionDBStubInstance.genericReturnObject = new List<loan__Loan_Disbursal_Transaction__c>{disbursalTransaction1,disbursalTransaction2};
        CommissionCalculationUtil.disbursalTransactionDBInstance = (LoanDisbursalTransactionsDB) Test.createStub(LoanDisbursalTransactionsDB.class, disbursalTransactionDBStubInstance);

        List<loan__Broker__c> brokerList = new List<loan__Broker__c>();
        loan__Broker__c broker1 = new loan__Broker__c();
        broker1.loan__Account__c = acc.id;
        broker1.loan__Contact__c = contract.Broker_Contact__c;
        broker1.loan__Commission_Plan__c = commissionPlan.Id;
        broker1.loan__Calculation_Method__c = acc.Commision_Based_On__c;
        broker1.loan__Lending_Account__c = disbursalTransaction1.loan__Loan_Account__c;
        broker1.Disbursal_Transaction__c = disbursalTransaction1.id;
        broker1.Flat_Referral_Fee__c = 100;
        brokerList.add(broker1);

        loan__Broker__c broker2 = new loan__Broker__c();
        broker2.loan__Account__c = acc.id;
        broker2.loan__Contact__c = contract.Broker_Contact__c;
        broker2.loan__Commission_Plan__c = commissionPlan.Id;
        broker2.loan__Calculation_Method__c = acc.Commision_Based_On__c;
        broker2.loan__Lending_Account__c = disbursalTransaction2.loan__Loan_Account__c;
        broker2.Disbursal_Transaction__c = disbursalTransaction2.id;
        broker2.Flat_Referral_Fee__c = 100;
        brokerList.add(broker2);

        DBManagerTestsStub brokerDBStubInstance = new DBManagerTestsStub();
        brokerDBStubInstance.genericReturnObject = brokerList;
        CommissionCalculationUtil.brokerDBInstance = (BrokerDB) Test.createStub(BrokerDB.class, brokerDBStubInstance);

        Test.startTest();
            broker1.Flat_Referral_Fee__c = 0;
            broker1.Commission_Point__c = 5;
            new CommissionCalculationUtil().calculateCommission(brokerList);
        Test.stopTest();

        System.assertEquals(2,brokerList.size());
        System.assertEquals('Broker Commission calculated Successfully.',broker1.Commission_Calculation_Message__c);
    }

    @isTest
    private static void commissionBasedOnField(){

        Account acc = new Account();
        acc.loan__Broker__c = true;
        acc.Is_Broker_Active__c = true;
        acc.Commission_Eligible__c = true;
        acc.Commision_Based_On__c = Brokers.COMMISSION_CALC_METHOD_PERCENTAGE;
        acc.Default_Broker_Commission__c = 8;
        acc.New_Max_Broker_Commission__c = 10;
        acc.Total_Clawback_Amount__c = 100;
        acc.Id = TestUtility.getFakeId(Account.getSObjectType());

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{acc};
        CommissionCalculationUtil.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Contact con = new Contact();
        con.Id = TestUtility.getFakeId(Contact.getSObjectType());
        con.AccountId = acc.id;
        con.Account = acc;

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact>{con};
        CommissionCalculationUtil.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        loan__Loan_Account__c contract = new loan__Loan_Account__c();
        contract.Type__c = 'New';
        contract.loan__Loan_Amount__c = 10000;
        contract.loan__Expected_Repayment_Start_Date__c = Date.today();
        contract.Broker_Contact__c = con.Id;
        contract.id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        contract.loan__Funding_in_Tranches__c = true;
        contract.loan__Account__c = acc.Id;
        contract.Broker_Standard_Commission__c = 6;
        contract.loan__Closed_Date__c = Date.today().addDays(-100);
        contract.loan__Loan_Status__c = 'Approved';

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{contract};
        CommissionCalculationUtil.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        loan__Payment_Mode__c paymentModeId = new loan__Payment_Mode__c();
        paymentModeId.Id = TestUtility.getFakeId(loan__Payment_Mode__c.getSObjectType());

        loan__Commission_Plan__c commissionPlan = new loan__Commission_Plan__c();
        commissionPlan.Id = TestUtility.getFakeId(loan__Commission_Plan__c.getSObjectType());

        DBManagerTestsStub commissionPlanDBStubInstance = new DBManagerTestsStub();
        commissionPlanDBStubInstance.genericReturnObject = new List<loan__Commission_Plan__c>{commissionPlan};
        ServicingHelper.commissionPlanDBInstance = (CommissionPlanDB) Test.createStub(CommissionPlanDB.class, commissionPlanDBStubInstance);

        loan__Loan_Disbursal_Transaction__c disbursalTransaction = new loan__Loan_Disbursal_Transaction__c();
        disbursalTransaction.loan__Loan_Account__c = contract.id;
        disbursalTransaction.loan__Disbursal_Date__c = system.today();
        disbursalTransaction.loan__Disbursed_Amt__c = contract.loan__Loan_Amount__c;
        disbursalTransaction.loan__Mode_of_Payment__c = paymentModeId.Id;
        disbursalTransaction.loan__Loan_Account__r  = contract;
        disbursalTransaction.Id = TestUtility.getFakeId(loan__Loan_Disbursal_Transaction__c.getSObjectType());

        DBManagerTestsStub disbursalTransactionDBStubInstance = new DBManagerTestsStub();
        disbursalTransactionDBStubInstance.genericReturnObject = new List<loan__Loan_Disbursal_Transaction__c>{disbursalTransaction};
        CommissionCalculationUtil.disbursalTransactionDBInstance = (LoanDisbursalTransactionsDB) Test.createStub(LoanDisbursalTransactionsDB.class, disbursalTransactionDBStubInstance);

        list<loan__Broker__c> brokerList = new list<loan__Broker__c>();
        loan__Broker__c broker = new loan__Broker__c();
        broker.loan__Account__c = acc.Id;
        broker.loan__Contact__c = con.Id;
        broker.loan__Commission_Plan__c = commissionPlan.Id;
        broker.loan__Calculation_Method__c = acc.Commision_Based_On__c;
        broker.loan__Lending_Account__c = contract.Id;
        broker.loan__Lending_Account__r = contract;
        broker.Disbursal_Transaction__c = disbursalTransaction.Id;
        broker.Disbursal_Transaction__r = disbursalTransaction;
        broker.Id = TestUtility.getFakeId(loan__Broker__c.getSObjectType());
        brokerList.add(broker);

        DBManagerTestsStub brokerDBStubInstance = new DBManagerTestsStub();
        brokerDBStubInstance.genericReturnObject = brokerList;
        CommissionCalculationUtil.brokerDBInstance = (BrokerDB) Test.createStub(BrokerDB.class, brokerDBStubInstance);

        Test.startTest();
            new CommissionCalculationUtil().calculateCommission(new List<loan__Broker__c>{broker});

            contract.Broker_Standard_Commission__c = null;
            new CommissionCalculationUtil().calculateCommission(new List<loan__Broker__c>{broker});

            acc.Commission_Eligible__c = false;
            new CommissionCalculationUtil().calculateCommission(new List<loan__Broker__c>{broker});

            acc.Commission_Eligible__c = true;
            acc.Is_Broker_Active__c = false;
            new CommissionCalculationUtil().calculateCommission(new List<loan__Broker__c>{broker});

            acc.Is_Broker_Active__c = true;
            new CommissionCalculationUtil().calculateCommission(new List<loan__Broker__c>{broker});

            contract.loan__Loan_Status__c = 'Closed - Premature';
            new CommissionCalculationUtil().calculateCommission(new List<loan__Broker__c>{broker});

            contract.loan__Closed_Date__c = Date.today().addDays(-30);
            new CommissionCalculationUtil().calculateCommission(new List<loan__Broker__c>{broker});

            acc.Default_Broker_Commission__c = 11;
            new CommissionCalculationUtil().calculateCommission(new List<loan__Broker__c>{broker});

            acc.Commision_Based_On__c = Brokers.COMMISSION_CALC_METHOD_FLAT;
            new CommissionCalculationUtil().calculateCommission(new List<loan__Broker__c>{broker});
        Test.stopTest();

        System.assertEquals('Closed - Premature',contract.loan__Loan_Status__c);
        System.assertEquals('Flat Referral Fee updated Successfully.',broker.Commission_Calculation_Message__c);
        System.assertEquals(11,acc.Default_Broker_Commission__c);
    }
}