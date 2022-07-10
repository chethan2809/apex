public class Ocrolus {

    public static final String OCROLUS_API = 'Ocrolus_API';
    public static final String OCROLUS_DOC_STATUS_VERIFYING = 'VERIFYING';
    public static final String OCROLUS_DOC_STATUS_COMPLETE = 'VERIFICATION_COMPLETE';
    public static final String OCROLUS_DOC_STATUS_FAILED = 'FAILED';
    public static final String OCROLUS_DOC_STATUS_ANALYTICS_SENT = 'ANALYTICS REQUEST SENT';
    public static Boolean isManualRun = false;
    public static final Set<String> OCROLUS_INELIGIBLE_APP_STATUS = new Set<String> {
        'CLOSED - APPROVED', 'CLOSED - DECLINED'
    };

    public static void createCANOcrolusReportDetail(
        Map<String, Object> ocrolusResponseMap, genesis__Applications__c application, CAN_Ocrolus_Report__c ocrolusReport
    ) {
        System.debug('00ocrolusResponseMap.get(pk)' + ocrolusResponseMap.get('pk'));
        ocrolusReport.Analytics_PK__c = String.valueOf(ocrolusResponseMap.get('pk'));
        ocrolusReport.Application__c = application.Id;
        ocrolusReport.UUID__c = String.valueOf(ocrolusResponseMap.get('uuid'));
        ocrolusReport.Book_Name__c = String.valueOf(ocrolusResponseMap.get('name'));
    }

    public static void setOcrolusReport(
        Map<String, Object> ocrolusAnalyticsMap, genesis__Applications__c application, CAN_Ocrolus_Report__c ocrolusReport
    ){
        Map<String, Object> genericOcrolusIndicators = (Map<String, Object>) ocrolusAnalyticsMap.get('Indicators');
        Map<String, Object> ocrolusIndicatorsForBusinessType = checkSoleOrNonSole(application, genericOcrolusIndicators);

        ocrolusReport.Offer_GAV_Amount__c = convertToDecimal(ocrolusIndicatorsForBusinessType.get('OfferGAV'));
        if(application.Type__c == GeneralConstants.LOAN_TYPE_RENEWAL) {
            ocrolusReport.Max_Daily_Payment__c = 99999;
        } else {
            ocrolusReport.Max_Daily_Payment__c = convertToDecimal(ocrolusIndicatorsForBusinessType.get('MaxDailyPayment'));
        }
        ocrolusReport.Max_Weekly_Payment__c = (ocrolusReport.Max_Daily_Payment__c != null)? ocrolusReport.Max_Daily_Payment__c * 5 : 0;
        ocrolusReport.Volatility_w_out_ADB_support__c = convertToDecimal(ocrolusIndicatorsForBusinessType.get('Volatility'));
        ocrolusReport.Number_Of_Deposits__c = convertToDecimal(ocrolusIndicatorsForBusinessType.get('NumberOfDeposits'));
        ocrolusReport.Number_Of_Bank_Statements__c = convertToDecimal(ocrolusIndicatorsForBusinessType.get('NumberOfBankStatements'));
        ocrolusReport.Primary_Bank_Account_Number__c = convertToString(ocrolusIndicatorsForBusinessType.get('PrimaryBankAccountNumber'));
        ocrolusReport.Primary_Bank_Account_Name__c = convertToString(ocrolusIndicatorsForBusinessType.get('PrimaryBankAccountName'));

        ocrolusReport.Number_Of_Competitors__c = convertToDecimal(genericOcrolusIndicators.get('NumberOfCompetitors'));
        ocrolusReport.Is_Debt_Consolidator__c = Boolean.valueOf(genericOcrolusIndicators.get('DebtConsolidator'));
        ocrolusReport.Has_Suspicious_Activity__c = Boolean.valueOf(genericOcrolusIndicators.get('SuspiciousActivity'));
        ocrolusReport.Is_Potential_Fraud__c = Boolean.valueOf(genericOcrolusIndicators.get('PotentialFraud'));
        ocrolusReport.Has_Ending_Balance_Mismatch__c = Boolean.valueOf(genericOcrolusIndicators.get('EndingBalanceMismatch'));
        ocrolusReport.Has_Begin_Ending_Balance_Mismatch__c = Boolean.valueOf(genericOcrolusIndicators.get('BeginEndingBalanceMismatch'));
        ocrolusReport.Competitor_Names__c = convertListToString(ocrolusAnalyticsMap.get('competitors'));
        ocrolusReport.All_Competitors__c = convertCompetitorsListToString(ocrolusAnalyticsMap.get('competitors'), genericOcrolusIndicators.get('NumberOfCompetitorsDetails'));
    }

    public static Map<String, Object> checkSoleOrNonSole(genesis__Applications__c application, Map<String, Object> ocrolusAnalyticsMap) {
        if(application.Business_Type__c == GeneralConstants.LEGAL_TYPE_SOLE_PROP) {
            return (Map<String, Object>) ocrolusAnalyticsMap.get('sole');
        } else {
            return (Map<String, Object>) ocrolusAnalyticsMap.get('non_sole');
        }
    }

    public static Decimal convertToDecimal(Object value) {
        if(value != null) {
            return (Decimal) value;
        }
        return 0;
    }

    public static String convertToString(Object value) {
        if(value != null) {
            return String.valueOf(value);
        }
        return null;
    }

    public static String convertListToString(Object value) {
        if(value != null) {
            List<Object> valueList = (List<Object>) value;
            return String.join( valueList, ',' );
        }
        return null;
    }

    public static Boolean isCANVerificationCompleted(CAN_Ocrolus_Report__c ocrolusReport, CAN_Ocrolus_Report__c oldOcrolusReport) {
        return (oldOcrolusReport.Offer_GAV_Amount__c != ocrolusReport.Offer_GAV_Amount__c
            || oldOcrolusReport.Max_Daily_Payment__c != ocrolusReport.Max_Daily_Payment__c
            || oldOcrolusReport.Number_Of_Bank_Statements__c != ocrolusReport.Number_Of_Bank_Statements__c
            || oldOcrolusReport.Number_Of_Deposits__c != ocrolusReport.Number_Of_Deposits__c
        );
    }

    public static String convertCompetitorsListToString(Object payOffCompetitors, Object allCompetitors) {
        String fieldResult = '';
        List<String> fieldResultsList = new List<String>();
        List<Object> payOffCompetitorsList = (List<Object>) payOffCompetitors;

        if (allCompetitors != null){
            List<Object> allCompetitorsList = (List<Object>) allCompetitors;
            for (Object competitor : allCompetitorsList){
                Map<String, Object> competitorDetail = (Map<String, Object>) competitor;
                fieldResult = String.valueOf(competitorDetail.get('lender_name'));

                if (!payOffCompetitorsList.contains(fieldResult)){
                    List<Object> frequencyList = (List<Object>) competitorDetail.get('frequency');
                    String frequencies = String.join(frequencyList, ', ');
                    fieldResult += ' (' + frequencies + ')';
                }

                fieldResultsList.add(fieldResult);
            }
            return String.join(fieldResultsList, ', ');
        }
        return null;
    }
}