@isTest(isParallel=true)
private class EmailDBTests {

    private static EmailDB emailDBInstance = new EmailDB();

    @isTest
    static void sendEmailWithSingleEmailMessage(){

        List<Messaging.SendEmailResult> sendEmailResultList;
        String fromAddress = 'test1@example.com';
        String subject = 'Dummy Subject';
        String htmlTextBody = '<b>Dummy Html Text Body</b><br/>';
        List<String> toAddress = new List<String>{'test@example.com'};

        Messaging.SingleEmailMessage email = Emails.getEmailMessageSetup(
            toAddress, null, fromAddress, subject, htmlTextBody, true,
            new Map<String, Blob>{'a' => Blob.valueOf('a')}, null
        );

        System.Test.startTest();
            sendEmailResultList = emailDbInstance.sendEmail(email);
        System.Test.stopTest();

        System.assertEquals(true, sendEmailResultList.get(0).isSuccess());
    }

    @isTest
    static void sendBulkEmailWithSingleEmailMessage(){

        List<Messaging.SendEmailResult> sendEmailResultList;
        String fromAddress = 'test1@example.com';
        String subject = 'Dummy Subject';
        String htmlTextBody = '<b>Dummy Html Text Body</b><br/>';
        List<String> toAddress = new List<String>{'test@example.com'};

        Messaging.SingleEmailMessage email = Emails.getEmailMessageSetup(
            toAddress, null, fromAddress, subject, htmlTextBody, true,
            new Map<String, Blob>{'a' => Blob.valueOf('a')}, null
        );

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        emailList.add(email);

        System.Test.startTest();
            sendEmailResultList = emailDbInstance.sendBulkEmail(emailList);
        System.Test.stopTest();

        System.assertEquals(true, sendEmailResultList.get(0).isSuccess());
    }

    @isTest
    static void checkSendEmailWithSingleEmailMessageForNull(){

        List<Messaging.SendEmailResult> sendEmailResultList;

        System.Test.startTest();
            sendEmailResultList = emailDbInstance.sendEmail(null);
        System.Test.stopTest();

        System.assert(sendEmailResultList.isEmpty());
    }

    @isTest
    static void checkSendBulkEmailWithSingleEmailMessageErrorForNull(){

        List<Messaging.SendEmailResult> sendEmailResultList;
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

        System.Test.startTest();
            sendEmailResultList = emailDbInstance.sendBulkEmail(emailList);
        System.Test.stopTest();

        System.assert(sendEmailResultList.isEmpty());
    }
}