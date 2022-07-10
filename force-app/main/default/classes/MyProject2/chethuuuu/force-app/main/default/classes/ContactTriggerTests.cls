@isTest
private class ContactTriggerTests {

    private static ContactDB contactDBInstance = new ContactDB();

    @isTest
    private static void contactTriggerTest(){
        Contact contact = TestUtility.createContact();
        contact.LastName = 'Dummy Contact';
        contact.Email = 'test@gmail.com';
        contact.Salutation = 'Mr.';

        ContactDBInstance.addUpdate(contact);
        ContactDBInstance.executeUpdates();

        list<Contact> contactList = [
            SELECT Id, Name, Email
            FROM Contact
        ];

        System.assert(contact.Id != null);
        System.assertEquals(1, contactList.size());
        System.assertEquals(contact.Email, contactList[0].Email);
    }
}