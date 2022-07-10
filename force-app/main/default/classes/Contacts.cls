public class Contacts {

    public static Contact createGuarantorContact(Lead leadRecord, Id legalEntityType,
        Account guarantorAccount
    ){
        Contact guarantorContact = new Contact();
        guarantorContact.Title__c = leadRecord.Title__c;
        guarantorContact.BirthDate = leadRecord.DOB__c;
        guarantorContact.genesis__SSN__c = leadRecord.SSN__c;
        guarantorContact.ints__Social_Security_Number__c = leadRecord.SSN__c;
        guarantorContact.email = leadRecord.Email;
        guarantorContact.MobilePhone = leadRecord.MobilePhone;
        guarantorContact.Phone = leadRecord.Phone;
        guarantorContact.AccountId = guarantorAccount.Id;
        guarantorContact.MailingBuildingNumber__c = leadRecord.PersonalBuildingNumber__c;
        guarantorContact.MailingStreet = leadRecord.Street__c;
        guarantorContact.MailingCity = leadRecord.City__c;
        guarantorContact.MailingState = leadRecord.State__c;
        guarantorContact.MailingCountry = leadRecord.Country__c;
        guarantorContact.MailingPostalCode = leadRecord.Postal_Code__c;
        guarantorContact.clcommon__Legal_Entity_type__c = legalEntityType;
        guarantorContact.Contact_Type__c = Leads.GUARANTOR;
        guarantorContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(guarantorContact.Contact_Type__c.toUpperCase()).getRecordTypeId();
        return guarantorContact;
    }

    public static Contact createBrokerContact(Lead leadRecord, Account brokerAccount)
    {
        Contact brokerContact = new Contact();
        brokerContact.Title__c = leadRecord.Title__c;
        brokerContact.BirthDate = leadRecord.DOB__c;
        brokerContact.genesis__SSN__c = leadRecord.SSN__c;
        brokerContact.ints__Social_Security_Number__c = leadRecord.SSN__c;
        brokerContact.email = leadRecord.Email;
        brokerContact.MobilePhone = leadRecord.MobilePhone;
        brokerContact.Phone = leadRecord.Phone;
        brokerContact.AccountId = brokerAccount.Id;
        brokerContact.MailingBuildingNumber__c = leadRecord.PersonalBuildingNumber__c;
        brokerContact.MailingStreet = leadRecord.Street__c;
        brokerContact.MailingCity = leadRecord.City__c;
        brokerContact.MailingState = leadRecord.State__c;
        brokerContact.MailingCountry = leadRecord.Country__c;
        brokerContact.MailingPostalCode = leadRecord.Postal_Code__c;
        brokerContact.Contact_Type__c = Leads.BROKER;
        brokerContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(brokerContact.Contact_Type__c.toUpperCase()).getRecordTypeId();
        return brokerContact;
    }

    public static void setContactFieldsOnBeforeInsert(Contact newContact)
    {
        if(newContact.ints__Social_Security_Number__c != null) {
            newContact.genesis__SSN__c = newContact.ints__Social_Security_Number__c;
        }
        if(newContact.genesis__SSN__c != null) {
            newContact.ints__Social_Security_Number__c = newContact.genesis__SSN__c;
        }
        newContact.clcommon__Current_Street__c = newContact.MailingStreet;
        newContact.clcommon__Current_City__c = newContact.MailingCity;
        newContact.clcommon__Current_State__c = newContact.MailingState;
        newContact.clcommon__Current_Zip_Code__c = newContact.MailingPostalCode;
        newContact.clcommon__Current_Country__c = newContact.MailingCountry;

        if(newContact.MailingState != null) {
            newContact.MailingState = GeneralHelper.convertStateNameToShortCode(newContact.MailingState);
        }
        if(newContact.Do_Not_Contact__c) {
            newContact.Do_Not_Sync_With_SFMC__c = true;
        } else if(newContact.Marketing_Opt_out__c) {
            newContact.Do_Not_Sync_With_SFMC__c = true;
        }
        if(newContact.Contact_Type__c != null) {
            newContact.loan__Contact_Type__c = newContact.Contact_Type__c;
        }
        if(newContact.loan__Contact_Type__c != null) {
            newContact.Contact_Type__c = newContact.loan__Contact_Type__c;
        }
        if(newContact.Contact_Type__c != null) {
            newContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(newContact.Contact_Type__c.toUpperCase()).getRecordTypeId();
        }
    }

    public static void setContactFieldsOnBeforeUpdate(Contact newContact, Contact oldContact)
    {
        if(newContact.genesis__SSN__c != oldContact.genesis__SSN__c) {
            newContact.ints__Social_Security_Number__c = newContact.genesis__SSN__c;
        }
        if(newContact.ints__Social_Security_Number__c != oldContact.ints__Social_Security_Number__c) {
            newContact.genesis__SSN__c = newContact.ints__Social_Security_Number__c;
        }
        newContact.clcommon__Current_Street__c = newContact.MailingStreet;
        newContact.clcommon__Current_City__c = newContact.MailingCity;
        newContact.clcommon__Current_State__c = newContact.MailingState;
        newContact.clcommon__Current_Zip_Code__c = newContact.MailingPostalCode;
        newContact.clcommon__Current_Country__c = newContact.MailingCountry;

        if(newContact.MailingState != null && newContact.MailingState != oldContact.MailingState) {
            newContact.MailingState = GeneralHelper.convertStateNameToShortCode(newContact.MailingState);
        }
        if(newContact.Do_Not_Contact__c != oldContact.Do_Not_Contact__c && newContact.Do_Not_Contact__c) {
            newContact.Do_Not_Sync_With_SFMC__c = true;
        } else if(newContact.Marketing_Opt_out__c != oldContact.Marketing_Opt_out__c && newContact.Marketing_Opt_out__c) {
            newContact.Do_Not_Sync_With_SFMC__c = true;
        }
        if(newContact.Contact_Type__c != oldContact.Contact_Type__c && newContact.Contact_Type__c != null) {
            newContact.loan__Contact_Type__c = newContact.Contact_Type__c;
        }
        if(newContact.loan__Contact_Type__c != oldContact.loan__Contact_Type__c &&  newContact.loan__Contact_Type__c != null) {
            newContact.Contact_Type__c = newContact.loan__Contact_Type__c;
        }
        if(newContact.Contact_Type__c != null) {
            newContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(newContact.Contact_Type__c.toUpperCase()).getRecordTypeId();
        }
    }
}