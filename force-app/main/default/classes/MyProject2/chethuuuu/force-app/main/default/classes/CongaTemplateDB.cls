public class CongaTemplateDB extends DBManager {

    public List<APXTConga4__Conga_Template__c> getCongaTemplatesByGroupNames(Set<String> groupNames) {
        return  [
            SELECT Id, APXTConga4__Template_Group__c
            FROM APXTConga4__Conga_Template__c
            WHERE APXTConga4__Template_Group__c IN :groupNames
        ];
    }
}