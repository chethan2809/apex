@isTest(isParallel=true)
private class ExperiansTests {

    @isTest
    private static void experianBusinessAPIDetailsTestMethod(){
        API_Detail__mdt apiDetails = Experians.experianBusinessAPIDetails;
        System.assert(apiDetails != null);
    }

    @isTest
    private static void experianConsumerAPIDetailsTestMethod(){
        API_Detail__mdt apiDetails = Experians.experianConsumerAPIDetails;
        System.assert(apiDetails != null);
    }

    @isTest
    private static void createBusinessCreditReportDetail(){
        GeneralHelper.currentSystemDate = Date.newInstance(2021, 03, 01);

        Account existingAccountDetail = new Account();
        existingAccountDetail.Id = TestUtility.getFakeId(Account.getSObjectType());

        Account newAccountDetail = new Account();
        newAccountDetail.Id = TestUtility.getFakeId(Account.getSObjectType());

        Credit_Report_Detail__c existingCreditReportDetail = new Credit_Report_Detail__c();
        existingCreditReportDetail.Type__c = GeneralConstants.CREDIT_REPORT_TYPE_EXPERIAN_BUSINESS;
        existingCreditReportDetail.Account__c = existingAccountDetail.Id;

        Map<String, Object> accountBusinessSearch = new Map<String, Object>();
        accountBusinessSearch.put('bin', '12345');
        accountBusinessSearch.put('reliabilityCode', 7);
        List<Object> tradePaymentExperiencesList = new List<Object>();
        Map<String, Object> tradePaymentExperienceMap = new Map<String, Object>();
            tradePaymentExperienceMap.put('comments','CHARGEOFF');
            tradePaymentExperienceMap.put('businessCategory','FINCLSVCS');
        Map<String, Object> recentHighCredit = new Map<String, Object>();
            recentHighCredit.put('amount',6000);
            tradePaymentExperienceMap.put('recentHighCredit',recentHighCredit);
        List<Object> bankruptcyDetailList = new List<Object>();
        Map<String, Object> bankruptcyDetailMap = new Map<String, Object>();
        bankruptcyDetailMap.put('documentNumber','documentNumber');
        bankruptcyDetailMap.put('dateFiled','2021-01-01');
        bankruptcyDetailMap.put('legalAction','legalAction');
        bankruptcyDetailList.add(bankruptcyDetailMap);
        List<Object> judgmentDetailList = new List<Object>();
        Map<String, Object> judgmentDetailMap = new Map<String, Object>();
        judgmentDetailMap.put('documentNumber','documentNumber');
        judgmentDetailMap.put('legalType','legalType');
        judgmentDetailMap.put('filingLocation','filingLocation');
        judgmentDetailMap.put('liabilityAmount','liabilityAmount');
        judgmentDetailMap.put('dateFiled','2021-01-01');
        judgmentDetailMap.put('legalAction','legalAction');
        judgmentDetailList.add(judgmentDetailMap);
        List<Object> taxLienDetailList = new List<Object>();
        Map<String, Object> taxLienDetailMap = new Map<String, Object>();
        taxLienDetailMap.put('documentNumber','documentNumber');
        taxLienDetailMap.put('legalType','legalType');
        taxLienDetailMap.put('filingLocation','filingLocation');
        taxLienDetailMap.put('liabilityAmount','liabilityAmount');
        taxLienDetailMap.put('dateFiled','2021-01-01');
        taxLienDetailMap.put('legalAction','legalAction');
        taxLienDetailList.add(taxLienDetailMap);
        List<Object> collectionDetails = new List<Object>();
        Map<String, Object> collectionMap = new Map<String, Object>();
        collectionMap.put('accountStatus','Open Account');
        collectionMap.put('amountPlacedForCollection', 4000);
        collectionMap.put('amountPaid', 5000);
        collectionDetails.add(collectionMap);
        Map<String, Object> accountCreditProfile = new Map<String, Object>();
        accountCreditProfile.put('allTradelineCount',77);
        accountCreditProfile.put('fileEstablishedDate',Date.today());
        accountCreditProfile.put('legalBusinessName','legalBusinessName');
        accountCreditProfile.put('street','street');
        accountCreditProfile.put('city','city');
        accountCreditProfile.put('state','state');
        accountCreditProfile.put('zip','zip');
        accountCreditProfile.put('zipExtension','zipExtension');
        accountCreditProfile.put('businessType','businessType');
        accountCreditProfile.put('taxId','taxId');
        accountCreditProfile.put('tradePaymentExperiences',tradePaymentExperiencesList);
        accountCreditProfile.put('bankruptcyDetail',bankruptcyDetailList);
        accountCreditProfile.put('taxLienDetail',taxLienDetailList);
        accountCreditProfile.put('judgmentDetail',judgmentDetailList);
        accountCreditProfile.put('collectionsDetail',collectionDetails);
        Map<String, Object> accountCreditAggregates = new Map<String, Object>();
        accountCreditAggregates.put('TTO077',0077);
        accountCreditAggregates.put('TTC058',058);
        accountCreditAggregates.put('CLO015',015);
        accountCreditAggregates.put('DMO013','SICCode');
        Map<Id, Credit_Report_Detail__c> existingCreditReportByAccountId = new Map<Id, Credit_Report_Detail__c>();
        existingCreditReportByAccountId.put(existingAccountDetail.Id, existingCreditReportDetail);

        Test.startTest();
            Credit_Report_Detail__c actualExistingCreditReport = Experians.createBusinessCreditReportDetail(
                accountBusinessSearch, accountCreditProfile, accountCreditAggregates, existingAccountDetail,
                existingCreditReportByAccountId
            );
            Credit_Report_Detail__c actualNewCreditReport =  Experians.createBusinessCreditReportDetail(
                accountBusinessSearch, accountCreditProfile, accountCreditAggregates, newAccountDetail,
                existingCreditReportByAccountId
            );
        Test.stopTest();

        System.assertEquals(newAccountDetail.Id, actualNewCreditReport.Account__c);
        System.assertEquals('12345', actualNewCreditReport.BIN__c);
        System.assertEquals('12345', actualExistingCreditReport.BIN__c);
        System.assertEquals(7, actualNewCreditReport.Reliability_Code__c);
        System.assertEquals(7, actualExistingCreditReport.Reliability_Code__c);
    }

