public class CongaSignDocumentTriggerHandler {
    @TestVisible
    private static ApplicationDB applicationDBInstance = new ApplicationDB();
    @TestVisible
    private static CongaSignDocumentDB congaSignDocumentDBInstance= new CongaSignDocumentDB();

    public void afterInsert(List<APXT_CongaSign__Document__c> congaSignDocumentList ) {
        Set<Id> finalCongaSignDocumentIds = new Set<Id>();
        for(APXT_CongaSign__Document__c congaSignDocument :congaSignDocumentList){
            if(congaSignDocument.APXT_CongaSign__Type__c == CongaSignDocuments.STATUS_FINAL){
              finalCongaSignDocumentIds.add(congaSignDocument.Id);
            }
        }

        if(!finalCongaSignDocumentIds.isEmpty()) {
            CategoryAttachAssnManager.createDocumentCategoryAssociationForSignedDocuments(
                congaSignDocumentDBInstance.getFinalSignDocumentsIds(finalCongaSignDocumentIds)
            );
        }
    }

    private class CongaSignDocumentTriggerHandlerException extends Exception {}

}