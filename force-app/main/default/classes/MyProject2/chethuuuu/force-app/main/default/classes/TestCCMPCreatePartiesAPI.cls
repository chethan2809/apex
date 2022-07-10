@isTest
private class TestCCMPCreatePartiesAPI {

    @isTest
    private static void createPartiesAPIContactListNotNull(){

        Account account = new Account();
        account.Name = 'Dummy Account';
        account.Type = GeneralConstants.PARTY_TYPE_BORROWER;
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(account.Type).getRecordTypeId();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{account};
        CCMPCreatePartiesAPI.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Contact contact = new Contact();
        contact.FirstName = 'first';
        contact.LastName = 'last';
        contact.Email = 'Testemailccbp@gmail.com';
        contact.AccountId = TestUtility.getFakeId(Account.getSObjectType());
        contact.loan__Contact_Type__c = Leads.GUARANTOR;
        contact.Id = TestUtility.getFakeId(Contact.getSObjectType());

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        ContactDBStubInstance.genericReturnObject = new List<Contact>{contact};
        CCMPCreatePartiesAPI.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, ContactDBStubInstance);

        User testUser = (User) JSON.deserialize(
            '{ "AccountId" : "accountId"}' , User.class
        );
        testUser.Email = 'no@email.com';
        testUser.ContactId = contact.Id;
        testUser.Id = TestUtility.getFakeId(User.getSObjectType());

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User>{testUser};
        CCMPCreatePartiesAPI.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        clcommon__Legal_Entity__c legalEntity = new clcommon__Legal_Entity__c();
        legalEntity.Name = GeneralConstants.LEGAL_TYPE_CORPORATION;
        legalEntity.Id = TestUtility.getFakeId(clcommon__Legal_Entity__c.getSObjectType());

