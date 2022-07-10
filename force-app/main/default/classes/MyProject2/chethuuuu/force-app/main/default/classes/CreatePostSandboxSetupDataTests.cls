@isTest
private class CreatePostSandboxSetupDataTests {

    @isTest
    private static void runSetup() {
        System.Test.startTest();
            CreatePostSandboxSetupData.runSetup();
        System.Test.stopTest();

        List<clcommon__CL_Product__c> actualCLProducts = [
            SELECT Id FROM clcommon__CL_Product__c WHERE clcommon__Product_Name__c = 'CAN Capital'
        ];

        System.assert(!actualCLProducts.isEmpty());
    }
}