public class PaymentArrangementsManager {

    @TestVisible
    private static PaymentArrangementsDB paymentArrangementsDBInstance = new PaymentArrangementsDB();
    @TestVisible
    private static AccountDB accountDBInstance = new AccountDB();
    @TestVisible
    private static CollectionCaseDB collectionCaseDBInstance = new CollectionCaseDB();
    @TestVisible
    private static EmailDB emailDBInstance = new EmailDB();
    @TestVisible
    private static AutomatedPaymentSetupDB automatedPaymentSetupDBInstance = new AutomatedPaymentSetupDB();

    @AuraEnabled
    public static String createAPSRecord(Map<String, Object> apsObject) {
        loan__Automated_Payment_Setup__c aps = (loan__Automated_Payment_Setup__c) JSON.deserialize(JSON.serialize(apsObject) , loan__Automated_Payment_Setup__c.class);
        try {
            insert aps;
        } catch (Exception ex) {
            return 'aps insert exception : ' + ex.getMessage() + ' - ' + ex;
        } return aps.Id;
    }

    @AuraEnabled
    public static String updateAPSRecord(Map<String, Object> apsObject) {
        loan__Automated_Payment_Setup__c aps = (loan__Automated_Payment_Setup__c) JSON.deserialize(JSON.serialize(apsObject) , loan__Automated_Payment_Setup__c.class);
        try {
            update aps;
        } catch (Exception ex) {
            return 'aps update exception : ' + ex.getMessage() + ' - ' + ex;
        } return aps.Id;
    }

    @AuraEnabled
    public static String createChargeRecord(Map<String, Object> chargeObject) {
        loan__Charge__c charge = (loan__Charge__c) JSON.deserialize(JSON.serialize(chargeObject) , loan__Charge__c.class);
        try {
            insert charge;
        } catch (Exception ex) {
            return 'Charge insert exception : ' + ex.getMessage() + ' - ' + ex;
        } return charge.Id;
    }

    @AuraEnabled
    public static string updatePaymentArrangement(Id paymentArrangementId, Id apsId){
        Payment_Arrangements__c paymentArrangement = new Payment_Arrangements__c(Id = paymentArrangementId);
        paymentArrangement.Automated_Payment_Setup__c = apsId;
        try {
            paymentArrangementsDBInstance.addUpdate(paymentArrangement).executeUpdates();
            return 'Success';
        } catch (Exception e) { return e.getMessage(); }
    }

    @AuraEnabled
    public static string updateActivePaymentArrangementOnAccount(Id accountId, String activePaymentArrangementType, Boolean activePaymentArrangement){
        Account account = new Account(Id = accountId);
        account.Active_Payment_Arrangement_Type__c = activePaymentArrangementType;
        account.Active_Payment_Arrangement__c = activePaymentArrangement;
        try {
            accountDBInstance.addUpdate(account).executeUpdates();
            return 'Success';
        } catch (Exception e) { return e.getMessage(); }
    }

    @AuraEnabled
    public static string updateCollectionCaseStatusAndSubStatus(Id collectionCaseId, String collectionCaseStatus, String collectionCaseSubStatus){
        Collection_Case__c collectionCase = new Collection_Case__c(Id = collectionCaseId);
        String returnString = '';
        if(collectionCaseStatus != null){
            collectionCase.Collections_status__c = collectionCaseStatus;
        }
        if(collectionCaseSubStatus != null){
            collectionCase.Collections_sub_status__c = collectionCaseSubStatus;
        }
        if(collectionCaseStatus != null || collectionCaseSubStatus != null){
            try {
                collectionCaseDBInstance.addUpdate(collectionCase).executeUpdates();
                returnString = 'Success';
            } catch (Exception e) {
               returnString = e.getMessage();
            }
        } return returnString;
    }

    public static void sendEmailPaymentArrangement(List<String> emailAddress) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        String emailSubject = 'Notification';
        String emailBody = '';

        Messaging.SingleEmailMessage email = Emails.getEmailMessageSetup(
            emailAddress, null, CustomMetaDataHelper.defaultGeneralSetting.From_Email__c, emailSubject, emailBody, false, null, null
        );
        emailList.add(email);
        if(!emailAddress.isEmpty()) {
            emailDBInstance.sendBulkEmail(emailList);
        }
    }

    @AuraEnabled
    public static Integer calculatePaymentOccurrence(Decimal transactionAmount, String frequency, Date startDate, Date endDate, Date debitDate){
        Decimal totalPaymentAmount = 0.0;
        Integer numberOfOccurrence = 0;
        Date initialDate = Date.newInstance(0001, 1, 1);
        try {
            if(startDate != debitDate){
                startDate = debitDate;
            }
            Integer remainder = Math.mod(initialDate.daysBetween(startDate),7);
            if(remainder == 0){
                startDate = startDate.addDays(1);
            }
            if(remainder == 1){
                startDate = startDate.addDays(2);
            }
            remainder = -1;
            if(frequency == CollectionCaseConstants.FREQUENCY_DAILY){
                for(Date loopDate = startDate; loopDate <= endDate; loopDate = loopDate.addDays(1)){
                    remainder = Math.mod(initialDate.daysBetween(loopDate), 7);
                    if(loopDate <= endDate && remainder != 0 && remainder != 1){
                        numberOfOccurrence += 1;
                    }
                }
                totalPaymentAmount = transactionAmount * numberOfOccurrence;
                System.debug('totalPayment:'+totalPaymentAmount);
            }
            else if(frequency == CollectionCaseConstants.FREQUENCY_WEEKLY){
                for(Date loopDate = startDate; loopDate <= endDate; loopDate = loopDate.addDays(7)){
                    if(loopDate <= endDate){
                        numberOfOccurrence += 1;
                    }
                }
                totalPaymentAmount = transactionAmount * numberOfOccurrence;
                System.debug('totalPayment:'+totalPaymentAmount);
            }
            else if(frequency == CollectionCaseConstants.FREQUENCY_BI_WEEKLY){
                for(Date loopDate = startDate; loopDate <= endDate; loopDate = loopDate.addDays(15)){
                    if(loopDate <= endDate){
                        numberOfOccurrence += 1;
                    }
                }
                totalPaymentAmount = transactionAmount * numberOfOccurrence;
                System.debug('totalPayment:'+totalPaymentAmount);
            }
            else if(frequency == CollectionCaseConstants.FREQUENCY_MONTHLY){
                for(Date loopDate = startDate; loopDate <= endDate; loopDate = loopDate.addDays(30)){
                    if(loopDate <= endDate){
                        numberOfOccurrence += 1;
                    }
                }
                totalPaymentAmount = transactionAmount * numberOfOccurrence;
                System.debug('totalPayment:'+totalPaymentAmount);
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
            numberOfOccurrence = -1;
        } return numberOfOccurrence;
    }
}