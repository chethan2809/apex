@IsTest
public with sharing class LightningLoginFormControllerTest {

    @IsTest
    static void LightningLoginFormControllerInstantiation() {
        LightningLoginFormController controller = new LightningLoginFormController();
        System.assertNotEquals(controller, null);
    }

    @IsTest
    static void testIsUsernamePasswordEnabled() {
        System.assertEquals(true, LightningLoginFormController.getIsUsernamePasswordEnabled());
    }

    @IsTest
    static void testIsSelfRegistrationEnabled() {
        System.assertEquals(false, LightningLoginFormController.getIsSelfRegistrationEnabled());
    }

    @IsTest
    static void testGetSelfRegistrationURL() {
        System.assertEquals(null, LightningLoginFormController.getSelfRegistrationUrl());
    }

    @IsTest
    static void testAuthConfig() {
        Auth.AuthConfiguration authConfig = LightningLoginFormController.getAuthConfig();
        System.assertNotEquals(null, authConfig);
    }

    @IsTest
    static void login() {
        Test.startTest();
            String loginString = LightningLoginFormController.login('testuser', 'testpwd', 'https://google.com');
        Test.stopTest();
    }

    @IsTest
    static void getForgotPasswordUrl() {
        Test.startTest();
            String passwordUrl = LightningLoginFormController.getForgotPasswordUrl();
        Test.stopTest();
    }

    @IsTest
    static void setExperienceId() {
        Test.startTest();
            String experianId = LightningLoginFormController.setExperienceId('expId');
        Test.stopTest();
        System.assert(experianId != null);
    }
}