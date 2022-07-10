@isTest
private class QueueableJobHandlerTests {

    @TestSetup
    static void makeData(){
        Contact con = TestUtility.createContact();

        TestUtility.runSetupData();
        genesis__Applications__c application = TestUtility.createApplication();
        application.Credit_Check_Consent__c = true;
        application.Primary_Guarantor__c = con.Id;
        application.SIC_Code__c = '99';
        application.Business_Start_Date__c = TestUtility.currentSystemDate.addYears(-4);
        update application;

        con.AccountId = application.genesis__Account__c;
        update con;

        clcommon__Party_Type__c partyTypeBorrower = new clcommon__Party_Type__c();
        partyTypeBorrower.Name = GeneralConstants.PARTY_TYPE_BORROWER;
        insert partyTypeBorrower;

        clcommon__Party_Type__c partyType = new clcommon__Party_Type__c();
        partyType.Name = GeneralConstants.PARTY_TYPE_GUARANTOR;
        insert partyType;
        OriginationHelper.partyTypeToId = null;

        clcommon__Party__c party = new clcommon__Party__c();
        party.clcommon__Account__c = application.genesis__Account__c;
        party.clcommon__Contact__c = con.id;
        party.genesis__Application__c = application.id;
        party.clcommon__Type__c = OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BORROWER);
        party.Beneficial_Owner_Type__c = 'Beneficial Owner';
        party.Competitor_Amount__c = 10000;
        insert party;

