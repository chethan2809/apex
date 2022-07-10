public class CongaSignTransactionsDB extends DBManager {
    public List<APXT_CongaSign__Transaction__c> getCongaSignTransactionsByIds(Set<Id> congaSignTransactionIds){
        return [
            SELECT Id, Name, APXT_CongaSign__Status__c, Parent_a6t__r.Name, Parent_a6t__r.Primary_Guarantor__r.Email,
                Parent_a6t__r.Owner.Name, Parent_a6t__r.Owner.Email, Parent_a6t__r.Opportunity__c, Parent_a6t__r.Opportunity__r.OwnerId,
                Parent_a6t__r.Sales_Rep__c
            FROM APXT_CongaSign__Transaction__c
            WHERE Id IN :congaSignTransactionIds
        ];
    }
}