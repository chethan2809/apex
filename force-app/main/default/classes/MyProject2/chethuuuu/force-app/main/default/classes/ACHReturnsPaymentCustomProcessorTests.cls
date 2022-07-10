@isTest
private class ACHReturnsPaymentCustomProcessorTests {
    @isTest
    private static void parseFile() {
        String fileContent = '';
        String objectType = '';
        List<loan.ACHReturn> achReturns;
        Test.startTest();
            ACHReturnsPaymentCustomProcessor contentParser = new ACHReturnsPaymentCustomProcessor();
            achReturns = contentParser.parseFile(fileContent, objectType);
        Test.stopTest();
        System.assertEquals(0, achReturns.size());
    }
}