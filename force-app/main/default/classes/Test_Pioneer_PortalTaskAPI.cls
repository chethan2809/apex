@IsTest(isParallel=true)
private class Test_Pioneer_PortalTaskAPI {
    @testSetup
    private static void setup() {
       TestUtility.runSetupData();
       clcommon__Document_Definition__c docDef = new clcommon__Document_Definition__c();
       docDef.Name = 'Bank Statements';
       docDef.clcommon__Active__c = true;
       docDef.Document_Category__c = 'Application';
       INSERT docDef;
       genesis__Applications__c application = TestUtility.createApplication();
    }
    @IsTest
    static void testPortalInit() {
        genesis__Applications__c application = [SELECT Id, Name FROM genesis__Applications__c];     
        Attachment attach=new Attachment();
    	attach.Name='Unit Test Attachment';
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	attach.body=bodyBlob;
        attach.parentId=[Select Id From clcommon__Document_Category__c Where genesis__Application__c =:application.Id].Id;
        insert attach;

        Test.startTest();
                clcommon.Response response = new Pioneer_PortalTaskAPI().invokeAction('', null, new Map<String, Object>{
                         'documentCatogories' => JSON.serialize([SELECT Id, Name FROM clcommon__Document_Category__c]),
                         CustomConstants.APPLICATION_ID => application.Id
                });
                system.assertEquals(response.Status,'SUCCESS');
         Test.stopTest();
    }
    @IsTest
    static void testPortalInitNoAttachment() {
        genesis__Applications__c application = [SELECT Id, Name FROM genesis__Applications__c];     
        Test.startTest();
                clcommon.Response response = new Pioneer_PortalTaskAPI().invokeAction('', null, new Map<String, Object>{
                         'documentCatogories' => JSON.serialize([SELECT Id, Name FROM clcommon__Document_Category__c]),
                         CustomConstants.APPLICATION_ID => application.Id
                });
                system.assertEquals(response.Status,'ERROR');
         Test.stopTest();
    }

    @IsTest
    static void testPortalInitException() {
        genesis__Applications__c application = [SELECT Id, Name FROM genesis__Applications__c];
        Test.startTest();  
                clcommon.Response response = new Pioneer_PortalTaskAPI().invokeAction('', null, new Map<String, Object>{
                         'documentCatogories' => JSON.serialize(application),
                         CustomConstants.APPLICATION_ID => application.Id
                });
                system.assertEquals(response.Status,'API_EXCEPTION');            
         Test.stopTest();
    }
}