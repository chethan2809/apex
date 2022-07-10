public class CreditReportDetailDB extends DBManager{

    public List<Credit_Report_Detail__c> getBusinessCreditReportByAccountIds(Set<Id> accountIds) {
        return [
            SELECT Id, Account__c, Total_No_Trades_Count__c, Months_Since_Biz_Added_To_Experian__c, Contact__c, Application__c,
                Trades_Count_DBT_30_Plus__c, Most_Recent_Open_Collections_Trade_Age__c, Legal_Name__c, Street__c, Tax_Liens__c, Type__c,
                City__c, State__c, Zip__c, ZipExtension__c, Industry_Type__c, SIC_Code__c, Business_Start_Date__c, Business_First_Seen_YYYY__c,
                Is_Recent_Bankruptcy__c, Is_Open_Bankruptcy__c, Competitor_Judgement__c, Judgement_Liens__c, Source_Type__c
            FROM Credit_Report_Detail__c
            WHERE Account__c IN :accountIds
                AND Type__c = :GeneralConstants.CREDIT_REPORT_TYPE_EXPERIAN_BUSINESS
                AND Source_Type__c = :GeneralConstants.CREDIT_REPORT_SOURCE_TYPE_APPLICATIONS
        ];
    }

    public List<Credit_Report_Detail__c> getBusinessAndLexisNexisReportsByAccountIdsAndApplicationIds(
        Set<Id> accountIds, Set<Id> applicationIds
    ) {
        return [
            SELECT Id, Application__c, Account__c, Type__c, Industry_Type__c, SIC_Code__c,
                Business_Start_Date__c, Business_First_Seen_YYYY__c, Contact__c, Source_Type__c
            FROM Credit_Report_Detail__c
            WHERE (Type__c = :GeneralConstants.CREDIT_REPORT_TYPE_EXPERIAN_BUSINESS
                    OR Type__c = :GeneralConstants.CREDIT_REPORT_TYPE_LEXIS_NEXIS)
                AND (Account__c IN :accountIds OR Application__c IN :applicationIds)
                AND Source_Type__c = :GeneralConstants.CREDIT_REPORT_SOURCE_TYPE_APPLICATIONS
        ];
    }

    public List<Credit_Report_Detail__c> getConsumerCreditReportByContactIds(Set<Id> contactIds) {
        return [
            SELECT Id, Contact__c, Bankruptcy_Risk_Score__c, Account__c, Application__c,
                No_Of_Open_Trades__c, Overall_Amount_Balance_Ratio__c, Total_Credit_Inquiries_Last_6_Months__c,
                Open_Revolving_Trades_CreditRatio_100__c, Open_Revolving_Trades_Last_6_Months__c,
                Mortgage_Trades_90Days_Dlq_In_12_months__c, Mortgage_Trades_In_12Months__c,
                Total_Credit_Personal_Finance_Inquires__c, Avg_Months_Trds_Opn_Excl_Collections__c, Personal_FICO_Score__c,
                Total_No_Trades_Count__c, Is_Recent_Bankruptcy__c, Is_Open_Bankruptcy__c, Total_No_Late_Mortgage_Count__c,
                Credit_Statement__c, Score_Factor_Code__c, Source_Type__c
            FROM Credit_Report_Detail__c
            WHERE Contact__c IN :contactIds
                AND Type__c = :GeneralConstants.CREDIT_REPORT_TYPE_EXPERIAN_CONSUMER
                AND Source_Type__c = :GeneralConstants.CREDIT_REPORT_SOURCE_TYPE_APPLICATIONS
        ];
    }

    public List<Credit_Report_Detail__c> getLexisNexisCreditReportByApplicationIds(Set<Id> applicationIds) {
        return [
            SELECT Id, Application__c, Type__c, Industry_Type__c, SIC_Code__c, Business_Start_Date__c, Business_First_Seen_YYYY__c,
                Fraud_Point_Score__c, Account__c, Contact__c, Source_Type__c
            FROM Credit_Report_Detail__c
            WHERE Application__c IN :applicationIds
                AND Type__c = :GeneralConstants.CREDIT_REPORT_TYPE_LEXIS_NEXIS
                AND Source_Type__c = :GeneralConstants.CREDIT_REPORT_SOURCE_TYPE_APPLICATIONS
        ];
    }

    public List<Credit_Report_Detail__c> getCanScoringReportByApplicationIds(Set<Id> applicationIds) {
        return [
            SELECT Id, Application__c, CAN_Scoring__c, Source_Type__c
            FROM Credit_Report_Detail__c
            WHERE Application__c IN :applicationIds
                AND Type__c = :GeneralConstants.CREDIT_REPORT_TYPE_CAN_SCORING
                AND Source_Type__c = :GeneralConstants.CREDIT_REPORT_SOURCE_TYPE_APPLICATIONS
        ];
    }

    public List<Credit_Report_Detail__c> getAllReportByApplicationIdOrAccountIdOrContactId(
        Set<Id> accountIdOrContactId, Set<Id> applicationIds
    ) {
        return [
            SELECT Id, Contact__c, Bankruptcy_Risk_Score__c, Account__c, Total_No_Trades_Count__c, CAN_Scoring__c,
                No_Of_Open_Trades__c, Overall_Amount_Balance_Ratio__c, Total_Credit_Inquiries_Last_6_Months__c,
                Open_Revolving_Trades_CreditRatio_100__c, Open_Revolving_Trades_Last_6_Months__c,Trades_Count_DBT_30_Plus__c,
                Mortgage_Trades_90Days_Dlq_In_12_months__c, Mortgage_Trades_In_12Months__c,Type__c,Most_Recent_Open_Collections_Trade_Age__c,
                Total_Credit_Personal_Finance_Inquires__c, Avg_Months_Trds_Opn_Excl_Collections__c, Personal_FICO_Score__c,
                Months_Since_Biz_Added_To_Experian__c, Guarantors_Whose_Identity_Not_Verified__c, Is_Guarantor_Identity_Verified__c,
                Is_Proof_Of_Ownership_Verified__c, Financial_Services_Charge_off__c, Credit_Statement__c, Judgement_Liens__c, Application__c,
                Past_Due_Amount__c, Total_Collection_Amount__c, Source_Type__c
            FROM Credit_Report_Detail__c
            WHERE Source_Type__c = :GeneralConstants.CREDIT_REPORT_SOURCE_TYPE_APPLICATIONS
                AND (Contact__c IN :AccountIdOrContactId
                OR Account__c IN :accountIdOrContactId
                OR Application__c IN :applicationIds)
        ];
    }

    public List<Credit_Report_Detail__c> getDataMerchReportByAccountIds(Set<Id> accountIds) {
        return [
            SELECT Id, Application__c, Account__c, Type__c, BIN__c, Legal_Name__c, Address__c, Street__c,
            City__c, State__c
            FROM Credit_Report_Detail__c
            WHERE Account__c IN :accountIds
                AND Type__c = :GeneralConstants.CREDIT_REPORT_TYPE_DATA_MERCH
        ];
    }
}