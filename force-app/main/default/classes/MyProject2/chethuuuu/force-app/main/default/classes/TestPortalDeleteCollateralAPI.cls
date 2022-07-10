@isTest
private class TestPortalDeleteCollateralAPI {

    @isTest
    private static void testDeleteCollateralAPI() {

        TestUtility.runSetupData();
        genesis__Applications__c application = TestUtility.createApplication();

        clcommon__Collateral__c collateral = new clcommon__Collateral__c();
        collateral.clcommon__Collateral_Name__c = 'Dummy Collateral';
        collateral.clcommon__Address__c = 'USA';
        collateral.clcommon__City__c = 'CA';
        collateral.clcommon__Collateral_Code__c = '1001';
        collateral.clcommon__Postal_Code__c = '51610';
        insert collateral;

        genesis__Application_Collateral__c applicationCollateral = new genesis__Application_Collateral__c();
        applicationCollateral.genesis__Collateral__c = collateral.Id;
        insert applicationCollateral;

        Test.startTest();
            clcommon.Response response = new PortalDeleteCollateralAPI().invokeAction('', null, new Map<String, Object>{
                    'applicationId' => application.Id,
                    'collaterals' => JSON.serialize(applicationCollateral)
            });
        Test.stopTest();

        System.assertEquals(clcommon.Constants.SUCCESS, response.Status);
        System.assertEquals(null, response.errorMessage);
        System.assertEquals('NO_ERROR', response.errorCode);
    }

    @isTest
    private static void testDeleteCollateralList() {

        Test.startTest();
            clcommon.Response response = new PortalDeleteCollateralAPI().invokeAction('', null, new Map<String, Object>{});
    	Test.stopTest();

        System.assertEquals('ERROR', response.Status);
        System.assertEquals('Something went wrong', response.errorMessage);
        System.assertEquals('API_EXCEPTION', response.errorCode);
    }
}