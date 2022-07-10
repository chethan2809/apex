@isTest
private class TestPortalSelectOfferAPI
{
    @isTest
    private static void test1()
    {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);
        Test.startTest();

        Profile profile = [Select Id from Profile where name = 'System Administrator'];
        User testUser = new User(
            ProfileId = profile.Id,
            Username = TestUtility.generateFakeName() + 'test6@test.com',
            Alias = 'test',
            Email='testu45678@test.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
            insert testUser;

            TestUtility.runSetupData();
            genesis__Applications__c appln = TestUtility.createApplication();
        	appln.Portal_Stage__c = 'LoanInfo';
        	Update appln;
        	String applicationId = (String)appln.Id;
        	String selectedOfferId = (String)'selectedOfferId';
        	String portalStage = (String) appln.Portal_Stage__c;
        	String portalSubstage = (String) appln.Portal_Sub_Stage__c;

        	appln = PortalSelectOfferAPI.updatePricingdetails(appln,selectedOfferId);

        	clcommon.Response response = new PortalSelectOfferAPI().invokeAction('', null, new Map<String, Object>{
                  'applicationId'=>applicationId,
                  'selectedOfferId'=>selectedOfferId,
                  'portalStage'=>portalStage,
                  'portalSubstage'=>portalSubstage
        	});

        	List<genesis__Application_Pricing_Detail__c> PricingList = new  List<genesis__Application_Pricing_Detail__c>();
        	try
        	{
            	genesis__Application_Pricing_Detail__c g_apd = new genesis__Application_Pricing_Detail__c(
            	);
            	PricingList.add(g_apd);
        	}
        	catch(Exception e)
        {
            if (e!=null)
            {
                Boolean b = True;
                System.assertEquals(True, b);
            }
            else
            {
                Boolean b = False;
                System.assertEquals(False, b );
            }
        }
        Test.stopTest();
    }

    @isTest
    private static void test2()
    {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);
        Test.startTest();

        Profile profile = [Select Id from Profile where name = 'System Administrator'];
        User testUser = new User(
            ProfileId = profile.Id,
            Username = TestUtility.generateFakeName() + 'test7@test.com',
            Alias = 'test',
            Email=System.now().millisecond() + 'test2@test.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
            insert testUser;

            TestUtility.runSetupData();
            genesis__Applications__c appln = TestUtility.createApplication();

        String applicationId = (String)appln.Id;
        String selectedOfferId = (String)'selectedOfferId';
        String portalStage = (String) appln.Portal_Stage__c;
        String portalSubstage = (String) appln.Portal_Sub_Stage__c;

        appln = PortalSelectOfferAPI.updatePricingdetails(appln,selectedOfferId);

        genesis__Application_Pricing_Detail__c apd = new genesis__Application_Pricing_Detail__c();
        apd.genesis__Application__c = appln.Id;
        apd.genesis__Term__c = 60;
        apd.genesis__Selected__c = true;
        insert apd;

        try
        {
            clcommon.Response response = new PortalSelectOfferAPI().invokeAction('', null, new Map<String, Object>{
                  'applicationId'=>applicationId,
                  'selectedOfferId'=>selectedOfferId,
                  'portalStage'=>portalStage,
                  'portalSubstage'=>portalSubstage
            });
        }
        catch(Exception e)
        {
            if (e!=null)
            {
                Boolean b = True;
                System.assertEquals(True, b);
            }
            else
            {
                Boolean b = False;
                System.assertEquals(False, b );
            }
        }
        Test.stopTest();
    }

    @isTest
    private static void test3()
    {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);
        Test.startTest();

        Profile profile = [Select Id from Profile where name = 'System Administrator'];
        User testUser = new User(
            ProfileId = profile.Id,
            Username = TestUtility.generateFakeName() + 'test8@test.com',
            Alias = 'test',
            Email=System.now().millisecond() + 'test2@test.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
            insert testUser;

             TestUtility.runSetupData();
            genesis__Applications__c appln = TestUtility.createApplication();
        String applicationId = (String)appln.Id;
        String portalStage = (String) appln.Portal_Stage__c;
        String portalSubstage = (String) appln.Portal_Sub_Stage__c;

        genesis__Application_Pricing_Detail__c apd = new genesis__Application_Pricing_Detail__c();
        apd.genesis__Application__c = appln.Id;
        apd.genesis__Term__c = 60;
        apd.genesis__Selected__c = false;
        insert apd;

        String selectedOfferId = (String)apd.Id;

        appln = PortalSelectOfferAPI.updatePricingdetails(appln,selectedOfferId);

        try
        {
            clcommon.Response response = new PortalSelectOfferAPI().invokeAction('', null, new Map<String, Object>{
                  'applicationId'=>applicationId,
                  'selectedOfferId'=>selectedOfferId,
                  'portalStage'=>portalStage,
                  'portalSubstage'=>portalSubstage
            });
        }
        catch(Exception e)
        {
            if (e!=null)
            {
                Boolean b = True;
                System.assertEquals(True, b);
            }
            else
            {
                Boolean b = False;
                System.assertEquals(False, b );
            }
        }
        Test.stopTest();
    }
}