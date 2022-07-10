@isTest
private class ContactsTests {

    @isTest
    private static void createGuarantorContact() {
        Lead leadRecord = new Lead();
        leadRecord.Title__c = 'Owner';
        leadRecord.Id = TestUtility.getFakeId(Lead.getSObjectType());

        Account guarantorAccount = TestUtility.createAccount();

        clcommon__Legal_Entity__c legalEntity = new clcommon__Legal_Entity__c();
        legalEntity.Name = GeneralConstants.LEGAL_TYPE_CORPORATION;
        legalEntity.clcommon__Legal_Entity_Type__c = 'Corporation';
        legalEntity.Id = TestUtility.getFakeId(clcommon__Legal_Entity__c.getSObjectType());

        Test.startTest();
            Contact guarantorContact = Contacts.createGuarantorContact(leadRecord, legalEntity.Id, guarantorAccount);
        Test.stopTest();

        system.assert(guarantorContact != Null);
        system.assertEquals(leadRecord.Title__c, guarantorContact.Title__c);
        system.assertEquals(legalEntity.Id, guarantorContact.clcommon__Legal_Entity_Type__c);
        system.assertEquals(guarantorAccount.Id, guarantorContact.AccountId);
    }

    @isTest
    private static void createBrokerContact() { 
        Lead leadRecord = new Lead();
        leadRecord.Title__c = 'Owner';
        leadRecord.Id = TestUtility.getFakeId(Lead.getSObjectType());

        Account brokerAccount = TestUtility.createAccount();

        Test.startTest();
            Contact brokerContact = Contacts.createBrokerContact(leadRecord, brokerAccount);
        Test.stopTest();

        system.assert(brokerContact != Null);
        system.assertEquals(leadRecord.Title__c, brokerContact.Title__c);
        system.assertEquals(brokerAccount.Id, brokerContact.AccountId);
    }

    @isTest
    private static void setContactFieldsOnBeforeInsertTest() {

        Contact newContact = new Contact();
        newContact.MailingState = 'New York';

        Test.startTest();
            Contacts.setContactFieldsOnBeforeInsert(newContact);
        Test.stopTest();

        system.assert(newContact != null);
        system.assertEquals('NY', newContact.MailingState);
    }

    @isTest
    private static void setContactFieldsOnBeforeUpdateTest() {

        Contact newContact = new Contact();
        newContact.MailingState = 'New York';

        Contact oldContact = new Contact();
        newContact.MailingState = 'Ohio';

        Test.startTest();
            Contacts.setContactFieldsOnBeforeUpdate(newContact, oldContact);
        Test.stopTest();

        system.assert(newContact != null);
        system.assertEquals('OH', newContact.MailingState);
    }
}