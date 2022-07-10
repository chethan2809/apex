public class DescribeHelper {

    @TestVisible
    private static DescribeHelper describeHelperInstance = new DescribeHelper();

    public static Map<String, Schema.SObjectType> getGlobalDescribe{
        get{
            if(getGlobalDescribe == null){
                getGlobalDescribe = Schema.getGlobalDescribe();
            }
            return getGlobalDescribe;
        }
        set;
    }

    public static Map<String, Schema.DescribeSObjectResult> sObjectResult{
        get{
            if(sObjectResult == null){
                sObjectResult = new Map<String, Schema.DescribeSObjectResult>();
            }
            return sObjectResult;
        }
        set;
    }

    public static Schema.DescribeSObjectResult getSObjectResult(String objectType) {
        if(!sObjectResult.containsKey(objectType)){
            Schema.SObjectType convertToObj = getGlobalDescribe.get(objectType);
            if (convertToObj == null) {
                throw new DescribeHelperException(objectType + ' does not exist in the system.');
            }
            Schema.DescribeSObjectResult res = convertToObj.getDescribe();
            sObjectResult.put(objectType, res);
        }
        return sObjectResult.get(objectType);
    }

    public static List<String> getPickListValues(String objectType, String selectedField){
        List<String> pickListValuesList = new List<String>();

        Schema.DescribeSObjectResult res = getSObjectResult(objectType);
        Schema.sObjectField sObjectFieldName = res.fields.getMap().get(selectedField);
        List<Schema.PickListEntry> pickListEntryValues = describeHelperInstance.getPickListEntries(sObjectFieldName);
        for( Schema.PickListEntry pickListVal : pickListEntryValues){
            pickListValuesList.add(pickListVal.getLabel());
        }

        return pickListValuesList;
    }

    public List<Schema.PickListEntry> getPickListEntries(Schema.sObjectField sObjectFieldName) {
        return sObjectFieldName.getDescribe().getPicklistValues();
    }

    private class DescribeHelperException extends Exception {}
}