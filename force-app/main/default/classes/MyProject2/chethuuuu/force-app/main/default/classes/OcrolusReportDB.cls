public class OcrolusReportDB extends DBManager {

    public List<CAN_Ocrolus_Report__c> getCANOcrolusReportByPK(String analyticsPK) {
        return [
            SELECT Id, Analytics_PK__c, Application__c, Offer_GAV_Amount__c, Document_Status__c, Analytics_Count__c
            FROM CAN_Ocrolus_Report__c
            WHERE Analytics_PK__c = :analyticsPK
        ];
    }

    public List<CAN_Ocrolus_Report__c> getCANOcrolusReportByApplicationIDs(Set<Id> applicationIds) {
        return [
            SELECT Id, Book_Name__c, Application__c, Analytics_PK__c, Primary_Bank_Account_Number__c, Number_Of_Competitors__c,
                Competitor_Names__c, Number_Of_Bank_Statements__c, Is_Potential_Fraud__c, Primary_Bank_Account_Name__c, Number_Of_Deposits__c,
                Is_Debt_Consolidator__c, Max_Daily_Payment__c, Document_Status__c, Has_Begin_Ending_Balance_Mismatch__c,
                Has_Ending_Balance_Mismatch__c, Has_Suspicious_Activity__c, Max_Weekly_Payment__c, Offer_GAV_Amount__c, UUID__c,
                Volatility_w_out_ADB_support__c, Analytics_Count__c
            FROM CAN_Ocrolus_Report__c
            WHERE Application__c IN :applicationIds
        ];
    }

    public List<CAN_Ocrolus_Report__c> getCANOcrolusReportByIds(Set<Id> ocrolusReportIds) {
        return [
            SELECT Id, Analytics_PK__c, Application__c, Analytics_Count__c
            FROM CAN_Ocrolus_Report__c
            WHERE Id IN :ocrolusReportIds
        ];
    }
    
    public List<clcommon__Category_Attachment_Association__c> getCategoryAttsByAppIds(Set<Id> applicationIds) {
        return [
            SELECT Id, clcommon__Document_Category__c, Application__c
            FROM clcommon__Category_Attachment_Association__c
            WHERE clcommon__Document_Category__r.genesis__Application__c IN :applicationIds
        ];
    }
}