    @isTest
    private static void competitorJudgementIdentification(){
        OriginationHelper.competitorAccountNames = new Set<String>{'TESTCOMPETITOR'};
        List<Object> judgmentDetailList = new List<Object>();
        Map<String, Object> judgmentDetailMap = new Map<String, Object>();
        judgmentDetailMap.put('plaintiffName', 'Test Competitor');
        judgmentDetailList.add(judgmentDetailMap);

        Test.startTest();
            Boolean isCompetitorJudgement = Experians.competitorJudgementIdentification(judgmentDetailList);
        Test.stopTest();

        System.assertEquals(true, isCompetitorJudgement);
    }

    @isTest
    private static void competitorJudgementIdentificationFalse(){
        OriginationHelper.competitorAccountNames = new Set<String>{'Test Ss Competitor'};
        List<Object> judgmentDetailList = new List<Object>();
        Map<String, Object> judgmentDetailMap = new Map<String, Object>();
        judgmentDetailMap.put('plaintiffName', 'Test Competitor');
        judgmentDetailList.add(judgmentDetailMap);

        Test.startTest();
            Boolean isCompetitorJudgement = Experians.competitorJudgementIdentification(judgmentDetailList);
        Test.stopTest();

        System.assertEquals(false, isCompetitorJudgement);
    }

    @isTest
    private static void calculatingCollectionDetailTestMethod(){

        Credit_Report_Detail__c businessCreditReport = new Credit_Report_Detail__c();
        businessCreditReport.Total_Collection_Amount__c = 0;

        List<Object> collectionDetails = new List<Object>();
        Map<String, Object> collectionMap = new Map<String, Object>();
        collectionMap.put('accountStatus', 'Open Account');
        collectionMap.put('amountPlacedForCollection', 4000);
        collectionMap.put('amountPaid', 3000);
        collectionDetails.add(collectionMap);

        Test.startTest();
            Experians.calculatingCollectionDetail(collectionDetails, businessCreditReport);
        Test.stopTest();

        System.assertEquals(1000, businessCreditReport.Total_Collection_Amount__c);
    }

    @isTest
    private static void validateFinancialServicesChargeOffTrue() {

        List<Object> tradePaymentExperienceList = new List<Object>();
        Map<String, Object> tradePaymentExperienceMap = new Map<String, Object>();
            tradePaymentExperienceMap.put('comments','CHARGEOFF');
            tradePaymentExperienceMap.put('businessCategory','FINCLSVCS');
        Map<String, Integer> recentHighCredit = new Map<String, Integer>();
            recentHighCredit.put('amount', 6000);
        tradePaymentExperienceMap.put('recentHighCredit',recentHighCredit);
        tradePaymentExperienceList.add(tradePaymentExperienceMap);

        Test.startTest();
            Boolean isFinancialServicesChargeOff = Experians.validateFinancialServicesChargeOff(tradePaymentExperienceList);
        Test.stopTest();

        System.assertEquals(true, isFinancialServicesChargeOff);
    }

    @isTest
    private static void validateFinancialServicesChargeOffFalse() {

        List<Object> tradePaymentExperienceList = new List<Object>();
        Map<String, Object> tradePaymentExperienceMap = new Map<String, Object>();
            tradePaymentExperienceMap.put('comments','CHARGEOFF');
            tradePaymentExperienceMap.put('businessCategory','FINCLSVCS');
        Map<String, Integer> recentHighCredit = new Map<String, Integer>();
            recentHighCredit.put('amount', 1000);
        tradePaymentExperienceMap.put('recentHighCredit',recentHighCredit);
        tradePaymentExperienceList.add(tradePaymentExperienceMap);

        Test.startTest();
            Boolean isFinancialServicesChargeOff = Experians.validateFinancialServicesChargeOff(tradePaymentExperienceList);
        Test.stopTest();

        System.assertEquals(false, isFinancialServicesChargeOff);
    }

    @isTest
    private static void unifyingBusinessBankruptcyDetailsForRecentBankruptcy(){
        GeneralHelper.currentSystemDate = Date.newInstance(2021, 03, 01);

        Credit_Report_Detail__c businessCreditReport = new Credit_Report_Detail__c();
        businessCreditReport.Is_Recent_Bankruptcy__c = false;
        businessCreditReport.Is_Open_Bankruptcy__c = false;

        List<Object> bankruptcyDetailList = new List<Object>();
        Map<String, Object> bankruptcyDetailMapOne = new Map<String, Object>();
        bankruptcyDetailMapOne.put('documentNumber','12345');
        bankruptcyDetailMapOne.put('dateFiled', '2021-02-01');
        bankruptcyDetailMapOne.put('legalAction', 'RELEASED');
        bankruptcyDetailList.add(bankruptcyDetailMapOne);
        Map<String, Object> bankruptcyDetailMapTwo = new Map<String, Object>();
        bankruptcyDetailMapTwo.put('documentNumber','12345');
        bankruptcyDetailMapTwo.put('dateFiled', '2021-03-01');
        bankruptcyDetailMapTwo.put('legalAction', 'RELEASED');
        bankruptcyDetailList.add(bankruptcyDetailMapTwo);

        Test.startTest();
            Experians.unifyingBusinessBankruptcyDetails(bankruptcyDetailList, businessCreditReport);
        Test.stopTest();

        System.assertEquals(true, businessCreditReport.Is_Recent_Bankruptcy__c);
        System.assertEquals(false, businessCreditReport.Is_Open_Bankruptcy__c);
    }

