@isTest(isParallel=true)
private class AANNotificationManagerTests {

    private static EmailDB emailDBInstance = new EmailDB();

    @isTest
    private static void sendAANNotification() {

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);

        clcommon__Legal_Entity__c legalEntity = new clcommon__Legal_Entity__c();
        legalEntity.clcommon__Legal_Entity_Type__c = 'Sole Proprietorship';
        legalEntity.Name = 'Test Legal Entity';

        Account guarantorAccountRecord = new Account();
        guarantorAccountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());
        guarantorAccountRecord.BillingCity='delhi';
        guarantorAccountRecord.BillingStreet='Street';
        guarantorAccountRecord.BillingState='State';
        guarantorAccountRecord.BillingPostalCode='678905';
        guarantorAccountRecord.BillingCountry='India';
        guarantorAccountRecord.Merchant_ID__c = '12345';
        guarantorAccountRecord.Industry = 'Textile';
        guarantorAccountRecord.clcommon__Legal_Entity_Type__c = legalEntity.Id;
        guarantorAccountRecord.Business_Name__c = 'Test Business';
        guarantorAccountRecord.Doing_Business_As_Name__c = 'Test';

        Contact brokerContactRecord = new Contact();
        brokerContactRecord.FirstName = 'Broker Test';
        brokerContactRecord.LastName = 'CanCapital';
        brokerContactRecord.AccountId = guarantorAccountRecord.Id;
        brokerContactRecord.Account = guarantorAccountRecord;
        brokerContactRecord.MailingCity = 'TEST';
        brokerContactRecord.MailingState = 'CA';
        brokerContactRecord.MailingStreet = 'Test Address';
        brokerContactRecord.MailingPostalCode = '22222';
        brokerContactRecord.MailingCountry = 'USA';
        brokerContactRecord.Last_Consumer_Credit_Pull__c = Date.newInstance(2020, 01, 02);
        brokerContactRecord.Last_Date_of_Inquiry__c = Date.newInstance(2020, 01, 02);
        brokerContactRecord.FICO_MKT__c = 22;
        brokerContactRecord.Reasons_for_Credit_Score__c = 'Time in Business';

        Contact partyContactRecord = new Contact();
        partyContactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        partyContactRecord.FirstName = 'Party Test';
        partyContactRecord.LastName = 'Can Party';
        partyContactRecord.Email = 'cancapitalparty@test.com';
        partyContactRecord.MailingCity = 'TEST';
        partyContactRecord.MailingState = 'CA';
        partyContactRecord.MailingStreet = 'Test Address';
        partyContactRecord.MailingPostalCode = '22222';
        partyContactRecord.MailingCountry = 'USA';
        partyContactRecord.Last_Consumer_Credit_Pull__c = Date.newInstance(2020, 01, 02);
        partyContactRecord.Last_Date_of_Inquiry__c = Date.newInstance(2020, 01, 02);
        partyContactRecord.FICO_MKT__c = 22;
        partyContactRecord.Reasons_for_Credit_Score__c = 'Time in Business';

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Broker_Contact__c = brokerContactRecord.Id;
        application.Broker_Contact__r = brokerContactRecord;
        application.genesis__Account__c = guarantorAccountRecord.Id;
        application.genesis__Account__r = guarantorAccountRecord;
        application.Business_Start_Date__c = Date.Today();
        application.Decline_Reasons__c = 'Time In Business';
        application.Primary_Guarantor__c = partyContactRecord.Id;
        application.Primary_Guarantor__r = partyContactRecord;
        application.AAN_Letter_Sent__c = false;
        application.Electronic_Consent_Check__c = true;
        application.Auto_Renewed__c = false;
        application.Is_EIS_Renewal__c = false;
        application.Last_Status_Update_Date__c = GeneralHelper.currentSystemDate;

        clcommon__Party_Type__c partyType = new clcommon__Party_Type__c();
        partyType.Name = 'GUARANTOR';

        clcommon__Party__c party = new clcommon__Party__c();
        party.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        party.genesis__Application__c = application.Id;
        party.genesis__Application__r = application;
        party.Competitor_Amount__c = 4000;
        party.clcommon__Contact__c = partyContactRecord.Id;
        party.clcommon__Contact__r = partyContactRecord;
        party.clcommon__Type__r = partyType;
        party.clcommon__Type__c = partyType.Id;
        party.clcommon__isPrimary__c = true;

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = new List<clcommon__Party__c>{party};
        AANNotificationManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        Credit_Report_Detail__c creditReportDetail = new Credit_Report_Detail__c();
        creditReportDetail.Contact__c = partyContactRecord.Id;
        creditReportDetail.Contact__r = partyContactRecord;
        creditReportDetail.Personal_FICO_Score__c = 100;
        creditReportDetail.Score_Factor_Code__c = '10,14,33';

        Map<String, Credit_Score_Factor_Reason_Mapping__mdt> reasonCodeMap = new Map<String, Credit_Score_Factor_Reason_Mapping__mdt>();
        Credit_Score_Factor_Reason_Mapping__mdt reasonCodeMapping = new Credit_Score_Factor_Reason_Mapping__mdt();
        reasonCodeMapping.Reason__c = 'Reason1';
        reasonCodeMap.put('10', reasonCodeMapping);
        CustomMetaDataHelper.reasonCodeMap = reasonCodeMap;

        DBManagerTestsStub applicationDBInstance = new DBManagerTestsStub();
        applicationDBInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        AANNotificationManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBInstance);


        DBManagerTestsStub contactDBInstance = new DBManagerTestsStub();
        contactDBInstance.genericReturnObject = new List<Contact>{partyContactRecord};
        AANNotificationManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBInstance);

        DBManagerTestsStub accountDBInstance = new DBManagerTestsStub();
        accountDBInstance.genericReturnObject = new List<Account>{guarantorAccountRecord};
        AANNotificationManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBInstance);

        DBManagerTestsStub creditReportDetailDBStubInstance = new DBManagerTestsStub();
        creditReportDetailDBStubInstance.genericReturnObject = new List<Credit_Report_Detail__c>{creditReportDetail};
        AANNotificationManager.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, creditReportDetailDBStubInstance);

        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>();
        applicationMap.put(application.Id, application);

        Test.startTest();
            AANNotificationManager.sendAANNotification(applicationMap);
        Test.stopTest();

        System.assertEquals(1, applicationDBInstance.forUpdateSObjects.size());
        System.assertEquals(true, application.AAN_Letter_Sent__c);
    }

    @isTest
    private static void sendAANNotificationToGuarantor() {

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Document documentRecord = new Document();
        documentRecord.Name = 'Dummy File';
        documentRecord.DeveloperName = 'CAN_CAPITAL_IMAGE';
        documentRecord.Body = Blob.valueOf('Dummy File Body');
        documentRecord.FolderId = TestUtility.getFakeId(Folder.getSObjectType());
        documentRecord.Type = 'txt';
        documentRecord.ContentType = 'test';
        documentRecord.Id = TestUtility.getFakeId(Document.getSObjectType());

        Contact cbpContact = new Contact();
        cbpContact.FirstName = 'credit Report Test';
        cbpContact.LastName = 'Can credit Report';
        cbpContact.MailingCity = 'TEST';
        cbpContact.MailingState = 'CA';
        cbpContact.MailingStreet = 'Test Address';
        cbpContact.MailingPostalCode = '22222';
        cbpContact.MailingCountry = 'USA';
        cbpContact.Last_Consumer_Credit_Pull__c = Date.newInstance(2020, 01, 02);
        cbpContact.Last_Date_of_Inquiry__c = Date.newInstance(2020, 01, 02);
        cbpContact.FICO_MKT__c = 22;
        cbpContact.Reasons_for_Credit_Score__c = 'Time in Business';
        cbpContact.Email = 'test@hm.com';

        clcommon__Party__c party = new clcommon__Party__c();
        party.clcommon__Contact__r = cbpContact;

        EmailTemplate template = new EmailTemplate();
        template.isActive = true;
        template.Name = 'name';
        template.DeveloperName = 'AAN_Notification_To_Guarantor';
        template.TemplateType = 'text';
        template.FolderId = UserInfo.getUserId();
        template.body = '{{CONTACT_NAME}}{{TRANSACTION_DATE}}{{TRANSACTION_AMOUNT}}{{CAN_CAPITAL_EMPLOYEE_NAME}}{{CAN_CAPITAL_EMPLOYEE_TITLE}}{{CAN_CAPITAL_EMPLOYEE_EMAIL}}{{CAN_CAPITAL_EMPLOYEE_PHONE}}';
        template.subject = '{{CONTACT_NAME}}';
        template.HtmlValue = '{{CONTACT_NAME}}{{TRANSACTION_DATE}}{{TRANSACTION_AMOUNT}}{{CAN_CAPITAL_EMPLOYEE_NAME}}{{CAN_CAPITAL_EMPLOYEE_TITLE}}{{CAN_CAPITAL_EMPLOYEE_EMAIL}}{{CAN_CAPITAL_EMPLOYEE_PHONE}}';

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = new List<clcommon__Party__c>{party};
        AANNotificationManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

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

        DBManagerTestsStub emailDBStubInstance = new DBManagerTestsStub();
        emailDBStubInstance.genericReturnObject = new List<Messaging.SendEmailResult>{sendEmailResult[0]};
        AANNotificationManager.emailDBInstance = (EmailDB) Test.createStub(EmailDB.class, emailDBStubInstance);

        DBManagerTestsStub documentDBInstance = new DBManagerTestsStub();
        documentDBInstance.genericReturnObject = new List<Document>{documentRecord};
        AANNotificationManager.documentDBInstance = (DocumentDB) Test.createStub(DocumentDB.class, documentDBInstance);

        DBManagerTestsStub emailTemplateDBInstance = new DBManagerTestsStub();
        emailTemplateDBInstance.genericReturnObject = new List<EmailTemplate>{template};
        AANNotificationManager.emailTemplateDBInstance = (EmailTemplateDB) Test.createStub(EmailTemplateDB.class, emailTemplateDBInstance);

        String templateByName = 'AAN_Notification_To_Guarantor';
        List<String> reasonCodes = new List<String>{'10', '14', '19'};
        Decimal experianCreditScore = 330;

        Test.startTest();
            AANNotificationManager.sendAANNotificationsToGuarantor(party, templateByName, emailList, experianCreditScore, reasonCodes);
        Test.stopTest();

        System.assertEquals(true, sendEmailResult.get(0).isSuccess());
    }

    @isTest
    private static void sendAANNotificationForAbondonApplication() {

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);

        clcommon__Legal_Entity__c legalEntity = new clcommon__Legal_Entity__c();
        legalEntity.clcommon__Legal_Entity_Type__c = 'Sole Proprietorship';
        legalEntity.Name = 'Test Legal Entity';

        Account guarantorAccountRecord = new Account();
        guarantorAccountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());
        guarantorAccountRecord.BillingCity='delhi';
        guarantorAccountRecord.BillingStreet='Street';
        guarantorAccountRecord.BillingState='State';
        guarantorAccountRecord.BillingPostalCode='678905';
        guarantorAccountRecord.BillingCountry='India';
        guarantorAccountRecord.Merchant_ID__c = '12345';
        guarantorAccountRecord.Industry = 'Textile';
        guarantorAccountRecord.clcommon__Legal_Entity_Type__c = legalEntity.Id;
        guarantorAccountRecord.Business_Name__c = 'Test Business';
        guarantorAccountRecord.Doing_Business_As_Name__c = 'Test';

        Contact brokerContactRecord = new Contact();
        brokerContactRecord.FirstName = 'Broker Test';
        brokerContactRecord.LastName = 'CanCapital';
        brokerContactRecord.AccountId = guarantorAccountRecord.Id;
        brokerContactRecord.Account = guarantorAccountRecord;
        brokerContactRecord.MailingCity = 'TEST';
        brokerContactRecord.MailingState = 'CA';
        brokerContactRecord.MailingStreet = 'Test Address';
        brokerContactRecord.MailingPostalCode = '22222';
        brokerContactRecord.MailingCountry = 'USA';
        brokerContactRecord.Last_Consumer_Credit_Pull__c = Date.newInstance(2020, 01, 02);
        brokerContactRecord.Last_Date_of_Inquiry__c = Date.newInstance(2020, 01, 02);
        brokerContactRecord.FICO_MKT__c = 22;
        brokerContactRecord.Reasons_for_Credit_Score__c = 'Time in Business';

        Contact partyContactRecord = new Contact();
        partyContactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        partyContactRecord.FirstName = 'Party Test';
        partyContactRecord.LastName = 'Can Party';
        partyContactRecord.Email = 'cancapitalparty@test.com';
        partyContactRecord.MailingCity = 'TEST';
        partyContactRecord.MailingState = 'CA';
        partyContactRecord.MailingStreet = 'Test Address';
        partyContactRecord.MailingPostalCode = '22222';
        partyContactRecord.MailingCountry = 'USA';
        partyContactRecord.Last_Consumer_Credit_Pull__c = Date.newInstance(2020, 01, 02);
        partyContactRecord.Last_Date_of_Inquiry__c = Date.newInstance(2020, 01, 02);
        partyContactRecord.FICO_MKT__c = 22;
        partyContactRecord.Reasons_for_Credit_Score__c = 'Time in Business';

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Abandon_Application__c" : "true"}', genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Broker_Contact__c = brokerContactRecord.Id;
        application.Broker_Contact__r = brokerContactRecord;
        application.genesis__Account__c = guarantorAccountRecord.Id;
        application.genesis__Account__r = guarantorAccountRecord;
        application.Business_Start_Date__c = Date.Today();
        application.Decline_Reasons__c = 'Time In Business';
        application.Primary_Guarantor__c = partyContactRecord.Id;
        application.Primary_Guarantor__r = partyContactRecord;
        application.AAN_Letter_Sent__c = false;
        application.Electronic_Consent_Check__c = true;
        application.Auto_Renewed__c = false;
        application.Is_EIS_Renewal__c = false;
        application.Last_Status_Update_Date__c = GeneralHelper.currentSystemDate;

        clcommon__Party_Type__c partyType = new clcommon__Party_Type__c();
        partyType.Name = 'GUARANTOR';

        clcommon__Party__c party = new clcommon__Party__c();
        party.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        party.genesis__Application__c = application.Id;
        party.genesis__Application__r = application;
        party.Competitor_Amount__c = 4000;
        party.clcommon__Contact__c = partyContactRecord.Id;
        party.clcommon__Contact__r = partyContactRecord;
        party.clcommon__Type__r = partyType;
        party.clcommon__Type__c = partyType.Id;
        party.clcommon__isPrimary__c = true;

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = new List<clcommon__Party__c>{party};
        AANNotificationManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        Credit_Report_Detail__c creditReportDetail = new Credit_Report_Detail__c();
        creditReportDetail.Contact__c = partyContactRecord.Id;
        creditReportDetail.Contact__r = partyContactRecord;
        creditReportDetail.Personal_FICO_Score__c = 100;
        creditReportDetail.Score_Factor_Code__c = '10,14,33';

        Map<String, Credit_Score_Factor_Reason_Mapping__mdt> reasonCodeMap = new Map<String, Credit_Score_Factor_Reason_Mapping__mdt>();
        Credit_Score_Factor_Reason_Mapping__mdt reasonCodeMapping = new Credit_Score_Factor_Reason_Mapping__mdt();
        reasonCodeMapping.Reason__c = 'Reason1';
        reasonCodeMap.put('10', reasonCodeMapping);
        CustomMetaDataHelper.reasonCodeMap = reasonCodeMap;

        DBManagerTestsStub applicationDBInstance = new DBManagerTestsStub();
        applicationDBInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        AANNotificationManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBInstance);


        DBManagerTestsStub contactDBInstance = new DBManagerTestsStub();
        contactDBInstance.genericReturnObject = new List<Contact>{partyContactRecord};
        AANNotificationManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBInstance);

        DBManagerTestsStub accountDBInstance = new DBManagerTestsStub();
        accountDBInstance.genericReturnObject = new List<Account>{guarantorAccountRecord};
        AANNotificationManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBInstance);

        DBManagerTestsStub creditReportDetailDBStubInstance = new DBManagerTestsStub();
        creditReportDetailDBStubInstance.genericReturnObject = new List<Credit_Report_Detail__c>{creditReportDetail};
        AANNotificationManager.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, creditReportDetailDBStubInstance);

        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>();
        applicationMap.put(application.Id, application);

        Test.startTest();
            AANNotificationManager.sendAANNotification(applicationMap);
        Test.stopTest();

        System.assertEquals(1, applicationDBInstance.forUpdateSObjects.size());
        System.assertEquals(true, application.Abandoned_Application_AAN_Sent__c);
    }
}