@isTest(isParallel=true)
private class PurchaseStatementsTests {
    @isTest
    private static void buildPurchaseStatementWrapperTIER1Test() {
        Double writeOffPercent = 0.10;
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        WebBank_Calculations_Tier_Mapping__mdt tierMapping = new WebBank_Calculations_Tier_Mapping__mdt();
        tierMapping.DeveloperName = 'TIER_1';
        tierMapping.Loan_Origination_Assistance_Pct__c = 2.0;
        tierMapping.Loan_Purchase_Premium_Pct__c = 0.2;
        tierMapping.MaxAPR__c = 19.99;
        tierMapping.MinAPR__c = 0.0;
        tierMapping.Servicing_Pct__c = 1.0;
        tierMapping.Writeoff_Pct__c = 10.0;
        Map<String, WebBank_Calculations_Tier_Mapping__mdt> webBankMap =  new Map<String, WebBank_Calculations_Tier_Mapping__mdt> ();
        webBankMap.put(tierMapping.DeveloperName, tierMapping);
        CustomMetaDataHelper.webBankCalculationsTierMappingMap = webBankMap;

        list<loan__Loan_Disbursal_Transaction__c> disbursementList = new list<loan__Loan_Disbursal_Transaction__c>();
        list<loan__Loan_Disbursal_Transaction__c> processedDisbursementList = new list<loan__Loan_Disbursal_Transaction__c>();

        loan__Loan_Account__c loanAccount = (loan__Loan_Account__c) JSON.deserialize(
            '{ "Name" : "Loan Account",  "loan__Total_Interest_Amortization_Based__c" : "10000", "loan__Total_Amount_Paid__c" : "299"}' ,
            loan__Loan_Account__c.class
        );
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loanAccount.Origination_Fee__c = 30;
        loanAccount.Origination_Fee_Percentage__c = 3;
        loanAccount.loan__Disbursed_Amount__c = 1000;
        loanAccount.loan__Frequency_of_Loan_Payment__c = GeneralConstants.FREQUENCY_DAILY;
        loanAccount.loan__Last_Installment_Date__c = GeneralHelper.currentSystemDate.addDays(60);
        loanAccount.loan__Interest_Rate__c = 10;
        loanAccount.Pricing_Factor__c = 1.2;
        loanAccount.loan__Number_of_Installments__c = 12;

        loan__Investor_Loan__c investmentOrder = (loan__Investor_Loan__c) JSON.deserialize(
            '{"loan__Total_Amount_Paid__c" : "10", "loan__Remaining_Investment_Amount__c" : "10"}', loan__Investor_Loan__c.class
        );
        investmentOrder.Id = TestUtility.getFakeId(loan__Investor_Loan__c.getSObjectType());
        investmentOrder.loan__Inv_Accrued_Interest_Amt__c = 10;
        investmentOrder.loan__Principal_Amount_Paid__c = 10;

        List<loan__Investor_Loan__c> investmentOrderList = new List<loan__Investor_Loan__c>{investmentOrder};
        String jsonInvestmentOrderList = '{"totalSize" : 1, "done" : true, "records" : ' + JSON.serialize(investmentOrderList, false) + '}';

        loan__Loan_Disbursal_Transaction__c disbursal = (loan__Loan_Disbursal_Transaction__c) JSON.deserialize(
            '{ "Investment_Orders__r" : ' + jsonInvestmentOrderList + ', "Actual_Disbursed_Amount__c" : 1000 }',
            loan__Loan_Disbursal_Transaction__c.class
        );
        disbursal.Id = TestUtility.getFakeId(loan__Loan_Disbursal_Transaction__c.getSObjectType());
        disbursal.loan__Loan_Account__r = loanAccount;
        disbursal.WebBank_Accrued_Origination_Fee__c = 20;
        disbursal.Write_Offs__c = 15;
        disbursal.Loan_Origination_Assistance_Fee__c=30;
        disbursal.Servicing_Fee__c = 20;
        disbursal.Purchase_Loan_Origination_Assistance_Fee__c = 100;
        disbursal.WebBank_Loan_Purchase_Premium__c = 20;
        disbursal.loan__Disbursal_Date__c = GeneralHelper.currentSystemDate;
        disbursal.Repurchase_Date__c = GeneralHelper.currentSystemDate.addDays(15);
        disbursal.Net_Settlement__c = 100;
        disbursal.loan__Disbursed_Amt__c = 1000;
        disbursementList.add(disbursal);

        Test.startTest();
            List<String> csvRowValues =  PurchaseStatements.buildPurchaseStatementWrapper(disbursementList, processedDisbursementList);
        Test.stopTest();

        System.assertEquals(2, csvRowValues.size());
    }

