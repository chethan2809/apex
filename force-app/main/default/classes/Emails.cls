public class Emails {

    public static Messaging.SingleEmailMessage getEmailMessageSetup(
        List<String> toAddresses, List<String> ccAddresses, String fromAddress, String subject, String textBody, Boolean isHTMLTextBody,
        Map<String, Blob> attachmentBlobsByFileName, OrgWideEmailAddress orgWideAddress
    ) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(toAddresses);
        email.setCcAddresses(ccAddresses);
        email.setSubject(subject);
        if(orgWideAddress != null) {
            email.setOrgWideEmailAddressId(orgWideAddress.Id);
            email.setReplyTo(orgWideAddress.Address);
        } else {
            email.setReplyTo(fromAddress);
            email.setSenderDisplayName(fromAddress);
        }

        if (isHTMLTextBody) {
             email.setHtmlBody(textBody);
        } else {
            email.setPlainTextBody(textBody);
        }

        if(attachmentBlobsByFileName != null && !attachmentBlobsByFileName.isEmpty()) {
            List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();
            for(String fileName : attachmentBlobsByFileName.keySet()){
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName(fileName);
                attachment.setBody(attachmentBlobsByFileName.get(fileName));
                fileAttachments.add(attachment);
            }
            email.setFileAttachments(fileAttachments);
        }

        return email;
    }
}