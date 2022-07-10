public class Experians {

    public static final String EXPERIAN_BUSINESS_API_SANDBOX = 'Experian_Business_API_Sandbox';
    public static final String EXPERIAN_BUSINESS_API_PRODUCTION = 'Experian_Business_API_Production';
    public static final String EXPERIAN_CONSUMER_API_SANDBOX = 'Experian_Consumer_API_Sandbox';
    public static final String EXPERIAN_CONSUMER_API_PRODUCTION = 'Experian_Consumer_API_Production';
    public static final String EXPERIAN_TEMPLATE_NAME = 'Experian_Credit_Freeze_Letter';
    public static final String CAN_CAPITAL_LOGO = 'CAN_CAPITAL_IMAGE';
    public static final String EXPERIAN_GENERIC_STATUS = 'is either frozen, locked or otherwise inaccessible';
    public static final String EXPERIAN_GENERIC_REPORT = 'Please remove the credit freeze or lock on the Personal Guarantor’s Experian credit report and then';
    public static final String EXPERIAN_WEB_BANK_ADDRESS = ', Salt Lake City, Utah';
    public static final String EXPERIAN_FROZEN_STATUS = 'is frozen';
    public static final String EXPERIAN_LOCK_STATUS = 'is locked';
    public static final String EXPERIAN_NOT_FOUND_STATUS = 'cannot be found based on the provided data';
    public static final String EXPERIAN_MERCHANT_CREDIT_FREEZE = 'Please remove the credit freeze on the Personal Guarantor’s Experian credit report and then ';
    public static final String EXPERIAN_BROKER_CREDIT_FREEZE = 'Once the credit freeze on the Personal Guarantor’s Experian credit report has been lifted, respond to this email or ';
    public static final String EXPERIAN_MERCHANT_CREDIT_LOCK = 'Please remove the lock on the Personal Guarantor’s Experian credit report and then ';
    public static final String EXPERIAN_BROKER_CREDIT_LOCK = 'Once the lock on the Personal Guarantor’s Experian credit report has been removed, respond to this email or ';
    public static final String EXPERIAN_MERCHANT_CREDIT_NOT_FOUND = 'Please confirm the information above for the Personal Guarantor and then ';
    public static final String EXPERIAN_BROKER_CREDIT_NOT_FOUND = 'Please confirm the information above for the Personal Guarantor by responding to this email or ';
    public static final String EXPERIAN_CREDIT_NOT_FOUND_DETAILS = '<br><ul style="list-style:circle"><li>Confirm the following information for the Personal Guarantor:<ul style="list-style:square"><li>First and Last Name</li><li>Residential Address</li><li>Social Security Number</li><li>Date of Birth</li></ul></li></ul>';
    public static final String AAN_MODE_EMAIL = 'Email';
    public static final String AAN_MODE_COMPUMAIL = 'CompuMail';

    public static API_Detail__mdt experianBusinessAPIDetails {
        get {
            if(experianBusinessAPIDetails == null) {
                if(GeneralHelper.getOrgInformation.isSandbox){
                    experianBusinessAPIDetails = CustomMetaDataHelper.apiDetailsByName.get(EXPERIAN_BUSINESS_API_SANDBOX);
                } else {
                    experianBusinessAPIDetails = CustomMetaDataHelper.apiDetailsByName.get(EXPERIAN_BUSINESS_API_PRODUCTION);
                }
            }
            return experianBusinessAPIDetails;
        }
        set;
    }

    public static API_Detail__mdt experianConsumerAPIDetails {
        get {
            if(experianConsumerAPIDetails == null) {
                if(GeneralHelper.getOrgInformation.isSandbox){
                    experianConsumerAPIDetails = CustomMetaDataHelper.apiDetailsByName.get(EXPERIAN_CONSUMER_API_SANDBOX);
                } else {
                    experianConsumerAPIDetails = CustomMetaDataHelper.apiDetailsByName.get(EXPERIAN_CONSUMER_API_PRODUCTION);
                }
            }
            return experianConsumerAPIDetails;
        }
        set;
    }

    public static Credit_Report_Detail__c createBusinessCreditReportDetail(
        Map<String, Object> accountBusinessSearch, Map<String, Object> accountCreditProfile, Map<String, Object> accountCreditAggregates,
        Account accountDetail, Map<Id, Credit_Report_Detail__c> existingCreditReportByAccountId
    ) {
        Credit_Report_Detail__c businessCreditReport;

        if(existingCreditReportByAccountId.containsKey(accountDetail.Id)) {
            businessCreditReport = existingCreditReportByAccountId.get(accountDetail.Id);
        } else {
            businessCreditReport = new Credit_Report_Detail__c();
            businessCreditReport.Type__c = GeneralConstants.CREDIT_REPORT_TYPE_EXPERIAN_BUSINESS;
            businessCreditReport.Account__c = accountDetail.Id;
        }

        businessCreditReport.BIN__c = String.valueOf(accountBusinessSearch.get('bin'));
        businessCreditReport.Reliability_Code__c = Integer.valueOf(accountBusinessSearch.get('reliabilityCode'));

        businessCreditReport.Months_Since_Biz_Added_To_Experian__c = accountCreditAggregates.get('TTO077') != null ?
            Integer.valueOf(accountCreditAggregates.get('TTO077')) : 0;

        businessCreditReport.Trades_Count_DBT_30_Plus__c = accountCreditAggregates.get('TTC058')!= null ?
            Integer.valueOf(accountCreditAggregates.get('TTC058')) : 0;

        businessCreditReport.Most_Recent_Open_Collections_Trade_Age__c = accountCreditAggregates.get('CLO015') != null ?
            Integer.valueOf(accountCreditAggregates.get('CLO015')) : 0;

        businessCreditReport.SIC_Code__c = accountCreditAggregates.get('DMO013') != null ? String.valueOf(accountCreditAggregates.get('DMO013')) : null;

        businessCreditReport.Total_No_Trades_Count__c = accountCreditProfile.get('allTradelineCount') != null ?
            Integer.valueOf(accountCreditProfile.get('allTradelineCount')) : 0;

        businessCreditReport.Business_Start_Date__c = accountCreditProfile.get('fileEstablishedDate') != null?
                                                    Date.ValueOf(accountCreditProfile.get('fileEstablishedDate')) : null;
        businessCreditReport.Legal_Name__c = accountCreditProfile.get('legalBusinessName') != null ?
                                                    String.valueOf(accountCreditProfile.get('legalBusinessName')) : null;
        businessCreditReport.Street__c = accountCreditProfile.get('street') != null ?
                                                    String.valueOf(accountCreditProfile.get('street')) : null;
        businessCreditReport.City__c = accountCreditProfile.get('city') != null ?
                                                    String.valueOf(accountCreditProfile.get('city')) : null;
        businessCreditReport.State__c =accountCreditProfile.get('state') != null ?
                                                    String.valueOf(accountCreditProfile.get('state')) : null;
        businessCreditReport.Zip__c = accountCreditProfile.get('zip') != null ?
                                                    String.valueOf(accountCreditProfile.get('zip')) : null;
        businessCreditReport.ZipExtension__c = accountCreditProfile.get('zipExtension') != null ?
                                                    String.valueOf(accountCreditProfile.get('zipExtension')) : null;
        businessCreditReport.Industry_Type__c = accountCreditProfile.get('businessType') != null ?
                                                    String.valueOf(accountCreditProfile.get('businessType')) : null;
        businessCreditReport.Tax_ID__c = accountCreditProfile.get('taxId') != null ?
                                                    String.valueOf(accountCreditProfile.get('taxId')) : null;

        if(accountCreditProfile.get('tradePaymentExperiences') != null) {
            businessCreditReport.Financial_Services_Charge_off__c = validateFinancialServicesChargeOff(
                (List<Object>) accountCreditProfile.get('tradePaymentExperiences')
            );
        }

        if(accountCreditProfile.get('bankruptcyDetail') != null) {
            unifyingBusinessBankruptcyDetails((List<Object>) accountCreditProfile.get('bankruptcyDetail'), businessCreditReport);
        }
        if(accountCreditProfile.get('taxLienDetail') != null) {
            businessCreditReport.Tax_Liens__c = unifyingBusinessTaxLienDetail((List<Object>) accountCreditProfile.get('taxLienDetail'));
        }
        if(accountCreditProfile.get('judgmentDetail') != null) {
            businessCreditReport.Judgement_Liens__c = unifyingBusinessJudgmentDetail((List<Object>) accountCreditProfile.get('judgmentDetail'));
        }
        if(accountCreditProfile.get('judgmentDetail') != null && !OriginationHelper.competitorAccountNames.isEmpty()) {
            businessCreditReport.Competitor_Judgement__c = competitorJudgementIdentification(
                (List<Object>) accountCreditProfile.get('judgmentDetail')
            );
        }

        if(accountCreditProfile.get('collectionsDetail') != null) {
            calculatingCollectionDetail((List<Object>) accountCreditProfile.get('collectionsDetail'), businessCreditReport);
        } else {
            businessCreditReport.Total_Collection_Amount__c = 0;
        }

        return businessCreditReport;
    }

    @TestVisible
    private static Boolean competitorJudgementIdentification(List<Object> judgmentDetailList) {
        for(Object judgmentDetail : judgmentDetailList) {
            Map<String, Object> judgmentDetailMap = (Map<String, Object>) judgmentDetail;
            if(judgmentDetailMap.get('plaintiffName') != null) {
                String plaintiffName = String.ValueOf(judgmentDetailMap.get('plaintiffName')).replaceAll('\\s', '').toUpperCase();
                if(OriginationHelper.competitorAccountNames.contains(plaintiffName)) {
                    return true;
                }
            }
        }

        return false;
    }

    @TestVisible
    private static void calculatingCollectionDetail(List<Object> collectionDetails, Credit_Report_Detail__c businessCreditReport) {
        Integer totalCollectionAmount = 0;
        for(Object collection : collectionDetails) {
            Map<String, Object> collectionMap = (Map<String, Object>) collection;
            if(collectionMap.get('accountStatus') == 'Open Account') {
                totalCollectionAmount +=
                    Integer.valueOf(collectionMap.get('amountPlacedForCollection')) - Integer.valueOf(collectionMap.get('amountPaid'));
            }
        }

        businessCreditReport.Total_Collection_Amount__c = totalCollectionAmount;
    }

    @TestVisible
    private static Boolean validateFinancialServicesChargeOff(List<Object> tradePaymentExperienceList) {
        for (Object tradePaymentExperience: tradePaymentExperienceList) {
            Map<String, Object> tradePaymentExperienceMap = (Map<String, Object>) tradePaymentExperience;
            Map<String, Object> recentHighCredit = (Map<String, Object>) tradePaymentExperienceMap.get('recentHighCredit');
            Integer amount = recentHighCredit.get('amount') != null?
                Integer.ValueOf(recentHighCredit.get('amount')) : 0;
            String comments = tradePaymentExperienceMap.get('comments') != null?
                String.ValueOf(tradePaymentExperienceMap.get('comments')).replaceAll('\\s', '') : null;
            String businessCategory = tradePaymentExperienceMap.get('businessCategory') != null?
                String.ValueOf(tradePaymentExperienceMap.get('businessCategory')).replaceAll('\\s', '') : null;

            if(businessCategory == 'FINCLSVCS' && comments == 'CHARGEOFF' && amount >= 5000) {
                return true;
            }
        }
        return false;
    }

    @TestVisible
    private static void unifyingBusinessBankruptcyDetails(List<Object> bankruptcyDetailList, Credit_Report_Detail__c businessCreditReport) {
        Set<String> closedBankruptcyActions = new Set<String> {
            'FULLRELEASE', 'RELEASED', 'TERMINATED', 'SATISFIED', 'VACATED', 'AMENDED', 'ASSIGNED', 'PARTIALRELEASE', 'CONTINUED',
            'CHAPTER7DISMISSED', 'CHAPTER11DISMISSED', 'CHAPTER13COMPLETED', 'CHAPTER13DISMISSED',
            'CHAPTER12DISMISSED', 'CHAPTER10-DISMISSED', 'CHAPTER10–CLOSED', 'CHAPTER7-CLOSED',
            'CHAPTER11-CLOSED', 'CHAPTER12–CLOSED', 'CHAPTER13–CLOSED'
        };
        Set<String> openBankruptcyActions = new Set<String> {
            'FILED', 'ABSTRACT', 'CHAPTER7INVOLUNTARY', 'CHAPTER7VOLUNTARY', 'CHAPTER7', 'CHAPTER11INVOLUNTARY', 'CHAPTER11VOLUNTARY',
            'CHAPTER11', 'INVOLUNTARY', 'VOLUNTARY', 'CHAPTER13', 'CHAPTER12', 'CHAPTER10'
        };
        Map<String, Date> documentDocumentNumberToDate = new Map<String, Date>();
        Map<String, Boolean> documentNumberToIsRecent = new Map<String, Boolean>();
        Map<String, Boolean> documentNumberToIsOpen = new Map<String, Boolean>();

        for(Object bankruptcyDetail : bankruptcyDetailList) {
            Map<String, Object> bankruptcyDetailMap = (Map<String, Object>) bankruptcyDetail;
            String documentNumber = String.ValueOf(bankruptcyDetailMap.get('documentNumber'));
            Date dateFiled = GeneralHelper.getDateFromUntypedString(String.ValueOf(bankruptcyDetailMap.get('dateFiled')), 0, 1, 2, '-');
            String legalAction = String.valueOf(bankruptcyDetailMap.get('legalAction'));

            if(!documentDocumentNumberToDate.containsKey(documentNumber)) {
                documentDocumentNumberToDate.put(documentNumber, dateFiled);
                if((getValidBankruptcyCount(legalAction, closedBankruptcyActions) || getValidBankruptcyCount(legalAction, openBankruptcyActions))
                    && dateFiled > GeneralHelper.currentSystemDate.addMonths(-24)
                ) {
                    documentNumberToIsRecent.put(documentNumber, true);
                }
                if(getValidBankruptcyCount(legalAction, openBankruptcyActions)) {
                    documentNumberToIsOpen.put(documentNumber, true);
                }
            } else if(documentDocumentNumberToDate.containsKey(documentNumber)
                && dateFiled > documentDocumentNumberToDate.get(documentNumber)
            ) {
                documentDocumentNumberToDate.put(documentNumber, dateFiled);
                if((getValidBankruptcyCount(legalAction, closedBankruptcyActions) || getValidBankruptcyCount(legalAction, openBankruptcyActions))
                    && dateFiled > GeneralHelper.currentSystemDate.addMonths(-24)
                ) {
                    documentNumberToIsRecent.put(documentNumber, true);
                }
                if(getValidBankruptcyCount(legalAction, openBankruptcyActions)) {
                    documentNumberToIsOpen.put(documentNumber, true);
                } else if(getValidBankruptcyCount(legalAction, closedBankruptcyActions)) {
                    documentNumberToIsOpen.put(documentNumber, false);
                }
            }
        }

        businessCreditReport.Is_Recent_Bankruptcy__c = documentNumberToIsRecent.values().contains(true);
        businessCreditReport.Is_Open_Bankruptcy__c = documentNumberToIsOpen.values().contains(true);
    }

    @TestVisible
    private static Integer unifyingBusinessTaxLienDetail(List<Object> taxLienDetailList) {
        Set<String> openTaxLienActions = new Set<String> {
            'LIEN'
        };
        Integer taxLiensLiabilityAmount = 0;
        Map<String, Date> taxLienKeyToDate = new Map<String, Date>();

        for(Object taxLienDetail : taxLienDetailList) {
            Map<String, Object> taxLienDetailMap = (Map<String, Object>) taxLienDetail;
            String key = String.ValueOf(taxLienDetailMap.get('legalType'))
                + String.ValueOf(taxLienDetailMap.get('filingLocation')) + String.ValueOf(taxLienDetailMap.get('liabilityAmount'));
            Date dateFiled = GeneralHelper.getDateFromUntypedString(String.ValueOf(taxLienDetailMap.get('dateFiled')), 0, 1, 2, '-');

            if(!taxLienKeyToDate.containsKey(key)) {
                taxLienKeyToDate.put(key, dateFiled);
                taxLiensLiabilityAmount += getBusinessJudgmentAndTaxLienLiabilityAmount(taxLienDetailMap, openTaxLienActions);
            } else if(taxLienKeyToDate.containsKey(key) && dateFiled > taxLienKeyToDate.get(key)) {
                taxLienKeyToDate.put(key, dateFiled);
                taxLiensLiabilityAmount += getBusinessJudgmentAndTaxLienLiabilityAmount(taxLienDetailMap, openTaxLienActions);
            }
        }

        return taxLiensLiabilityAmount;
    }

    @TestVisible
    private static Integer unifyingBusinessJudgmentDetail(List<Object> judgmentDetailList) {
        Set<String> openJudgmentActions = new Set<String> {
            'FILED', 'ABSTRACT'
        };
        Integer judgmentLiensLiabilityAmount = 0;
        Map<String, Date> judgmentKeyToDate = new Map<String, Date>();

        for(Object judgmentDetail : judgmentDetailList) {
            Map<String, Object> judgmentDetailMap = (Map<String, Object>) judgmentDetail;
            String key = String.ValueOf(judgmentDetailMap.get('legalType'))
                + String.ValueOf(judgmentDetailMap.get('filingLocation')) + String.ValueOf(judgmentDetailMap.get('liabilityAmount'));
            Date dateFiled = GeneralHelper.getDateFromUntypedString(String.ValueOf(judgmentDetailMap.get('dateFiled')), 0, 1, 2, '-');

            if(!judgmentKeyToDate.containsKey(key)) {
                judgmentKeyToDate.put(key, dateFiled);
                judgmentLiensLiabilityAmount += getBusinessJudgmentAndTaxLienLiabilityAmount(judgmentDetailMap, openJudgmentActions);
            } else if(judgmentKeyToDate.containsKey(key) && dateFiled > judgmentKeyToDate.get(key)
            ) {
                judgmentKeyToDate.put(key, dateFiled);
                judgmentLiensLiabilityAmount += getBusinessJudgmentAndTaxLienLiabilityAmount(judgmentDetailMap, openJudgmentActions);
            }
        }

        return judgmentLiensLiabilityAmount;
    }

    @TestVisible
    private static Integer getBusinessJudgmentAndTaxLienLiabilityAmount(Map<String, Object> judgmentDetailMap, Set<String> validStatuses) {
        if(judgmentDetailMap.get('legalAction') != null
            && validStatuses.contains(String.valueOf(judgmentDetailMap.get('legalAction')).replaceAll('\\s','').toUpperCase())) {
            return judgmentDetailMap.get('liabilityAmount') != null? Integer.ValueOf(judgmentDetailMap.get('liabilityAmount')) : 0;
        } else {
            return 0;
        }
    }

    @TestVisible
    private static Boolean getValidBankruptcyCount(String status, Set<String> validStatuses) {
        if(status != null && validStatuses.contains(status.replaceAll('\\s','').toUpperCase())) {
              return true;
        } else {
            return false;
        }
    }

    public static  Credit_Report_Detail__c setExperianBusinessDefaultReport(
        Id accountId, Map<Id, Credit_Report_Detail__c> creditReportByAccountId
    ) {
        Experian_Default_Credit_Report__mdt experianDefaultReport = CustomMetaDataHelper.defaultExperianReport;
        Credit_Report_Detail__c creditReport;

        if(creditReportByAccountId.containsKey(accountId)) {
            creditReport = creditReportByAccountId.get(accountId);
        } else {
            creditReport = new Credit_Report_Detail__c();
            creditReport.Type__c = GeneralConstants.CREDIT_REPORT_TYPE_EXPERIAN_BUSINESS;
            creditReport.Account__c = accountId;
        }

        creditReport.Months_Since_Biz_Added_To_Experian__c = experianDefaultReport.Months_Since_Biz_Added_To_Experian__c;
        creditReport.Trades_Count_DBT_30_Plus__c = experianDefaultReport.Trades_Count_DBT_30_Plus__c;
        creditReport.Most_Recent_Open_Collections_Trade_Age__c = experianDefaultReport.Most_Recent_Open_Collections_Trade_Age__c;
        creditReport.SIC_Code__c = experianDefaultReport.Business_Report_Sic_Code__c;
        creditReport.Total_No_Trades_Count__c = experianDefaultReport.Total_No_Trades_Count__c;
        creditReport.Business_Start_Date__c = null;
        creditReport.Industry_Type__c = null;
        creditReport.Tax_ID__c = null;
        creditReport.Financial_Services_Charge_off__c = experianDefaultReport.Financial_Services_ChargeOff__c;
        creditReport.Is_Recent_Bankruptcy__c = false;
        creditReport.Is_Open_Bankruptcy__c = false;
        creditReport.Tax_Liens__c = 0;
        creditReport.Judgement_Liens__c = 0;
        creditReport.Competitor_Judgement__c = experianDefaultReport.Competitors_Judgement__c;

        return creditReport;
    }

    public static Credit_Report_Detail__c createConsumerCreditReportDetail(
        Map<String, Object> contactCreditProfile, Contact contactDetail, Map<Id, Credit_Report_Detail__c> existingCreditReportByContactIdMap
    ) {

        Credit_Report_Detail__c consumerCreditReport;
        if(existingCreditReportByContactIdMap.containsKey(contactDetail.Id)) {
            consumerCreditReport = existingCreditReportByContactIdMap.get(contactDetail.Id);
        } else {
            consumerCreditReport = new Credit_Report_Detail__c();
            consumerCreditReport.Type__c = GeneralConstants.CREDIT_REPORT_TYPE_EXPERIAN_CONSUMER;
            consumerCreditReport.Contact__c = contactDetail.Id;
        }

        if(contactCreditProfile.containsKey('statement')) {
            setExperianConsumerStatement((List<Object>) contactCreditProfile.get('statement'), consumerCreditReport);
        }

        if(consumerCreditReport.Credit_Statement__c == null
            || (!consumerCreditReport.Credit_Statement__c.contains('FILE FROZEN') && !consumerCreditReport.Credit_Statement__c.contains('FILE LOCKED') || !consumerCreditReport.Credit_Statement__c.contains('NO RECORD FOUND'))
        ) {
            consumerCreditReport.Bankruptcy_Risk_Score__c = contactCreditProfile.get('BKScore') != null ?
                Integer.valueOf(contactCreditProfile.get('BKScore')) : 0;
            consumerCreditReport.Overall_Amount_Balance_Ratio__c = contactCreditProfile.get('OverallAmounttoBalanceRatio') != null ?
                Integer.valueOf(contactCreditProfile.get('OverallAmounttoBalanceRatio')) : 0;
            consumerCreditReport.Total_Credit_Inquiries_Last_6_Months__c = contactCreditProfile.get('TotalNbrCreditInquiriesLast6months') != null ?
                Integer.valueOf(contactCreditProfile.get('TotalNbrCreditInquiriesLast6months')) : 0;
            consumerCreditReport.Open_Revolving_Trades_CreditRatio_100__c = contactCreditProfile.get('OpenRevolvingTradesCreditAmtRatio') != null ?
                Integer.valueOf(contactCreditProfile.get('OpenRevolvingTradesCreditAmtRatio')) : 0;
            consumerCreditReport.Open_Revolving_Trades_Last_6_Months__c= contactCreditProfile.get('OpenRevolvingTradesinlast6months') != null ?
                Integer.valueOf(contactCreditProfile.get('OpenRevolvingTradesinlast6months')) : 0;
            consumerCreditReport.Mortgage_Trades_90Days_Dlq_In_12_months__c = contactCreditProfile.get('MortgageTrades>90daysDlqin12months') != null ?
                Integer.valueOf(contactCreditProfile.get('MortgageTrades>90daysDlqin12months')) : 0;
            consumerCreditReport.Mortgage_Trades_In_12Months__c = contactCreditProfile.get('MortgageTradesin12months') != null ?
                Integer.valueOf(contactCreditProfile.get('MortgageTradesin12months')) : 0;
            consumerCreditReport.Total_Credit_Personal_Finance_Inquires__c = contactCreditProfile.get('Totalnoofcreditpersonalfinanceinquiries') != null ?
                Integer.valueOf(contactCreditProfile.get('Totalnoofcreditpersonalfinanceinquiries')) : 0;
            consumerCreditReport.Avg_Months_Trds_Opn_Excl_Collections__c = contactCreditProfile.get('AvgmonthsTradesOpnExcludeCollections') != null ?
                Integer.valueOf(contactCreditProfile.get('AvgmonthsTradesOpnExcludeCollections')) : 0;
            consumerCreditReport.Address__c = contactCreditProfile.get('address') != null ?
                                                String.valueOf(contactCreditProfile.get('address')) : null;
            consumerCreditReport.First_Name__c = contactCreditProfile.get('firstName') != null ?
                                                String.valueOf(contactCreditProfile.get('firstName')) : null;
            consumerCreditReport.Last_Name__c = contactCreditProfile.get('lastName') != null ?
                                                String.valueOf(contactCreditProfile.get('lastName')) : null;
            consumerCreditReport.SSN__c = contactCreditProfile.get('ssnNumber') != null ?
                                                String.valueOf(contactCreditProfile.get('ssnNumber')) : null;
            consumerCreditReport.Date_of_Birth__c = contactCreditProfile.get('dobYear') != null ?
                                                Date.newInstance((Integer) contactCreditProfile.get('dobYear'), (Integer) contactCreditProfile.get('dobMonth'),
                                                    (Integer) contactCreditProfile.get('dobDate')
                                                ) : null;
            consumerCreditReport.Personal_FICO_Score__c = contactCreditProfile.get('FICOScore') != null ?
                Integer.valueOf(contactCreditProfile.get('FICOScore')) : 0;

            if(contactCreditProfile.get('totalLateMortgage') != null) {
                calculateTradeListDetails((List<Object>) contactCreditProfile.get('totalLateMortgage'), consumerCreditReport);
            } else {
                consumerCreditReport.Total_No_Late_Mortgage_Count__c = 0;
                consumerCreditReport.No_Of_Open_Trades__c = 0;
            }

            if(contactCreditProfile.get('totalTradeItems') != null) {
                calculateTotalTradeItems((List<Object>) contactCreditProfile.get('totalTradeItems'), consumerCreditReport);
            } else {
                consumerCreditReport.Total_No_Trades_Count__c = 0;
                consumerCreditReport.Past_Due_Amount__c = 0;
            }
            if(contactCreditProfile.containsKey('publicRecord')) {
                unifyingConsumerBankruptcyDetails((List<Object>)contactCreditProfile.get('publicRecord'), consumerCreditReport);
            }
            if(contactCreditProfile.containsKey('FICOScoreFactors')) {
                Map<String, Object> ficoScoreFactorsMap = (Map<String, Object>) contactCreditProfile.get('FICOScoreFactors');

                List<Object> scoreFactorList =
                    ficoScoreFactorsMap.containsKey('scoreFactors') ? (List<Object>) ficoScoreFactorsMap.get('scoreFactors')
                        : new List<Object>();
                for(Object scoreFactor : scoreFactorList) {
                    Map<String, Object> scoreFactorMap = (Map<String, Object>) scoreFactor;
                    if(consumerCreditReport.Score_Factor_Code__c != null) {
                        consumerCreditReport.Score_Factor_Code__c += String.valueOf(scoreFactorMap.get('code')) + ',';
                    }
                    else {
                        consumerCreditReport.Score_Factor_Code__c = String.valueOf(scoreFactorMap.get('code')) + ',';
                    }
                }
            }
        }

        return consumerCreditReport;

    }

    public static Credit_Report_Detail__c findHighestScoreReport(
        Set<Id> contactIds, Map<Id, Credit_Report_Detail__c> creditReportMap, Map<Id, clcommon__Party__c> partyByContactId
    ) {
        Integer personalScore = 0;
        Credit_Report_Detail__c finalCreditReport;
        for(Id contactId : contactIds) {
            if(creditReportMap.containsKey(contactId)) {
                partyByContactId.get(contactId).clcommon__isPrimary__c = false;
                Credit_Report_Detail__c creditReport = creditReportMap.get(contactId);
                Integer reportPersonalScore = Integer.valueOf(creditReport.Personal_FICO_Score__c);
                if(reportPersonalScore >= personalScore) {
                    personalScore = reportPersonalScore;
                    finalCreditReport = creditReport;
                }
            }
        }
        if(finalCreditReport != null) {
            partyByContactId.get(finalCreditReport.Contact__c).clcommon__isPrimary__c = true;
        }
        return finalCreditReport;

    }

    public static void prepareCreditReportMessage(
        Set<Id> contactIds, Map<Id, String> contactIdToCreditReportMessage, Map<Id, clcommon__Party__c> partyByContactId
    ) {
        for(Id contactId : contactIds) {
            if(contactIdToCreditReportMessage.containsKey(contactId) && contactIdToCreditReportMessage.get(contactId) != null) {
                partyByContactId.get(contactId).Credit_Report_Message__c = contactIdToCreditReportMessage.get(contactId);
                partyByContactId.get(contactId).Last_Date_of_Inquiry__c = GeneralHelper.currentSystemDateTime;
            }
        }
    }

    public static List<String> getContactAddresses(Map<Id, Contact> contactMap, Set<Id> contactIds) {
        List<String> toAddresses = new List<String>();
        for (Id conId : contactIds) {
            Contact contactDetail = contactMap.get(conId);
            toAddresses.add(contactDetail.Email);
        }

        return toAddresses;

    }

    public static void calculateTradeListDetails(List<Object> tradeLineList, Credit_Report_Detail__c consumerCreditReport) {
        Integer totalLateMortgage = 0;
        Integer openTradesCount = 0;
        for (Object tradeLine : tradeLineList) {
            Map<String, Object> tradeLineMap = (Map<String, Object>) tradeLine;
            if((checkLateMortgageAccountType(tradeLineMap) && checkLateMortgageKob(tradeLineMap))
                && checkLateMortgageStatus(tradeLineMap)
            ) {
                totalLateMortgage++;
            }

            if(tradeLineMap.get('lastPaymentDate') != null || tradeLineMap.get('openDate') != null) {
                String statusUpdateDate = tradeLineMap.get('lastPaymentDate') != null ?
                    String.valueOf(tradeLineMap.get('lastPaymentDate')) : String.valueOf(tradeLineMap.get('openDate'));
                Date lastStatusUpdateDate = getDateFromUntypedString(String.valueOf(statusUpdateDate));
                if(tradeLineMap.get('openOrClosedText') != 'Closed' && GeneralHelper.currentSystemDate.addDays(-365) <= lastStatusUpdateDate) {
                    openTradesCount++;
                }
            }
        }

        consumerCreditReport.Total_No_Late_Mortgage_Count__c = totalLateMortgage;
        consumerCreditReport.No_Of_Open_Trades__c = openTradesCount;
    }

    public static Boolean checkLateMortgageAccountType(Map<String, Object> accountTypeMap) {
        Set<Integer> accountType = new Set<Integer> { 27, 4, 5, 8, 17, 19, 25, 26 };
        if(accountType.contains(Integer.valueOf(accountTypeMap.get('accountType')))) {
            return true;
        }
        return false;
    }

    public static Boolean checkLateMortgageKob(Map<String, Object> kobMap) {
        Set<String> kobValues = new Set<String> {
            'FM', 'BM', 'FB', 'FR', 'FL', 'BC', 'DC', 'ZR', 'NZ', 'BB', 'FF', 'FP', 'UZ', 'FA', 'FS', 'AT', 'PC', 'DV', 'JA', 'NU', 'FC',
            'UW', 'FZ', 'ZT', 'BI', 'NA', 'UE', 'PH', 'KI', 'RD', 'RE', 'RP', 'RZ'
        };
        if(kobValues.contains(String.valueOf(kobMap.get('kob')))) {
            return true;
        }
        return false;
    }


/**************************************************************************************
* @Description  This method determines if a Tradeline has status associated to a
* Mortgage Delinquency decline
*
* @Param		Map<String, Object> statusMap  Set of Tradelines status
* @Return  Boolean
*       True : if a Tradeline has status associated to a Mortgage Delinquency decline.
*       False: if a Tradeline does not have status associated to a Mortgage Delinquency decline.
*
**************************************************************************************/
    public static Boolean checkLateMortgageStatus(Map<String, Object> statusMap) {
        Set<Integer> statusValues = new Set<Integer> { 83, 82,84, 87 };
        if(statusValues.contains(Integer.valueOf(statusMap.get('status')))) {
            return true;
        }
        return false;
    }

    public static void calculateTotalTradeItems(List<Object> summaries, Credit_Report_Detail__c consumerCreditReport) {
        List<Object> attributeList;
        for(Object summaryObj:summaries) {
            Map<String, Object> summaryMap = (Map<String, Object>) summaryObj;
            if(summaryMap.get('summaryType') == 'Profile Summary') {
                attributeList = (List<Object>) summaryMap.get('attributes');
            }
        }
        consumerCreditReport.Total_No_Trades_Count__c = 0;
        consumerCreditReport.Past_Due_Amount__c = 0;

        if(attributeList != null) {
            for(Object attributeObj:attributeList) {
                Map<String, Object> attributeMap = (Map<String, Object>) attributeObj;
                if(attributeMap.get('id') == 'totalTradeItems') {
                    consumerCreditReport.Total_No_Trades_Count__c = Integer.valueOf(attributeMap.get('value'));
                }
                if(attributeMap.get('id') == 'pastDueAmount') {
                    consumerCreditReport.Past_Due_Amount__c = Integer.valueOf(attributeMap.get('value'));
                }
            }
        }
    }

    @TestVisible
    private static void unifyingConsumerBankruptcyDetails(
        List<Object> bankruptcyDetailList, Credit_Report_Detail__c consumerCreditReport
    ) {
        Set<String> closedBankruptcyActions = new Set<String> {
            'BANKRUPTCYCHAPTER13-DISMISSED', 'BANKRUPTCYCHAPTER11-DISMISSED', 'BANKRUPTCYCHAPTER7-DISMISSED',
            'BANKRUPTCYCHAPTER12-DISMISSED'
        };
        Set<String> openBankruptcyActions = new Set<String> {
            'BANKRUPTCYCHAPTER13-PETITIONFILED', 'BANKRUPTCYCHAPTER7-PETITIONFILED',
            'BANKRUPTCYCHAPTER11-PETITIONFILED', 'BANKRUPTCYCHAPTER12-PETITIONFILED'
        };

        Map<String, Date> documentReferenceNumberToDate = new Map<String, Date>();
        Map<String, Boolean> documentNumberToIsRecent = new Map<String, Boolean>();
        Map<String, Boolean> documentNumberToIsOpen = new Map<String, Boolean>();

        for(Object bankruptcyDetail : bankruptcyDetailList) {
            Map<String, Object> bankruptcyDetailMap = (Map<String, Object>) bankruptcyDetail;
            String referenceNumber = String.ValueOf(bankruptcyDetailMap.get('referenceNumber'));
            Date dateFiled = getDateFromUntypedString(String.ValueOf(bankruptcyDetailMap.get('filingDate')));
            String statusText = String.valueOf(bankruptcyDetailMap.get('statusText'));
            if(!documentReferenceNumberToDate.containsKey(referenceNumber)) {
                documentReferenceNumberToDate.put(referenceNumber, dateFiled);
                if((getValidBankruptcyCount(statusText, closedBankruptcyActions) || getValidBankruptcyCount(statusText, openBankruptcyActions))
                    && dateFiled > GeneralHelper.currentSystemDate.addMonths(-24)
                ) {
                    documentNumberToIsRecent.put(referenceNumber, true);
                } if(getValidBankruptcyCount(statusText, openBankruptcyActions)) {
                    documentNumberToIsOpen.put(referenceNumber, true);
                }
            } else if(documentReferenceNumberToDate.containsKey(referenceNumber)
                && dateFiled > documentReferenceNumberToDate.get(referenceNumber)
            ) {
                documentReferenceNumberToDate.put(referenceNumber, dateFiled);
                if((getValidBankruptcyCount(statusText, closedBankruptcyActions) || getValidBankruptcyCount(statusText, openBankruptcyActions))
                    && dateFiled > GeneralHelper.currentSystemDate.addMonths(-24)
                ) {
                    documentNumberToIsRecent.put(referenceNumber, true);
                }
                if(getValidBankruptcyCount(statusText, openBankruptcyActions)) {
                    documentNumberToIsOpen.put(referenceNumber, true);
                } else if(getValidBankruptcyCount(statusText, closedBankruptcyActions)) {
                    documentNumberToIsOpen.put(referenceNumber, false);
                }
            }
        }

        consumerCreditReport.Is_Recent_Bankruptcy__c = documentNumberToIsRecent.values().contains(true);
        consumerCreditReport.Is_Open_Bankruptcy__c = documentNumberToIsOpen.values().contains(true);
    }

    public static void setExperianConsumerStatement(List<Object> statementList, Credit_Report_Detail__c consumerCreditReport) {
        if(statementList!= null) {
            for (Object statementObj : statementList) {
                Map<String, Object> statementMap = (Map<String, Object>) statementObj;
                if(statementMap.get('statementText') != null) {
                    consumerCreditReport.Credit_Statement__c = String.valueOf(statementMap.get('statementText'));
                    break;
                }
            }
        }
    }

    public static Map<String, Map<String, String>> getCreditFreezeContactDetails(Contact contactDetail, Account accountDetail,
        String applicationExpireDate, clcommon__Party__c brokerParty, String creditReportMessage, genesis__Applications__c application
    ){
        Map<String, String> scoringContactDetail = new Map<String, String>();
        Map<String, Map<String, String>> scoringBrokerAndGuarantorContactDetail = new Map<String, Map<String, String>>();
        String creditReportIssueMessage = '';
        if(creditReportMessage != null) {
            creditReportIssueMessage = creditReportMessage;
        } else {
            creditReportIssueMessage = contactDetail.Credit_Report_Message__c;
        }

        String salesRepEmailAddress = application.Sales_Rep__c != null && application.Sales_Rep__r.Email != null ? application.Sales_Rep__r.Email : null;

        if(brokerParty == null && application.Opportunity__c != null
            && (application.Type__c == GeneralConstants.LOAN_TYPE_NEW
                || (application.Type__c == GeneralConstants.LOAN_TYPE_RENEWAL && (
                        application.Opportunity__r.Offer_Notification_To_Guarantor__c || contactDetail.Is_Generic__c
                    )
                )
            )
        ) {
            scoringContactDetail.put('toAddress', contactDetail.Email);
            scoringContactDetail.put('guarantorCcAddresses', salesRepEmailAddress);
            scoringContactDetail.put('accountName', accountDetail.Name != null ? accountDetail.Name : '' );
            scoringContactDetail.put('accountAddress',
                accountDetail.BillingBuildingNumber__c != null ? accountDetail.BillingBuildingNumber__c : ''
            );
            scoringContactDetail.put('accountStreet', accountDetail.BillingStreet != null ? accountDetail.BillingStreet : '');
            scoringContactDetail.put('accountCity', accountDetail.BillingCity != null ? accountDetail.BillingCity : '');
            scoringContactDetail.put('accountState', accountDetail.BillingState != null ? accountDetail.BillingState : '');
            scoringContactDetail.put('accountZip', accountDetail.BillingPostalCode != null ? accountDetail.BillingPostalCode : '');
            scoringContactDetail.put('firstName', contactDetail.FirstName != null ? contactDetail.FirstName : '');
            scoringContactDetail.put('lastName', contactDetail.LastName != null ? contactDetail.LastName : '');
            scoringContactDetail.put('applicationExpireDate', applicationExpireDate);
            scoringContactDetail.put('businessName', 'Thank you for your business’ application');
            scoringContactDetail.put('merchantBusinessName', accountDetail.Name != null ? accountDetail.Name : '');
            if(contactDetail.Is_Generic__c == true) {
                scoringContactDetail.put('creditStatus', EXPERIAN_GENERIC_STATUS);
                scoringContactDetail.put('creditReportMessage', EXPERIAN_GENERIC_REPORT);
                scoringContactDetail.put('creditNotFoundDetails', '');
                scoringContactDetail.put('webBankAddress', EXPERIAN_WEB_BANK_ADDRESS);
                contactDetail.Is_Generic__c = false;
            }
            else{
                if(creditReportIssueMessage.contains('FILE FROZEN')) {
                    scoringContactDetail.put('creditStatus', EXPERIAN_FROZEN_STATUS);
                    scoringContactDetail.put('creditReportMessage', EXPERIAN_MERCHANT_CREDIT_FREEZE);
                    scoringContactDetail.put('creditNotFoundDetails', '');
                }
                if(creditReportIssueMessage.contains('FILE LOCKED')) {
                    scoringContactDetail.put('creditStatus', EXPERIAN_LOCK_STATUS);
                    scoringContactDetail.put('creditReportMessage', EXPERIAN_MERCHANT_CREDIT_LOCK);
                    scoringContactDetail.put('creditNotFoundDetails', '');
                }
                if(creditReportIssueMessage.contains('NO RECORD FOUND')) {
                    scoringContactDetail.put('creditStatus', EXPERIAN_NOT_FOUND_STATUS);
                    scoringContactDetail.put('creditReportMessage', EXPERIAN_MERCHANT_CREDIT_NOT_FOUND);
                    scoringContactDetail.put('creditNotFoundDetails', EXPERIAN_CREDIT_NOT_FOUND_DETAILS);
                }
                scoringContactDetail.put('webBankAddress', '');
            }

            scoringBrokerAndGuarantorContactDetail.put('guarantor', scoringContactDetail);
        }

        if(brokerParty != null && contactDetail.Is_Generic__c == false && application.Opportunity__c != null
            && application.Opportunity__r.Offer_Notification_To_Broker__c
            && (application.Type__c == GeneralConstants.LOAN_TYPE_NEW
                || (application.Type__c == GeneralConstants.LOAN_TYPE_RENEWAL)
            )
        ) {
            scoringContactDetail.put('toAddress', brokerParty.clcommon__Contact__r.Email != null ? brokerParty.clcommon__Contact__r.Email : null);
            scoringContactDetail.put('brokerCcAddresses', salesRepEmailAddress);
            scoringContactDetail.put('additionalCcAddresses',
                brokerParty.clcommon__Account__r.Email_cc__c != null ? brokerParty.clcommon__Account__r.Email_cc__c : null);
                scoringContactDetail.put('toAddress', brokerParty.clcommon__Contact__r.Email != null ? brokerParty.clcommon__Contact__r.Email : null);
                scoringContactDetail.put('brokerCcAddresses',
                    application.Sales_Rep__c != null && application.Sales_Rep__r.Email != null ? application.Sales_Rep__r.Email : null
                );
                scoringContactDetail.put('additionalCcAddresses',
                    brokerParty.clcommon__Account__r.Email_cc__c != null ? brokerParty.clcommon__Account__r.Email_cc__c : null);
                scoringContactDetail.put('accountName', brokerParty.clcommon__Account__r.Name != null ? brokerParty.clcommon__Account__r.Name : '' );
                scoringContactDetail.put('accountAddress',
                    brokerParty.clcommon__Account__r.BillingBuildingNumber__c != null ? brokerParty.clcommon__Account__r.BillingBuildingNumber__c : ''
                );
                scoringContactDetail.put('accountStreet', brokerParty.clcommon__Account__r.BillingStreet != null ? brokerParty.clcommon__Account__r.BillingStreet : '');
                scoringContactDetail.put('accountCity', brokerParty.clcommon__Account__r.BillingCity != null ? brokerParty.clcommon__Account__r.BillingCity : '');
                scoringContactDetail.put('accountState', brokerParty.clcommon__Account__r.BillingState != null ? brokerParty.clcommon__Account__r.BillingState : '');
                scoringContactDetail.put('accountZip', brokerParty.clcommon__Account__r.BillingPostalCode != null ? brokerParty.clcommon__Account__r.BillingPostalCode : '');
                scoringContactDetail.put('firstName', brokerParty.clcommon__Contact__r.FirstName != null ? brokerParty.clcommon__Contact__r.FirstName : '');
                scoringContactDetail.put('lastName', brokerParty.clcommon__Contact__r.LastName != null ? brokerParty.clcommon__Contact__r.LastName : '');
                scoringContactDetail.put('applicationExpireDate', applicationExpireDate);
                scoringContactDetail.put('businessName', ('Thank you for submitting an application for ' + (accountDetail.Name != null ? accountDetail.Name : '')));
                scoringContactDetail.put('merchantBusinessName', accountDetail.Name != null ? accountDetail.Name : '');
                if(CreditReportIssueMessage.contains('FILE FROZEN')) {
                    scoringContactDetail.put('creditStatus', EXPERIAN_FROZEN_STATUS);
                    scoringContactDetail.put('creditReportMessage', EXPERIAN_BROKER_CREDIT_FREEZE);
                    scoringContactDetail.put('creditNotFoundDetails', '');
                }
                if(CreditReportIssueMessage.contains('FILE LOCKED')) {
                    scoringContactDetail.put('creditStatus', EXPERIAN_LOCK_STATUS);
                    scoringContactDetail.put('creditReportMessage', EXPERIAN_BROKER_CREDIT_LOCK);
                    scoringContactDetail.put('creditNotFoundDetails', '');
                }
                if(CreditReportIssueMessage.contains('NO RECORD FOUND')) {
                    scoringContactDetail.put('creditStatus', EXPERIAN_NOT_FOUND_STATUS);
                    scoringContactDetail.put('creditReportMessage', EXPERIAN_BROKER_CREDIT_NOT_FOUND);
                    scoringContactDetail.put('creditNotFoundDetails', EXPERIAN_CREDIT_NOT_FOUND_DETAILS);
                }
                scoringContactDetail.put('webBankAddress', '');
                scoringBrokerAndGuarantorContactDetail.put('broker', scoringContactDetail);
        }
        return scoringBrokerAndGuarantorContactDetail;
    }

    public static void getScoringEmailDetails(
        List<Messaging.SingleEmailMessage> emailList, Map<String, Map<String, String>> scoringIssueDetail, EmailTemplate scoringEmailTemplate,
        List<Document> documents
    ) {
        List<String> guarantorToAddresses = new List<String>();
        List<String> brokerToAddresses = new List<String>();
        List<String> guarantorCcAddresses = new List<String>();
        List<String> brokerCcAddresses = new List<String>();
        Map<String, String> scoringGuarantorIssueDetail = scoringIssueDetail.get('guarantor');
        Map<String, String> scoringBrokerIssueDetail = scoringIssueDetail.get('broker');
        String guarantorTemplateBody = scoringEmailTemplate.HtmlValue;
        OrgWideEmailAddress orgWideAddress = GeneralHelper.orgWideEmailAddressByEmail.get(GeneralConstants.CAN_APP_SUPPORT_EMAIL_ADDRESS);
        String templateUrl = '';
        if(!documents.isEmpty()) {
            if(GeneralHelper.domainUrl.contains('genesisextn.visualforce.com')) {
                templateUrl = GeneralHelper.domainUrl.replace('genesisextn.visualforce.com', 'c.documentforce.com/servlet/servlet.ImageServer?');
            } else {
                templateUrl = GeneralHelper.domainUrl.replace('.my.salesforce.com', '--c.documentforce.com/servlet/servlet.ImageServer?');
            }
            templateUrl += 'id=' + documents[0].Id + '&oid=' + UserInfo.getOrganizationId();
        }
        if(scoringGuarantorIssueDetail != null) {
            if(scoringGuarantorIssueDetail.get('toAddress') != null) {
                guarantorToAddresses.add(scoringGuarantorIssueDetail.get('toAddress'));
            }
            if(scoringGuarantorIssueDetail.get('guarantorCcAddresses') != null) {
                guarantorCcAddresses.add(scoringGuarantorIssueDetail.get('guarantorCcAddresses'));
            }
            guarantorTemplateBody = guarantorTemplateBody.replace('{{CONTACT_FIRSTNAME}}', String.valueOf(scoringGuarantorIssueDetail.get('firstName')));
            guarantorTemplateBody = guarantorTemplateBody.replace('{{CONTACT_LASTNAME}}', String.valueOf(scoringGuarantorIssueDetail.get('lastName')));
            guarantorTemplateBody = guarantorTemplateBody.replace('{{ACCOUNT_BILLINGADDRESS}}', String.valueOf(scoringGuarantorIssueDetail.get('accountAddress')));
            guarantorTemplateBody = guarantorTemplateBody.replace('{{ACCOUNT_BILLINGSTREET}}', String.valueOf(scoringGuarantorIssueDetail.get('accountStreet')));
            guarantorTemplateBody = guarantorTemplateBody.replace('{{ACCOUNT_BILLINGCITY}}', String.valueOf(scoringGuarantorIssueDetail.get('accountCity')));
            guarantorTemplateBody = guarantorTemplateBody.replace('{{ACCOUNT_BILLINGSTATECODE}}', String.valueOf(scoringGuarantorIssueDetail.get('accountState')));
            guarantorTemplateBody = guarantorTemplateBody.replace('{{ACCOUNT_BILLINGPOSTALCODE}}', String.valueOf(scoringGuarantorIssueDetail.get('accountZip')));
            guarantorTemplateBody = guarantorTemplateBody.replace('{{ACCOUNT_NAME}}', String.valueOf(scoringGuarantorIssueDetail.get('accountName')));
            guarantorTemplateBody = guarantorTemplateBody.replace('{{MERCHANT_BUSINESS_NAME}}', String.valueOf(scoringGuarantorIssueDetail.get('merchantBusinessName')));
            guarantorTemplateBody = guarantorTemplateBody.replace('{{REPORT_DATE}}', String.valueOf(GeneralHelper.currentSystemDate));
            guarantorTemplateBody = guarantorTemplateBody.replace('{{APPLICATION_DECLINE_DATE}}', scoringGuarantorIssueDetail.get('applicationExpireDate'));
            guarantorTemplateBody = guarantorTemplateBody.replace('{{CREDIT_REPORT_MESSAGE}}', String.valueOf(scoringGuarantorIssueDetail.get('creditReportMessage')));
            guarantorTemplateBody = guarantorTemplateBody.replace('{{BUSINESS_NAME}}', String.valueOf(scoringGuarantorIssueDetail.get('businessName')));
            guarantorTemplateBody = guarantorTemplateBody.replace('{{CREDIT_REPORT_STATUS}}', scoringGuarantorIssueDetail.get('creditStatus'));
            guarantorTemplateBody = guarantorTemplateBody.replace('{{DETAILS_FOR_CREDIT_NOT_FOUND}}', scoringGuarantorIssueDetail.get('creditNotFoundDetails'));
            guarantorTemplateBody = guarantorTemplateBody.replace('{{WEB_BANK_ADDRESS}}', scoringGuarantorIssueDetail.get('webBankAddress'));
            guarantorTemplateBody = guarantorTemplateBody.replace('{{IMAGE__LOGO}}', templateUrl);
            emailList.add(Emails.getEmailMessageSetup(
                guarantorToAddresses, guarantorCcAddresses, CustomMetaDataHelper.defaultGeneralSetting.From_Email__c, scoringEmailTemplate.Subject,
                guarantorTemplateBody, true, null, orgWideAddress)
            );
        }

        if(scoringBrokerIssueDetail != null) {
            String brokerTemplateBody = scoringEmailTemplate.HtmlValue;
            if(scoringBrokerIssueDetail.get('additionalCcAddresses') != null) {
                for(String additionalEmail :scoringBrokerIssueDetail.get('additionalCcAddresses').split(',')) {
                    brokerCcAddresses.add(additionalEmail);
                }
            }
            if(scoringBrokerIssueDetail.get('brokerCcAddresses') != null) {
                brokerCcAddresses.add(scoringBrokerIssueDetail.get('brokerCcAddresses'));
            }
            if(scoringBrokerIssueDetail.get('toAddress') != null) {
                brokerToAddresses.add(scoringBrokerIssueDetail.get('toAddress'));
            }
            brokerTemplateBody = brokerTemplateBody.replace('{{CONTACT_FIRSTNAME}}', String.valueOf(scoringBrokerIssueDetail.get('firstName')));
            brokerTemplateBody = brokerTemplateBody.replace('{{CONTACT_LASTNAME}}', String.valueOf(scoringBrokerIssueDetail.get('lastName')));
            brokerTemplateBody = brokerTemplateBody.replace('{{ACCOUNT_BILLINGADDRESS}}', String.valueOf(scoringBrokerIssueDetail.get('accountAddress')));
            brokerTemplateBody = brokerTemplateBody.replace('{{ACCOUNT_BILLINGSTREET}}', String.valueOf(scoringBrokerIssueDetail.get('accountStreet')));
            brokerTemplateBody = brokerTemplateBody.replace('{{ACCOUNT_BILLINGCITY}}', String.valueOf(scoringBrokerIssueDetail.get('accountCity')));
            brokerTemplateBody = brokerTemplateBody.replace('{{ACCOUNT_BILLINGSTATECODE}}', String.valueOf(scoringBrokerIssueDetail.get('accountState')));
            brokerTemplateBody = brokerTemplateBody.replace('{{ACCOUNT_BILLINGPOSTALCODE}}', String.valueOf(scoringBrokerIssueDetail.get('accountZip')));
            brokerTemplateBody = brokerTemplateBody.replace('{{ACCOUNT_NAME}}', String.valueOf(scoringBrokerIssueDetail.get('accountName')));
            brokerTemplateBody = brokerTemplateBody.replace('{{MERCHANT_BUSINESS_NAME}}', String.valueOf(scoringBrokerIssueDetail.get('merchantBusinessName')));
            brokerTemplateBody = brokerTemplateBody.replace('{{REPORT_DATE}}', String.valueOf(GeneralHelper.currentSystemDate));
            brokerTemplateBody = brokerTemplateBody.replace('{{APPLICATION_DECLINE_DATE}}', scoringBrokerIssueDetail.get('applicationExpireDate'));
            brokerTemplateBody = brokerTemplateBody.replace('{{CREDIT_REPORT_MESSAGE}}', String.valueOf(scoringBrokerIssueDetail.get('creditReportMessage')));
            brokerTemplateBody = brokerTemplateBody.replace('{{BUSINESS_NAME}}', String.valueOf(scoringBrokerIssueDetail.get('businessName')));
            brokerTemplateBody = brokerTemplateBody.replace('{{CREDIT_REPORT_STATUS}}', scoringBrokerIssueDetail.get('creditStatus'));
            brokerTemplateBody = brokerTemplateBody.replace('{{DETAILS_FOR_CREDIT_NOT_FOUND}}', scoringBrokerIssueDetail.get('creditNotFoundDetails'));
            brokerTemplateBody = brokerTemplateBody.replace('{{IMAGE__LOGO}}', templateUrl);
            brokerTemplateBody = brokerTemplateBody.replace('{{WEB_BANK_ADDRESS}}', '');
            emailList.add(Emails.getEmailMessageSetup(
                brokerToAddresses, brokerCcAddresses, CustomMetaDataHelper.defaultGeneralSetting.From_Email__c, scoringEmailTemplate.Subject,
                brokerTemplateBody, true, null, orgWideAddress)
            );
        }
    }

    public static Date getDateFromUntypedString(String dateString) {
        Integer yearIndex = Integer.valueOf(dateString.substring(4,8));
        Integer monthIndex = Integer.valueOf(dateString.substring(0,2));
        Integer dayIndex = Integer.valueOf(dateString.substring(2,4));
        Date actualDate = Date.newInstance( Integer.valueOf(yearIndex), Integer.valueOf(monthIndex), Integer.valueOf(dayIndex));
        return actualDate;
    }
}