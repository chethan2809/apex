@isTest
    public class UCCCalloutMocksTests {
        @isTest
        public static void UCCCallOutMockCreateFilingTestMethod() {

            UCCCalloutMock.UCCCallOutMockCreateFiling obj = new UCCCalloutMock.UCCCallOutMockCreateFiling();
            HTTPRequest req = new HTTPRequest();

            Test.startTest();
                obj.respond(req);
            Test.stopTest();

            System.assert(obj.respond(req) != Null);
    }

    @isTest
    public static void UCCCalloutMockGetOrderInformationByUCCFilingDetailTests() {
        UCCCalloutMock.UCCCalloutMockGetOrderInformationByUCCFilingDetail obj = new UCCCalloutMock.UCCCalloutMockGetOrderInformationByUCCFilingDetail();
            HTTPRequest req = new HTTPRequest();

            Test.startTest();
                obj.respond(req);
            Test.stopTest();

            System.assert(obj.respond(req) != Null);
    }

    @isTest
    public static void UCCCalloutMockUccFilingContinuationTests() {
        UCCCalloutMock.UCCCalloutMockUccFilingContinuation obj = new UCCCalloutMock.UCCCalloutMockUccFilingContinuation();
        HTTPRequest req = new HTTPRequest();

        Test.startTest();
            obj.respond(req);
        Test.stopTest();

        System.assert(obj.respond(req) != Null);
    }

    @isTest
    public static void UCCCalloutMockUccValidateApproveFilingTests() {
        UCCCalloutMock.UCCCalloutMockUccValidateApproveFiling obj = new UCCCalloutMock.UCCCalloutMockUccValidateApproveFiling();
        HTTPRequest req = new HTTPRequest();

        Test.startTest();
            obj.respond(req);
        Test.stopTest();

        System.assert(obj.respond(req) != Null);
    }

    @isTest
    public static void UCCCalloutMockTerminateUCCFilingTests() {
        UCCCalloutMock.UCCCalloutMockTerminateUCCFiling obj = new UCCCalloutMock.UCCCalloutMockTerminateUCCFiling();
        HTTPRequest req = new HTTPRequest();

        Test.startTest();
            obj.respond(req);
        Test.stopTest();

        System.assert(obj.respond(req) != Null);
    }

    @isTest
    public static void UCCCalloutMockUpdateUCCFilingTests() {
        UCCCalloutMock.UCCCalloutMockUpdateUCCFiling obj = new UCCCalloutMock.UCCCalloutMockUpdateUCCFiling();
        HTTPRequest req = new HTTPRequest();

        Test.startTest();
            obj.respond(req);
        Test.stopTest();

        System.assert(obj.respond(req) != Null);
    }
}