        DBManagerTestsStub legalEntityDBStubInstance = new DBManagerTestsStub();
        legalEntityDBStubInstance.genericReturnObject = new List<clcommon__Legal_Entity__c>{legalEntity};
        CCMPCreatePartiesAPI.legalEntityDBInstance = (LegalEntityDB) Test.createStub(LegalEntityDB.class, legalEntityDBStubInstance);

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Origination_Fee_Amount__c" : "299", "Business_Type__c" : "Sole Proprietorship"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        application.Opportunity__c = TestUtility.getFakeId(Opportunity.getSObjectType());
        application.Industry_Rating__c = 'A+ Medical';
        application.SC4_Tier__c = 'TIER 1';
        application.Annual_Volume__c = 1413777;
        application.Type__c = 'New';
        application.Origination_Fee_Percentage__c = 1;
        application.genesis__Payment_Frequency__c = 'DAILY';
        application.Maximum_Funding_Amount__c = 275000;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        CCMPCreatePartiesAPI.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        clcommon__Party_Type__c partyTypeGuarantor = new clcommon__Party_Type__c();
        partyTypeGuarantor.Name = GeneralConstants.PARTY_TYPE_GUARANTOR;
        partyTypeGuarantor.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());

        clcommon__Party__c party = new clcommon__Party__c();
        party.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        party.genesis__Application__c = application.Id;
        party.clcommon__Contact__c = contact.Id;
        party.clcommon__Account__c = account.Id;
        party.clcommon__Type__c = partyTypeGuarantor.Id;

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = new List<clcommon__Party__c>{party};
        CCMPCreatePartiesAPI.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        Test.startTest();
            clcommon.Response response = new CCMPCreatePartiesAPI().invokeAction('', null, new Map<String, Object>{
                'partyType' =>GeneralConstants.PARTY_TYPE_GUARANTOR,
                'title' => 'Owner',
                'lastName' =>'LastName',
                'firstName'=>'Contact',
                'email'=>'Testcontactx@email.com',
                'birthDate' => '2010-01-01',
                'mobilePhone' => '998979',
                'socialSecurityNumber' => '23445',
                'coBorrowerBuilding' => '8776',
                'coBorrowerCity' => 'CA',
                'coBorrowerState' => 'CA',
                'coBorrowerPostalCode' => '1234',
                'coBorrowerCountry' => 'USA'
            });
        Test.stopTest();

        System.assert(response != null);
        System.assertEquals('SUCCESS', response.status);
    }

    @isTest
    private static void createPartiesAPIContactListEqualsToNull (){

        Account account = new Account();
        account.Name = 'Dummy Account';
        account.Type = GeneralConstants.PARTY_TYPE_BORROWER;
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(account.Type).getRecordTypeId();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{account};
        CCMPCreatePartiesAPI.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Contact contact = new Contact();
        contact.FirstName = 'first';
        contact.LastName = 'last';
        contact.Email = 'Testemailccbp@gmail.com';
        contact.AccountId = TestUtility.getFakeId(Account.getSObjectType());
        contact.loan__Contact_Type__c = Leads.GUARANTOR;
        contact.Id = TestUtility.getFakeId(Contact.getSObjectType());

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        CCMPCreatePartiesAPI.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, ContactDBStubInstance);

        User testUser = (User) JSON.deserialize(
            '{ "AccountId" : "accountId"}' , User.class
        );
        testUser.Email = 'no@email.com';
        testUser.ContactId = contact.Id;
        testUser.Id = TestUtility.getFakeId(User.getSObjectType());

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User>{testUser};
        CCMPCreatePartiesAPI.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        clcommon__Legal_Entity__c legalEntity = new clcommon__Legal_Entity__c();
        legalEntity.Name = GeneralConstants.LEGAL_TYPE_CORPORATION;
        legalEntity.Id = TestUtility.getFakeId(clcommon__Legal_Entity__c.getSObjectType());

        DBManagerTestsStub legalEntityDBStubInstance = new DBManagerTestsStub();
        legalEntityDBStubInstance.genericReturnObject = new List<clcommon__Legal_Entity__c>{legalEntity};
        CCMPCreatePartiesAPI.legalEntityDBInstance = (LegalEntityDB) Test.createStub(LegalEntityDB.class, legalEntityDBStubInstance);

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Origination_Fee_Amount__c" : "299", "Business_Type__c" : "Sole Proprietorship"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        application.Opportunity__c = TestUtility.getFakeId(Opportunity.getSObjectType());
        application.Industry_Rating__c = 'A+ Medical';
        application.SC4_Tier__c = 'TIER 1';
        application.Annual_Volume__c = 1413777;
        application.Type__c = 'New';
        application.Origination_Fee_Percentage__c = 1;
        application.genesis__Payment_Frequency__c = 'DAILY';
        application.Maximum_Funding_Amount__c = 275000;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        CCMPCreatePartiesAPI.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        clcommon__Party_Type__c partyTypeGuarantor = new clcommon__Party_Type__c();
        partyTypeGuarantor.Name = GeneralConstants.PARTY_TYPE_GUARANTOR;
        partyTypeGuarantor.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());

        clcommon__Party__c party = new clcommon__Party__c();
        party.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        party.genesis__Application__c = application.Id;
        party.clcommon__Contact__c = contact.Id;
        party.clcommon__Account__c = account.Id;
        party.clcommon__Type__c = partyTypeGuarantor.Id;

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = new List<clcommon__Party__c>{party};
        CCMPCreatePartiesAPI.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        Test.startTest();
            clcommon.Response response = new CCMPCreatePartiesAPI().invokeAction('', null, new Map<String, Object>{
                'partyType' =>GeneralConstants.PARTY_TYPE_GUARANTOR,
                'title' => 'Owner',
                'lastName' =>'LastName',
                'firstName'=>'Contact',
                'email'=>'Testcontactx@email.com',
                'birthDate' => '2010-01-01',
                'mobilePhone' => '998979',
                'socialSecurityNumber' => '23445',
                'coBorrowerBuilding' => '8776',
                'coBorrowerCity' => 'CA',
                'coBorrowerState' => 'CA',
                'coBorrowerPostalCode' => '1234',
                'coBorrowerCountry' => 'USA'
            });
        Test.stopTest();

        System.assert(response != null);
        System.assertEquals('ERROR', response.status);
    }
}