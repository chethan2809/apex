@IsTest
private class LeadEmailServiceTests
{
    @IsTest
    private static void emailToLeadTest()
    {
        Messaging.InboundEmail email  = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.plainTextBody = '##BODYSTART## \n Last Name: Das \n ##BODYEND##';
        email.fromAddress = 'test@example.com';
        String contactEmail = 'jsmith@example.com';
        email.subject = 'Dummy Account Name 123';
        Messaging.InboundEmail.BinaryAttachment[] bAttachments =
        new List<Messaging.InboundEmail.BinaryAttachment> {
            new Messaging.InboundEmail.BinaryAttachment()
        };

        bAttachments[0].body = Blob.valueOf('columnHeader1');
        bAttachments[0].filename = 'attach1.bin';
        bAttachments[0].mimeTypeSubType = 'whatever';
        email.BinaryAttachments = bAttachments;
        LeadEmailService emailService = new LeadEmailService();
        System.Test.startTest();
        Messaging.InboundEmailResult result = emailService.handleInboundEmail(email, env);
        System.Test.stopTest();
        System.assert(result.success);
    }
}