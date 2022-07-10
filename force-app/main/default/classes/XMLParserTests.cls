@isTest(isParallel=true)
private class XMLParserTests {
    @isTest
    private static void parseXMLResponse() {
        Set<String> parentModels = new Set<String> {'OrderInfo', 'Filer', 'DebtorName', 'SecuredName', 'IndividualName', 'Note', 'Attachment'};
        Set<String> responseModels = new Set<String> {'OrderID'};
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/xml');
        response.setStatusCode(200);
        response.setStatus('OK');
        response.setBody(
            '<GetOrderInformationResult><OrderInfo><OrderID>153405863</OrderID><OrderID>153401234</OrderID></OrderInfo></GetOrderInformationResult>'
        );

        Map<String, List<String>> xmlDataMap = new Map<String, List<String>>();
        Test.startTest();
            xmlDataMap = XMLParser.parseXMLResponse(response, responseModels, parentModels);
        Test.stopTest();

        System.assert(xmlDataMap.containsKey('OrderID'));
    }

    @isTest
    private static void parseXMLWithFailedResponse() {
        Set<String> parentModels = new Set<String> {'OrderInfo', 'Filer', 'DebtorName', 'SecuredName', 'IndividualName', 'Note', 'Attachment'};
        Set<String> responseModels = new Set<String> {'faultstring'};
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/xml');
        response.setStatusCode(500);

        Map<String, List<String>> xmlDataMap = new Map<String, List<String>>();
        Test.startTest();
            xmlDataMap = XMLParser.parseXMLResponse(response, responseModels, parentModels);
        Test.stopTest();

        System.assert(!xmlDataMap.containsKey('faultstring'));
    }
}