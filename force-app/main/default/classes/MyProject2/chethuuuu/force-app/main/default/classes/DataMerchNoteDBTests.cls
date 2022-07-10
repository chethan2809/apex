@isTest
public class DataMerchNoteDBTests {

    private static DataMerchNoteDB dataMerchNoteDBInstance = new DataMerchNoteDB();

    @isTest
    private static void  getDataMerchNotesByAccountIds(){
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(accountId);

        Test.startTest();
            List<Data_Merch_Note__c> dataMerchNoteList = dataMerchNoteDBInstance.getDataMerchNotesByAccountIds(accountIds);
        Test.stopTest();

        System.assert(dataMerchNoteList != null);
        System.assert(dataMerchNoteList.isEmpty());
    }
}