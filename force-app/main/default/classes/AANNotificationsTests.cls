@isTest
private class AANNotificationsTests {
    @isTest
    static void buildGuarantorAANNotificationTemplateBodytests(){

    GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
    clcommon__Legal_Entity__c legalEntity = new clcommon__Legal_Entity__c();
    legalEntity.clcommon__Legal_Entity_Type__c = 'Sole Proprietorship';
    legalEntity.Name = 'Test Legal Entity';

    Account guarantorAccountRecord = new Account();
    guarantorAccountRecord.BillingCity='delhi';
    guarantorAccountRecord.BillingStreet='Street';
    guarantorAccountRecord.BillingState='State';
    guarantorAccountRecord.BillingPostalCode='678905';
    guarantorAccountRecord.BillingCountry='India';
    guarantorAccountRecord.Merchant_ID__c = '12345';
    guarantorAccountRecord.Industry = 'Textile';
    guarantorAccountRecord.clcommon__Legal_Entity_Type__c = legalEntity.Id;
    guarantorAccountRecord.Business_Name__c = 'Test Business';

    Contact brokerContactRecord = new Contact();
    brokerContactRecord.FirstName = 'Broker Test';
    brokerContactRecord.LastName = 'CanCapital';
    brokerContactRecord.AccountId = guarantorAccountRecord.Id;
    brokerContactRecord.Account = guarantorAccountRecord;

    Contact partyContactRecord = new Contact();
    partyContactRecord.FirstName = 'Party Test';
    partyContactRecord.LastName = 'Can Party';
    partyContactRecord.Last_Consumer_Credit_Pull__c = GeneralHelper.currentSystemDate;

    genesis__Applications__c application = new genesis__Applications__c();
    application.Broker_Contact__c = brokerContactRecord.Id;
    application.Broker_Contact__r = brokerContactRecord;
    application.genesis__Account__c = guarantorAccountRecord.Id;
    application.genesis__Account__r = guarantorAccountRecord;
    application.Business_Start_Date__c = Date.Today();
    application.Decline_Reasons__c = 'Time In Business';

    clcommon__Party__c party = new clcommon__Party__c();
    party.genesis__Application__c = application.Id;
    party.genesis__Application__r = application;
    party.Competitor_Amount__c = 4000;
    party.clcommon__Contact__c = partyContactRecord.Id;
    party.clcommon__Contact__r = partyContactRecord;

    GeneralHelper.domainUrl = 'testDomain';
    List<Document> documentList = new List<Document>();
    Document documentRecord = new Document();
    documentRecord.Name = 'Dummy File';
    documentRecord.DeveloperName = 'CAN_CAPITAL_IMAGE';
    documentRecord.Body = Blob.valueOf('Dummy File Body');
    documentRecord.FolderId = TestUtility.getFakeId(Folder.getSObjectType());
    documentRecord.Type = 'txt';
    documentRecord.ContentType = 'test';
    documentRecord.Id = TestUtility.getFakeId(Document.getSObjectType());
    documentList.add(documentRecord);

    EmailTemplate template = new EmailTemplate();
    template.Id = TestUtility.getFakeId(EmailTemplate.getSObjectType());
    template.isActive = true;
    template.Name = 'name';
    template.DeveloperName = 'unique_name_addSomethingSpecialHere';
    template.FolderId = UserInfo.getUserId();
    template.Body = '{{ACCOUNT_NAME}}{{CURRENT_DATE}}{{CUSTOMER_NAME}}{{BILLING_STREET}}{{BILLING_CITY}}{{BILLING_STATE}}{{BILLING_POSTAL_CODE}}{{IMAGE__LOGO}}';
    template.subject = '{{BORROWER_ID}}{{BROKER_ACCOUNT_NAME}}';
    template.HtmlValue = '{{ACCOUNT_NAME}}{{CURRENT_DATE}}{{CUSTOMER_NAME}}{{BILLING_STREET}}{{BILLING_CITY}}{{BILLING_STATE}}{{BILLING_POSTAL_CODE}}{{IMAGE__LOGO}}';

    test.startTest();
        String actualBody = AANNotifications.buildGuarantorAANNotificationTemplateBody(party, template.Body, documentList);
    test.stopTest();

    System.assertNotEquals(null, actualBody);
    }

