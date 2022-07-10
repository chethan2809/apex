@isTest(isParallel=true)
private class TestDescribeHelper {

    @isTest
    static void getSObjectResult() {
        Test.startTest();
            Schema.DescribeSObjectResult sObjectResult = DescribeHelper.getSObjectResult('Lead');
        Test.stopTest();

        System.assert(sObjectResult != null);
    }

    @isTest
    static void getPickListValues() {
        Test.startTest();
            List<String> picklistValues = DescribeHelper.getPickListValues('Lead', 'Industry');
        Test.stopTest();

        System.assert(picklistValues.size() > 0);
    }
}