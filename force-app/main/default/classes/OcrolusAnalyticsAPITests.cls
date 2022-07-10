@isTest
private class OcrolusAnalyticsAPITests {

    @isTest
    private static void processOcrolusAnalyticsRequest() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/v1/ocrolus/analytics/';
        req.requestBody = Blob.valueOf(JSON.serialize(setUpReturnPayloadData()));

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
            OcrolusAnalyticsAPI.processOcrolusAnalyticsRequest();
        Test.stopTest();

        RestResponse resVal = RestContext.response;
        System.assertEquals(500, resVal.statusCode);
    }

    @isTest
    private static void processOcrolusAnalyticsRequestException() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Map<String,Object> ocrolusAnalyticsMap = new Map<String,Object>();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/v1/ocrolus/analytics/';
        req.requestBody = Blob.valueof(JSON.serialize(ocrolusAnalyticsMap));

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
            OcrolusAnalyticsAPI.processOcrolusAnalyticsRequest();
        Test.stopTest();

        RestResponse resVal = RestContext.response;
        System.assertEquals(400, resVal.statusCode);
    }

    private static Map<String, Object> setUpReturnPayloadData() {

        Map<String,Object> ocrolusAnalyticsMap = new Map<String,Object>();
        Map<String, Object> ocrolusIndicatorsForBusinessType = new Map<String, Object> ();
        Map<String, Object> ocrolusIndicators = new Map<String, Object> ();
        ocrolusIndicatorsForBusinessType.put('OfferGAV', 808708.2436);
        ocrolusIndicatorsForBusinessType.put('MaxDailyPayment', 851.2645);
        ocrolusIndicatorsForBusinessType.put('Volatility', null);
        ocrolusIndicatorsForBusinessType.put('NumberOfDeposits', 10);
        ocrolusIndicatorsForBusinessType.put('NumberOfBankStatements', 11);
        ocrolusIndicatorsForBusinessType.put('PrimaryBankAccountNumber', null);
        ocrolusIndicatorsForBusinessType.put('PrimaryBankAccountName', '128642520 CENTRIS FEDERAL CREDIT UNION CHECKING');

        ocrolusIndicators.put('non_sole', ocrolusIndicatorsForBusinessType);
        ocrolusIndicators.put('sole', ocrolusIndicatorsForBusinessType);
        ocrolusIndicators.put('NumberOfCompetitors', 1);
        ocrolusIndicators.put('DebtConsolidator', false);
        ocrolusIndicators.put('SuspiciousActivity', false);
        ocrolusIndicators.put('PotentialFraud', false);
        ocrolusIndicators.put('EndingBalanceMismatch', false);
        ocrolusIndicators.put('BeginEndingBalanceMismatch', true);

        List<String> competitorList = new List<String>();
        competitorList.add('Vader Servicing');

        ocrolusAnalyticsMap.put('pk', 12872807);
        ocrolusAnalyticsMap.put('Indicators', ocrolusIndicators);
        ocrolusAnalyticsMap.put('competitors', competitorList);
        return ocrolusAnalyticsMap;
    }
}