    @isTest
    static void buildSolePropGuarantorAANNotificationTemplateBodyTests(){
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        clcommon__Legal_Entity__c legalEntity = new clcommon__Legal_Entity__c();
        legalEntity.clcommon__Legal_Entity_Type__c = 'Sole Proprietorship';
        legalEntity.Name = 'Test Legal Entity';

        Account guarantorAccountRecord = new Account();
        guarantorAccountRecord.BillingCity='delhi';
        guarantorAccountRecord.BillingStreet='Street';
        guarantorAccountRecord.BillingState='State';
        guarantorAccountRecord.BillingPostalCode='678905';
        guarantorAccountRecord.BillingCountry='India';
        guarantorAccountRecord.Merchant_ID__c = '12345';
        guarantorAccountRecord.Industry = 'Textile';
        guarantorAccountRecord.clcommon__Legal_Entity_Type__c = legalEntity.Id;
        guarantorAccountRecord.Business_Name__c = 'Test Business';

        Contact brokerContactRecord = new Contact();
        brokerContactRecord.FirstName = 'Broker Test';
        brokerContactRecord.LastName = 'CanCapital';
        brokerContactRecord.AccountId = guarantorAccountRecord.Id;
        brokerContactRecord.Account = guarantorAccountRecord;

        Contact partyContactRecord = new Contact();
        partyContactRecord.FirstName = 'Party Test';
        partyContactRecord.LastName = 'Can Party';
        partyContactRecord.Last_Consumer_Credit_Pull__c = GeneralHelper.currentSystemDate;

        genesis__Applications__c application = new genesis__Applications__c();
        application.Broker_Contact__c = brokerContactRecord.Id;
        application.Broker_Contact__r = brokerContactRecord;
        application.genesis__Account__c = guarantorAccountRecord.Id;
        application.genesis__Account__r = guarantorAccountRecord;
        application.Business_Start_Date__c = Date.Today();
        application.Decline_Reasons__c = 'Time In Business';

        clcommon__Party__c party = new clcommon__Party__c();
        party.genesis__Application__c = application.Id;
        party.genesis__Application__r = application;
        party.Competitor_Amount__c = 4000;
        party.clcommon__Contact__c = partyContactRecord.Id;
        party.clcommon__Contact__r = partyContactRecord;

    List<String> reasonCodes = new List<String>();
    reasonCodes.add('Reason1');
    reasonCodes.add('Reason2');

    EmailTemplate template = new EmailTemplate();
    template.Id = TestUtility.getFakeId(EmailTemplate.getSObjectType());
    template.isActive = true;
    template.Name = 'name';
    template.DeveloperName = 'unique_name_addSomethingSpecialHere';
    template.FolderId = UserInfo.getUserId();
    template.Body = '{{NONSOLECONTENTSTART}}Thank you for applying{{NONSOLECONTENTEND}}';
    template.subject = '{{BORROWER_ID}}{{BROKER_ACCOUNT_NAME}}';
    template.HtmlValue = '{{NONSOLECONTENTSTART}}Thank you for applying{{NONSOLECONTENTEND}}';

    test.startTest();
        String actualBody = AANNotifications.buildSolePropGuarantorAANNotificationTemplateBody(party, template.Body, 300, reasonCodes);
    test.stopTest();

    System.assertNotEquals(null, actualBody);
    }

    @isTest
    static void buildNonSoleAANNotificationTemplateBodyTests(){
    EmailTemplate template = new EmailTemplate();
    template.Id = TestUtility.getFakeId(EmailTemplate.getSObjectType());
    template.isActive = true;
    template.Name = 'name';
    template.DeveloperName = 'unique_name_addSomethingSpecialHere';
    template.FolderId = UserInfo.getUserId();
    template.Body = '{{SOLEPROPBODYSTART}}T{{SOLEPROPBODYEND}} '
        + '{{SOLEPROPCONTENTSTART}}T{{SOLEPROPCONTENTEND}} '
        + '{{SOLEPROPADDRESSSTART}}T{{SOLEPROPADDRESSEND}}';
    template.subject = '{{BORROWER_ID}}{{BROKER_ACCOUNT_NAME}}';
    template.HtmlValue = '{{SOLEPROPBODYSTART}}T{{SOLEPROPBODYEND}} '
        + '{{SOLEPROPCONTENTSTART}}T{{SOLEPROPCONTENTEND}} '
        + '{{SOLEPROPADDRESSSTART}}T{{SOLEPROPADDRESSEND}}';

    test.startTest();
        String actualBody = AANNotifications.buildNonSoleAANNotificationTemplateBody(template.Body);
    test.stopTest();

    System.assertNotEquals(null, actualBody);
    }

    @isTest
    private static void getReasonCodesByContact(){
        List<String> reasonCodes =  new List<String>{'Reason1'};

        test.startTest();
            String reasons = AANNotifications.getReasonCodesByContact(reasonCodes);
        test.stopTest();

        System.assertNotEquals(reasonCodes[0], reasons);
    }
}