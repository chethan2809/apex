@isTest
public class WasabiHTTPCallOutMocksTests {
	@isTest
    public static void WasabiSendDocumentSuccessResponseTestMethod(){

        WasabiHTTPCallOutMocks.WasabiSendDocumentSuccessResponse obj = new WasabiHTTPCallOutMocks.WasabiSendDocumentSuccessResponse();
        HTTPRequest req = new HTTPRequest();

        Test.startTest();
            obj.respond(req);
        Test.stopTest();

        System.assert(obj.respond(req) != Null);
    }

    @isTest
    public static void WasabiGetDocumentSuccessResponseTestMethod(){

        WasabiHTTPCallOutMocks.WasabiGetDocumentSuccessResponse obj = new WasabiHTTPCallOutMocks.WasabiGetDocumentSuccessResponse();
        HTTPRequest req = new HTTPRequest();

        Test.startTest();
            obj.respond(req);
        Test.stopTest();

        System.assert(obj.respond(req) != Null);
    }

    @isTest
    public static void WasabiErrorResponseTestMethod(){

        WasabiHTTPCallOutMocks.WasabiErrorResponse obj = new WasabiHTTPCallOutMocks.WasabiErrorResponse();
     	HTTPRequest req = new HTTPRequest();

        Test.startTest();
            obj.respond(req);
        Test.stopTest();

        System.assert(obj.respond(req) != Null);
    }
}