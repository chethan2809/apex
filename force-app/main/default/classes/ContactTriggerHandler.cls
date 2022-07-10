public class ContactTriggerHandler {

    @TestVisible
    private static PartyDB partyDBInstance = new PartyDB();
    public void beforeInsert(List<Contact> newContactList)
    {
        for (Contact newContact : newContactList) {
            Contacts.setContactFieldsOnBeforeInsert(newContact);
        }
    }

    public void beforeUpdate(Map<Id, Contact> newContactMap, Map<Id, Contact> oldContactMap)
    {
        for (Contact newContact : newContactMap.values()) {
            Contact oldContact = oldContactMap.get(newContact.Id);
            Contacts.setContactFieldsOnBeforeUpdate(newContact, oldContact);
        }
    }
}