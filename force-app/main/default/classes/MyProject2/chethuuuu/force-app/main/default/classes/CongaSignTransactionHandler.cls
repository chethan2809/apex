public class CongaSignTransactionHandler {

    private static ApplicationDB applicationDBInstance = new ApplicationDB();

    public void afterUpdate(Map<Id, APXT_CongaSign__Transaction__c> newCongaSignTransactionMap, Map<Id, APXT_CongaSign__Transaction__c> oldCongaSignTransactionMap) {
        Set<Id> applicationIds = new Set<Id>();
        Map<Id, Id> applicationIdToAttachmentId = new Map<Id, Id>();
        for(APXT_CongaSign__Transaction__c congaSignTransaction : newCongaSignTransactionMap.values()) {
            APXT_CongaSign__Transaction__c oldCongaSignTransaction = oldCongaSignTransactionMap.get(congaSignTransaction.Id);
            if(CongaSignTransactions.isStatusChanged(congaSignTransaction, oldCongaSignTransaction)
                && congaSignTransaction.Parent_a6t__c != null
            ) {

                if(congaSignTransaction.APXT_CongaSign__Status__c == CongaSignTransactions.STATUS_SENT) {
                    genesis__Applications__c application = new genesis__Applications__c(Id = congaSignTransaction.Parent_a6t__c);
                    application.genesis__Status__c = Applications.STATUS_DOCS_OUT;
                    applicationIdToAttachmentId.put(application.Id, congaSignTransaction.APXT_CongaSign__ContentDocumentId__c);
                    applicationDBInstance.addUpdate(application);
                } else if(congaSignTransaction.APXT_CongaSign__Status__c == CongaSignTransactions.STATUS_DECLINED) {
                    genesis__Applications__c application = new genesis__Applications__c(Id = congaSignTransaction.Parent_a6t__c);
                    Applications.setDenialReasons(application, 'Customer Not Interested');
                    applicationDBInstance.addUpdate(application);
                }
            }
        }
        if(!applicationIdToAttachmentId.isEmpty()) {
            CategoryAttachAssnManager.createDocumentCategoryAssociationByContenDocumentId(
                applicationIdToAttachmentId, GeneralConstants.DOCUMENT_TYPE_LOAN_AGREEMENT
            );
        }

        applicationDBInstance.executeUpdates();
    }
}