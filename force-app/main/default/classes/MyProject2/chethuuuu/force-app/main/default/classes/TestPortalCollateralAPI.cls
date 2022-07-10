@isTest
private with sharing class TestPortalCollateralAPI {

    @isTest
    static void testPortalCollateral() {

        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

        Test.startTest();
        Profile profile = [Select Id from Profile where name = 'System Administrator'];
        User testUser = new User(
            ProfileId = profile.Id,
            Username = TestUtility.generateFakeName() + '@example.com',
            Alias = 'test',
            Email=System.now().millisecond() + 'test1@test.com',
            EmailEncodingKey='UTF-8',
            FirstName='Bruce',
            LastName='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        insert testUser;

        System.runAs ( testUser ) {
            clcommon__Party_Type__c partyType =new clcommon__Party_Type__c(Name = CustomConstants.BORROWER);
            insert partyType;

            clcommon__CL_Product__c clProduct = new clcommon__CL_Product__c(clcommon__Product_Name__c = 'Dummy Product');
            insert clProduct;

            Account testAccount = TestUtility.createAccount();

            Contact testContact = TestUtility.createContact();

            TestUtility.runSetupData();
            genesis__Applications__c appln = TestUtility.createApplication();

            clcommon__Party__c party = new clcommon__Party__c();
            party.clcommon__Account__c = testAccount.Id;
            party.genesis__Application__c = appln.Id;
            party.clcommon__Type__c = partyType.Id;
            insert party;

            clcommon__Collateral__c Collateral = new clcommon__Collateral__c();
            Collateral.genesis__Application__c = appln.Id;
            Collateral.clcommon__Collateral_Name__c = 'test collateral';
            insert Collateral;

            clcommon__Collateral__c Collaterals = new clcommon__Collateral__c();
            Collaterals.genesis__Application__c = appln.Id;
            Collaterals.clcommon__Collateral_Name__c = 'test collaterals';

            clcommon__Collateral_Location__c location = new clcommon__Collateral_Location__c();
            location.clcommon__Collateral__c = Collateral.Id;
            location.clcommon__City__c = 'Bengaluru';
            location.clcommon__Country__c = 'India';
            location.clcommon__State_Province__c = 'Karnataka';
            location.clcommon__Street_Address__c = '4th Cross';
            location.clcommon__Zip_Code__c = '560001';
            insert location;

            clcommon__Collateral_Owner__c colOwner = new clcommon__Collateral_Owner__c ();
            colOwner.clcommon__Account__c = testAccount.Id;
            colOwner.clcommon__Collateral__c = Collateral.Id;
            insert colOwner;

            clcommon.Response response = new PortalCollateralAPI().invokeAction('', null, new Map<String, Object>{
                'accountId' => testAccount.Id,
                'contactId' => testContact.Id,
                'ActionType'=> 'AddCollateral',
                'applicationId' => appln.Id,
                'portalStage' => appln.Portal_Stage__c,
                'portalSubstage' => appln.Portal_Sub_Stage__c,
                'applicationCollateralDetails' => JSON.serialize(Collaterals),
                'collateralLocation' => JSON.serialize(location)
            });

             clcommon.Response response2 = new PortalCollateralAPI().invokeAction('', null, new Map<String, Object>{
                'collateralId' => Collateral.Id,
                'CollateralOwnershipDetails' => JSON.serialize(colOwner),
                'ActionType'=> 'AddOwner',
                'applicationId' => appln.Id,
                'applicationCollateralDetails' => JSON.serialize(Collateral)
            });

            Test.stopTest();

            system.assertEquals(response.Status,'SUCCESS');
        }
    }

    @isTest
    static void testPortalCollateralException() {
        Test.startTest();
            clcommon.Response response = new PortalCollateralAPI().invokeAction('test', null, new Map<String, Object>{
        });
        Test.stopTest();
   }
}