    @isTest
    private static void buildPurchaseStatementWrapperTIER2Test() {
        Double writeOffPercent = 0.10;
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        WebBank_Calculations_Tier_Mapping__mdt tierMapping = new WebBank_Calculations_Tier_Mapping__mdt();
        tierMapping.DeveloperName = 'TIER_2';
        tierMapping.Loan_Origination_Assistance_Pct__c = 2.0;
        tierMapping.Loan_Purchase_Premium_Pct__c = 0.2;
        tierMapping.MaxAPR__c = 19.99;
        tierMapping.MinAPR__c = 0.0;
        tierMapping.Servicing_Pct__c = 1.0;
        tierMapping.Writeoff_Pct__c = 10.0;
        Map<String, WebBank_Calculations_Tier_Mapping__mdt> webBankMap =  new Map<String, WebBank_Calculations_Tier_Mapping__mdt> ();

        webBankMap.put(tierMapping.DeveloperName, tierMapping);
        CustomMetaDataHelper.webBankCalculationsTierMappingMap = webBankMap;

        list<loan__Loan_Disbursal_Transaction__c> disbursementList = new list<loan__Loan_Disbursal_Transaction__c>();
        list<loan__Loan_Disbursal_Transaction__c> processedDisbursementList = new list<loan__Loan_Disbursal_Transaction__c>();

        loan__Loan_Account__c loanAccount = (loan__Loan_Account__c) JSON.deserialize(
            '{ "Name" : "Loan Account",  "loan__Total_Interest_Amortization_Based__c" : "10000", "loan__Total_Amount_Paid__c" : "299"}' ,
            loan__Loan_Account__c.class
        );
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loanAccount.Origination_Fee__c = 30;
        loanAccount.Origination_Fee_Percentage__c = 3;
        loanAccount.loan__Disbursed_Amount__c = 1000;
        loanAccount.loan__Frequency_of_Loan_Payment__c = GeneralConstants.FREQUENCY_DAILY;
        loanAccount.loan__Last_Installment_Date__c = GeneralHelper.currentSystemDate.addDays(60);
        loanAccount.loan__Interest_Rate__c = 24;
        loanAccount.Pricing_Factor__c = 1.2;
        loanAccount.loan__Number_of_Installments__c = 12;

        loan__Investor_Loan__c investmentOrder = (loan__Investor_Loan__c) JSON.deserialize(
            '{"loan__Total_Amount_Paid__c" : "10", "loan__Remaining_Investment_Amount__c" : "10"}', loan__Investor_Loan__c.class
        );
        investmentOrder.Id = TestUtility.getFakeId(loan__Investor_Loan__c.getSObjectType());
        investmentOrder.loan__Inv_Accrued_Interest_Amt__c = 10;
        investmentOrder.loan__Principal_Amount_Paid__c = 10;

        List<loan__Investor_Loan__c> investmentOrderList = new List<loan__Investor_Loan__c>{investmentOrder};
        String jsonInvestmentOrderList = '{"totalSize" : 1, "done" : true, "records" : ' + JSON.serialize(investmentOrderList, false) + '}';

        loan__Loan_Disbursal_Transaction__c disbursal = (loan__Loan_Disbursal_Transaction__c) JSON.deserialize(
            '{ "Investment_Orders__r" : ' + jsonInvestmentOrderList + ', "Actual_Disbursed_Amount__c" : 1000 }',
            loan__Loan_Disbursal_Transaction__c.class
        );
        disbursal.Id = TestUtility.getFakeId(loan__Loan_Disbursal_Transaction__c.getSObjectType());
        disbursal.loan__Loan_Account__r = loanAccount;
        disbursal.WebBank_Accrued_Origination_Fee__c = 20;
        disbursal.Write_Offs__c = 15;
        disbursal.Loan_Origination_Assistance_Fee__c=30;
        disbursal.Servicing_Fee__c = 20;
        disbursal.Purchase_Loan_Origination_Assistance_Fee__c = 100;
        disbursal.WebBank_Loan_Purchase_Premium__c = 20;
        disbursal.loan__Disbursal_Date__c = GeneralHelper.currentSystemDate;
        disbursal.Repurchase_Date__c = GeneralHelper.currentSystemDate.addDays(15);
        disbursal.Net_Settlement__c = 100;
        disbursal.loan__Disbursed_Amt__c = 1000;
        disbursementList.add(disbursal);

        Test.startTest();
            List<String> csvRowValues =  PurchaseStatements.buildPurchaseStatementWrapper(disbursementList, processedDisbursementList);
        Test.stopTest();

        System.assertEquals(2, csvRowValues.size());
    }

