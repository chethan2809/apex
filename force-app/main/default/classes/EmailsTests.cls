@isTest(isParallel=true)
private class EmailsTests {

    @isTest
    static void getEmailMessageSetupForHtmlBody() {

        String fromAddress = 'test1@test.com';
        String subject = 'Dummy Subject';
        String htmlTextBody = '<b>Dummy Html Text Body</b><br/>';
        List<String> toAddress = new List<String>{'test@test.com'};

        System.Test.startTest();
            Messaging.SingleEmailMessage email = Emails.getEmailMessageSetup(
                toAddress, null, fromAddress, subject, htmlTextBody, true,
                new Map<String, Blob>{'a' => Blob.valueof('a')}, null
            );
        System.Test.stopTest();

        System.assertEquals(htmlTextBody, email.getHtmlBody());
        System.assertEquals(subject, email.getSubject());
        System.assertEquals(toAddress, email.getToAddresses());
        System.assertEquals(fromAddress, email.getReplyTo());
        System.assertEquals(fromAddress, email.getSenderDisplayName());
        System.assert(!email.getFileAttachments().isEmpty(), 'File Attachment must not be Empty');

    }

    @isTest
    static void getEmailMessageSetupForPlainBody() {

        String fromAddress = 'test1@test.com';
        String subject = 'Dummy Subject';
        String plainTextBody = 'Dummy Plain Text Body';
        List<String> toAddress = new List<String>{'test@test.com'};

        System.Test.startTest();
            Messaging.SingleEmailMessage email = Emails.getEmailMessageSetup(
                toAddress, null, fromAddress, subject, plainTextBody, false,
                new Map<String, Blob>{'a' => Blob.valueof('a')}, null
            );
        System.Test.stopTest();

        System.assertEquals(plainTextBody, email.getPlainTextBody());
        System.assertEquals(subject, email.getSubject());
        System.assertEquals(toAddress, email.getToAddresses());
        System.assertEquals(fromAddress, email.getReplyTo());
        System.assertEquals(fromAddress, email.getSenderDisplayName());
        System.assert(!email.getFileAttachments().isEmpty(), 'File Attachment must not be Empty');
    }

    @isTest
    static void getEmailMessageSetupWithOrgWideFromAddress() {

        String fromAddress = 'test1@test.com';
        String subject = 'Dummy Subject';
        String plainTextBody = 'Dummy Plain Text Body';
        List<String> toAddress = new List<String>{'test@test.com'};
        OrgWideEmailAddress orgWideAddress = new OrgWideEmailAddress();
        orgWideAddress.Id = TestUtility.getFakeId(OrgWideEmailAddress.getSObjectType());
        orgWideAddress.Address = 'Test@Canacapital.com';

        System.Test.startTest();
            Messaging.SingleEmailMessage email = Emails.getEmailMessageSetup(
                toAddress, null, fromAddress, subject, plainTextBody, false,
                new Map<String, Blob>{'a' => Blob.valueof('a')}, orgWideAddress
            );
        System.Test.stopTest();

        System.assertEquals(plainTextBody, email.getPlainTextBody());
        System.assertEquals(subject, email.getSubject());
        System.assertEquals(toAddress, email.getToAddresses());
        System.assertEquals(orgWideAddress.Address, email.getReplyTo());
        System.assertEquals(orgWideAddress.Id, email.getOrgWideEmailAddressId());
        System.assert(!email.getFileAttachments().isEmpty(), 'File Attachment must not be Empty');
    }
}