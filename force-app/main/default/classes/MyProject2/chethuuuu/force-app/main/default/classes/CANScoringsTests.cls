@isTest
public class CANScoringsTests {

    @isTest
    static void createCANScoringCreditReportDetail(){

       TestUtility.runSetupData();

       genesis__Applications__c application =  new genesis__Applications__c();
       application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

       Id applicationsId = application.Id;

       Credit_Report_Detail__c creditReport = new Credit_Report_Detail__c();
       creditReport.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
       creditReport.Application__c = applicationsId;

       Map<Id, Credit_Report_Detail__c> creditReportByApplicationId = new Map<Id, Credit_Report_Detail__c>();
       creditReportByApplicationId.put(application.Id, creditReport) ;

       creditReport = creditReportByApplicationId.get(application.Id);

       Map<String, Object> canScoringResponseMap = new Map<String, Object>();
       canScoringResponseMap.put('score', '8.206353954644555');
       Decimal canScore = Decimal.valueOf((String) canScoringResponseMap.get('score'));
       Decimal expectedValue = canScore.setScale(4);

       Test.startTest();
            Credit_Report_Detail__c creditReports = CANScorings.createCANScoringCreditReportDetail(canScoringResponseMap, application, creditReportByApplicationId);
       Test.stopTest();

       system.assert(creditReports != null);
       system.assertEquals(expectedValue, creditReports.CAN_Scoring__c);
    }

    @isTest
    static void createCANScoringCreditReportDetailCondition(){

       TestUtility.runSetupData();

       genesis__Applications__c application =  new genesis__Applications__c();
       application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

       Id applicationsId = application.Id;

       Credit_Report_Detail__c creditReport = new Credit_Report_Detail__c();
       creditReport.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
       creditReport.Type__c = 'CAN Scoring';

       Map<Id, Credit_Report_Detail__c> creditReportByApplicationId = new Map<Id, Credit_Report_Detail__c>();
       creditReportByApplicationId.put(null , creditReport) ;

       Map<String, Object> canScoringResponseMap = new Map<String, Object>();
	   canScoringResponseMap.put('score', '8.206353954644555');


       Test.startTest();
            Credit_Report_Detail__c creditReports = CANScorings.createCANScoringCreditReportDetail(canScoringResponseMap, application, creditReportByApplicationId);
       Test.stopTest();

       system.assert(creditReports != null);
       system.assertEquals(GeneralConstants.CREDIT_REPORT_TYPE_CAN_SCORING , creditReports.Type__c);
    }

    @isTest
    static void updateTIERInApplication(){

       Decimal canScore = 10;

       genesis__Applications__c applicationDetail =  new genesis__Applications__c();
       applicationDetail.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
       applicationDetail.Type__c = 'Renewal';
       applicationDetail.SC4_Tier__c = 'TIER 1';
       CAN_Score_Cut_Off_Matrix__mdt canScoreCutOff = CAN_Score_Cut_Off_Matrix__mdt.getInstance('Renewal_TIER1');

       Test.startTest();
            CANScorings.updateTIERInApplication(canScore, applicationDetail);
       Test.stopTest();

       system.assertEquals(applicationDetail.SC4_Tier__c , canScoreCutOff.SC4_Tier__c);
    }
}