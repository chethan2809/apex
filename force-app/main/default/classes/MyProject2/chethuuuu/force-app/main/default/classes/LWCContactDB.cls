public with sharing class LWCContactDB {

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts() {
        return [
            SELECT Id, LastName, FirstName, Birthdate, Phone
            FROM Contact LIMIT 10
        ];
    }
}