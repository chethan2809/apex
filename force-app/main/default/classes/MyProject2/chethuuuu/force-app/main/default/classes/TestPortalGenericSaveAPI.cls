@isTest
public with sharing class TestPortalGenericSaveAPI{

    @IsTest
    static void testPortalGenericSave1() {
        TestUtility.runSetupData();
        genesis__Applications__c application = TestUtility.createApplication();

        clcommon__Collateral__c collateralRecord = new clcommon__Collateral__c();
        collateralRecord.genesis__Application__c = application.Id;
        collateralRecord.clcommon__Collateral_Name__c = 'test collateral';

        Test.startTest();
            clcommon.Response response = new PortalGenericSaveAPI().invokeAction('', null, new Map<String, Object>{
                    'objectName' => 'collateral',
                    'objectData' => Json.serialize(collateralRecord)
            });
        Test.stopTest();

        System.assert(response != null);
        System.assertEquals('SUCCESS', response.Status);
    }

    @isTest
    private static void getNamespaceForObjectName(){

        PortalGenericSaveAPI getNamespaceObj = new PortalGenericSaveAPI();

        Test.startTest();
            getNamespaceObj.getNamespaceForObjectName();
        Test.stopTest();

        System.assert(getNamespaceObj != Null);
    }
}