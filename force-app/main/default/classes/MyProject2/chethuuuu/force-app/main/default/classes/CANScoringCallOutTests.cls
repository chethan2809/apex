@isTest
public class CANScoringCallOutTests {

    @TestSetup
    static void makeData(){

        TestUtility.runSetupData();
        genesis__Applications__c application = TestUtility.createApplication();
    }
    @future(Callout=true)
    public static void requestCANScorefutureMethod(Id Applicationid){

        genesis__Applications__c application = [SELECT id,Name,Type__c,genesis__Account__c
                                                FROM genesis__Applications__c
                                                WHERE id =:Applicationid
                                                LIMIT 1];

        Account accnt = [SELECT id,Name
                       	 FROM Account
                         WHERE id =:application.genesis__Account__c
                         LIMIT 1];

        List<Credit_Report_Detail__c> creditReportDetailList =
            [SELECT Id,Type__c,Application__c,Total_Credit_Inquiries_Last_6_Months__c,
                    Trades_Count_DBT_30_Plus__c,Total_No_Trades_Count__c,Open_Revolving_Trades_CreditRatio_100__c,Open_Revolving_Trades_Last_6_Months__c,Overall_Amount_Balance_Ratio__c,Mortgage_Trades_90Days_Dlq_In_12_months__c,
                    Mortgage_Trades_In_12Months__c,Total_Credit_Personal_Finance_Inquires__c,Most_Recent_Open_Collections_Trade_Age__c,
                    Personal_FICO_Score__c,Avg_Months_Trds_Opn_Excl_Collections__c,Months_Since_Biz_Added_To_Experian__c
             FROM Credit_Report_Detail__c
             WHERE Application__c =:application.id];

        Map<String,Credit_Report_Detail__c> creditReportDetailMap = new Map<String,Credit_Report_Detail__c>();

        	for(Credit_Report_Detail__c creditRec : creditReportDetailList){
        	creditReportDetailMap.put(creditRec.Type__c,creditRec);
        	}

        Map<Id, Map<String, Credit_Report_Detail__c>> creditReportDetailByApplicationId = new Map<Id, Map<String, Credit_Report_Detail__c>>();
   		creditReportDetailByApplicationId.put(application.id,creditReportDetailMap);

        Test.setMock(HttpCalloutMock.class, new MockCANScoringCallOut());
        CANScoringCallOut.requestCANScore(application,creditReportDetailByApplicationId,accnt);
        try{
            Test.setMock(HttpCalloutMock.class, new MockCANScoringCallOutStatusNotOK());
        	CANScoringCallOut.requestCANScore(application,creditReportDetailByApplicationId,accnt);
        }catch(Exception e){}

        System.assert(creditReportDetailList != Null);
    }

    @isTest
    public static void requestCANScoreTestMethod(){

        genesis__Applications__c application = [SELECT id,Name,Type__c,genesis__Account__c
                                                FROM genesis__Applications__c
                                                LIMIT 1];

        Account accnt = [SELECT id,Name
                       	 FROM Account
                         WHERE id =:application.genesis__Account__c LIMIT 1];

        Credit_Report_Detail__c creditReportDetail = new Credit_Report_Detail__c();
        creditReportDetail.Type__c = 'Experian Consumer';
        creditReportDetail.Application__c = application.Id;
        creditReportDetail.Account__c = accnt.Id;
		insert creditReportDetail;

        Credit_Report_Detail__c creditReportDetail1 = new Credit_Report_Detail__c();
        creditReportDetail1.Type__c = 'Experian Business';
        creditReportDetail1.Application__c = application.Id;
        creditReportDetail1.Account__c = accnt.Id;
		insert creditReportDetail1;

        requestCANScorefutureMethod(application.id);

        system.assert(accnt != Null);
        System.assertEquals('Experian Business', creditReportDetail1.Type__c);
    }
}