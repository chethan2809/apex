@isTest
private class TaskManagerTests {

    private static EmailDB emailDBInstance = new EmailDB();

    @isTest
    private static void sendTaskStatusEmailNotificationTest() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

        User salesRep = new User();
        salesRep.FirstName = 'Sales';
        salesRep.LastName = 'Rep';
        salesRep.ProfileID = [Select Id From Profile Where Name='System Administrator'].Id;
        salesRep.Email = 'testsalesrep@cancapital.com';
        salesRep.Title = 'SalesRepresentative';
        salesRep.Phone = '98765';
        salesRep.EmailEncodingKey = 'ISO-8859-1';
        salesRep.LanguageLocaleKey = 'en_US';
        salesRep.TimeZoneSidKey = 'America/New_York';
        salesRep.LocaleSidKey = 'en_US';
        salesRep.Username = TestUtility.generateFakeName() + '@example.com';
        salesRep.CommunityNickname = 'testUser123';
        salesRep.Alias = 't1';
        salesRep.IsActive = true;
        insert salesRep;

        collect__Loan_Account__c collectionContract = new collect__Loan_Account__c();
        collectionContract.OwnerId = salesRep.Id;
        insert collectionContract;

        List<collect__Collection_Activity__c> collectionActivities = new List<collect__Collection_Activity__c>();
        collect__Collection_Activity__c collectionActivity = new collect__Collection_Activity__c();
        collectionActivity.collect__Dev_Contract__c = collectionContract.Id;
        collectionActivity.collect__Account_Manager__c = salesRep.Id;
        insert collectionActivity;

        collect__Collection_Activity__c actualCollectionActivity = [
            SELECT Id, collect__Dev_Contract__c, collect__Dev_Contract__r.Owner.Name,
                collect__Account_Manager__c, collect__Account_Manager__r.Name, collect__Dev_Contract__r.Owner.Email
            FROM collect__Collection_Activity__c WHERE Id =:collectionActivity.Id
            LIMIT 1
        ];

        collectionActivities.add(actualCollectionActivity);

        EmailTemplate template = new EmailTemplate();
        template.body = 'Test Body';
        template.subject = 'Test Subject';
        template.HtmlValue = 'Test Body';
        template.Id = TestUtility.getFakeId(EmailTemplate.getSObjectType());

        String fromAddress = 'test1@example.com';
        String subject = 'Dummy Subject';
        String htmlTextBody = '<b>Dummy Html Text Body</b><br/>';
        List<String> toAddress = new List<String>{'test@example.com'};

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = Emails.getEmailMessageSetup(
            toAddress, null, fromAddress, subject, htmlTextBody, true,
            new Map<String, Blob>{'a' => Blob.valueOf('a')}, null
        );
        emailList.add(email);

        List<Messaging.SendEmailResult> sendEmailResult = emailDbInstance.sendEmail(email);

        Test.startTest();
        TaskManager.sendTaskStatusEmailNotification(collectionActivities, template);
        Test.stopTest();

        System.assertEquals(true, sendEmailResult.get(0).isSuccess());
    }

    @isTest
    private static void setAccountOutcomeActivityFieldsWhenOutOfMarket() {

        Task task = new Task();
        task.Id = TestUtility.getFakeId(Task.getSObjectType());
        task.Status = 'Completed';
        task.Activity_Outcome__c = Tasks.OUTCOME_OUT_OF_MARKET;

        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        TaskManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Map<Id, String> taskMap = new Map<Id, String>();
        taskMap.put(accountRecord.Id, task.Activity_Outcome__c);

        Test.startTest();
            TaskManager.setAccountOutcomeActivityFields(taskMap);
        Test.stopTest();

        System.assertEquals(1, accountDBStubInstance.forUpdateSObjects.size());
        Account actualUpdatedAccount = (Account) accountDBStubInstance.forUpdateSObjects.get(0);

        System.assertEquals(accountRecord.Id, actualUpdatedAccount.Id);
        System.assertEquals(task.Activity_Outcome__c, actualUpdatedAccount.Most_Recent_Activity_Outcome__c);
        System.assertEquals(true, actualUpdatedAccount.Out_of_Market__c);
    }

    @isTest
    private static void setAccountOutcomeActivityFieldsWhenNotOutOfMarket() {

        Task task = new Task();
        task.Id = TestUtility.getFakeId(Task.getSObjectType());
        task.Status = 'Completed';
        task.Activity_Outcome__c = 'Out of Business';

        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());

        DBManagerTestsStub accountDBStub = new DBManagerTestsStub();
        TaskManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStub);

        Map<Id, String> taskMap = new Map<Id, String>();
        taskMap.put(accountRecord.Id, task.Activity_Outcome__c);

        Test.startTest();
            TaskManager.setAccountOutcomeActivityFields(taskMap);
        Test.stopTest();

        System.assertEquals(1, accountDBStub.forUpdateSObjects.size());
        Account actualUpdatedAccount = (Account) accountDBStub.forUpdateSObjects.get(0);

        System.assertEquals(accountRecord.Id, actualUpdatedAccount.Id);
        System.assertEquals(task.Activity_Outcome__c, actualUpdatedAccount.Most_Recent_Activity_Outcome__c);
        System.assertEquals(false, actualUpdatedAccount.Out_of_Market__c);
    }

}