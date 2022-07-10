public class CongaQueryDB extends DBManager {

    public List<APXTConga4__Conga_Merge_Query__c> getCongaQueriesByMatchingName(String name) {
        name = '%' + name + '%';
        return [SELECT Id FROM APXTConga4__Conga_Merge_Query__c WHERE APXTConga4__Name__c LIKE :name];
    }
}