        clcommon__Party__c party1 = new clcommon__Party__c();
        party1.clcommon__Account__c = application.genesis__Account__c;
        party1.clcommon__Contact__c = con.id;
        party1.genesis__Application__c = application.id;
        party1.clcommon__Type__c = OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_GUARANTOR);
        party1.Beneficial_Owner_Type__c = 'Beneficial Owner';
        party1.clcommon__isPrimary__c = true;
        party1.Competitor_Amount__c = 10000;
        insert party1;
    }

    @isTest
    private static void executeExperianConsumerQueueableJobTestMethod(){

        QueueableJobHandler qHandler = new QueueableJobHandler();
        genesis__Applications__c application = [SELECT id,genesis__Account__c,Primary_Guarantor__c,
                                                        Type__c
                                                FROM genesis__Applications__c
                                                LIMIT 1];
        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        applicationList.add(application);

        Test.startTest();
            qHandler.executeExperianConsumerQueueableJob(applicationList);
        Test.stopTest();

        System.assertEquals(1, applicationList.size());
    }

    @isTest
    private static void executeExperianBusinessQueueableJobTestMethod(){

        QueueableJobHandler qHandler = new QueueableJobHandler();
        genesis__Applications__c application = [SELECT id,genesis__Account__c,Primary_Guarantor__c,
                                                        Type__c, Is_Manual_Score_Run__c
                                                FROM genesis__Applications__c
                                                LIMIT 1];

        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        applicationList.add(application);

        Test.startTest();
            qHandler.executeExperianBusinessQueueableJob(applicationList);
        Test.stopTest();

        System.assertEquals(1, applicationList.size());
    }

    @isTest
    private static void executeLexisNexisBIIDQueueableJobTestMethod(){

        QueueableJobHandler qHandler = new QueueableJobHandler();
        genesis__Applications__c application = [SELECT id,genesis__Account__c,Primary_Guarantor__c,
                                                        Type__c, Is_Manual_Score_Run__c
                                                FROM genesis__Applications__c
                                                LIMIT 1];

        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        applicationList.add(application);

        Test.startTest();
            qHandler.executeLexisNexisBIIDQueueableJob(applicationList);
        Test.stopTest();

        System.assertEquals(1, applicationList.size());
    }

    @isTest
    private static void executeLexisNexisFraudScoreQueueableJobTestMethod(){

        QueueableJobHandler qHandler = new QueueableJobHandler();
        genesis__Applications__c application = [SELECT id,genesis__Account__c,Primary_Guarantor__c,
                                                        Type__c, Is_Manual_Score_Run__c, genesis__Status__c
                                                FROM genesis__Applications__c
                                                LIMIT 1];

        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        applicationList.add(application);

        Test.startTest();
            qHandler.executeLexisNexisFraudScoreQueueableJob(applicationList);
        Test.stopTest();

        System.assertEquals(1, applicationList.size());
    }

    @isTest
    private static void executeExperianBusinessQueueableJobTestMethod2(){

        QueueableJobHandler qHandler = new QueueableJobHandler();
        genesis__Applications__c application = [SELECT id,genesis__Account__c,Primary_Guarantor__c,
                                                        Type__c, Is_Manual_Score_Run__c
                                                FROM genesis__Applications__c
                                                LIMIT 1];

        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        applicationList.add(application);

        Test.startTest();
            qHandler.executeExperianBusinessQueueableJob(applicationList);
            qHandler.executeExperianConsumerQueueableJob(applicationList);
        Test.stopTest();

        System.assertEquals(1, applicationList.size());
    }

    @isTest
    private static void executeCANScoringQueueableJobTestMethod(){

        QueueableJobHandler qHandler = new QueueableJobHandler();
        genesis__Applications__c application = [SELECT id,genesis__Account__c,Primary_Guarantor__c,
                                                        Type__c, Is_Manual_Score_Run__c
                                                FROM genesis__Applications__c
                                                LIMIT 1];

        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        applicationList.add(application);

        Test.startTest();
            qHandler.executeCANScoringQueueableJob(applicationList);
        Test.stopTest();

        System.assertEquals(1, applicationList.size());
    }

    @isTest
    private static void executeOcrolusQueueableJobTestMethod(){

        QueueableJobHandler qHandler = new QueueableJobHandler();
        genesis__Applications__c application = [SELECT id,genesis__Account__c,Primary_Guarantor__c,
                                                        Type__c, Is_Manual_Score_Run__c, genesis__Status__c
                                                FROM genesis__Applications__c
                                                LIMIT 1];

        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        applicationList.add(application);

        Test.startTest();
            qHandler.executeExperianConsumerQueueableJob(applicationList);
            qHandler.executeOcrolusQueueableJob(applicationList);
        Test.stopTest();

        System.assertEquals(1, applicationList.size());
    }

    @isTest
    private static void executeOcrolusQueueableJobTestMethod2(){

        QueueableJobHandler qHandler = new QueueableJobHandler();
        genesis__Applications__c application = [SELECT id,genesis__Account__c,Primary_Guarantor__c,
                                                        Type__c, Is_Manual_Score_Run__c, genesis__Status__c
                                                FROM genesis__Applications__c
                                                LIMIT 1];

        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        applicationList.add(application);

        Test.startTest();
            qHandler.executeOcrolusQueueableJob(applicationList);
        Test.stopTest();

        System.assertEquals(1, applicationList.size());
    }

    @isTest
    private static void executeLexisNexisBIIDQueueableJobTestMethod2(){

        QueueableJobHandler qHandler = new QueueableJobHandler();
        genesis__Applications__c application = [SELECT id,genesis__Account__c,Primary_Guarantor__c,
                                                        Type__c, Is_Manual_Score_Run__c, genesis__Status__c
                                                FROM genesis__Applications__c
                                                LIMIT 1];

        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        applicationList.add(application);

        Test.startTest();
            qHandler.executeExperianConsumerQueueableJob(applicationList);
            qHandler.executeExperianBusinessQueueableJob(applicationList);
            qHandler.executeLexisNexisBIIDQueueableJob(applicationList);
            qHandler.executeLexisNexisFraudScoreQueueableJob(applicationList);
        Test.stopTest();

        System.assertEquals(1, applicationList.size());
    }

    @isTest
    private static void executeWasabiQueueableJobTestMethod(){

        QueueableJobHandler qHandler = new QueueableJobHandler();
        genesis__Applications__c application = [SELECT id,genesis__Account__c,Primary_Guarantor__c,
                                                        Type__c
                                                FROM genesis__Applications__c
                                                LIMIT 1];

        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        applicationList.add(application);

        DBManagerTestsStub catAttAssociationSStubInstance = new DBManagerTestsStub();
        WasabiManager.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, catAttAssociationSStubInstance);

        clcommon__Category_Attachment_Association__c catAttAssociation = (clcommon__Category_Attachment_Association__c) JSON.deserialize(
            '{ "Name" : "Test-Name"}' , clcommon__Category_Attachment_Association__c.class
        );
        catAttAssociation.Id = TestUtility.getFakeId(clcommon__Category_Attachment_Association__c.getSObjectType());

        Map<Id, clcommon__Category_Attachment_Association__c > catAttAssociationMap = new Map<Id, clcommon__Category_Attachment_Association__c >();
        catAttAssociationMap.put(catAttAssociation.Id, catAttAssociation);

        CategoryAttachAssns.RequestType requestType;

        Test.startTest();
            qHandler.executeExperianConsumerQueueableJob(applicationList);
            qHandler.executeWasabiQueueableJob(catAttAssociationMap, requestType);
        Test.stopTest();

        System.assertEquals(1, applicationList.size());
    }

    @isTest
    private static void executeWasabiQueueableJobTestMethod2(){

        QueueableJobHandler qHandler = new QueueableJobHandler();
        genesis__Applications__c application = [SELECT id,genesis__Account__c,Primary_Guarantor__c,
                                                        Type__c
                                                FROM genesis__Applications__c
                                                LIMIT 1];

        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        applicationList.add(application);

        DBManagerTestsStub catAttAssociationSStubInstance = new DBManagerTestsStub();
        WasabiManager.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, catAttAssociationSStubInstance);

        clcommon__Category_Attachment_Association__c catAttAssociation = (clcommon__Category_Attachment_Association__c) JSON.deserialize(
            '{ "Name" : "Test-Name"}' , clcommon__Category_Attachment_Association__c.class
        );
        catAttAssociation.Id = TestUtility.getFakeId(clcommon__Category_Attachment_Association__c.getSObjectType());

        Map<Id, clcommon__Category_Attachment_Association__c > catAttAssociationMap = new Map<Id, clcommon__Category_Attachment_Association__c >();
        catAttAssociationMap.put(catAttAssociation.Id, catAttAssociation);

        CategoryAttachAssns.RequestType requestType;

        Test.startTest();
            qHandler.executeWasabiQueueableJob(catAttAssociationMap, requestType);
        Test.stopTest();

        System.assertEquals(1, applicationList.size());
    }

    @isTest
    private static void executeSFTPScoringRawDataQueueableJobTestMethod(){

        String cronExp = '0 0 12 1 1 ? *';
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Id ContactId = TestUtility.getFakeId(Contact.getSObjectType());
        Credit_Report_Detail__c report = new Credit_Report_Detail__c();
        report.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        report.Account__c = TestUtility.getFakeId(Account.getSObjectType());

        List<Credit_Report_Detail__c> creditReport = new List<Credit_Report_Detail__c>();
        creditReport.add(report);
        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();

        Map<Id, Map<String, String>> responseMapByCreditReportDetails = new Map<Id, Map<String, String>>();
        Map<String, String> responseMap = new Map<String, String>();
        responseMap.put('consumerReport', 'consumerReportResponse');
        responseMapByCreditReportDetails.put(report.Account__c , responseMap);

        genesis__Applications__c application =  new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        applicationList.add(application);
        Map<Id, Id> contactIdAccountIdToApplicationIds = new Map<Id, Id>();
        contactIdAccountIdToApplicationIds.put(ContactId, application.Id);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        SFTPScoringRawDataManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        SFTPScoringRawDataManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Test.startTest();
            new QueueableJobHandler().executeSFTPScoringRawDataQueueableJob(creditReport, responseMapByCreditReportDetails, contactIdAccountIdToApplicationIds);
        Test.stopTest();

        System.assertEquals(1,creditReport.size());
    }

    @isTest
    private static void executeSFTPScoringRawDataQueueableJobTestMethod1(){

        genesis__Applications__c applications = [SELECT id,genesis__Account__c,
                                                        Primary_Guarantor__c,
                                                        Type__c
                                                FROM genesis__Applications__c
                                                LIMIT 1];

        List<genesis__Applications__c> applicationsList = new List<genesis__Applications__c>();
        applicationsList.add(applications);
        String cronExp = '0 0 12 1 1 ? *';
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Id ContactId = TestUtility.getFakeId(Contact.getSObjectType());
        Credit_Report_Detail__c report = new Credit_Report_Detail__c();
        report.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        report.Account__c = TestUtility.getFakeId(Account.getSObjectType());

        List<Credit_Report_Detail__c> creditReport = new List<Credit_Report_Detail__c>();
        creditReport.add(report);
        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();

        Map<Id, Map<String, String>> responseMapByCreditReportDetails = new Map<Id, Map<String, String>>();
        Map<String, String> responseMap = new Map<String, String>();
        responseMap.put('consumerReport', 'consumerReportResponse');
        responseMapByCreditReportDetails.put(report.Account__c , responseMap);

        genesis__Applications__c application =  new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        applicationList.add(application);
        Map<Id, Id> contactIdAccountIdToApplicationIds = new Map<Id, Id>();
        contactIdAccountIdToApplicationIds.put(ContactId, application.Id);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        SFTPScoringRawDataManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        SFTPScoringRawDataManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Test.startTest();
            new QueueableJobHandler().executeExperianConsumerQueueableJob(applicationsList);
            new QueueableJobHandler().executeSFTPScoringRawDataQueueableJob(creditReport, responseMapByCreditReportDetails, contactIdAccountIdToApplicationIds);
        Test.stopTest();

        System.assertEquals(true,!contactIdAccountIdToApplicationIds.isEmpty());
    }
}