@isTest(isParallel=true)
private class TestPartnerDocumentUploadManager {

    @isTest
    static void uploadDocument () {
        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());
        account.Name = 'TestPartnerCal';
        account.Partner_API_Key__c = GeneralHelper.generateUniqueReferenceId(account.Id);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{account};
        PartnerAPIHelpers.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Contact contact = new Contact();
        contact.LastName = 'test';
        contact.AccountId = account.Id;
        contact.Id = TestUtility.getFakeId(Contact.getSObjectType());

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact>{contact};
        PartnerAPIHelpers.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        Map<String, String> testUserMap = new Map<String, String>();
        testUserMap.put('Id', TestUtility.getFakeId(User.getSObjectType()));
        testUserMap.put('ContactId', contact.Id);
        testUserMap.put('AccountId', contact.AccountId);
        testUserMap.put('Email', 'no@email.com');
        String strUser = JSON.serialize(testUserMap);
        User testUser = (User) JSON.deserialize(strUser, User.class);

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User>{testUser};
        PartnerAPIHelpers.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        Map<String, String> applicationMap = new Map<String, String>();
        applicationMap.put('Id', TestUtility.getFakeId(genesis__Applications__c.getSObjectType()));
        applicationMap.put('Name', 'APP-0000000678');
        applicationMap.put('Broker_Contact__c', testUser.ContactId);
        applicationMap.put('genesis__Status__c', Applications.STATUS_APPROVED);
        applicationMap.put('Overall_Status__c', Applications.STATUS_APPROVED);
        String jsonString = JSON.serialize(applicationMap);
        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(jsonString, genesis__Applications__c.class);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        PartnerAPIHelpers.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        clcommon__Document_Definition__c documentDefinition = new clcommon__Document_Definition__c();
        documentDefinition.Name = 'Bank Statements';
        documentDefinition.clcommon__Active__c = true;
        documentDefinition.Id = TestUtility.getFakeId(clcommon__Document_Definition__c.getSObjectType());

        clcommon__Document_Category__c documentCategory = new clcommon__Document_Category__c();
        documentCategory.clcommon__Category_Name__c = 'Bank Statements';
        documentCategory.genesis__Application__c = application.Id;
        documentCategory.Id = TestUtility.getFakeId(clcommon__Document_Category__c.getSObjectType());

        DBManagerTestsStub documentCategoryDBStubInstance = new DBManagerTestsStub();
        documentCategoryDBStubInstance.genericReturnObject = new List<clcommon__Document_Category__c>{documentCategory};
        PartnerDocumentUploadManager.documentCategoryDBInstance = (DocumentCategoryDB) Test.createStub(DocumentCategoryDB.class, documentCategoryDBStubInstance);

        DBManagerTestsStub documentCategoryDBStubInstanceNew = new DBManagerTestsStub();
        documentCategoryDBStubInstanceNew.genericReturnObject = new List<clcommon__Document_Category__c>{documentCategory};
        CategoryAttachAssnManager.documentCategoryDBInstance = (DocumentCategoryDB) Test.createStub(DocumentCategoryDB.class, documentCategoryDBStubInstanceNew);

        Attachment attachment = new Attachment();
        attachment.Body = Blob.valueOf('this is test pdf content');
        attachment.Name = 'name';
        attachment.parentId = documentCategory.Id;

        DBManagerTestsStub attachmentDBStubInstance = new DBManagerTestsStub();
        attachmentDBStubInstance.genericReturnObject = new List<Attachment>{attachment};
        PartnerDocumentUploadManager.attachmentDBInstance  = (AttachmentDB) Test.createStub(AttachmentDB.class, attachmentDBStubInstance);

        clcommon__Category_Attachment_Association__c categoryAttachmentAssociation = new clcommon__Category_Attachment_Association__c();
        categoryAttachmentAssociation.Id = TestUtility.getFakeId(clcommon__Category_Attachment_Association__c.getSObjectType());

        DBManagerTestsStub categoryAttachmentAssociationDBStubInstance = new DBManagerTestsStub();
        categoryAttachmentAssociationDBStubInstance.genericReturnObject = new List<clcommon__Category_Attachment_Association__c>{categoryAttachmentAssociation};
        CategoryAttachAssnManager.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, categoryAttachmentAssociationDBStubInstance);

        RestRequest request = new RestRequest();
        request.addHeader('httpMethod', 'POST');
        request.requestUri = '/services/apexrest/v1/partner/uploaddocs/';
        request.addParameter('application', application.Name);
        request.addParameter('partnerEmail', testUser.Email);
        request.addParameter('partnerAPIKey', account.Partner_API_Key__c);
        request.addParameter('name','test123.pdf');
        request.addParameter('documentType','Bank Statements');
        request.addParameter('contentType','application/pdf');

        request.requestBody = Blob.valueOf('this is test pdf content');

        Test.startTest();
            PartnerDocumentUploadManager.uploadDocument(request);
        Test.stopTest();

        System.assertEquals(1, attachmentDBStubInstance.forInsertSObjects.size());
        System.assertEquals('test123.pdf', ((Attachment)attachmentDBStubInstance.forInsertSObjects.get(0)).Name);
    }
}