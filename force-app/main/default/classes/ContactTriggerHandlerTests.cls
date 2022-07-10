@isTest
private class ContactTriggerHandlerTests {

    private static ContactTriggerHandler contactTriggerHandler = new ContactTriggerHandler();

    @isTest
    private static void beforeInsert(){

        Contact contact = new Contact();
        contact.ints__Social_Security_Number__c = '134234235';
        contact.MailingStreet = '1700 W Blancke St';
        contact.MailingCity = 'Linden';
        contact.MailingState = 'New Jersey';
        contact.MailingPostalCode = '07036';
        contact.MailingCountry = 'USA';
        contact.LastName = 'Test Contact';
        contact.Do_Not_Contact__c = false;
        contact.Marketing_Opt_out__c = false;
        insert contact;

        List<Contact> contactList = new List<Contact>();
        contactList.add(contact);

        Test.startTest();
            contactTriggerHandler.beforeInsert(contactList);
        Test.stopTest();

        Contact contactRecord = [SELECT Id, clcommon__Current_Street__c,Do_Not_Contact__c,
            Contact_Type__c,Marketing_Opt_out__c,loan__Contact_Type__c
        FROM Contact WHERE Id =: contact.Id];
        System.assertEquals(contact.MailingStreet, contactRecord.clcommon__Current_Street__c);
    }

    @isTest
    private static void beforeUpdate(){
        Contact contactNewRecord = TestUtility.createContact();
        contactNewRecord.genesis__SSN__c = '134234235';
        contactNewRecord.MailingState = 'new York';
        contactNewRecord.Do_Not_Contact__c = false;
        contactNewRecord.Marketing_Opt_out__c = false;
        update contactNewRecord;

        Contact contactOldRecord = [SELECT Id, ints__Social_Security_Number__c,Contact_Type__c,
            Do_Not_Contact__c,Marketing_Opt_out__c,loan__Contact_Type__c
        FROM Contact WHERE Id =: contactNewRecord.Id];
        contactOldRecord.genesis__SSN__c = '234234234';
        contactOldRecord.MailingState = 'ohio';
        contactOldRecord.Do_Not_Contact__c = false;
        contactOldRecord.Marketing_Opt_out__c = false;
        update contactOldRecord;

        Map<Id, Contact> contactNewMap = new Map<Id, Contact>();
        contactNewMap.put(contactNewRecord.Id, contactNewRecord);

        Map<Id, Contact> contactOldMap = new Map<Id, Contact>();
        contactOldMap.put(contactOldRecord.Id, contactOldRecord);

        Test.startTest();
            contactTriggerHandler.beforeUpdate(contactNewMap, contactOldMap);
        Test.stopTest();

        Contact contactUpdate = [SELECT Id, ints__Social_Security_Number__c,Do_Not_Contact__c,
            Contact_Type__c,Marketing_Opt_out__c,loan__Contact_Type__c
        FROM Contact WHERE Id =: contactNewRecord.Id];
        System.assertEquals('234234234', contactUpdate.ints__Social_Security_Number__c);
    }
}