@isTest
public class LightningLoginFormControllerTests {
    private static LightningLoginFormController controller = new LightningLoginFormController();

    @isTest
    static void loginTest() {
        Test.startTest();
            String actualExpId = LightningLoginFormController.login('TestUser', 'Password', 'http://a.com');
        Test.stopTest();

        System.assertEquals(null, actualExpId);
    }

    @isTest
    static void getForgotPasswordUrl() {
        Test.startTest();
            String authConfig = LightningLoginFormController.getForgotPasswordUrl();
        Test.stopTest();

        System.assertEquals(null, authConfig);
    }

    @isTest
    static void testIsUsernamePasswordEnabled() {
        Test.startTest();
            Boolean actualValue = LightningLoginFormController.getIsUsernamePasswordEnabled();
        Test.stopTest();

        System.assertEquals(true, actualValue);
    }

    @isTest
    static void testIsSelfRegistrationEnabled() {
        Test.startTest();
            Boolean actualValue = LightningLoginFormController.getIsSelfRegistrationEnabled();
        Test.stopTest();

        System.assertEquals(false, actualValue);
    }

    @isTest
    static void testGetSelfRegistrationURL() {
        Auth.AuthConfiguration authConfig = LightningLoginFormController.getAuthConfig();
        Test.startTest();
            String actualValue = LightningLoginFormController.getSelfRegistrationUrl();
        Test.stopTest();

        System.assertEquals(null, actualValue);
    }

    @isTest
    static void testAuthConfig() {
        Auth.AuthConfiguration authConfig = LightningLoginFormController.getAuthConfig();
        System.assertNotEquals(null, authConfig);
    }

    @isTest
    private static void setExperienceId() {
        String expId = TestUtility.getFakeId(Account.getSObjectType());
        Test.startTest();
            String actualExpId = LightningLoginFormController.setExperienceId(expId);
        Test.stopTest();

        System.assertEquals('This method can be invoked only from within a community.', actualExpId);
    }
}