    @isTest
    private static void unifyingBusinessBankruptcyDetailsForOpenBankruptcy(){
        GeneralHelper.currentSystemDate = Date.newInstance(2021, 03, 01);

        Credit_Report_Detail__c businessCreditReport = new Credit_Report_Detail__c();
        businessCreditReport.Is_Recent_Bankruptcy__c = false;
        businessCreditReport.Is_Open_Bankruptcy__c = false;

        List<Object> bankruptcyDetailList = new List<Object>();
        Map<String, Object> bankruptcyDetailMapOne = new Map<String, Object>();
        bankruptcyDetailMapOne.put('documentNumber','12345');
        bankruptcyDetailMapOne.put('dateFiled', '2021-02-01');
        bankruptcyDetailMapOne.put('legalAction', 'ABSTRACT');
        bankruptcyDetailList.add(bankruptcyDetailMapOne);
        Map<String, Object> bankruptcyDetailMapTwo = new Map<String, Object>();
        bankruptcyDetailMapTwo.put('documentNumber','12345');
        bankruptcyDetailMapTwo.put('dateFiled', '2021-03-01');
        bankruptcyDetailMapTwo.put('legalAction', 'ABSTRACT');
        bankruptcyDetailList.add(bankruptcyDetailMapTwo);

        Test.startTest();
            Experians.unifyingBusinessBankruptcyDetails(bankruptcyDetailList, businessCreditReport);
        Test.stopTest();

        System.assertEquals(true, businessCreditReport.Is_Recent_Bankruptcy__c);
        System.assertEquals(true, businessCreditReport.Is_Open_Bankruptcy__c);
    }

    @isTest
    private static void unifyingBusinessTaxLienDetailTestMethod(){
        GeneralHelper.currentSystemDate = Date.newInstance(2021, 03, 01);

        List<Object> taxLienDetailList = new List<Object>();
        Map<String, Object> taxLienDetailMap = new Map<String, Object>();
        taxLienDetailMap.put('documentNumber','12345');
        taxLienDetailMap.put('legalType','LIEN');
        taxLienDetailMap.put('filingLocation','filingLocation');
        taxLienDetailMap.put('liabilityAmount', 1000);
        taxLienDetailMap.put('dateFiled','2021-01-01');
        taxLienDetailMap.put('legalAction','LIEN');
        taxLienDetailList.add(taxLienDetailMap);
        Map<String, Object> taxLienDetailMapTwo = new Map<String, Object>();
        taxLienDetailMapTwo.put('documentNumber','12345');
        taxLienDetailMapTwo.put('legalType','LIEN');
        taxLienDetailMapTwo.put('filingLocation','filingLocation');
        taxLienDetailMapTwo.put('liabilityAmount', 1000);
        taxLienDetailMapTwo.put('dateFiled','2021-03-01');
        taxLienDetailMapTwo.put('legalAction','LIEN');
        taxLienDetailList.add(taxLienDetailMapTwo);

        Test.startTest();
            Integer taxLiensLiabilityAmount = Experians.unifyingBusinessTaxLienDetail(taxLienDetailList);
        Test.stopTest();

        System.assertEquals(2000, taxLiensLiabilityAmount);
    }

    @isTest
    private static void unifyingBusinessJudgmentDetailTestMethod(){
        GeneralHelper.currentSystemDate = Date.newInstance(2021, 03, 01);

        List<Object> judgmentDetailList = new List<Object>();
        Map<String, Object> judgmentDetailMap = new Map<String, Object>();
        judgmentDetailMap.put('documentNumber','12345');
        judgmentDetailMap.put('legalType','legalType');
        judgmentDetailMap.put('filingLocation','filingLocation');
        judgmentDetailMap.put('liabilityAmount', '1000');
        judgmentDetailMap.put('dateFiled', '2021-01-01');
        judgmentDetailMap.put('legalAction', 'ABSTRACT');
        judgmentDetailList.add(judgmentDetailMap);
        Map<String, Object> judgmentDetailMapTwo = new Map<String, Object>();
        judgmentDetailMapTwo.put('documentNumber','12345');
        judgmentDetailMapTwo.put('legalType','legalType');
        judgmentDetailMapTwo.put('filingLocation','filingLocation');
        judgmentDetailMapTwo.put('liabilityAmount', '1000');
        judgmentDetailMapTwo.put('dateFiled', '2021-03-01');
        judgmentDetailMapTwo.put('legalAction', 'ABSTRACT');
        judgmentDetailList.add(judgmentDetailMapTwo);

        Test.startTest();
        Integer judgmentLiensLiabilityAmount = Experians.unifyingBusinessJudgmentDetail(judgmentDetailList);
        Test.stopTest();

        System.assertEquals(2000, judgmentLiensLiabilityAmount);
    }

