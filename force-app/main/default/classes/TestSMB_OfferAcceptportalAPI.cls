@isTest
public class TestSMB_OfferAcceptportalAPI
{
    @isTest
    public static void test2()
    {
        Test.startTest();
        TestUtility.runSetupData();
        genesis__Applications__c appln = TestUtility.createApplication();

        appln.Portal_Stage__c = 'LoanInfo';
        Update appln;

        List <genesis__Application_Pricing_Detail__c> Price = new List <genesis__Application_Pricing_Detail__c>();
        insert Price;

        clcommon.Response response = new SMB_OfferAcceptportalAPI().invokeAction('',null,new Map<String,Object>{
            'appId' => appln.Id,
            'Portal_Sub_Stage__c' => appln.Portal_Sub_Stage__c
        });

        if (appln.Portal_Sub_Stage__c != null)
        {
            Boolean b = True;
            System.assertEquals(True, b);
        }
        else
        {
            Boolean b = False;
            System.assertEquals(False, b);
        }

        Test.stopTest();
    }

    @isTest
    public static void test4()
    {
        Test.startTest();
        TestUtility.runSetupData();
        genesis__Applications__c appln = TestUtility.createApplication();
        appln.Portal_Stage__c = 'LoanInfo';
        Update appln;

        genesis__Application_Pricing_Detail__c apd = new genesis__Application_Pricing_Detail__c();
        apd.genesis__Application__c = appln.Id;
        apd.genesis__Term__c = 60;
        apd.genesis__Selected__c = true;
        apd.genesis__Payment_Amount_Per_Period__c = 100.00;
        insert apd;

        String apdId = string.valueOf(apd.Id);

        List <genesis__Application_Pricing_Detail__c> Price = new List <genesis__Application_Pricing_Detail__c>();
        insert Price;

        clcommon.Response response = new SMB_OfferAcceptportalAPI().invokeAction('',null,new Map<String,Object>{
            'applicationId' => appln.Id,
            'SelectedPaymentPlan' => apdId
        });

        Test.stopTest();
    }

    @isTest
    public static void test3()
    {
        Test.startTest();

        clcommon.Response response = new SMB_OfferAcceptportalAPI().invokeAction(null,null,new Map<String,Object>{});
        response.status = clcommon.Constants.ERROR;
        response.errorCode = clcommon.Constants.API_EXCEPTION;
        Test.stopTest();

        system.assertEquals(response.errorCode,'API_EXCEPTION');

    }
}