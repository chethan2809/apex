@isTest
private class CLXConstantsTests {

    @isTest
    private static void clxConstantsPaymentPayoffResponses() {

        Test.startTest();
            Object x = CLXConstants.PAYMENT_AMT_RESPONSE;
            x = CLXConstants.PAYOFF_AMT_RESPONSE;
            x = CLXConstants.PAYMENT_SUC_RESPONSE;
            x = CLXConstants.PAYMENT_FAIL_RESPONSE;
            x = CLXConstants.PAYMENT_DUP_RESPONSE;
            x = CLXConstants.PAYMENT_OVER_RESPONSE;
            x = CLXConstants.PAYMENT_CLOSED_RESPONSE;
            x = CLXConstants.PAYOFF_SUC_RESPONSE;
            x = CLXConstants.PAYOFF_FAIL_RESPONSE;
            x = CLXConstants.PAYOFF_DUP_RESPONSE;
            x = CLXConstants.PAYOFF_NOT_RESPONSE;
            x = CLXConstants.REPAY_ACCT_RESPONSE;
        Test.stopTest();
    }
}