@IsTest public with sharing class SiteRegisterControllerTest {

    @IsTest
    static void testRegistration() {
        SiteRegisterController controller = new SiteRegisterController();
        controller.username = TestUtility.generateFakeName() + '@example.com';
        controller.email = 'test@force.com';
        controller.communityNickname = 'test';
        System.assert(controller.registerUser() == null);

        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd123';
        System.assert(controller.registerUser() == null);
    }
}