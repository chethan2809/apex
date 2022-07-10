@isTest(isParallel=true)
private class EmailTemplateDBTests {

    private static EmailTemplateDB emailTemplateDBInstance = new EmailTemplateDB();

    @isTest
    private static void getTemplatesByName() {

        Test.startTest();
            List<EmailTemplate> emailTemplateList = emailTemplateDBInstance.getTemplatesByName(new Set<String>{'Test Template'});
        Test.stopTest();

        System.assert(emailTemplateList != null);
    }
}