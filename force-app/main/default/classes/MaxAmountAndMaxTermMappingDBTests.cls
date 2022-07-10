@isTest(isParallel=true)
public class MaxAmountAndMaxTermMappingDBTests {

    private static MaxAmountAndMaxTermMappingDB maxAmountAndMaxTermMappingDBInstance = new MaxAmountAndMaxTermMappingDB();

    @isTest
    private static void getMaxAmountAndMaxTermMappings() {

        Test.startTest();
            List<CAN_Max_Amount_And_Max_Term_Mapping__c> canMaxAmountMaxTermList = maxAmountAndMaxTermMappingDBInstance.getMaxAmountAndMaxTermMappings();
        Test.stopTest();

        System.assert(canMaxAmountMaxTermList != null);
        System.assert(canMaxAmountMaxTermList.isEmpty());
    }

    @isTest
    private static void getMaxAmountAndMaxTermMappingsByRandomNumber() {

        Test.startTest();
            List<CAN_Max_Amount_And_Max_Term_Mapping__c> canMaxAmountMaxTermList = maxAmountAndMaxTermMappingDBInstance.getMaxAmountAndMaxTermMappingsByRandomNumber(1);
        Test.stopTest();

        System.assert(canMaxAmountMaxTermList != null);
        System.assert(canMaxAmountMaxTermList.isEmpty());
    }

}