@IsTest
public class Test_SMB_BusinessInfoAPI {

    @isTest
    static void test_SMB_BusinessInfoAPI()
    {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);
        Test.startTest();
        Profile profile = [Select Id from Profile where name = 'System Administrator'];
        User testUser = new User(
        ProfileId = profile.Id,
        Username = TestUtility.generateFakeName() + '@example.com',
        Alias = 'test',
        Email='testUser2342@test.com',
        EmailEncodingKey='UTF-8',
        Firstname='Bruce',
        Lastname='Wayne',
        LanguageLocaleKey='en_US',
        LocaleSidKey='en_US',
        TimeZoneSidKey='America/Chicago'
        );
        insert testUser;

        clcommon.Response response = new SMB_BusinessInfoAPI().invokeAction('', null, new Map<String, Object>{
        });
        Test.stopTest();
    }

    @isTest
    static void test_SMB_BusinessInfoAPI1()
    {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);
        Test.startTest();

        Profile profile = [Select Id from Profile where name = 'System Administrator'];
        User testUser = new User(
        ProfileId = profile.Id,
        Username = TestUtility.generateFakeName() + '@example.com',
        Alias = 'test',
        Email='testUser2362@test.com',
        EmailEncodingKey='UTF-8',
        Firstname='Bruce',
        Lastname='Wayne',
        LanguageLocaleKey='en_US',
        LocaleSidKey='en_US',
        TimeZoneSidKey='America/Chicago'
        );
        insert testUser;

        Map<String, String> args = new Map<String, String>{
                        'paramKey' => 'paramKey'
                };

        clcommon.Response response = new SMB_BusinessInfoAPI().invokeAction('', null, new Map<String, Object>{
                  'paramKey' => JSON.serialize(args)
        });
        Test.stopTest();
    }

    @isTest
    static void test_SMB_BusinessInfoAPI2()
    {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);
        Test.startTest();

        Profile profile = [Select Id from Profile where name = 'System Administrator'];
        User testUser = new User(
        ProfileId = profile.Id,
        Username = TestUtility.generateFakeName() + '@example.com',
        Alias = 'test',
        Email='testUser2392@test.com',
        EmailEncodingKey='UTF-8',
        Firstname='Bruce',
        Lastname='Wayne',
        LanguageLocaleKey='en_US',
        LocaleSidKey='en_US',
        TimeZoneSidKey='America/Chicago'
        );
        insert testUser;

        TestUtility.runSetupData();
         genesis__Applications__c appln = TestUtility.createApplication();

        Map<String, String> args = new Map<String, String>{
                        'applicationId' => appln.Id,
                        'paramKey' => appln.Id
                };

        clcommon.Response response = new SMB_BusinessInfoAPI().invokeAction('', null, new Map<String, Object>{
                  'paramKey' => JSON.serialize(args)
        });
        Test.stopTest();
    }
}