    @isTest
    private static void setExperianBusinessDefaultReport() {
        Experian_Default_Credit_Report__mdt experianDefaultReport = new Experian_Default_Credit_Report__mdt();
        experianDefaultReport.Total_No_Trades_Count__c = 10;
        CustomMetaDataHelper.defaultExperianReport = experianDefaultReport;

        Account existingAccountDetail = new Account();
        existingAccountDetail.Id = TestUtility.getFakeId(Account.getSObjectType());

        Account newAccountDetail = new Account();
        newAccountDetail.Id = TestUtility.getFakeId(Account.getSObjectType());

        Credit_Report_Detail__c existingCreditReportDetail = new Credit_Report_Detail__c();
        existingCreditReportDetail.Type__c = GeneralConstants.CREDIT_REPORT_TYPE_EXPERIAN_BUSINESS;
        existingCreditReportDetail.Account__c = existingAccountDetail.Id;

        Map<Id, Credit_Report_Detail__c> existingCreditReportByAccountId = new Map<Id, Credit_Report_Detail__c>();
        existingCreditReportByAccountId.put(existingAccountDetail.Id, existingCreditReportDetail);

        Test.startTest();
            Credit_Report_Detail__c actualNewCreditReport = Experians.setExperianBusinessDefaultReport(
                newAccountDetail.Id, existingCreditReportByAccountId
            );
            Credit_Report_Detail__c actualExistingCreditReport = Experians.setExperianBusinessDefaultReport(
                existingAccountDetail.Id, existingCreditReportByAccountId
            );
        Test.stopTest();

        System.assertEquals(
            experianDefaultReport.Total_No_Trades_Count__c, actualNewCreditReport.Total_No_Trades_Count__c
        );
        System.assertEquals(
            experianDefaultReport.Total_No_Trades_Count__c, actualExistingCreditReport.Total_No_Trades_Count__c
        );
    }

    @isTest
    private static void createConsumerCreditReportDetail() {
        GeneralHelper.currentSystemDate = Date.newInstance(2021, 03, 01);

        Contact existingContactDetail = new Contact();
        existingContactDetail.Id = TestUtility.getFakeId(Contact.getSObjectType());

        Contact newContactDetail = new Contact();
        newContactDetail.Id = TestUtility.getFakeId(Contact.getSObjectType());

        Credit_Report_Detail__c existingCreditReportDetail = new Credit_Report_Detail__c();
        existingCreditReportDetail.Type__c = GeneralConstants.CREDIT_REPORT_TYPE_EXPERIAN_CONSUMER;
        existingCreditReportDetail.Contact__c = existingContactDetail.Id;

        Map<Id, Credit_Report_Detail__c> existingCreditReportByContactId = new Map<Id, Credit_Report_Detail__c>();
        existingCreditReportByContactId.put(existingContactDetail.Id, existingCreditReportDetail);

        List<Object> tradeLineList = new List<Object>();
        Map<String, Object> tradeLineMap = new Map<String, Object>();
            tradeLineMap.put('lastPaymentDate','01012021');
            tradeLineMap.put('openDate','01012020');
            tradeLineList.add(tradeLineMap);
        List<Object> statementList = new List<Object>();
        Map<String, Object> statementMap = new Map<String, Object>();
            statementMap.put('statementText','statementText');
            statementList.add(statementMap);
        List<Object> attributeList = new List<Object>();
        Map<String, Object> attributeMap = new Map<String, Object>();
            attributeMap.put('id','totalTradeItems');
            attributeMap.put('value',6000);
            attributeList.add(attributeMap);
        Map<String, Object> summaryMap = new Map<String, Object>();
            summaryMap.put('summaryType','Profile Summary');
            summaryMap.put('attributes',attributeList);
            tradeLineList.add(summaryMap);
        List<Object> bankruptcyDetailList = new List<Object>();
        Map<String, Object> bankruptcyDetailMap = new Map<String, Object>();
        bankruptcyDetailMap.put('referenceNumber','referenceNumber');
        bankruptcyDetailMap.put('filingDate','01012021');
        bankruptcyDetailMap.put('statusText','statusText');
        bankruptcyDetailList.add(bankruptcyDetailMap);
        List<Object> scoreFactorList = new List<Object>();
        Map<String, Object> scoreFactorMap = new Map<String, Object>();
        scoreFactorMap.put('code','10');
        scoreFactorMap.put('code','14');
        scoreFactorMap.put('code','33');
        scoreFactorList.add(scoreFactorMap);
        Map<String, Object> ficoScoreFactorMap = new Map<String, Object>();
        ficoScoreFactorMap.put('scoreFactors',scoreFactorList);
        Map<String, Object> contactCreditProfile = new Map<String, Object>();
        contactCreditProfile.put('statement',statementList);
        contactCreditProfile.put('BKScore',10);
        contactCreditProfile.put('OverallAmounttoBalanceRatio',15);
        contactCreditProfile.put('TotalNbrCreditInquiriesLast6months',30);
        contactCreditProfile.put('OpenRevolvingTradesCreditAmtRatio',35);
        contactCreditProfile.put('OpenRevolvingTradesinlast6months',40);
        contactCreditProfile.put('MortgageTrades>90daysDlqin12months',45);
        contactCreditProfile.put('MortgageTradesin12months',50);
        contactCreditProfile.put('Totalnoofcreditpersonalfinanceinquiries',45);
        contactCreditProfile.put('AvgmonthsTradesOpnExcludeCollections',55);
        contactCreditProfile.put('address','Test Address');
        contactCreditProfile.put('firstName','firstNameTest');
        contactCreditProfile.put('lastName','lastNameTest');
        contactCreditProfile.put('ssnNumber','ssnNumber');
        contactCreditProfile.put('dobYear',2020);
        contactCreditProfile.put('dobMonth',06);
        contactCreditProfile.put('dobDate',05);
        contactCreditProfile.put('FICOScore', 65);
        contactCreditProfile.put('totalLateMortgage', tradeLineList);
        contactCreditProfile.put('totalTradeItems', tradeLineList);
        contactCreditProfile.put('publicRecord',bankruptcyDetailList);
        contactCreditProfile.put('FICOScoreFactors',ficoScoreFactorMap);

        Test.startTest();
            Credit_Report_Detail__c actualExistingCreditReport = Experians.createConsumerCreditReportDetail(
                contactCreditProfile, existingContactDetail, existingCreditReportByContactId
            );
            Credit_Report_Detail__c actualNewCreditReport = Experians.createConsumerCreditReportDetail(
                contactCreditProfile, newContactDetail, existingCreditReportByContactId
            );
        Test.stopTest();

        System.assertEquals(65, actualNewCreditReport.Personal_FICO_Score__c);
        System.assertEquals(65, actualExistingCreditReport.Personal_FICO_Score__c);
    }

