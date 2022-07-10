public class AccountContactRelationDB extends DBManager
{
    public List<AccountContactRelation> getAccountContactRelationByAccountIds(Set<Id> accountIds) {
        return [
            SELECT Id, AccountId, ContactId, IsActive, IsDirect, LastModifiedById, LastModifiedDate, Contact.Name,
                Contact.loan__Contact_Type__c, Contact.Email, Contact.Phone, Contact.MobilePhone, Contact.Title__c,
                Contact.Alternate_Phone__c, Contact.Birthdate, Contact.ints__Social_Security_Number__c, Contact.MailingStreet,
                Contact.MailingState, Contact.MailingCity, Contact.MailingCountry,
                Contact.MailingPostalCode, Contact.Alternate_Email__c, Contact.Do_Not_Contact__c
            FROM AccountContactRelation
            WHERE AccountId IN :accountIds
                AND IsActive = true
                AND IsDirect = false
        ];
    }

    public List<AccountContactRelation> getAllAccountContactRelationByAccountIds(Set<Id> accountIds) {
        return [
            SELECT AccountId, ContactId, Id, IsActive, IsDirect, LastModifiedById, LastModifiedDate
            FROM AccountContactRelation
            WHERE AccountId IN :accountIds
                AND IsActive = true
        ];
    }

    public List<AccountContactRelation> getAccountAttorneyContactDirectRelationByAccountIds(Set<Id> accountIds) {
        return [
            SELECT AccountId, ContactId, Id, IsActive, IsDirect, LastModifiedById, LastModifiedDate
            FROM AccountContactRelation
            WHERE AccountId IN :accountIds
                AND Account.Type = :Accounts.BORROWER
                AND IsActive = true
                AND Contact.Contact_Type__c = :CollectionCaseConstants.CONTACT_TYPE_ATTORNEY
        ];
    }
}