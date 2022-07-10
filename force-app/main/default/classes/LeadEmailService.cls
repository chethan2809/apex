public class LeadEmailService implements Messaging.InboundEmailHandler
{
    public static LeadDB leadDBInstance = new LeadDB();
    public static ContentVersionDB contentVersionDBInstance = new ContentVersionDB();
    public static ContentDocumentLinkDB contentDocumentLinkDBInstance = new ContentDocumentLinkDB();
    public static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    public static Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
    public static Lead leadRecord = new Lead();
    public Messaging.InboundEmailResult handleInboundEmail (
        Messaging.InboundEmail email, Messaging.InboundEnvelope env)
    {
        try {
            if(email.plainTextBody != Null && email.plainTextBody != '') {
                String removeWhiteSpaces = email.plainTextBody.trim();
                Integer bodyStartIndex = removeWhiteSpaces.IndexOf('##BODYSTART##');
                Integer bodyEndIndex = removeWhiteSpaces.lastIndexOf('##BODYEND##');
                String emailBody = removeWhiteSpaces.substring(bodyStartIndex, bodyEndIndex);
                String[] emailBodyRows = emailBody.split('\n');
                for(String bodyRow : emailBodyRows) {
                    if(!String.isEmpty(bodyRow)) {
                        String[] rowContents = bodyRow.split(':');
                        String label = '';
                        String value = '';
                        if(rowContents.size() >= 1) {
                            label = rowContents[0].trim();
                        }
                        if(rowContents.size() > 1) {
                       		value = rowContents[1].trim();
                        }
                        switch on label {
                            when 'Last Name' {
                                leadRecord.LastName = value;
                            }
                            when 'Company' {
                                leadRecord.Company = value;
                            }
                        }
                    }
                }
            }


            if(email.fromAddress != null) {
                leadRecord.Broker_Email__c = email.fromAddress;
            }
            leadRecord.LeadSource = Leads.SOURCE_EMAIL;
            leadDBInstance.addInsert(leadRecord);
            leadDBInstance.executeInserts();

            If(email.binaryAttachments != null) {
                for (Messaging.InboundEmail.BinaryAttachment leadAttachment : email.binaryAttachments) {
                    handleAttachments(leadAttachment, leadRecord);
                }
            }

            } catch(exception e) {
                Error_Log__c errorLog = ErrorLogs.createErrorLog (
                    'Email to Lead', e.getMessage(), e.getStackTraceString(),
                    null, 'Error', null, true
                );
                errorLogDBInstance.addInsert(errorLog);
                errorLogDBInstance.executeInserts();

                Lead leadException = new Lead();
                leadException.Email_Body__c = e.getMessage() + ' - ' + email.plainTextBody;
                leadException.Broker_Email__c = email.fromAddress;
                leadException.LastName = Leads.ERROR_LEAD;
                leadException.Company = Leads.ERROR_COMPANY;
                leadException.LeadSource = Leads.SOURCE_EMAIL;
                leadDBInstance.addInsert(leadException);
                leadDBInstance.executeInserts();

                If(email.binaryAttachments != null) {
                    for (Messaging.InboundEmail.BinaryAttachment leadAttachment : email.binaryAttachments) {
                        handleAttachments(leadAttachment, leadException);
                    }
                }
            }
        return result;
    }

    public void handleAttachments(Messaging.InboundEmail.BinaryAttachment leadAttachment, Lead leadRecord)
    {
        ContentVersion leadContentInsert = ContentVersions.insertAttachmentToContentVersion(leadAttachment);
        contentVersionDBInstance.addInsert(leadContentInsert);
        contentVersionDBInstance.executeInserts();
        ContentDocumentLink contentDocLink = ContentDocumentLinks.insertAttachmentToSObject(leadRecord,leadContentInsert);
        contentDocumentLinkDBInstance.addInsert(contentDocLink);
        contentDocumentLinkDBInstance.executeInserts();
    }
}