    @isTest
    private static void findHighestScoreReport() {
        Contact contactDetailOne = new Contact();
        contactDetailOne.Id = TestUtility.getFakeId(Contact.getSObjectType());

        Credit_Report_Detail__c existingCreditReportDetailOne = new Credit_Report_Detail__c();
        existingCreditReportDetailOne.Type__c = GeneralConstants.CREDIT_REPORT_TYPE_EXPERIAN_CONSUMER;
        existingCreditReportDetailOne.Contact__c = contactDetailOne.Id;
        existingCreditReportDetailOne.Personal_FICO_Score__c = 30;

        Contact contactDetailTwo = new Contact();
        contactDetailOne.Id = TestUtility.getFakeId(Contact.getSObjectType());

        Credit_Report_Detail__c existingCreditReportDetailTwo = new Credit_Report_Detail__c();
        existingCreditReportDetailTwo.Type__c = GeneralConstants.CREDIT_REPORT_TYPE_EXPERIAN_CONSUMER;
        existingCreditReportDetailTwo.Contact__c = contactDetailTwo.Id;
        existingCreditReportDetailTwo.Personal_FICO_Score__c = 50;

        Map<Id, Credit_Report_Detail__c> creditReportMap = new Map<Id, Credit_Report_Detail__c>();
        creditReportMap.put(contactDetailOne.Id, existingCreditReportDetailOne);
        creditReportMap.put(contactDetailTwo.Id, existingCreditReportDetailTwo);

        Map<String, Id> partyTypeToId = new Map<String, Id>();
        partyTypeToId.put(GeneralConstants.PARTY_TYPE_BORROWER, TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType()));
        OriginationHelper.partyTypeToId = partyTypeToId;

