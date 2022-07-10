public class DataMerchCalloutParser {

    Account accountObj;

    public DataMerchCalloutParser(Account accountObj) {
        this.accountObj = accountObj;
    }

    public String merchantEIN {
        get {
            if(this.accountObj != null) {
                merchantEIN = this.accountObj.Business_Tax_ID__c;
            }
            return merchantEIN;
        }
        set;
    }

    public Map<String, Object> dataMerchResponseBody(HttpResponse response) {
        String responseBody = response.getBody();
        List<Object> responseList;
        Map<String, Object> responseMap;
        Map<String, Object> resultMap = new Map<String, Object>();

        //DataMerch results are contained on list of json and errors on json only
        if(responseBody.startsWith('[')){
            responseList = (List<Object>) JSON.deserializeUntyped(responseBody);
            if(responseList.size() > 0){
                responseMap = (Map<String, Object>) responseList[0];
                resultMap.putAll((Map<String,Object>)responseMap.get('merchant'));
            }
        }
        return resultMap;
    }
}