@isTest
private class BrokerManagerTests {

    @isTest
    private static void createBrokerAndCalculateCommission(){

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
        BrokerManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Contact con = new Contact();
        con.Id = TestUtility.getFakeId(Contact.getSObjectType());
        con.AccountId = acc.id;
        con.Account = acc;

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact>{con};
        BrokerManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

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
        BrokerManager.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        loan__Payment_Mode__c paymentModeId = new loan__Payment_Mode__c();
        paymentModeId.Id = TestUtility.getFakeId(loan__Payment_Mode__c.getSObjectType());

        loan__Loan_Disbursal_Transaction__c disbursalTransaction = new loan__Loan_Disbursal_Transaction__c();
        disbursalTransaction.loan__Loan_Account__c = contract.id;
        disbursalTransaction.loan__Disbursal_Date__c = Date.today();
        disbursalTransaction.loan__Disbursed_Amt__c = contract.loan__Loan_Amount__c;
        disbursalTransaction.loan__Mode_of_Payment__c = paymentModeId.Id;
        disbursalTransaction.Id = TestUtility.getFakeId(loan__Loan_Disbursal_Transaction__c.getSObjectType());
        disbursalTransaction.loan__Loan_Account__r  = contract;

        loan__Disbursal_Txn_Distribution__c disbursalDistributionTxn = new loan__Disbursal_Txn_Distribution__c(loan__Loan_Disbursal_Transaction__c = disbursalTransaction.Id);
        disbursalDistributionTxn.Id = TestUtility.getFakeId(loan__Disbursal_Txn_Distribution__c.getSObjectType());
        disbursalDistributionTxn.loan__Loan_Disbursal_Transaction__r = disbursalTransaction;
        disbursalDistributionTxn.loan__Distribution_Amount__c = 10000;
        disbursalDistributionTxn.Funded_Source__c = 'Merchant';

        DBManagerTestsStub disbursalTransactionDBStubInstance = new DBManagerTestsStub();
        disbursalTransactionDBStubInstance.genericReturnObject = new List<loan__Loan_Disbursal_Transaction__c>{disbursalTransaction};
        BrokerManager.disbursalTransactionDBInstance = (LoanDisbursalTransactionsDB) Test.createStub(LoanDisbursalTransactionsDB.class, disbursalTransactionDBStubInstance);

        DBManagerTestsStub disbursalTxnDistributionDBStubInstance = new DBManagerTestsStub();
        disbursalTxnDistributionDBStubInstance.genericReturnObject = new List<loan__Disbursal_Txn_Distribution__c>{disbursalDistributionTxn};
        BrokerManager.loanDisbursalTxnDistributionDBInstance = (LoanDisbursalTxnDistributionDB) Test.createStub(LoanDisbursalTxnDistributionDB.class, disbursalTxnDistributionDBStubInstance);

        loan__Commission_Plan__c commissionPlan = new loan__Commission_Plan__c();
        commissionPlan.Id = TestUtility.getFakeId(loan__Commission_Plan__c.getSObjectType());

        DBManagerTestsStub commissionPlanDBStubInstance = new DBManagerTestsStub();
        commissionPlanDBStubInstance.genericReturnObject = new List<loan__Commission_Plan__c>{commissionPlan};
        ServicingHelper.commissionPlanDBInstance = (CommissionPlanDB) Test.createStub(CommissionPlanDB.class, commissionPlanDBStubInstance);

        Test.StartTest();
            BrokerManager.createBrokerAndCalculateCommission(new Set<Id>{disbursalTransaction.Id});
        Test.stopTest();

        System.assertEquals(true, acc.Is_Broker_Active__c);
        System.assertEquals('New', contract.Type__c);
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
        BrokerManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Contact con = new Contact();
        con.Id = TestUtility.getFakeId(Contact.getSObjectType());
        con.AccountId = acc.id;
        con.Account = acc;

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact>{con};
        BrokerManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

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
        BrokerManager.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

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

        loan__Disbursal_Txn_Distribution__c disbursalDistributionTxn = new loan__Disbursal_Txn_Distribution__c(loan__Loan_Disbursal_Transaction__c = disbursalTransaction.Id);
        disbursalDistributionTxn.Id = TestUtility.getFakeId(loan__Disbursal_Txn_Distribution__c.getSObjectType());
        disbursalDistributionTxn.loan__Loan_Disbursal_Transaction__r = disbursalTransaction;
        disbursalDistributionTxn.loan__Distribution_Amount__c = 10000;
        disbursalDistributionTxn.Funded_Source__c = 'Merchant';

        DBManagerTestsStub disbursalTransactionDBStubInstance = new DBManagerTestsStub();
        disbursalTransactionDBStubInstance.genericReturnObject = new List<loan__Loan_Disbursal_Transaction__c>{disbursalTransaction};
        BrokerManager.disbursalTransactionDBInstance = (LoanDisbursalTransactionsDB) Test.createStub(LoanDisbursalTransactionsDB.class, disbursalTransactionDBStubInstance);

        DBManagerTestsStub disbursalTxnDistributionDBStubInstance = new DBManagerTestsStub();
        disbursalTxnDistributionDBStubInstance.genericReturnObject = new List<loan__Disbursal_Txn_Distribution__c>{disbursalDistributionTxn};
        BrokerManager.loanDisbursalTxnDistributionDBInstance = (LoanDisbursalTxnDistributionDB) Test.createStub(LoanDisbursalTxnDistributionDB.class, disbursalTxnDistributionDBStubInstance);

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
        BrokerManager.brokerDBInstance = (BrokerDB) Test.createStub(BrokerDB.class, brokerDBStubInstance);

        Test.startTest();
            BrokerManager.calculateCommission(new List<loan__Broker__c>{broker});

            contract.Broker_Standard_Commission__c = null;
            BrokerManager.calculateCommission(new List<loan__Broker__c>{broker});

            acc.Commission_Eligible__c = false;
            BrokerManager.calculateCommission(new List<loan__Broker__c>{broker});

            acc.Commission_Eligible__c = true;
            acc.Is_Broker_Active__c = false;
            BrokerManager.calculateCommission(new List<loan__Broker__c>{broker});

            acc.Is_Broker_Active__c = true;
            BrokerManager.calculateCommission(new List<loan__Broker__c>{broker});

            contract.loan__Loan_Status__c = 'Closed - Premature';
            BrokerManager.calculateCommission(new List<loan__Broker__c>{broker});

            contract.loan__Closed_Date__c = Date.today().addDays(-30);
            BrokerManager.calculateCommission(new List<loan__Broker__c>{broker});

            acc.Default_Broker_Commission__c = 11;
            BrokerManager.calculateCommission(new List<loan__Broker__c>{broker});

            acc.Commision_Based_On__c = Brokers.COMMISSION_CALC_METHOD_FLAT;
            BrokerManager.calculateCommission(new List<loan__Broker__c>{broker});
        Test.stopTest();

        System.assertEquals('Flat Referral Fee updated Successfully.',broker.Commission_Calculation_Message__c);
        System.assertEquals(true,acc.Commission_Eligible__c);
        }

