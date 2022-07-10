@isTest
private class BorrowerBankAccountViewerCtrlTests {

    @TestSetup
    static void makeData(){
        TestUtility.runSetupData();
        genesis__Applications__c application = TestUtility.createApplication();
    }

    @isTest
    static void getApplicationById() {
        genesis__Applications__c application = [
            SELECT Id
            FROM genesis__Applications__c
            LIMIT 1
        ];

        Test.startTest();
        Map<String, Object> applicationMap = BorrowerBankAccountViewerCtrl.getApplicationById(application.Id);
        Test.stopTest();

        System.assert(!applicationMap.isEmpty());
    }

    @isTest
    static void getApplicationByIdWhenNoAppFound() {
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Exception ex;

        Test.startTest();
        try {
            Map<String, Object> applicationMap = BorrowerBankAccountViewerCtrl.getApplicationById(applicationId);
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

        System.assert(ex != null);
    }

    @isTest
    static void getBankAccountDetailsByAccountId() {
        Account accountRecord = [
            SELECT Id, Name
            FROM Account
            LIMIT 1
        ];

        Test.startTest();
        List<Object> bankAccountObjectList = BorrowerBankAccountViewerCtrl.getBankAccountDetailsByAccountId(accountRecord.Id);
        Test.stopTest();

        System.assertEquals(1, bankAccountObjectList.size());
    }

    @isTest
    static void createBankAccount() {
        Account accountRecord = [
            SELECT Id, Name
            FROM Account
            LIMIT 1
        ];

        Map<String, Object> bankAccountMap = new Map<String, Object>();
        bankAccountMap.put('sObject', 'loan__Bank_Account__c');
        bankAccountMap.put('loan__Bank_Name__c', 'CHASE BANK');
        bankAccountMap.put('loan__Account_Type__c', 'Saving');
        bankAccountMap.put('loan__Active__c', true);
        bankAccountMap.put('loan__Bank_Account_Number__c', 111111111);
        bankAccountMap.put('loan__Routing_Number__c', 111111111);
        bankAccountMap.put('loan__Account__c', accountRecord.Id);

        Test.startTest();
            String response = BorrowerBankAccountViewerCtrl.createBankAccount(bankAccountMap);
        Test.stopTest();

        System.assertEquals('Success', response);
    }

    @isTest
    static void createBankAccountException() {
        Account accountRecord = [
            SELECT Id, Name
            FROM Account
            LIMIT 1
        ];

        Map<String, Object> bankAccountMap = new Map<String, Object>();
        bankAccountMap.put('sObject', 'loan__Bank_Account__c');
        bankAccountMap.put('loan__Routing_Number__c', 111);
        bankAccountMap.put('loan__Account__c', accountRecord.Id);

        Test.startTest();
            String response = BorrowerBankAccountViewerCtrl.createBankAccount(bankAccountMap);
        Test.stopTest();

        System.assertNotEquals('Success', response);
    }

    @isTest
    static void updateBankAccount() {
        Account accountRecord = [
            SELECT Id, Name
            FROM Account
            LIMIT 1
        ];

        loan__Bank_Account__c bankAccount = TestUtility.generateBankAccount(
            null, accountRecord.Id
        );
        insert bankAccount;

        Map<Object, Object> bankAccountMap = new Map<Object, Object>();
        bankAccountMap.put('Id', bankAccount.Id);
        bankAccountMap.put('loan__Bank_Account_Number__c', 111111111);
        bankAccountMap.put('loan__Routing_Number__c', 111111111);

        List<Object> objectList = new List<Object> {bankAccountMap};

        Test.startTest();
            String response = BorrowerBankAccountViewerCtrl.updateBankAccount(objectList);
        Test.stopTest();

        System.assertEquals('Success', response);
    }

    @isTest
    static void updateBankAccountException() {
        Account accountRecord = [
            SELECT Id, Name
            FROM Account
            LIMIT 1
        ];

        loan__Bank_Account__c bankAccount = TestUtility.generateBankAccount(
            null, accountRecord.Id
        );
        insert bankAccount;

        Map<Object, Object> bankAccountMap = new Map<Object, Object>();
        bankAccountMap.put('Id', bankAccount.Id);
        bankAccountMap.put('loan__Routing_Number__c', 111);
        List<Object> objectList = new List<Object> {bankAccountMap};

        Test.startTest();
            String response = BorrowerBankAccountViewerCtrl.updateBankAccount(objectList);
        Test.stopTest();

        System.assertNotEquals('Success', response);
    }

    @isTest
    static void assignBankAccountToApplication() {
        genesis__Applications__c application = [
            SELECT Id, genesis__Account__c
            FROM genesis__Applications__c
            LIMIT 1
        ];

        loan__Bank_Account__c bankAccount = TestUtility.generateBankAccount(
            null, application.genesis__Account__c
        );
        insert bankAccount;

        Test.startTest();
            String response = BorrowerBankAccountViewerCtrl.assignBankAccountToApplication(application.Id, bankAccount.Id);
        Test.stopTest();

        System.assertEquals('Success', response);
    }

    @isTest
    static void assignBankAccountToApplicationException() {
        genesis__Applications__c application = [
            SELECT Id, genesis__Account__c
            FROM genesis__Applications__c
            LIMIT 1
        ];

        Id bankAccountId =  TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        Test.startTest();
            String response = BorrowerBankAccountViewerCtrl.assignBankAccountToApplication(application.Id, bankAccountId);
        Test.stopTest();

        System.assertNotEquals('Success', response);
    }

}