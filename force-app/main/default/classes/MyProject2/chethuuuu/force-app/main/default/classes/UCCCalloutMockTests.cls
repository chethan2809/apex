@isTest
public class UCCCalloutMockTests {
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
        req.setEndpoint('ContinueFiling');

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
    public static void UCCCalloutMockUccValidateFilingTests() {
        UCCCalloutMock.UCCCalloutMockUccValidateFiling obj = new UCCCalloutMock.UCCCalloutMockUccValidateFiling();
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

    @isTest
    public static void UCCCalloutMockGetPlaceIDTests() {

        UCCCalloutMock.UCCCalloutMockGetPlaceID obj = new UCCCalloutMock.UCCCalloutMockGetPlaceID();
         HTTPRequest req = new HTTPRequest();

        Test.startTest();
            obj.respond(req);
        Test.stopTest();

        System.assert(obj.respond(req) != Null);
    }

    @isTest
    public static void UCCCalloutMockGetCountyParishForUCCTests() {

        UCCCalloutMock.UCCCalloutMockGetCountyParishForUCC obj = new UCCCalloutMock.UCCCalloutMockGetCountyParishForUCC();
        HTTPRequest req = new HTTPRequest();

        Test.startTest();
            obj.respond(req);
        Test.stopTest();

        System.assert(obj.respond(req) != Null);
    }

    @isTest
    public static void UCCCalloutMockValidateStringValueTests() {

        UCCCalloutMock.UCCCalloutMockValidateStringValue obj = new UCCCalloutMock.UCCCalloutMockValidateStringValue();
        HTTPRequest req = new HTTPRequest();

        Test.startTest();
            obj.respond(req);
        Test.stopTest();

        System.assert(obj.respond(req) != Null);
    }

    @isTest
    public static void UCCCalloutMockGetUCCAttachmentsByAttachmentIdTests(){

        UCCCalloutMock.UCCCalloutMockGetUCCAttachmentsByAttachmentId obj = new UCCCalloutMock.UCCCalloutMockGetUCCAttachmentsByAttachmentId();
        HTTPRequest req = new HTTPRequest();

        Test.startTest();
            obj.respond(req);
        Test.stopTest();

        System.assert(obj.respond(req) != Null);
    }

    @isTest
    public static void UCCCalloutMockGetUCCAttachmentsFromExternalURLTests(){

        UCCCalloutMock.UCCCalloutMockGetUCCAttachmentsFromExternalURL obj = new UCCCalloutMock.UCCCalloutMockGetUCCAttachmentsFromExternalURL();
        HTTPRequest req = new HTTPRequest();

        Test.startTest();
            obj.respond(req);
        Test.stopTest();

        System.assert(obj.respond(req) != Null);
    }
}