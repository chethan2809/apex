@isTest
public class TestPartyDocCategoryCheckAPI {
@isTest
    private static void TestCategory()
    {
            test.startTest();

            clcommon__Party_Type__c partyType =new clcommon__Party_Type__c(Name = CustomConstants.BORROWER);
            insert partyType;
            clcommon__Party_Type__c cosign =new clcommon__Party_Type__c(Name = CustomConstants.COSIGNER);
            insert cosign;

            clcommon__CL_Product__c clProduct = new clcommon__CL_Product__c(clcommon__Product_Name__c = 'Dummy Product');
            insert clProduct;

            clcommon__Reciprocal_Role__c recRole = new clcommon__Reciprocal_Role__c();
            recRole.Name = 'test role';
            recRole.clcommon__Inverse_Role__c = 'Team member';
            insert recRole;

            Account testAccount = TestUtility.createAccount();

            Contact testContact = TestUtility.createContact();

            TestUtility.runSetupData();
            genesis__Applications__c appln = TestUtility.createApplication();

        clcommon__Party__c cmcparty = new clcommon__Party__c(clcommon__Account__c=testAccount.Id,genesis__Application__c=appln.Id, clcommon__Contact__c=testContact.Id,clcommon__Type__c=cosign.Id
);
        insert cmcparty;
        clcommon.Response response = new PartyDocCategoryCheckAPI().invokeAction(' ', null, new Map<String, Object>{
        CustomConstants.APPLICATION_ID => appln.Id

             });
            test.stopTest();
    }

    @IsTest
    static void testCategoryExc() {

        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

        Test.StartTest();
        Profile profile = [Select Id from Profile where name = 'Read Only'];
        User readOnlyUser = new User(
            profileId = profile.Id,
            Username = TestUtility.generateFakeName() + '@example.com',
            Alias = 'testing',
            EmailEncodingKey='UTF-8',
            FirstName='Tom',
            LastName='Tim',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        readOnlyUser.Email = readOnlyUser.Username;
        insert readOnlyUser;

        System.runAs ( readOnlyUser ) {

            clcommon.Response response = new PartyDocCategoryCheckAPI().invokeAction(' ', null, new Map<String, Object>{

             });

            system.assertNotEquals('ERROR',response.Status);
        }
        Test.StopTest();
    }
}