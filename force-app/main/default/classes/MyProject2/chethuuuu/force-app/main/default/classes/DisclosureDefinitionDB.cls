public class DisclosureDefinitionDB extends DBManager {
    public List<clcommon__Disclosure_Definition__c>  getDisclosureDefinition(){
        return [
            SELECT Id, Name, clcommon__Description__c FROM clcommon__Disclosure_Definition__c
        ];
    }
}