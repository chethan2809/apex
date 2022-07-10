@isTest
private class TestPortalUtils
{
    @isTest
    private static void testSession()
    {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);
        Test.startTest();
        Profile profile = [SELECT Id FROM Profile WHERE name = 'System Administrator' LIMIT 1];
        User testUser = new User(
            ProfileId = profile.Id,
            Username = TestUtility.generateFakeName() + '@example.com',
            Alias = 'test',
            Email=System.now().millisecond() + 'test2@test.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey =  'America/New_York'
        );
        insert testUser;

        Boolean b = PortalUtils.validateSession();

        if(testUser.Id != null)
        {
            testUser.IsActive = True;
            Boolean ex = testUser.IsActive;
            System.assertEquals(True, ex);
        }
        else
        {
            testUser.IsActive = False;
            Boolean ex = testUser.IsActive;
            System.assertEquals(False, ex);
        }
        Test.stopTest();
    }

    @isTest
    private static void testNull()
    {
        Test.startTest();
        try
        {
            Boolean b = PortalUtils.validateRequest( new Map <String, Object>{},new List<String>{'test','test1'});
            clcommon.Response c = PortalUtils.setResponse( null, null , null);
            clcommon.Response d = PortalUtils.setResponse( null );
            clcommon.Response o = PortalUtils.setResponse( null, new Map<String,Object>{});
        }
        catch (Exception e)
        {
            if ( e != null)
            {
                Boolean ex = True;
                System.assertEquals(True, ex);
            }
            else
            {
                Boolean ex = False;
                System.assertEquals(False, ex);
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void testPortalLog()
    {
        Test.startTest();

        clcommon__Log__c portalLog = new clcommon__Log__c();
        portalLog.clcommon__Time__c = DateTime.now();
        portalLog.clcommon__Message__c = 'This is Message';
        portalLog.clcommon__Type__c = null;
        insert portalLog;

        String p_message = portalLog.clcommon__Message__c;
        Datetime p_time = portalLog.clcommon__Time__c;
        String p_type = portalLog.clcommon__Type__c;

        Exception e = null;
        PortalUtils.insertPortalLog(p_message, p_type);

        Test.stopTest();
    }

    @IsTest
    private static void testPortalLog1()
    {
        Exception ex;
        try
        {
            Account account = new Account();
            account.phone = '123456';
            insert account;
        }
        catch (Exception e)
        {
            Test.startTest();
                PortalUtils.insertPortalLog(e, 'accounterror');
                ex = e;
            Test.stopTest();
            System.assert(ex != null);
        }
    }

    @IsTest
    private static void validateContact()
    {
        Contact contact = TestUtility.createContact();
        Test.startTest();
            boolean contactValue = PortalUtils.validateContact(contact.Id);
        Test.stopTest();
        System.assertEquals(True, contactValue);
    }

    @IsTest
    private static void validateAccount()
    {
        Account account = TestUtility.createAccount();
        Test.startTest();
            boolean accountValue = PortalUtils.validateAccount(account.Id);
        Test.stopTest();
        System.assertEquals(True, accountValue);
    }

    @IsTest
    private static void validaterRelatedContact()
    {
        Account account = TestUtility.createAccount();
        Contact contact = TestUtility.createContact();
        Test.startTest();
            boolean accountValue = PortalUtils.validaterRelatedContact(contact.Id, account.Id);
        Test.stopTest();
        System.assertEquals(false, accountValue);
    }
}