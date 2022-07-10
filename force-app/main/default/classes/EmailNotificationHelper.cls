public class EmailNotificationHelper {
    
    public static EmailTemplateDB emailTemplateDBInstance = new EmailTemplateDB();
    public static EmailDB emailDBInstance = new EmailDB();
    public static ContactDB contactDBInstance = new ContactDB();
    public static CaseDB caseDBInstance = new CaseDB();
    public static CongaSignTransactionsDB congaSignTransactionDBInstance = new CongaSignTransactionsDB();
    public static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

    public static void sendEmailNotification(String notificationType, String loanStatus, Contact oldContact, String OldAddress, Contact editedContact, 
                                        Account oldAccount, Account editedAccount, clcommon__Address__c editedBusinessAddress, 
                                        loan__Bank_Account__c oldBankAccount, loan__Bank_Account__c editedBankAccount, String oldPhone){
        String status = PortalConstants.API_RESPONSE_STATUS_SUCCESS;
        List<User> queueMemberUserList = new List<User>();
        Set<String> templateNames;
        if(loanStatus == PortalConstants.LOAN_ACTIVE_GOOD_STANDING_STATUS){
            queueMemberUserList = getQueueMembersEmailAddressAndName(PortalConstants.UNDER_WRITER_QUEUE_NAME);
        }
        else if(loanStatus == PortalConstants.LOAN_ACTIVE_BAD_STANDING_STATUS){
            queueMemberUserList = getQueueMembersEmailAddressAndName(PortalConstants.COLLECTIONS_TEAM_QUEUE_NAME);
        }
        if(notificationType == PortalConstants.NOTIFICATION_TYPE_CONTACT_PERSONAL_ADDRESS_CHANGE || 
           notificationType == PortalConstants.NOTIFICATION_TYPE_CONTACT_BUSINESS_ADDRESS_CHANGE ||
           notificationType == PortalConstants.NOTIFICATION_TYPE_CONTACT_PERSONAL_PHONE_CHANGE ||
           notificationType == PortalConstants.NOTIFICATION_TYPE_CONTACT_BUSINESS_PHONE_CHANGE){
                templateNames = new Set<String>{PortalConstants.CONTACT_INFO_CHANGE_NOTIFICATION_TEMPLATE};
        }
        else if(notificationType == PortalConstants.NOTIFICATION_TYPE_BANK_ACCOUNT_CHANGE){
            templateNames = new Set<String>{PortalConstants.BANK_ACCOUNT_CHANGE_NOTIFICATION_TEMPLATE};
        }
        List<EmailTemplate> notificationTemplates = emailTemplateDBInstance.getTemplatesByName(templateNames);
        if(!notificationTemplates.isEmpty() && !queueMemberUserList.isEmpty()){
            String emailBody = notificationTemplates[0].Body;
            String emailSubject = notificationTemplates[0].Subject;
            emailSubject = emailSubject.replace('[Account Name]',String.valueof(oldContact.Account.Name));

            emailBody = emailBody.replace('[Account Name]', String.valueof(oldContact.Account.Name));
            emailBody = emailBody.replace('[Contact Name]', String.valueof(oldContact.Name));
            emailBody = emailBody.replace('[Contact Email]', String.valueof(oldContact.Email) + '\n');
            emailBody = emailBody.replace('[Contact Phone]', String.valueof(oldContact.MobilePhone));
            emailBody = emailBody.replace('Current [Field Name]:', 'Current ' + notificationType + ':');
            emailBody = emailBody.replace('New [Field Name]:', 'New ' + notificationType + ':');
            if(notificationType == PortalConstants.NOTIFICATION_TYPE_CONTACT_PERSONAL_ADDRESS_CHANGE){
                /* String oldAddress = oldContact.MailingBuildingNumber__c + ' ' + oldContact.MailingStreet + '\n';
                oldAddress = oldAddress + oldContact.MailingCity + ' ' + oldContact.MailingState + '\n';
                oldAddress = oldAddress + oldContact.MailingCountry + ' ' + oldContact.MailingPostalCode; */
                emailBody = emailBody.replace('[Previous Value]',oldAddress);

                String newAddress = editedContact.MailingBuildingNumber__c==null?'':editedContact.MailingBuildingNumber__c + ' ' + editedContact.MailingStreet + '\n';
                newAddress = newAddress + editedContact.MailingCity + ' ' + editedContact.MailingState + '\n';
                newAddress = newAddress + editedContact.MailingCountry + ' ' + editedContact.MailingPostalCode;
                emailBody = emailBody.replace('[New Value]',newAddress);
            }
            else if(notificationType == PortalConstants.NOTIFICATION_TYPE_CONTACT_PERSONAL_PHONE_CHANGE){
                emailBody = emailBody.replace('[Previous Value]',oldPhone);
                emailBody = emailBody.replace('[New Value]',editedContact.MobilePhone);
            }
            else if(notificationType == PortalConstants.NOTIFICATION_TYPE_CONTACT_BUSINESS_PHONE_CHANGE){
                emailBody = emailBody.replace('[Previous Value]',oldPhone);
                emailBody = emailBody.replace('[New Value]',editedAccount.Phone);
            }
            else  if(notificationType == PortalConstants.NOTIFICATION_TYPE_CONTACT_BUSINESS_ADDRESS_CHANGE){
                String oldAccountAddress = oldAccount.BillingBuildingNumber__c == null?'':oldAccount.BillingBuildingNumber__c + ' ' + oldAccount.BillingStreet + '\n';
                oldAccountAddress = oldAccountAddress + oldAccount.BillingCity + ' ' + oldAccount.BillingState + '\n';
                oldAccountAddress = oldAccountAddress + oldAccount.BillingCountry + ' ' + oldAccount.BillingPostalCode;
                emailBody = emailBody.replace('[Previous Value]',oldAccountAddress);

                String newAddress = editedBusinessAddress.clcommon__Address_Line_2__c + ' ' + editedBusinessAddress.clcommon__Street_Address__c + '\n';
                newAddress = newAddress + editedBusinessAddress.clcommon__City__c + ' ' + editedBusinessAddress.clcommon__State_Province__c + '\n';
                newAddress = newAddress + editedBusinessAddress.clcommon__Country__c + ' ' + editedBusinessAddress.clcommon__Zip_Code__c;
                emailBody = emailBody.replace('[New Value]',newAddress);
            }
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            for(User user : queueMemberUserList){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                String mailBody = emailBody.replace('[First Name]', user.FirstName + ' ' + user.LastName);
                email.setSubject(emailSubject);
                email.setPlainTextBody(mailBody);
                email.toAddresses = new String[] {user.Email};
                emails.add(email);
            }
            List<Messaging.SendEmailResult> results = emailDBInstance.sendBulkEmail(emails);
            for(Messaging.SendEmailResult result : results){
                if(!result.isSuccess()){
                    Error_Log__c errorLog = ErrorLogs.createErrorLog (
                        notificationType, result.getErrors().toString(), null, null, 'Error', null, true);
                    errorLogDBInstance.addInsert(errorLog);
                    errorLogDbInstance.executeInserts();
                }
            }
        }
    }

    public static void sendMerchantEmailNotification(Map<Id, Id> caseIdsMap, List<Contact> contactList, Map<Id, Id> guarantorAccountIdsMap){

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        String emailAddress= '';
        OrgWideEmailAddress owea = new OrgWideEmailAddress();
        owea = GeneralHelper.orgWideEmailAddressByEmail.get(
            PortalConstants.CAN_CUSTOMER_SERVICE_EMAIL_ADDRESS);

        for(Contact contact :contactList) {
            Set<String> templateNames;
            Id accountId = guarantorAccountIdsMap.get(contact.AccountId);
            Id caseId = caseIdsMap.get(accountId);
            Case caseData = caseDBInstance.getCaseDetailsById(caseId, accountId);
            String notificationType = caseData.Type;
            STring caseStatus = caseData.Status;
            if(notificationType == PortalConstants.CASE_TYPE_BUSINESS_ADDRESS_CHANGE ) {
                templateNames = new Set<String>{PortalConstants.NOTIFICATION_TO_MERCHANT_BUSINESS_ADDRESS_CHANGE};
            }
            else if(notificationType == PortalConstants.CASE_TYPE_BANK_ACCOUNT_CHANGE ) {
                templateNames = new Set<String>{PortalConstants.NOTIFICATION_TO_MERCHANT_BANK_ACCOUNT_CHANGE};
            }

            List<EmailTemplate> notificationTemplates = emailTemplateDBInstance.getTemplatesByName(templateNames);

            if(!notificationTemplates.isEmpty()){
                String emailBody = notificationTemplates[0].HtmlValue;
                String emailSubject = notificationTemplates[0].Subject;

                emailSubject = emailSubject.replace('[Account Name]',String.valueof(contact.Account.Name));
                emailBody = emailBody.replace('[First Name]', (String.valueof(contact.Name)));

                if(notificationType == PortalConstants.CASE_TYPE_BANK_ACCOUNT_CHANGE && caseStatus == PortalConstants.NEW_CASE){
                    emailBody = emailBody.replace('[Message Body]', PortalConstants.MERCHANT_NOTIFICATION_NEW_STATUS_BODY_FOR_BANK_ACCOUNT);
                }

                else if(notificationType == PortalConstants.CASE_TYPE_BANK_ACCOUNT_CHANGE && caseStatus == PortalConstants.APPROVED_CASE){
                    emailBody = emailBody.replace('[Message Body]', PortalConstants.MERCHANT_NOTIFICATION_APPROVED_STATUS_BODY_FOR_BANK_ACCOUNT);
                }

                else if(notificationType == PortalConstants.CASE_TYPE_BANK_ACCOUNT_CHANGE && caseStatus == PortalConstants.REJECTED_CASE){
                    emailBody = emailBody.replace('[Message Body]', PortalConstants.MERCHANT_NOTIFICATION_REJECTED_STATUS_BODY_FOR_BANK_ACCOUNT);
                }

                else if(notificationType == PortalConstants.CASE_TYPE_BUSINESS_ADDRESS_CHANGE && caseStatus == PortalConstants.NEW_CASE){
                    emailBody = emailBody.replace('[Message Body]', PortalConstants.MERCHANT_NOTIFICATION_NEW_STATUS_BODY_FOR_BUSINESS_ADDRESS_CHANGE);
                }

                else if(notificationType == PortalConstants.CASE_TYPE_BUSINESS_ADDRESS_CHANGE && caseStatus == PortalConstants.APPROVED_CASE){
                    emailBody = emailBody.replace('[Message Body]', PortalConstants.MERCHANT_NOTIFICATION_APPROVED_STATUS_BODY_FOR_BUSINESS_ADDRESS_CHANGE);
                }

                else if(notificationType == PortalConstants.CASE_TYPE_BUSINESS_ADDRESS_CHANGE && caseStatus == PortalConstants.REJECTED_CASE){
                    emailBody = emailBody.replace('[Message Body]', PortalConstants.MERCHANT_NOTIFICATION_REJECTED_STATUS_BODY_FOR_BUSINESS_ADDRESS_CHANGE);
                }
                emailBody = emailBody.replace('<![CDATA[]]>','');
                emailBody = emailBody.replace('<![CDATA[','');
                emailBody = emailBody.replace(']]>','');
                if(emailAddress != contact.Email){
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setSubject(emailSubject);
                    email.setHtmlBody(emailBody);
                    email.toAddresses = new String[] {contact.Email};
                    if(owea != Null)
                        email.setOrgWideEmailAddressId(owea.Id);
                    emails.add(email);
                }
                emailAddress = contact.Email;
            }
            List<Messaging.SendEmailResult> results = emailDBInstance.sendBulkEmail(emails);

            for(Messaging.SendEmailResult result : results){
                if(!result.isSuccess()){
                    Error_Log__c errorLog = ErrorLogs.createErrorLog (
                        notificationType, result.getErrors().toString(), null, null, 'Error', null, true);
                    errorLogDBInstance.addInsert(errorLog);
                    errorLogDbInstance.executeInserts();
                }
            }
        }
    }
    
    public static void sendCongaSenderNotificationToBroker(Set<Id> congaSignTransactionIds, Map<Id,String> congaSignTransactionIdsMap){
        String status = PortalConstants.API_RESPONSE_STATUS_SUCCESS;
        Set<String> templateNames;
        Map<Id,APXT_CongaSign__Transaction__c> congaSignTransactionsDetailMap = new  Map<Id,APXT_CongaSign__Transaction__c>();
        try{
            List<EmailTemplate> notificationTemplates = emailTemplateDBInstance.getTemplatesByName(new Set<String>{CongaSignTransactions.CONGA_SENDER_NOTIFICATION_TEMPLATE});
            if(!notificationTemplates.isEmpty()){
                List<APXT_CongaSign__Transaction__c> congaSignTransactionsList = congaSignTransactionDBInstance.getCongaSignTransactionsByIds(congaSignTransactionIds);
                List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
                for(APXT_CongaSign__Transaction__c congaSignTransaction : congaSignTransactionsList){
                    String emailBody = notificationTemplates[0].HtmlValue;
                    String emailSubject = notificationTemplates[0].Subject;
                    emailBody = emailBody.replace(CongaSignTransactions.CONGA_NOTIFICATION_BROKER_NAME_KEY, congaSignTransaction.Parent_a6t__r.Owner.Name);
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    if(congaSignTransaction.APXT_CongaSign__Status__c == CongaSignTransactions.STATUS_SENT){
                        emailSubject = emailSubject.replace(CongaSignTransactions.CONGA_NOTIFICATION_SUBJECT_KEY, CongaSignTransactions.CONGA_NOTIFICATION_SUBJECT_SENT + ' - ' + congaSignTransaction.Parent_a6t__r.Name);
                        emailBody = emailBody.replace(CongaSignTransactions.CONGA_NOTIFICATION_TYPE_KEY, CongaSignTransactions.CONGA_NOTIFICATION_TITLE_SENT);
                        emailBody = emailBody.replace(CongaSignTransactions.CONGA_NOTIFICATION_MESSAGE_KEY, CongaSignTransactions.CONGA_NOTIFICATION_SENT_MSG);
                    }
                    else if(congaSignTransaction.APXT_CongaSign__Status__c == CongaSignTransactions.STATUS_COMPLETE){
                        emailSubject = emailSubject.replace(CongaSignTransactions.CONGA_NOTIFICATION_SUBJECT_KEY, CongaSignTransactions.CONGA_NOTIFICATION_SUBJECT_COMPLETE + ' - ' + congaSignTransaction.Parent_a6t__r.Name);
                        emailBody = emailBody.replace(CongaSignTransactions.CONGA_NOTIFICATION_TYPE_KEY, CongaSignTransactions.CONGA_NOTIFICATION_TITLE_COMPLETE);
                        emailBody = emailBody.replace(CongaSignTransactions.CONGA_NOTIFICATION_MESSAGE_KEY, CongaSignTransactions.CONGA_NOTIFICATION_COMPLETE_MSG);
                    }
                    else if(congaSignTransaction.APXT_CongaSign__Status__c == CongaSignTransactions.STATUS_DECLINED){
                        emailSubject = emailSubject.replace(CongaSignTransactions.CONGA_NOTIFICATION_SUBJECT_KEY, CongaSignTransactions.CONGA_NOTIFICATION_SUBJECT_DECLINED + ' - ' + congaSignTransaction.Parent_a6t__r.Name);
                        emailBody = emailBody.replace(CongaSignTransactions.CONGA_NOTIFICATION_TYPE_KEY, CongaSignTransactions.CONGA_NOTIFICATION_TITLE_DECLINED);
                        emailBody = emailBody.replace(CongaSignTransactions.CONGA_NOTIFICATION_MESSAGE_KEY, CongaSignTransactions.CONGA_NOTIFICATION_DECLINED_MSG);
                    }
                    emailBody = emailBody.replace(CongaSignTransactions.CONGA_NOTIFICATION_MERCHANT_EMAIL_KEY, congaSignTransaction.Parent_a6t__r.Primary_Guarantor__r.Email);
                    emailBody = emailBody.replace('<![CDATA[','');
                    emailBody = emailBody.replace(']]>','');
                    email.setSubject(emailSubject);
                    email.setHtmlBody(emailBody);
                    email.toAddresses = new String[] {congaSignTransaction.Parent_a6t__r.Owner.Email};
                    emails.add(email);
                }
                List<Messaging.SendEmailResult> results = emailDBInstance.sendBulkEmail(emails);
                for(Messaging.SendEmailResult result : results){
                    if(!result.isSuccess()){
                        Error_Log__c errorLog = ErrorLogs.createErrorLog (
                            CongaSignTransactions.CONGA_NOTIFICATION_FAILED_MSG, result.getErrors().toString(), null, null, 'Error', null, true);
                        errorLogDBInstance.addInsert(errorLog);
                        errorLogDbInstance.executeInserts();
                    }
                }
            }
        }catch(Exception ex){
            Error_Log__c errorLog = ErrorLogs.createErrorLog (
                CongaSignTransactions.CONGA_NOTIFICATION_FAILED_MSG,ex.getMessage(), ex.getStackTraceString(), null, 'Error', null, true);
            errorLogDBInstance.addInsert(errorLog);
            errorLogDbInstance.executeInserts();
        }
    }

    public static List<User> getQueueMembersEmailAddressAndName(String queueName){
        return [
            SELECT FirstName, LastName, Email
            FROM User
            WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = :queueName)
        ];
    }

}