    @isTest
    private static void adjustClawbackOnBrokerAccount(){

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
        BrokerManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Contact con = new Contact();
        con.Id = TestUtility.getFakeId(Contact.getSObjectType());
        con.AccountId = acc.id;
        con.Account = acc;

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact>{con};
        BrokerManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

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
        BrokerManager.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

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
        BrokerManager.disbursalTransactionDBInstance = (LoanDisbursalTransactionsDB) Test.createStub(LoanDisbursalTransactionsDB.class, disbursalTransactionDBStubInstance);

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
        BrokerManager.brokerDBInstance = (BrokerDB) Test.createStub(BrokerDB.class, brokerDBStubInstance);

        Test.startTest();
            broker1.Flat_Referral_Fee__c = 0;
            broker1.Commission_Point__c = 5;
            BrokerManager.calculateCommission(brokerList);
        Test.stopTest();

        System.assertEquals(0,acc.Total_Clawback_Amount__c);
    }

    @isTest
    private static void calculateRenewalTypeCommission(){

        Account acc = new Account();
        acc.Renewal_Amount_Commission__c = 'Gross Amount';
        acc.Is_Flat_Renewal__c = true;
        acc.Flat_Renewal_Commission__c = 100;
        acc.loan__Broker__c = true;
        acc.Is_Broker_Active__c = true;
        acc.Commission_Eligible__c = true;
        acc.Commision_Based_On__c = Brokers.COMMISSION_CALC_METHOD_PERCENTAGE;
        acc.Default_Broker_Commission__c = 8;
        acc.New_Max_Broker_Commission__c = 10;
        acc.Total_Clawback_Amount__c = 100;
        acc.Renewal_Max_Broker_Commission__c = 10;
        acc.Id = TestUtility.getFakeId(Account.getSObjectType());

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{acc};
        BrokerManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Contact con = new Contact();
        con.Id = TestUtility.getFakeId(Contact.getSObjectType());
        con.AccountId = acc.id;
        con.Account = acc;

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact>{con};
        BrokerManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        loan__Loan_Account__c contract = new loan__Loan_Account__c();
        contract.Type__c = 'RENEWAL';
        contract.loan__Loan_Amount__c = 10000;
        contract.loan__Expected_Repayment_Start_Date__c = Date.today();
        contract.Broker_Contact__c = con.Id;
        contract.id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        contract.loan__Funding_in_Tranches__c = true;
        contract.loan__Account__c = acc.Id;
        contract.Broker_Standard_Commission__c = 6;

        loan__Loan_Account__c contract1 = new loan__Loan_Account__c();
        contract1.Type__c = 'New';
        contract1.loan__Loan_Amount__c = 10000;
        contract1.loan__Expected_Repayment_Start_Date__c = Date.today();
        contract1.Broker_Contact__c = con.Id;
        contract1.id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        contract1.loan__Funding_in_Tranches__c = true;
        contract1.loan__Account__c = acc.Id;
        contract1.Broker_Standard_Commission__c = 6;

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{contract,contract1};
        BrokerManager.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

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
        disbursalTransaction2.loan__Loan_Account__c = contract1.id;
        disbursalTransaction2.loan__Disbursal_Date__c = system.today();
        disbursalTransaction2.loan__Disbursed_Amt__c = 3000;
        disbursalTransaction2.loan__Mode_of_Payment__c = paymentModeId.Id;
        disbursalTransaction2.loan__Loan_Account__r  = contract1;
        disbursalTransaction2.Id = TestUtility.getFakeId(loan__Loan_Disbursal_Transaction__c.getSObjectType());

        loan__Disbursal_Txn_Distribution__c disbursalDistributionTxn = new loan__Disbursal_Txn_Distribution__c(loan__Loan_Disbursal_Transaction__c = disbursalTransaction1.Id);
        disbursalDistributionTxn.Id = TestUtility.getFakeId(loan__Disbursal_Txn_Distribution__c.getSObjectType());
        disbursalDistributionTxn.loan__Loan_Disbursal_Transaction__r = disbursalTransaction1;
        disbursalDistributionTxn.loan__Distribution_Amount__c = 10000;
        disbursalDistributionTxn.Funded_Source__c = 'Merchant';

        DBManagerTestsStub disbursalTransactionDBStubInstance = new DBManagerTestsStub();
        disbursalTransactionDBStubInstance.genericReturnObject = new List<loan__Loan_Disbursal_Transaction__c>{disbursalTransaction1,disbursalTransaction2};
        BrokerManager.disbursalTransactionDBInstance = (LoanDisbursalTransactionsDB) Test.createStub(LoanDisbursalTransactionsDB.class, disbursalTransactionDBStubInstance);

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
        broker2.loan__Contact__c = contract1.Broker_Contact__c;
        broker2.loan__Commission_Plan__c = commissionPlan.Id;
        broker2.loan__Calculation_Method__c = acc.Commision_Based_On__c;
        broker2.loan__Lending_Account__c = disbursalTransaction2.loan__Loan_Account__c;
        broker2.Disbursal_Transaction__c = disbursalTransaction2.id;
        broker2.Flat_Referral_Fee__c = 100;
        brokerList.add(broker2);

        DBManagerTestsStub disbursalTxnDistributionDBStubInstance = new DBManagerTestsStub();
        disbursalTxnDistributionDBStubInstance.genericReturnObject = new List<loan__Disbursal_Txn_Distribution__c>{disbursalDistributionTxn};
        BrokerManager.loanDisbursalTxnDistributionDBInstance = (LoanDisbursalTxnDistributionDB) Test.createStub(LoanDisbursalTxnDistributionDB.class, disbursalTxnDistributionDBStubInstance);

        DBManagerTestsStub brokerDBStubInstance = new DBManagerTestsStub();
        brokerDBStubInstance.genericReturnObject = brokerList;
        BrokerManager.brokerDBInstance = (BrokerDB) Test.createStub(BrokerDB.class, brokerDBStubInstance);

        Test.startTest();
            BrokerManager.calculateCommission(new List<loan__Broker__c>{broker1});

            broker1.Flat_Referral_Fee__c = 0;
            broker1.Commission_Point__c = 5;

            BrokerManager.calculateCommission(new List<loan__Broker__c>{broker1});

            acc.Renewal_Amount_Commission__c = 'Net Amount';
            BrokerManager.calculateCommission(new List<loan__Broker__c>{broker1});

            acc.Renewal_Amount_Commission__c = '';
            BrokerManager.calculateCommission(new List<loan__Broker__c>{broker1});

            acc.Is_Flat_Renewal__c = false;
            BrokerManager.calculateCommission(new List<loan__Broker__c>{broker1});
        Test.stopTest();

        System.assertEquals('RENEWAL',contract.Type__c);
        System.assertEquals('', acc.Renewal_Amount_Commission__c);
        System.assertEquals('Broker Commission calculated Successfully.',broker1.Commission_Calculation_Message__c);
    }

