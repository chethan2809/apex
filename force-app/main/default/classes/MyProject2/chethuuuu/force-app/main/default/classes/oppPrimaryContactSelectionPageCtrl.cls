public class oppPrimaryContactSelectionPageCtrl {
    @TestVisible
    private static AccountContactRelationDB AccountContactRelationDBInstance = new AccountContactRelationDB();
    @TestVisible
    private static ContactDB ContactDBInstance = new ContactDB();
    @TestVisible
    private static OpportunityDB opportunityDBInstance = new OpportunityDB();
    @TestVisible
    private static AccountDB AccountDBInstance = new AccountDB();
    @TestVisible
    private static ErrorLogDB ErrorLogDBInstance = new ErrorLogDB();

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactsByOpportunityIds(Id opportunityId) {

        List<Opportunity> opportunityRecords = opportunityDBInstance.getOpportunityByIds(new Set<Id> {opportunityId});

        List<AccountContactRelation> accountContactRelationList = new List<AccountContactRelation>();

        if(!opportunityRecords.isEmpty()){
           accountContactRelationList = AccountContactRelationDBInstance.getAccountContactRelationByAccountIds(new Set<Id> {opportunityRecords[0].AccountId});
        }
        else{
            throw new oppPrimaryContactSelectionPageCtrlException('There was no opportunity record found with Id');
        }

        Set<Id> contactIds = new Set<Id>();

        for(AccountContactRelation accountContactRelationRecords : accountContactRelationList){
            contactIds.add(accountContactRelationRecords.contactId);
        }

        List<Contact> contactList = ContactDBInstance.getContactsByIds(contactIds);

        if(contactList.isEmpty()) {
            throw new oppPrimaryContactSelectionPageCtrlException('There was no Contact found with Id ' + contactIds);
        }
        return contactList;
    }

    private class oppPrimaryContactSelectionPageCtrlException extends Exception {}
}