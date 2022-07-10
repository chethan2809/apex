public class DocumentDefinitionDB extends DBManager {

    public List<clcommon__Document_Definition__c> getAllDocumentDefinitions() {
        return [SELECT Id, Name, Document_Category__c, clcommon__Show_In_Portal__c FROM clcommon__Document_Definition__c WHERE clcommon__Active__c = true];
    }
}