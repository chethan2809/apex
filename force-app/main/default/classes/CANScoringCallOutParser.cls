public class CANScoringCallOutParser {

    Contact contactObj;
    Account accountObj;
    public CANScoringCallOutParser(Contact contactObj, Account accountObj) {
        this.contactObj = contactObj;
        this.accountObj = accountObj;
    }

    public static Map<String, Object> buildRequest(
        genesis__Applications__c application, Map<Id, Map<String, Credit_Report_Detail__c>> creditReportDetailByApplicationId,
        Account accountDetail
    ) {
        Map<String, Credit_Report_Detail__c> creditReportByType = creditReportDetailByApplicationId.get(application.Id);

        if(creditReportByType == null || !creditReportByType.containsKey(GeneralConstants.CREDIT_REPORT_TYPE_EXPERIAN_BUSINESS)
            || !creditReportByType.containsKey(GeneralConstants.CREDIT_REPORT_TYPE_EXPERIAN_CONSUMER)
        ) {
            throw new CANScoringCallOutParserException(
                'Either Experian Business Report Or Consumer Report not exist for the Application: '+ application.Id
            );
        }

        Credit_Report_Detail__c experianBusinessCreditReport = creditReportByType.get(GeneralConstants.CREDIT_REPORT_TYPE_EXPERIAN_BUSINESS);
        Credit_Report_Detail__c experianConsumerCreditReport = creditReportByType.get(GeneralConstants.CREDIT_REPORT_TYPE_EXPERIAN_CONSUMER);

        Map<String, Object> paramBody = new Map<String, Object>();
        paramBody.put('contract_id', Integer.valueOf(application.Name.remove('APP-')));
        paramBody.put('product_id', 1);
        paramBody.put('contract_type', (application.Type__c == GeneralConstants.LOAN_TYPE_RENEWAL) ? 'refinance' : 'new');
        paramBody.put('iqt9426', experianConsumerCreditReport.Total_Credit_Inquiries_Last_6_Months__c);
        paramBody.put('ttc058', experianBusinessCreditReport.Trades_Count_DBT_30_Plus__c);
        paramBody.put('ttc050', experianBusinessCreditReport.Total_No_Trades_Count__c);
        paramBody.put('rev3423', experianConsumerCreditReport.Open_Revolving_Trades_CreditRatio_100__c);
        paramBody.put('rev0416', experianConsumerCreditReport.Open_Revolving_Trades_Last_6_Months__c);
        paramBody.put('all7170', experianConsumerCreditReport.Overall_Amount_Balance_Ratio__c);
        paramBody.put('mta2387', experianConsumerCreditReport.Mortgage_Trades_90Days_Dlq_In_12_months__c);
        paramBody.put('mta0317', experianConsumerCreditReport.Mortgage_Trades_In_12Months__c);
        paramBody.put('iqf9410', experianConsumerCreditReport.Total_Credit_Personal_Finance_Inquires__c);
        paramBody.put('clo015', experianBusinessCreditReport.Most_Recent_Open_Collections_Trade_Age__c);
        paramBody.put('fico', experianConsumerCreditReport.Personal_FICO_Score__c);
        paramBody.put('all8320', experianConsumerCreditReport.Avg_Months_Trds_Opn_Excl_Collections__c);
        paramBody.put('tto077', experianBusinessCreditReport.Months_Since_Biz_Added_To_Experian__c);

        if(application.Type__c == GeneralConstants.LOAN_TYPE_RENEWAL) {
            paramBody.put('avg_bounced_num_12m', accountDetail.Legacy_Average_Bounced_Number_12M__c != null ? accountDetail.Legacy_Average_Bounced_Number_12M__c : 0);
            paramBody.put('avg_bounced_num_1m', accountDetail.Legacy_Average_Bounced_Number_1M__c != null ? accountDetail.Legacy_Average_Bounced_Number_1M__c : 0);
            paramBody.put('paid_pct_high_ind', accountDetail.Paid_Pct_High_Ind__c != null ? accountDetail.Paid_Pct_High_Ind__c : 0);
            paramBody.put('ever_paid_days', accountDetail.Legacy_Ever_Paid_Days__c != null ? accountDetail.Legacy_Ever_Paid_Days__c : 0);
        }

        return paramBody;
    }

    private class CANScoringCallOutParserException extends Exception {}
}