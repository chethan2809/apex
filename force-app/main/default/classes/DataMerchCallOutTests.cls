@isTest(isParallel=true)
public class DataMerchCallOutTests {
    @Future(Callout=true)
    public static void getAccessTokenfuturemethod(){
        API_Detail__mdt apiDetails = DataMerch.dataMerchAPIDetails;
        Test.setMock(HttpCalloutMock.class, new DataMerchCallOutMock.DataMerchSuccessResponse());
        String token = DataMerchCallOut.getAccessToken(apiDetails);

        System.assert(token != Null);
    }

    @isTest
    public static void getAccessTokenTestMethod(){

		getAccessTokenfuturemethod();
    }

    @Future(Callout=true)
    public static void requestDataMerchfuturemethod(){
        Account accountObj = new Account();
        accountObj.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountObj.Business_Tax_ID__c = '852802924';

        Test.setMock(HttpCalloutMock.class, new DataMerchCallOutMock.DataMerchSuccessResponse());
        HttpResponse response = DataMerchCallOut.requestDataMerch(accountObj, 'DataMerch_API_Sandbox');

        System.assert(response != Null);
    }

    @isTest
    public static void requestDataMerchTestMethod(){

		requestDataMerchfuturemethod();
    }


}