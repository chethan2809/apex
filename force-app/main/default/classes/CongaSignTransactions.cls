public class CongaSignTransactions {

    public static final String STATUS_COMPLETE = 'COMPLETE';
    public static final String STATUS_DECLINED = 'DECLINED';
    public static final String STATUS_SENT = 'SENT';
    public static final String SIGN_DECLINED_REASON = 'Contract Sign Declined By Customer';
    public static String CONGA_NOTIFICATION_MESSAGE_KEY = '{Message_Text}';
    public static String CONGA_NOTIFICATION_BROKER_NAME_KEY = '{Broker_Name}';
    public static String CONGA_NOTIFICATION_TYPE_KEY = '{Notification_Type}';
    public static String CONGA_NOTIFICATION_MERCHANT_EMAIL_KEY = '{Merchant_Email_Address}';
    public static String CONGA_NOTIFICATION_SUBJECT_KEY = '{Conga_Signing_Document_Subject}';
    public static String CONGA_NOTIFICATION_SUBJECT_SENT = 'Conga Documents Sent for Signing';
    public static String CONGA_NOTIFICATION_SUBJECT_COMPLETE = 'Conga Documents Signing Complete';
    public static String CONGA_NOTIFICATION_SUBJECT_DECLINED = 'Conga Documents Signing Declined';
    public static String CONGA_NOTIFICATION_TITLE_SENT = 'Documents Sent';
    public static String CONGA_NOTIFICATION_TITLE_COMPLETE = 'Signing Complete!';
    public static String CONGA_NOTIFICATION_TITLE_DECLINED = 'Signing Declined!';
    public static String CONGA_SENDER_NOTIFICATION_TEMPLATE = 'Conga_Sender_Notification';
    public static String CONGA_NOTIFICATION_FAILED_MSG = 'Conga Notification Failed';
    public static String CONGA_NOTIFICATION_SENT_MSG = 'The documents have been sent out for signature to';
    public static String CONGA_NOTIFICATION_COMPLETE_MSG = 'The document signing is completed by';
    public static String CONGA_NOTIFICATION_DECLINED_MSG = 'The document signing is declined by';

    public static Boolean isStatusChanged(APXT_CongaSign__Transaction__c newCongaSignTransaction, APXT_CongaSign__Transaction__c oldCongaSignTransaction) {
        return (newCongaSignTransaction.APXT_CongaSign__Status__c != oldCongaSignTransaction.APXT_CongaSign__Status__c);
    }

    public static void sendChatterNotifications(APXT_CongaSign__Transaction__c congaSignTransaction) {
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setBody('Documents are Released to Merchant');
        notification.setTitle('Conga Sign Document Released');
        notification.setSenderId(congaSignTransaction.Parent_a6t__r.Opportunity__r.OwnerId);
        notification.setNotificationTypeId(GeneralHelper.customNotificationTypeByName.get('Conga_Notifications'));
        notification.setTargetId(congaSignTransaction.Parent_a6t__r.Opportunity__c);
        if(congaSignTransaction.Parent_a6t__r.Sales_Rep__c != null){
            notification.send(new Set<String> { congaSignTransaction.Parent_a6t__r.Sales_Rep__c });
        }
    }
}