public class CongaSignTransactionTriggerHandler {

    @TestVisible
    private static congaSignTransactionsDB congaSignTransactionsDBInstance = new congaSignTransactionsDB();

    public void afterInsert(Map<Id, APXT_CongaSign__Transaction__c> newCongaSignTransactionMap) {
        Set<Id> congaSignTxnIdsForChatter = new Set<Id>();
        Set<Id> applicationIds = new Set<Id>();
        for(APXT_CongaSign__Transaction__c congaSignTransaction : newCongaSignTransactionMap.values()){
            if(congaSignTransaction.Parent_a6t__c != null
               && congaSignTransaction.APXT_CongaSign__Status__c == CongaSignTransactions.STATUS_SENT
            ) {
                congaSignTxnIdsForChatter.add(congaSignTransaction.Id);
                applicationIds.add(congaSignTransaction.Parent_a6t__c);
            }
        }

        if(!congaSignTxnIdsForChatter.isEmpty()){
            CongaSignTransactionManager.sendCongaSignChatterNotifications(congaSignTxnIdsForChatter);
        }

        if(!applicationIds.isEmpty()){
            CongaSignTransactionManager.updateApplicationStatusOnDocsSent(applicationIds);
        }
    }

    public void afterUpdate(Map<Id, APXT_CongaSign__Transaction__c> newCongaSignTransactionMap, Map<Id, APXT_CongaSign__Transaction__c> oldCongaSignTransactionMap) {
        Set<Id> congaSignTransactionIds = new Set<Id>();
        Set<Id> congaSignTxnIdsForChatter = new Set<Id>();
        Set<Id> applicationIds = new Set<Id>();
        Map<Id,String> congaSignTransactionIdsMap = new Map<Id,String>();
        for(APXT_CongaSign__Transaction__c congaSignTransaction : newCongaSignTransactionMap.values()) {
            APXT_CongaSign__Transaction__c oldCongaSignTransaction = oldCongaSignTransactionMap.get(congaSignTransaction.Id);
            if(CongaSignTransactions.isStatusChanged(congaSignTransaction, oldCongaSignTransaction)
               && congaSignTransaction.Parent_a6t__c != null
            ) {
                if(congaSignTransaction.APXT_CongaSign__Status__c == CongaSignTransactions.STATUS_SENT) {
                    congaSignTxnIdsForChatter.add(congaSignTransaction.Id);
                    applicationIds.add(congaSignTransaction.Parent_a6t__c);
                }

                if(congaSignTransaction.APXT_CongaSign__Status__c == CongaSignTransactions.STATUS_SENT ||
                    congaSignTransaction.APXT_CongaSign__Status__c == CongaSignTransactions.STATUS_COMPLETE ||
                    congaSignTransaction.APXT_CongaSign__Status__c == CongaSignTransactions.STATUS_DECLINED)
                {
                    congaSignTransactionIds.add(congaSignTransaction.Id);
                    congaSignTransactionIdsMap.put(congaSignTransaction.Id, congaSignTransaction.APXT_CongaSign__Status__c);
                }
            }
        }

        if(!congaSignTransactionIds.isEmpty()){
            EmailNotificationHelper.sendCongaSenderNotificationToBroker(congaSignTransactionIds, congaSignTransactionIdsMap);
        }

        if(!congaSignTxnIdsForChatter.isEmpty()){
            CongaSignTransactionManager.sendCongaSignChatterNotifications(congaSignTxnIdsForChatter);
        }

        if(!applicationIds.isEmpty()){
            CongaSignTransactionManager.updateApplicationStatusOnDocsSent(applicationIds);
        }
    }
}