    @isTest
    private static void buildPurchaseStatementWrapperTIER3Test() {
        Double writeOffPercent = 0.10;
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        WebBank_Calculations_Tier_Mapping__mdt tierMapping = new WebBank_Calculations_Tier_Mapping__mdt();
        tierMapping.DeveloperName = 'TIER_3';
        tierMapping.Loan_Origination_Assistance_Pct__c = 2.0;
        tierMapping.Loan_Purchase_Premium_Pct__c = 0.2;
        tierMapping.MaxAPR__c = 19.99;
        tierMapping.MinAPR__c = 0.0;
        tierMapping.Servicing_Pct__c = 1.0;
        tierMapping.Writeoff_Pct__c = 10.0;
        Map<String, WebBank_Calculations_Tier_Mapping__mdt> webBankMap =  new Map<String, WebBank_Calculations_Tier_Mapping__mdt> ();

        webBankMap.put(tierMapping.DeveloperName, tierMapping);
        CustomMetaDataHelper.webBankCalculationsTierMappingMap = webBankMap;

        list<loan__Loan_Disbursal_Transaction__c> disbursementList = new list<loan__Loan_Disbursal_Transaction__c>();
        list<loan__Loan_Disbursal_Transaction__c> processedDisbursementList = new list<loan__Loan_Disbursal_Transaction__c>();

        loan__Loan_Account__c loanAccount = (loan__Loan_Account__c) JSON.deserialize(
            '{ "Name" : "Loan Account",  "loan__Total_Interest_Amortization_Based__c" : "10000", "loan__Total_Amount_Paid__c" : "299"}' ,
            loan__Loan_Account__c.class
        );
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loanAccount.Origination_Fee__c = 30;
        loanAccount.Origination_Fee_Percentage__c = 3;
        loanAccount.loan__Disbursed_Amount__c = 1000;
        loanAccount.loan__Frequency_of_Loan_Payment__c = GeneralConstants.FREQUENCY_DAILY;
        loanAccount.loan__Last_Installment_Date__c = GeneralHelper.currentSystemDate.addDays(60);
        loanAccount.loan__Interest_Rate__c = 49;
        loanAccount.Pricing_Factor__c = 1.2;
        loanAccount.loan__Number_of_Installments__c = 12;

        loan__Investor_Loan__c investmentOrder = (loan__Investor_Loan__c) JSON.deserialize(
            '{"loan__Total_Amount_Paid__c" : "10", "loan__Remaining_Investment_Amount__c" : "10"}', loan__Investor_Loan__c.class
        );
        investmentOrder.Id = TestUtility.getFakeId(loan__Investor_Loan__c.getSObjectType());
        investmentOrder.loan__Inv_Accrued_Interest_Amt__c = 10;
        investmentOrder.loan__Principal_Amount_Paid__c = 10;

        List<loan__Investor_Loan__c> investmentOrderList = new List<loan__Investor_Loan__c>{investmentOrder};
        String jsonInvestmentOrderList = '{"totalSize" : 1, "done" : true, "records" : ' + JSON.serialize(investmentOrderList, false) + '}';

        loan__Loan_Disbursal_Transaction__c disbursal = (loan__Loan_Disbursal_Transaction__c) JSON.deserialize(
            '{ "Investment_Orders__r" : ' + jsonInvestmentOrderList + ', "Actual_Disbursed_Amount__c" : 1000 }',
            loan__Loan_Disbursal_Transaction__c.class
        );
        disbursal.Id = TestUtility.getFakeId(loan__Loan_Disbursal_Transaction__c.getSObjectType());
        disbursal.loan__Loan_Account__r = loanAccount;
        disbursal.WebBank_Accrued_Origination_Fee__c = 20;
        disbursal.Write_Offs__c = 15;
        disbursal.Loan_Origination_Assistance_Fee__c=30;
        disbursal.Servicing_Fee__c = 20;
        disbursal.Purchase_Loan_Origination_Assistance_Fee__c = 100;
        disbursal.WebBank_Loan_Purchase_Premium__c = 20;
        disbursal.loan__Disbursal_Date__c = GeneralHelper.currentSystemDate;
        disbursal.Repurchase_Date__c = GeneralHelper.currentSystemDate.addDays(15);
        disbursal.Net_Settlement__c = 100;
        disbursal.loan__Disbursed_Amt__c = 1000;
        disbursementList.add(disbursal);

        Test.startTest();
            List<String> csvRowValues =  PurchaseStatements.buildPurchaseStatementWrapper(disbursementList, processedDisbursementList);
        Test.stopTest();

        System.assertEquals(2, csvRowValues.size());
    }

    @isTest
    private static void validateStringValueTest(){
        Test.startTest();
        String newValues = PurchaseStatements.validateStringValue(null);
        Test.stopTest();

        System.assertEquals(null, newValues);
    }

    @isTest
    private static void validateStringValueTest1(){
        Test.startTest();
        String newValues = PurchaseStatements.validateStringValue('DUM'+''+'MMY');
        Test.stopTest();

        System.assertEquals('DUMMMY', newValues);
    }

    @isTest
    private static void setInitialSummaryRowMapTest(){
        Test.startTest();
        Map<String, Double> rowMap = PurchaseStatements.setInitialSummaryRowMap();
        Test.stopTest();

        System.assertEquals(16, rowMap.size());
        System.assertEquals(0, rowMap.get('totalFundedAmount'));
    }

    @isTest
    private static void buildConsolidatedResultRowTest(){
        Map<String, Double> summaryRowMap = PurchaseStatements.setInitialSummaryRowMap();

        Test.startTest();
        List<String> rowMap = PurchaseStatements.buildConsolidatedResultRow(summaryRowMap);
        Test.stopTest();
        System.assertEquals(19, rowMap.size());
    }

}