@isTest(isParallel=true)
private class ContactDBTests {

    private static ContactDB contactDBInstance = new ContactDB();

    @isTest
    private static void getContactsByIds() {
        Id contactId = TestUtility.getFakeId(Contact.getSObjectType());
        Set<Id> contactIds = new Set<Id>();
        contactIds.add(contactId);

        Test.startTest();
            List<Contact> contactList = contactDBInstance.getContactsByIds(contactIds);
        Test.stopTest();

        System.assert(contactList != null);
        System.assert(contactList.isEmpty());
    }

    @isTest
    private static void getContactMailingAddressAndMobilePhoneByContactIds() {
        Id contactId = TestUtility.getFakeId(Contact.getSObjectType());
        Set<Id> contactIds = new Set<Id>();
        contactIds.add(contactId);

        Test.startTest();
            List<Contact> contactList = contactDBInstance.getContactMailingAddressAndMobilePhoneByContactIds(contactIds);
        Test.stopTest();

        System.assert(contactList != null);
        System.assert(contactList.isEmpty());
    }

    @isTest
    private static void getContactsByEmailId() {

        Test.startTest();
            List<Contact> contactList = contactDBInstance.getContactsByEmailId('test@gmail.com');
        Test.stopTest();

        System.assert(contactList != null);
        System.assert(contactList.isEmpty());
    }

    @isTest
    private static void getBrokerAccountIdFROMContactByEmail() {

        Test.startTest();
            List<Contact> contactList = contactDBInstance.getBrokerAccountIdFROMContactByEmail(new Set<String>{'test@gmail.com'});
        Test.stopTest();

        System.assert(contactList != null);
        System.assert(contactList.isEmpty());
    }

    @isTest
    private static void getExistingGuarantorContacts() {

        Test.startTest();
            List<Contact> contactList = contactDBInstance.getExistingGuarantorContacts(
                new Set<String>{'Test FName'}, new Set<String>{'Test LName'}, new Set<String>{'test@gmail.com'}
            );
        Test.stopTest();

        System.assert(contactList != null);
        System.assert(contactList.isEmpty());
    }

    @isTest
    private static void getExistingContactByNameAndEmail() {

        Test.startTest();
            List<Contact> contactList = contactDBInstance.getExistingContactByNameAndEmail(
                new Set<String>{'Test FName'}, new Set<String>{'Test LName'}, new Set<String>{'test@gmail.com'}
            );
        Test.stopTest();

        System.assert(contactList != null);
        System.assert(contactList.isEmpty());
    }

    @isTest
    private static void getRelatedGuarantorContactsByAccId() {
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(accountId);

        Test.startTest();
            List<Contact> contactList = contactDBInstance.getRelatedGuarantorContactsByAccId(accountIds);
        Test.stopTest();

        System.assert(contactList != null);
        System.assert(contactList.isEmpty());
    }

    @isTest
    private static void getContactsByAccountId() {
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(accountId);

        Test.startTest();
            List<Contact> contactList = contactDBInstance.getContactsByAccountId(accountIds);
        Test.stopTest();

        System.assert(contactList != null);
        System.assert(contactList.isEmpty());
    }
}