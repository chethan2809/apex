public class CANOcrolusReports {

    public static final Decimal HUMAN_ERROR_VALUE = 999999.00;
    public static final Decimal DEFAULT_VALUE = 9999.00;

    public static Decimal calculateGAV(genesis__Applications__c application, CAN_Ocrolus_Report__c ocrolusReport) {
        Decimal systemGAV = application.Annual_Volume__c;
        Decimal systemGAVMax = systemGAV * 1.10;
        Decimal systemGAVMin = systemGAV * 0.80;
        Boolean moIndicator = (ocrolusReport.Number_Of_Bank_Statements__c >= 12);
        Decimal updatedOcrolusGAV = ocrolusReport.Offer_GAV_Amount__c;
        Decimal finalSystemGAV = systemGAV;

        if(systemGAV != HUMAN_ERROR_VALUE && systemGAV != DEFAULT_VALUE){
            if(updatedOcrolusGAV == 0) {
                finalSystemGAV = DEFAULT_VALUE;
            } else if(updatedOcrolusGAV > systemGAV && updatedOcrolusGAV > systemGAVMax && moIndicator){
                finalSystemGAV = updatedOcrolusGAV;
            } else if(updatedOcrolusGAV > systemGAV && updatedOcrolusGAV > systemGAVMax && !moIndicator){
                finalSystemGAV = systemGAVMax;
            } else if(updatedOcrolusGAV < systemGAV && updatedOcrolusGAV > systemGAVMin){
                finalSystemGAV = systemGAV;
            } else if(updatedOcrolusGAV < systemGAVMin && updatedOcrolusGAV != 0){
                finalSystemGAV = updatedOcrolusGAV;
            } else if(updatedOcrolusGAV > systemGAV && updatedOcrolusGAV < systemGAVMax){
                finalSystemGAV = updatedOcrolusGAV;
            }
        } else if(updatedOcrolusGAV != 0) {
            finalSystemGAV = updatedOcrolusGAV;
        }

        return finalSystemGAV;
    }

    public static Map<Id, CAN_Ocrolus_Report__c> getOcrolusReportByApplicationId(List<CAN_Ocrolus_Report__c> ocrolusReportList) {
        Map<Id, CAN_Ocrolus_Report__c> ocrolusReportByApplicationId = new  Map<Id, CAN_Ocrolus_Report__c>();
        for(CAN_Ocrolus_Report__c canOcrolusReportDetail : ocrolusReportList) {
            ocrolusReportByApplicationId.put(canOcrolusReportDetail.Application__c, canOcrolusReportDetail);
        }

        return ocrolusReportByApplicationId;
    }

    public static CAN_Ocrolus_Report__c createRenewalApplicationOcrolusReport(CAN_Ocrolus_Report__c originalAppOcrolusReport, Id applicationId) {
        CAN_Ocrolus_Report__c renewalOcrolusReport = originalAppOcrolusReport;
        renewalOcrolusReport.Id = null;
        renewalOcrolusReport.Book_Name__c = null;
        renewalOcrolusReport.Analytics_PK__c = null;
        renewalOcrolusReport.UUID__c = null;
        renewalOcrolusReport.Document_Status__c = Ocrolus.OCROLUS_DOC_STATUS_COMPLETE;
        renewalOcrolusReport.Max_Daily_Payment__c = 99999;
        renewalOcrolusReport.Application__c = applicationId;
        return renewalOcrolusReport;
    }

    public static CAN_Ocrolus_Report__c createEISRenewalApplicationOcrolusReport(Id applicationId, Decimal legacyGAVAmount) {
        EIS_Default_Ocrolus_Report__mdt ocrolusDefaultReport = CustomMetaDataHelper.defaultEISOcrolusReport;

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Application__c = applicationId;
        ocrolusReport.Document_Status__c = Ocrolus.OCROLUS_DOC_STATUS_COMPLETE;

        ocrolusReport.Offer_GAV_Amount__c = legacyGAVAmount;
        ocrolusReport.Max_Daily_Payment__c = ocrolusDefaultReport.Max_Daily_Payment__c;
        ocrolusReport.Max_Weekly_Payment__c = ocrolusDefaultReport.Max_Weekly_Payment__c;
        ocrolusReport.Volatility_w_out_ADB_support__c = ocrolusDefaultReport.Volatility_w_out_ADB_support__c;
        ocrolusReport.Number_Of_Deposits__c = ocrolusDefaultReport.Number_Of_Deposits__c;
        ocrolusReport.Number_Of_Bank_Statements__c = ocrolusDefaultReport.Number_Of_Bank_Statements__c;
        ocrolusReport.Primary_Bank_Account_Number__c = ocrolusDefaultReport.Primary_Bank_Account_Number__c;
        ocrolusReport.Primary_Bank_Account_Name__c = ocrolusDefaultReport.Primary_Bank_Account_Name__c;

        ocrolusReport.Number_Of_Competitors__c = ocrolusDefaultReport.Number_Of_Competitors__c;
        ocrolusReport.Is_Debt_Consolidator__c = ocrolusDefaultReport.Is_Debt_Consolidator__c;
        ocrolusReport.Has_Suspicious_Activity__c = ocrolusDefaultReport.Has_Suspicious_Activity__c;
        ocrolusReport.Is_Potential_Fraud__c = ocrolusDefaultReport.Is_Potential_Fraud__c;
        ocrolusReport.Has_Ending_Balance_Mismatch__c = ocrolusDefaultReport.Has_Ending_Balance_Mismatch__c;
        ocrolusReport.Has_Begin_Ending_Balance_Mismatch__c = ocrolusDefaultReport.Has_Begin_Ending_Balance_Mismatch__c;
        ocrolusReport.Competitor_Names__c = ocrolusDefaultReport.Competitor_Names__c;

        return ocrolusReport;
    }
}