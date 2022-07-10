public class DataMerchNoteDB extends DBManager {

    public List<Data_Merch_Note__c> getDataMerchNotesByAccountIds(Set<Id> accountIds) {
        return [
            SELECT Id, Application__c, Account__c, Added_at__c, Added_by__c, Note_Category__c,
                Note_Text__c, FEIN__c, Legal_Name__c, Address__c, Street_1__c, Street_2__c, City__c,
                State__c
            FROM Data_Merch_Note__c
            WHERE Account__c IN :accountIds
            ORDER BY Account__c
        ];
    }

}