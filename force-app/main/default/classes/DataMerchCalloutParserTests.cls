@isTest
public class DataMerchCalloutParserTests {

    @isTest
    private static void dataMerchResponseBody(){
        Account accountDetail = new Account();
        accountDetail.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountDetail.Business_Tax_ID__c = '123456789';

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);
        response.setStatus('OK');
        response.setBody('[{"merchant": {"fein": "12-3456789", "legal_name": "Legal Name", "dba": "", "address": null, "street1": null, "street2": null, "city": "City Name", "state": "TX", "business_phone": "", "business_startdate": null, "industry": "", "notes": [{"note": { "note": "Default account", "category": "Default Account", "added_by": "Reporter Name", "created_at": "2022-03-02T19:52:49.803Z" }}]} }]');

        Test.startTest();
        DataMerchCalloutParser parser = new DataMerchCalloutParser(accountDetail);
        Map<String, Object> dataMerchResponse = parser.dataMerchResponseBody(response);
        Test.stopTest();

        System.assertEquals(accountDetail.Business_Tax_ID__c, parser.merchantEIN);
        System.assert(dataMerchResponse.size() > 0);
    }

}