        clcommon__Party__c partyOne = new clcommon__Party__c();
        partyOne.clcommon__Contact__c = contactDetailOne.Id;
        partyOne.clcommon__Type__c = OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BORROWER);

        clcommon__Party__c partyTwo = new clcommon__Party__c();
        partyTwo.clcommon__Contact__c = contactDetailTwo.Id;
        partyTwo.clcommon__Type__c = OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BORROWER);

        Map<Id, clcommon__Party__c> partyByContactId = new  Map<Id, clcommon__Party__c>();
        partyByContactId.put(contactDetailOne.Id, partyOne);
        partyByContactId.put(contactDetailTwo.Id, partyTwo);

        Test.startTest();
            Credit_Report_Detail__c finalReport = Experians.findHighestScoreReport(
                new Set<Id>{contactDetailOne.Id, contactDetailTwo.Id}, creditReportMap, partyByContactId
            );
        Test.stopTest();

        System.assertEquals(existingCreditReportDetailTwo.Personal_FICO_Score__c, finalReport.Personal_FICO_Score__c);
        System.assertEquals(true, partyTwo.clcommon__isPrimary__c);
    }

    @isTest
    private static void prepareCreditReportMessage() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());

        Map<Id, String> contactIdToCreditReportMessage = new Map<Id, String>();
        contactIdToCreditReportMessage.put(contactRecord.Id, 'FILE FROZEN');

        clcommon__Party__c partyRecord = new clcommon__Party__c();
        partyRecord.clcommon__Contact__c = contactRecord.Id;

        Map<Id, clcommon__Party__c> partyByContactId = new  Map<Id, clcommon__Party__c>();
        partyByContactId.put(contactRecord.Id, partyRecord);

        Test.startTest();
            Experians.prepareCreditReportMessage(
                new Set<Id>{contactRecord.Id}, contactIdToCreditReportMessage, partyByContactId
            );
        Test.stopTest();

        System.assertEquals(contactIdToCreditReportMessage.get(contactRecord.Id), partyRecord.Credit_Report_Message__c);
    }

    @isTest
    private static void getContactAddresses() {

        Contact contactDetail = new Contact();
        contactDetail.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactDetail.Email = 'testcontact@example.com';

        Set<Id> contactIds =  new Set<Id>();
        contactIds.add(contactDetail.Id);

        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        contactMap.put(contactDetail.Id, contactDetail);

        Test.startTest();
            List<String> actualAddresses = Experians.getContactAddresses(contactMap, contactIds);
        Test.stopTest();

        System.assertEquals(new List<String> {contactDetail.Email}, actualAddresses);
    }

    @isTest
    private static void calculateTradeListDetails() {
        GeneralHelper.currentSystemDate = Date.newInstance(2021, 03, 01);

        Credit_Report_Detail__c consumerCreditReport = new Credit_Report_Detail__c();

        List<Object> tradeLineList = new List<Object>();
        Map<String, Object> tradeLineMap = new Map<String, Object>();
        tradeLineMap.put('lastPaymentDate', '01012021');
        tradeLineMap.put('openDate', '01012019');
        tradeLineMap.put('openOrClosedText', 'Open');
        tradeLineMap.put('accountType', 17);
        tradeLineMap.put('kob', 'BC');
        tradeLineMap.put('status', 82);
        tradeLineList.add(tradeLineMap);

        Test.startTest();
            Experians.calculateTradeListDetails(tradeLineList, consumerCreditReport);
        Test.stopTest();

        System.assertEquals(1, consumerCreditReport.Total_No_Late_Mortgage_Count__c);
        System.assertEquals(1, consumerCreditReport.No_Of_Open_Trades__c);
    }

    @isTest
    private static void checkLateMortgageAccountType(){

        Map<String, Object> lateMortgageAccountTypeMap = new Map<String, Object>();
        lateMortgageAccountTypeMap.put('accountType', 17);

        Map<String, Object> notLateMortgageAccountTypeMap = new Map<String, Object>();
        notLateMortgageAccountTypeMap.put('accountType', 100);

        Test.startTest();
            Boolean lateMortgageAccountType = Experians.checkLateMortgageAccountType(lateMortgageAccountTypeMap);
            Boolean notLateMortgageAccountType = Experians.checkLateMortgageAccountType(notLateMortgageAccountTypeMap);
        Test.stopTest();

        System.assertEquals(true, lateMortgageAccountType);
        System.assertEquals(false, notLateMortgageAccountType);
    }

    private static void checkLateMortgageKob(){

        Map<String, Object> lateMortgageKOBMap = new Map<String, Object>();
        lateMortgageKOBMap.put('kob','FR');

        Map<String, Object> notLateMortgageKOBMap = new Map<String, Object>();
        notLateMortgageKOBMap.put('kob', 'XXX');

        Test.startTest();
            Boolean lateMortgageKOB = Experians.checkLateMortgageKob(lateMortgageKOBMap);
            Boolean notLateMortgageKOB = Experians.checkLateMortgageKob(notLateMortgageKOBMap);
        Test.stopTest();

        System.assertEquals(true, lateMortgageKOB);
        System.assertEquals(false, notLateMortgageKOB);
    }

    private static void checkLateMortgageStatus(){

        Map<String, Object> lateMortgageStatusMap = new Map<String, Object>();
        lateMortgageStatusMap.put('status', 60);

        Map<String, Object> notLateMortgageStatusMap = new Map<String, Object>();
        notLateMortgageStatusMap.put('status', 100);

        Test.startTest();
            Boolean lateMortgageStatus = Experians.checkLateMortgageStatus(lateMortgageStatusMap);
            Boolean notLateMortgageStatus = Experians.checkLateMortgageStatus(notLateMortgageStatusMap);
        Test.stopTest();

        System.assertEquals(true, lateMortgageStatus);
        System.assertEquals(false, notLateMortgageStatus);
    }

    @isTest
    private static void calculateTotalTradeItems(){

        Credit_Report_Detail__c consumerCreditReport = new Credit_Report_Detail__c();

        List<Object> attributeList = new List<Object>();
        Map<String, Object> attributeMap = new Map<String, Object>();
        attributeMap.put('id', 'totalTradeItems');
        attributeMap.put('value', 400);
        attributeList.add(attributeMap);
        Map<String, Object> attributeMapTwo = new Map<String, Object>();
        attributeMapTwo.put('id', 'pastDueAmount');
        attributeMapTwo.put('value', 200);
        attributeList.add(attributeMapTwo);

        List<Object> summaries = new List<Object>();
        Map<String, Object> summaryMap = new Map<String, Object>();
        summaryMap.put('summaryType', 'Profile Summary');
        summaryMap.put('attributes', attributeList);
        summaries.add(summaryMap);

        Test.startTest();
            Experians.calculateTotalTradeItems(summaries, consumerCreditReport);
        Test.stopTest();

        System.assertEquals(400, consumerCreditReport.Total_No_Trades_Count__c );
        System.assertEquals(200, consumerCreditReport.Past_Due_Amount__c);
    }

    @isTest
    private static void unifyingConsumerBankruptcyDetailsOpen() {
        GeneralHelper.currentSystemDate = Date.newInstance(2021, 03, 01);

        Credit_Report_Detail__c consumerCreditReport = new Credit_Report_Detail__c();

        List<Object> bankruptcyDetailList = new List<Object>();
        Map<String, Object> bankruptcyDetailMap = new Map<String, Object>();
        bankruptcyDetailMap.put('referenceNumber','referenceNumber');
        bankruptcyDetailMap.put('filingDate','01022021');
        bankruptcyDetailMap.put('statusText','BANKRUPTCYCHAPTER13-PETITIONFILED');
        bankruptcyDetailList.add(bankruptcyDetailMap);

        Map<String, Object> bankruptcyDetailTwo = new Map<String, Object>();
        bankruptcyDetailTwo.put('referenceNumber','referenceNumber');
        bankruptcyDetailTwo.put('filingDate','01032021');
        bankruptcyDetailTwo.put('statusText','BANKRUPTCYCHAPTER13-PETITIONFILED');
        bankruptcyDetailList.add(bankruptcyDetailTwo);

        Test.startTest();
            Experians.unifyingConsumerBankruptcyDetails(bankruptcyDetailList, consumerCreditReport);
        Test.stopTest();

        System.assertEquals(true, consumerCreditReport.Is_Open_Bankruptcy__c);
    }

    @isTest
    private static void unifyingConsumerBankruptcyDetailsRecent() {
        GeneralHelper.currentSystemDate = Date.newInstance(2021, 03, 01);

        Credit_Report_Detail__c consumerCreditReport = new Credit_Report_Detail__c();

        List<Object> bankruptcyDetailList = new List<Object>();
        Map<String, Object> bankruptcyDetailMap = new Map<String, Object>();
        bankruptcyDetailMap.put('referenceNumber','referenceNumber');
        bankruptcyDetailMap.put('filingDate','01022021');
        bankruptcyDetailMap.put('statusText','BANKRUPTCYCHAPTER13-DISMISSED');
        bankruptcyDetailList.add(bankruptcyDetailMap);

        Map<String, Object> bankruptcyDetailTwo = new Map<String, Object>();
        bankruptcyDetailTwo.put('referenceNumber','referenceNumber');
        bankruptcyDetailTwo.put('filingDate','01032021');
        bankruptcyDetailTwo.put('statusText','BANKRUPTCYCHAPTER13-DISMISSED');
        bankruptcyDetailList.add(bankruptcyDetailTwo);

        Test.startTest();
            Experians.unifyingConsumerBankruptcyDetails(bankruptcyDetailList, consumerCreditReport);
        Test.stopTest();

        System.assertEquals(true, consumerCreditReport.Is_Recent_Bankruptcy__c);
    }

    @isTest
    private static void setExperianConsumerStatement(){

        Credit_Report_Detail__c consumerCreditReport = new Credit_Report_Detail__c();

        List<Object> statementList = new List<Object>();
        Map<String, Object> statementMap = new Map<String, Object>();
        statementMap.put('statementText', 'statementText');
        statementList.add(statementMap);

        Test.startTest();
            Experians.setExperianConsumerStatement(statementList, consumerCreditReport);
        Test.stopTest();

        System.assertEquals('statementText', consumerCreditReport.Credit_Statement__c);
    }

    @isTest
    private static void getCreditFreezeContactDetailsGuarantor(){
        GeneralHelper.currentSystemDate = Date.newInstance(2021, 03, 01);

        Account accountDetail = new Account();
        accountDetail.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountDetail.BillingBuildingNumber__c = '123';
        accountDetail.Name = 'Test';
        accountDetail.BillingStreet = 'Rand St';
        accountDetail.BillingCity = 'Chicago';
        accountDetail.BillingState = 'IL';
        accountDetail.BillingPostalCode = '12234';
        accountDetail.Email_cc__c = 'test@yopmail.com, test@mailnator.com';

        Contact contactDetail = new Contact();
        contactDetail.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactDetail.AccountId = accountDetail.Id;
        contactDetail.Email = 'test@example.com';
        contactDetail.FirstName = 'Test';
        contactDetail.LastName = 'Test';

        User salesRep = new User();
        salesRep.Id = TestUtility.getFakeId(User.getSObjectType());
        salesRep.Email = 'test1@yopmail.com';

        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Id = TestUtility.getFakeId(Opportunity.getSObjectType());
        newOpportunity.Offer_Notification_To_Guarantor__c = true;
        newOpportunity.Offer_Notification_To_Broker__c = true;

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.Opportunity__c = newOpportunity.Id;
        application.Opportunity__r = newOpportunity;
        application.Sales_Rep__c = salesRep.Id;
        application.Sales_Rep__r = salesRep;

        Map<String, Id> partyTypeToId = new Map<String, Id>();
        partyTypeToId.put(GeneralConstants.PARTY_TYPE_BORROWER, TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType()));
        OriginationHelper.partyTypeToId = partyTypeToId;

        String creditReportIssueMessage = 'FILE FROZEN, FILE LOCKED, NO RECORD FOUND';

        Test.startTest();
            Map<String, Map<String, String>> creditFreezeContactDetail = Experians.getCreditFreezeContactDetails(
                contactDetail,accountDetail, String.valueOf(GeneralHelper.currentSystemDate.addDays(30)),
                null, creditReportIssueMessage, application
            );
        Test.stopTest();

        System.assert(creditFreezeContactDetail.containsKey('guarantor'));
    }

    @isTest
    private static void getScoringEmailDetailsGuarantorTestMethod(){
        GeneralHelper.currentSystemDate = Date.newInstance(2021, 03, 01);

        EmailTemplate emailTemplate = new EmailTemplate();
        emailTemplate.Subject = 'Test Subject';
        emailTemplate.HtmlValue = '<Html> TEst </Html>';

        Document documentRecord = new Document();
        documentRecord.Id = TestUtility.getFakeId(Document.getSObjectType());

        List<Document> documentList = new List<Document>();
        documentList.add(documentRecord);

        Account accountDetail = new Account();
        accountDetail.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountDetail.BillingBuildingNumber__c = '123';
        accountDetail.Name = 'Test';
        accountDetail.BillingStreet = 'Rand St';
        accountDetail.BillingCity = 'Chicago';
        accountDetail.BillingState = 'IL';
        accountDetail.BillingPostalCode = '12234';
        accountDetail.Email_cc__c = 'test@yopmail.com, test@mailnator.com';

        Contact contactDetail = new Contact();
        contactDetail.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactDetail.AccountId = accountDetail.Id;
        contactDetail.Email = 'test@example.com';
        contactDetail.FirstName = 'Test';
        contactDetail.LastName = 'Test';

        User salesRep = new User();
        salesRep.Id = TestUtility.getFakeId(User.getSObjectType());
        salesRep.Email = 'test1@yopmail.com';

        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Id = TestUtility.getFakeId(Opportunity.getSObjectType());
        newOpportunity.Offer_Notification_To_Guarantor__c = true;
        newOpportunity.Offer_Notification_To_Broker__c = true;

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.Opportunity__c = newOpportunity.Id;
        application.Opportunity__r = newOpportunity;
        application.Sales_Rep__c = salesRep.Id;
        application.Sales_Rep__r = salesRep;

        Map<String, Id> partyTypeToId = new Map<String, Id>();
        partyTypeToId.put(GeneralConstants.PARTY_TYPE_BORROWER, TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType()));
        OriginationHelper.partyTypeToId = partyTypeToId;

        String creditReportIssueMessage = 'FILE FROZEN, FILE LOCKED, NO RECORD FOUND';

        Map<String, Map<String, String>> scoringIssueEmailDetails = Experians.getCreditFreezeContactDetails(
            contactDetail,accountDetail, String.valueOf(GeneralHelper.currentSystemDate.addDays(30)),
            null, creditReportIssueMessage, application
        );

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

        Test.startTest();
            Experians.getScoringEmailDetails(emailList, scoringIssueEmailDetails, emailTemplate, documentList);
        Test.stopTest();

        System.assertEquals(1, emailList.size());
    }

    @isTest
    private static void getCreditFreezeContactDetailsBroker(){
        GeneralHelper.currentSystemDate = Date.newInstance(2021, 03, 01);

        Account accountDetail = new Account();
        accountDetail.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountDetail.BillingBuildingNumber__c = '123';
        accountDetail.Name = 'Test';
        accountDetail.BillingStreet = 'Rand St';
        accountDetail.BillingCity = 'Chicago';
        accountDetail.BillingState = 'IL';
        accountDetail.BillingPostalCode = '12234';
        accountDetail.Email_cc__c = 'test@yopmail.com, test@mailnator.com';

        Contact contactDetail = new Contact();
        contactDetail.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactDetail.AccountId = accountDetail.Id;
        contactDetail.Email = 'test@example.com';
        contactDetail.FirstName = 'Test';
        contactDetail.LastName = 'Test';

        User salesRep = new User();
        salesRep.Id = TestUtility.getFakeId(User.getSObjectType());
        salesRep.Email = 'test1@yopmail.com';

        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Id = TestUtility.getFakeId(Opportunity.getSObjectType());
        newOpportunity.Offer_Notification_To_Guarantor__c = true;
        newOpportunity.Offer_Notification_To_Broker__c = true;

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.Broker_Contact__c = contactDetail.Id;
        application.Broker_Contact__r = contactDetail;
        application.Opportunity__c = newOpportunity.Id;
        application.Opportunity__r = newOpportunity;
        application.Sales_Rep__c = salesRep.Id;
        application.Sales_Rep__r = salesRep;

        Map<String, Id> partyTypeToId = new Map<String, Id>();
        partyTypeToId.put(GeneralConstants.PARTY_TYPE_BORROWER, TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType()));
        OriginationHelper.partyTypeToId = partyTypeToId;

        clcommon__Party__c party = new clcommon__Party__c();
        party.clcommon__Account__c = accountDetail.Id;
        party.clcommon__Account__r = accountDetail;
        party.clcommon__Contact__c = contactDetail.Id;
        party.clcommon__Contact__r = contactDetail;
        party.clcommon__Type__c = OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BROKER);
        party.Beneficial_Owner_Type__c = 'Beneficial Owner';

        String creditReportIssueMessage = 'FILE FROZEN, FILE LOCKED, NO RECORD FOUND';

        Test.startTest();
            Map<String, Map<String, String>> creditFreezeContactDetail = Experians.getCreditFreezeContactDetails(
                contactDetail,accountDetail, String.valueOf(GeneralHelper.currentSystemDate.addDays(30)),
                party, creditReportIssueMessage, application
            );
        Test.stopTest();

        System.assert(creditFreezeContactDetail.containsKey('broker'));
    }

    @isTest
    private static void getScoringEmailDetailsBrokerTestMethod(){
        GeneralHelper.currentSystemDate = Date.newInstance(2021, 03, 01);

        EmailTemplate emailTemplate = new EmailTemplate();
        emailTemplate.Subject = 'Test Subject';
        emailTemplate.HtmlValue = '<Html> TEst </Html>';

        Document documentRecord = new Document();
        documentRecord.Id = TestUtility.getFakeId(Document.getSObjectType());

        List<Document> documentList = new List<Document>();
        documentList.add(documentRecord);

        Account accountDetail = new Account();
        accountDetail.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountDetail.BillingBuildingNumber__c = '123';
        accountDetail.Name = 'Test';
        accountDetail.BillingStreet = 'Rand St';
        accountDetail.BillingCity = 'Chicago';
        accountDetail.BillingState = 'IL';
        accountDetail.BillingPostalCode = '12234';
        accountDetail.Email_cc__c = 'test@yopmail.com, test@mailnator.com';

        Contact contactDetail = new Contact();
        contactDetail.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactDetail.AccountId = accountDetail.Id;
        contactDetail.Email = 'test@example.com';
        contactDetail.FirstName = 'Test';
        contactDetail.LastName = 'Test';

        User salesRep = new User();
        salesRep.Id = TestUtility.getFakeId(User.getSObjectType());
        salesRep.Email = 'test1@yopmail.com';

        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Id = TestUtility.getFakeId(Opportunity.getSObjectType());
        newOpportunity.Offer_Notification_To_Guarantor__c = true;
        newOpportunity.Offer_Notification_To_Broker__c = true;

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.Broker_Contact__c = contactDetail.Id;
        application.Broker_Contact__r = contactDetail;
        application.Opportunity__c = newOpportunity.Id;
        application.Opportunity__r = newOpportunity;
        application.Sales_Rep__c = salesRep.Id;
        application.Sales_Rep__r = salesRep;

        Map<String, Id> partyTypeToId = new Map<String, Id>();
        partyTypeToId.put(GeneralConstants.PARTY_TYPE_BORROWER, TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType()));
        OriginationHelper.partyTypeToId = partyTypeToId;

        clcommon__Party__c party = new clcommon__Party__c();
        party.clcommon__Account__c = accountDetail.Id;
        party.clcommon__Account__r = accountDetail;
        party.clcommon__Contact__c = contactDetail.Id;
        party.clcommon__Contact__r = contactDetail;
        party.clcommon__Type__c = OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BROKER);
        party.Beneficial_Owner_Type__c = 'Beneficial Owner';

        String creditReportIssueMessage = 'FILE FROZEN, FILE LOCKED, NO RECORD FOUND';

        Map<String, Map<String, String>> scoringIssueEmailDetails = Experians.getCreditFreezeContactDetails(
            contactDetail,accountDetail, String.valueOf(GeneralHelper.currentSystemDate.addDays(30)),
            party, creditReportIssueMessage, application
        );

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

        Test.startTest();
            Experians.getScoringEmailDetails(emailList, scoringIssueEmailDetails, emailTemplate, documentList);
        Test.stopTest();

        System.assertEquals(1, emailList.size());
    }
}