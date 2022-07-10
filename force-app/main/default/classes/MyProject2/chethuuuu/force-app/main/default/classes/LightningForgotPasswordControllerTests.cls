@isTest
private class LightningForgotPasswordControllerTests {
    private static LightningForgotPasswordController controller = new LightningForgotPasswordController();

    @isTest
    private static void testLightningForgotPasswordControllerInvalidUserName() {
        Test.startTest();
            String actualEmail = LightningForgotPasswordController.forgotPassword('fakeUser', 'http://a.com');
        Test.stopTest();

        System.assertEquals(Label.Site.invalid_email, actualEmail);
    }

    @isTest
    private static void testLightningForgotPasswordNull() {
        Test.startTest();
            String actualEmail = LightningForgotPasswordController.forgotPassword(null, null);
        Test.stopTest();

        System.assertEquals('Argument 1 cannot be null', actualEmail);
    }

    @isTest
    private static void setExperienceId() {
        String expId = TestUtility.getFakeId(Account.getSObjectType());
        Test.startTest();
            String actualExpId = LightningForgotPasswordController.setExperienceId(expId);
        Test.stopTest();

        System.assertEquals('This method can be invoked only from within a community.', actualExpId);
    }
}