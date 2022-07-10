@IsTest
public with sharing class ForgotPasswordControllerTest {

	@IsTest
	public static void testForgotPasswordController() {
		ForgotPasswordController controller = new ForgotPasswordController();
		controller.username = TestUtility.generateFakeName() + '@example.com';
		System.assertEquals(controller.forgotPassword(),null);
	}
}