    @isTest
    private static void calculateRenewalTypeCommissionMaxCommission(){
        Account acc = new Account();
        acc.Renewal_Amount_Commission__c = 'Gross Amount';
        acc.Is_Flat_Renewal__c = true;
        acc.Flat_Renewal_Commission__c = 100;
        acc.loan__Broker__c = true;
        acc.Is_Broker_Active__c = true;
        acc.Commission_Eligible__c = true;
        acc.Commision_Based_On__c = Brokers.COMMISSION_CALC_METHOD_PERCENTAGE;
        acc.Default_Broker_Commission__c = 8;
        acc.New_Max_Broker_Commission__c = 10;
        acc.Total_Clawback_Amount__c = 100;
        acc.Renewal_Max_Broker_Commission__c = 3;
        acc.Id = TestUtility.getFakeId(Account.getSObjectType());

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{acc};
        BrokerManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Contact con = new Contact();
        con.Id = TestUtility.getFakeId(Contact.getSObjectType());
        con.AccountId = acc.id;
        con.Account = acc;

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact>{con};
        BrokerManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        loan__Loan_Account__c contract = new loan__Loan_Account__c();
        contract.Type__c = 'RENEWAL';
        contract.loan__Loan_Amount__c = 10000;
        contract.loan__Expected_Repayment_Start_Date__c = Date.today();
        contract.Broker_Contact__c = con.Id;
        contract.id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        contract.loan__Funding_in_Tranches__c = true;
        contract.loan__Account__c = acc.Id;
        contract.Broker_Standard_Commission__c = 6;

        loan__Loan_Account__c contract1 = new loan__Loan_Account__c();
        contract1.Type__c = 'New';
        contract1.loan__Loan_Amount__c = 10000;
        contract1.loan__Expected_Repayment_Start_Date__c = Date.today();
        contract1.Broker_Contact__c = con.Id;
        contract1.id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        contract1.loan__Funding_in_Tranches__c = true;
        contract1.loan__Account__c = acc.Id;
        contract1.Broker_Standard_Commission__c = 6;

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{contract,contract1};
        BrokerManager.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

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
        disbursalTransaction2.loan__Loan_Account__c = contract1.id;
        disbursalTransaction2.loan__Disbursal_Date__c = system.today();
        disbursalTransaction2.loan__Disbursed_Amt__c = 3000;
        disbursalTransaction2.loan__Mode_of_Payment__c = paymentModeId.Id;
        disbursalTransaction2.loan__Loan_Account__r  = contract1;
        disbursalTransaction2.Id = TestUtility.getFakeId(loan__Loan_Disbursal_Transaction__c.getSObjectType());

        loan__Disbursal_Txn_Distribution__c disbursalDistributionTxn = new loan__Disbursal_Txn_Distribution__c(loan__Loan_Disbursal_Transaction__c = disbursalTransaction1.Id);
        disbursalDistributionTxn.Id = TestUtility.getFakeId(loan__Disbursal_Txn_Distribution__c.getSObjectType());
        disbursalDistributionTxn.loan__Loan_Disbursal_Transaction__r = disbursalTransaction1;
        disbursalDistributionTxn.loan__Distribution_Amount__c = 10000;
        disbursalDistributionTxn.Funded_Source__c = 'Merchant';

        DBManagerTestsStub disbursalTransactionDBStubInstance = new DBManagerTestsStub();
        disbursalTransactionDBStubInstance.genericReturnObject = new List<loan__Loan_Disbursal_Transaction__c>{disbursalTransaction1,disbursalTransaction2};
        BrokerManager.disbursalTransactionDBInstance = (LoanDisbursalTransactionsDB) Test.createStub(LoanDisbursalTransactionsDB.class, disbursalTransactionDBStubInstance);

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
        broker2.loan__Contact__c = contract1.Broker_Contact__c;
        broker2.loan__Commission_Plan__c = commissionPlan.Id;
        broker2.loan__Calculation_Method__c = acc.Commision_Based_On__c;
        broker2.loan__Lending_Account__c = disbursalTransaction2.loan__Loan_Account__c;
        broker2.Disbursal_Transaction__c = disbursalTransaction2.id;
        broker2.Flat_Referral_Fee__c = 100;
        brokerList.add(broker2);

        DBManagerTestsStub disbursalTxnDistributionDBStubInstance = new DBManagerTestsStub();
        disbursalTxnDistributionDBStubInstance.genericReturnObject = new List<loan__Disbursal_Txn_Distribution__c>{disbursalDistributionTxn};
        BrokerManager.loanDisbursalTxnDistributionDBInstance = (LoanDisbursalTxnDistributionDB) Test.createStub(LoanDisbursalTxnDistributionDB.class, disbursalTxnDistributionDBStubInstance);

        DBManagerTestsStub brokerDBStubInstance = new DBManagerTestsStub();
        brokerDBStubInstance.genericReturnObject = brokerList;
        BrokerManager.brokerDBInstance = (BrokerDB) Test.createStub(BrokerDB.class, brokerDBStubInstance);

        Test.startTest();
            BrokerManager.calculateCommission(new List<loan__Broker__c>{broker1});

            broker1.Flat_Referral_Fee__c = 0;
            broker1.Commission_Point__c = 5;

            BrokerManager.calculateCommission(new List<loan__Broker__c>{broker1});

            acc.Renewal_Amount_Commission__c = 'Net Amount';
            BrokerManager.calculateCommission(new List<loan__Broker__c>{broker1});

            acc.Renewal_Amount_Commission__c = '';
            BrokerManager.calculateCommission(new List<loan__Broker__c>{broker1});

            acc.Is_Flat_Renewal__c = false;
            BrokerManager.calculateCommission(new List<loan__Broker__c>{broker1});
        Test.stopTest();

        System.assertEquals('RENEWAL',contract.Type__c);
        System.assertEquals('', acc.Renewal_Amount_Commission__c);
        System.assertEquals('Broker commission is calculating more than Renewal Maximum Commission %. ',broker1.Commission_Calculation_Message__c);
    }
}