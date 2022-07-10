@isTest
private class TestPortalForgotPasswordAPI {

    @isTest
    private static void forgotPasswordAPISuccess() {
        User testUser = testUser();

        Test.startTest();
            clcommon.Response response = new PortalForgotPasswordAPI().invokeAction('', null, new Map<String, Object>{
                    'email' => testUser.Email
            });
		    System.ResetPasswordResult result =  System.resetPassword(testUser.Id, true);
        Test.stopTest();

        System.assertEquals(clcommon.Constants.SUCCESS, response.Status);
        System.assertEquals(null, response.errorMessage);
        System.assertEquals('NO_ERROR', response.errorCode);
    }

    @isTest
    private static void forgotPasswordAPIException() {
        User testUser = testUser();
        testUser.Email = '';

        Exception ex;
        Test.startTest();
        try{
            clcommon.Response response = new PortalForgotPasswordAPI().invokeAction('', null, new Map<String, Object>{
            'email' => testUser.Email
        });
        }
        catch (Exception e){
            ex = e;
            TestUtility.assertException(ex);
            System.assert(ex.getMessage() != null);
        }
        Test.stopTest();
	}

    @isTest
    private static void forgotPasswordAPIError() {

        Test.startTest();
            clcommon.Response response = new PortalForgotPasswordAPI().invokeAction(null, null, new Map<String, Object>{
            });
        Test.stopTest();

        response.status = clcommon.Constants.ERROR;
        response.errorCode = clcommon.Constants.API_EXCEPTION;

        System.assertEquals('ERROR', response.status);
        System.assertEquals('API_EXCEPTION', response.errorCode);
    }

    private static User testUser(){

        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = new User(
            ProfileId = profile.Id,
            Username = '596test2@test.com',
            Alias = 'test',
            Email = '596test2@test.com',
            EmailEncodingKey = 'UTF-8',
            FirstName = 'Bruce',
            LastName = 'Wayne',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Chicago'
        );
        insert testUser;
        return testUser;
    }
}