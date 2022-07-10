public class AccountContactRelationCtrl {

    @TestVisible
    private static AccountContactRelationDB AccountContactRelationDBInstance = new AccountContactRelationDB();
    @TestVisible
    private static ContactDB ContactDBInstance = new ContactDB();

    @AuraEnabled(cacheable=true)
    public static List<Contact> getAccountContactRelationByAccountId(Id opportunityId) {

        /* String [] oppAccessFields = new String[] {'Primary_Contact__c'};
        Map<String,Schema.SObjectField> fieldSchemaMap = DescribeHelper.getSObjectResult.fields.getMap();

        for (String fieldToCheck : oppAccessFields) {
            if (!fieldSchemaMap.get(fieldToCheck).getDescribe().isAccessible()) {
                throw new System.NoAccessException();

                 return null;
            }
        } */
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE Id = : opportunityId];

        List<AccountContactRelation> AccountContactRelationList = AccountContactRelationDBInstance.getAccountContactRelationByAccountIds(new Set<Id> {opp.AccountId});
        System.debug('Check3' + AccountContactRelationList);
        System.debug('Check4' + AccountContactRelationList.size());

		Set<Id> contactIds = new Set<Id>();

       for(AccountContactRelation accountContactRelationRecords : AccountContactRelationList){
            contactIds.add(accountContactRelationRecords.contactId);
        }
        System.debug('Check5' + contactIds);
        System.debug('Check6' + contactIds.size());

		List<Contact> contactList = ContactDBInstance.getContactsByIds(contactIds);

        if(contactList.isEmpty()) {
            throw new AccountContactRelationCtrlException('There was no account found with Id ' + contactIds);
        }

        System.debug('Check1' + contactList);
        System.debug('Check2' + contactList.size());
        return contactList;
        }

    private class AccountContactRelationCtrlException extends Exception {}
    }