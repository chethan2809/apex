@isTest
public class InvestorPayoutJobCallerTests {
    @isTest
    private static void executeInvestorPaymentJobTest() {
        TestUtility.runSetupData();

        Test.startTest();
            InvestorPayoutJobCaller.executeInvestorPaymentJob();
        Test.stopTest();
    }
}