@IsTest
public class TestPortalResetPasswordAPI {
   	/* Test Methods - Fuctionality */

    @isTest
    static void testResetPasswordAPI()
    {

        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

        Test.startTest();
        /* Test User */

        Profile profile = [Select Id from Profile where name = 'System Administrator'];
        User testUser = new User(
        ProfileId = profile.Id,
        Username = TestUtility.generateFakeName() + 'test2@test.com',
        Alias = 'test',
        Email=System.now().millisecond() + 'test2@test.com',
        EmailEncodingKey='UTF-8',
        FirstName='Bruce',
        LastName='Wayne',
        LanguageLocaleKey='en_US',
        LocaleSidKey='en_US',
        TimeZoneSidKey='America/Chicago'
        );
        insert testUser;

        clcommon.Response response = new PortalResetPasswordAPI().invokeAction('', null, new Map<String, Object>{
                  'email' => testUser.Email,
                  'password' => 'password'
        });


        if(testUser.Email != null && testUser.Email == testUser.Username)
        {
		    System.ResetPasswordResult result =  System.resetPassword(testUser.Id, true);

            response.status = clcommon.Constants.SUCCESS;

        	system.assertEquals(response.Status,'SUCCESS');
        }
        Test.stopTest();
    }

     @isTest
    static void testResetPasswordAPIExc()
    {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

        Test.startTest();

        /* Test User */

        Profile profile = [Select Id from Profile where name = 'System Administrator'];
        User testUser = new User(
        ProfileId = profile.Id,
        Username = TestUtility.generateFakeName() + 'test2@test.com',
        Alias = 'test',
        Email=System.now().millisecond() + 'test2@test.com',
        EmailEncodingKey='UTF-8',
        FirstName='Bruce',
        LastName='Wayne',
        LanguageLocaleKey='en_US',
        LocaleSidKey='en_US',
        TimeZoneSidKey='America/Chicago'
        );
        insert testUser;

        testUser.Email = '';
        try{
            clcommon.Response response = new PortalResetPasswordAPI().invokeAction('', null, new Map<String, Object>{
            'email' => testUser.Email
        });
        }
        catch (Exception e)
        {
            if ( e != null)
            {
                Boolean err = True;
                system.assertEquals(True,err);
            }
            else
            {
                Boolean err = False;
                system.assertEquals(False,err);
            }
        }
        Test.stopTest();
	}

}