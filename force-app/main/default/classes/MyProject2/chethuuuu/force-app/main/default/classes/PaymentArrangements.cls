public class PaymentArrangements {

    public static Payment_Arrangements__c setPAFieldsfromCongaSignTransaction(
        APXT_CongaSign__Transaction__c congaSignTransaction
    ) {
        Payment_Arrangements__c paymentArrangement = new Payment_Arrangements__c();
        paymentArrangement.Id = congaSignTransaction.Parent_aFw__c;
        paymentArrangement.Conga_Sign_Status__c = congaSignTransaction.APXT_CongaSign__Status__c;
        return paymentArrangement;
    }
}