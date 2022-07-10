public class CANScorings {

public static final String CAN_SCORING_API_SANDBOX = 'CAN_Scoring_API_Sandbox';
public static final String CAN_SCORING_API_PRODUCTION = 'CAN_Scoring_API_Production';

    public static Credit_Report_Detail__c createCANScoringCreditReportDetail(
        Map<String, Object> canScoringResponseMap, genesis__Applications__c application, Map<Id, Credit_Report_Detail__c> creditReportByApplicationId
    ) {

        Credit_Report_Detail__c creditReport;
        if(creditReportByApplicationId.containsKey(application.Id)) {
            creditReport = creditReportByApplicationId.get(application.Id);
        } else {
            creditReport = new Credit_Report_Detail__c();
            creditReport.Type__c = GeneralConstants.CREDIT_REPORT_TYPE_CAN_SCORING;
            creditReport.Application__c = application.Id;
        }
        Decimal canScore = Decimal.valueOf((String) CANScoringResponseMap.get('score'));
        creditReport.CAN_Scoring__c = canScore.setScale(4);

        return creditReport;
    }

    public static void updateTIERInApplication(Decimal score, genesis__Applications__c applicationDetail) {
        String applicationType;
        Decimal canScore = score;
        Map<String, CAN_Score_Cut_Off_Matrix__mdt> canCutOffMatrixScoreMap = CustomMetaDataHelper.canCutOffMatrixScoreMap;
        for(CAN_Score_Cut_Off_Matrix__mdt canCutOffMatrixScore : canCutOffMatrixScoreMap.values()) {
            if (CANCutOffMatrixScore.Loan_Type__c == applicationDetail.Type__c
                && CANScore <= CANCutOffMatrixScore.Max_Score__c
                && CANScore >= CANCutOffMatrixScore.Min_Score__c
            ) {
                applicationDetail.SC4_Tier__c = CANCutOffMatrixScore.SC4_Tier__c;
            }
        }
    }
}