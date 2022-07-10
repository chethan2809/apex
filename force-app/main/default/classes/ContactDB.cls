public class ContactDB extends DBManager {

    public List<Contact> getContactsByIds(Set<Id> contactIds) {
        return [
            SELECT Id, Name, AccountId, Last_Consumer_Credit_Pull__c, LastName, FirstName, genesis__SSN__c,
                MailingBuildingNumber__c, MailingAddress, Email, Birthdate, ints__Driver_License__c, Phone, Credit_Report_Message__c,
                loan__Contact_Type__c, Title__c, Is_Generic__c, MailingCity, MailingState, MailingStreet,
                MailingPostalCode, Last_Date_of_Inquiry__c, FICO_MKT__c, Reasons_for_Credit_Score__c
            FROM Contact
            WHERE Id IN :contactIds
        ];
    }

    public List<Contact> getContactMailingAddressAndMobilePhoneByContactIds(Set<Id> contactIds){
        return [
            SELECT Name, Email, MobilePhone, MailingBuildingNumber__c, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode,
                AccountId, Account.Name
            FROM Contact
            WHERE Id IN :contactIds
        ];
    }

    public List<Contact> getContactsByEmailId(String email){
        return [
            SELECT Id, Name
            FROM Contact
            WHERE Email = :email
        ];
    }

    public List<Contact> getBrokerAccountIdFROMContactByEmail(Set<String> email) {
        return [
            SELECT Id, AccountId, Name, Email
            FROM Contact
            WHERE Email IN :email
                AND Account.Type = :Leads.BROKER
        ];
    }

    public List<Contact> getExistingGuarantorContacts(Set<String> firstName, Set<String> lastName, Set<String> email) {
        return [
            SELECT Id, FirstName, LastName, Email, AccountId, Name
            FROM Contact
            WHERE  FirstName IN :firstName
                AND LastName IN :lastName
                AND Email IN :email
                AND loan__Contact_Type__c = :Leads.GUARANTOR
        ];
    }

    public List<Contact> getExistingContactByNameAndEmail(Set<String> firstName, Set<String> lastName, Set<String> email) {
        return [
            SELECT Id, AccountId, Name
            FROM Contact
            WHERE FirstName IN :firstName
            AND LastName IN : lastName
            AND Email IN : email
        ];
    }

    public List<Contact> getRelatedGuarantorContactsByAccId(Set <Id> accountIds) {
        return[
            SELECT Id, FirstName, LastName, AccountId, Account.Name, Name, Title__c, ints__Social_Security_Number__c,
                genesis__SSN__c, MailingBuildingNumber__c, MailingAddress, Email, Birthdate, Phone,
                MobilePhone, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode,
                clcommon__Legal_Entity_type__c, loan__Contact_Type__c, Title, LeadSource
            FROM Contact
            WHERE AccountId IN :accountIds
        ];
    }

    public List<Contact> getContactsByAccountId(Set <Id> accountIds) {
        return[
            SELECT Id, Name, AccountId
            FROM Contact
            WHERE AccountId IN :accountIds
        ];
    }
}