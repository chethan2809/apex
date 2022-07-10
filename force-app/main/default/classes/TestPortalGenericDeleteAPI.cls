@isTest
public class TestPortalGenericDeleteAPI {

    @IsTest
    static void testGenericDeleteAPI() {
        Test.startTest();
        clcommon.Response  response = new PortalGenericDeleteAPI().invokeAction('', null, new Map<String, Object>{
        });
        Test.stopTest();
        system.assertEquals(response.Status,'SUCCESS');
    }

    @IsTest
    static void testGenericDeleteAPI1() {
        Test.startTest();
        TestUtility.runSetupData();
        genesis__Applications__c appln = TestUtility.createApplication();

        Map<String, String> portalArgMapKeyToSobjectNameMap = new Map<String, String> {'objectName' => 'genesis__Applications__c'};

        clcommon.Response  response = new PortalGenericDeleteAPI().invokeAction('', null, new Map<String, Object>{
                'objectId' => appln.id,
                'objectName' => 'Application'
        });
        Test.stopTest();
        system.assertEquals(response.Status,'SUCCESS');
    }
}