@isTest
private class DBManagerTests {
    @isTest
    static void dbManagerDMLTests() {
        Contact contactRecord = TestUtility.generateContact();

        DBManager dbInstance = new DBManager();

        Exception testException;
        System.Test.startTest();
        try {
            dbInstance
                .addInsert(contactRecord)
                .executeInserts()
                .addUpdate(contactRecord)
                .executeUpdates()
                .addDelete(contactRecord)
                .executeDeletes();
        } catch (Exception e) {
            testException = e;
        }
        System.Test.stopTest();

        TestUtility.assertNullException(testException);
    }

    @isTest
    static void dBManagerDMLTestsList() {
        List<Contact> contacts = new List<Contact>{ TestUtility.generateContact() };

        DBManager dbInstance = new DBManager();

        Exception testException;
        System.Test.startTest();
        try {
            dbInstance
                .addInserts(contacts)
                .executeInserts()
                .addUpdates(contacts)
                .executeUpdates()
                .addUpdates(new Map<Id, Contact>(contacts))
                .executeUpdates()
                .addDeletes(contacts)
                .executeDeletes();
        } catch (Exception e) {
            testException = e;
        }
        System.Test.stopTest();

        TestUtility.assertNullException(testException);
    }

    @isTest
    static void dBManagerDeletesMap() {
        List<Contact> contacts = new List<Contact>{ TestUtility.generateContact() };

        DBManager dbInstance = new DBManager();

        Exception testException;
        System.Test.startTest();
        try {
            dbInstance
                .addInserts(contacts)
                .executeInserts()
                .addDeletes(new Map<Id, Contact>(contacts))
                .executeDeletes();
        } catch (Exception e) {
            testException = e;
        }
        System.Test.stopTest();

        TestUtility.assertNullException(testException);
    }

    @isTest
    static void executePartialInserts() {
        List<Contact> contacts = new List<Contact>{ TestUtility.generateContact() };

        DBManager dbInstance = new DBManager();

        Exception ex;
        DBManager.PartialResult partialResult;
        System.Test.startTest();
            try {
            partialResult = dbInstance.addInserts(contacts).executePartialInserts();
        } catch (Exception e) {
            ex = e;
        }
        System.Test.stopTest();

        TestUtility.assertNullException(ex);
        System.assertEquals(
            partialResult.sObjectList.size(),
            partialResult.saveResults.size()
        );
        System.assert(partialResult.saveResults.get(0).isSuccess());
    }

    @IsTest
    static void executePartialUpdates() {
        List<Contact> contacts = new List<Contact>{ TestUtility.generateContact() };

        DBManager dbInstance = new DBManager();
        dbInstance.addInserts(contacts).executeInserts();

        Exception testException;
        DBManager.PartialResult partialResult;

        System.Test.startTest();
        try {
            partialResult = dbInstance.addUpdates(contacts).executePartialUpdates();
        } catch (Exception e) {
            testException = e;
        }
        System.Test.stopTest();

        TestUtility.assertNullException(testException);
        System.assertEquals(
            partialResult.sObjectList.size(),
            partialResult.saveResults.size()
        );
        System.assert(partialResult.saveResults.get(0).isSuccess());
    }

    @IsTest
    static void executePartialUpserts() {
        Contact contactForInsert = new Contact();
        contactForInsert.LastName = 'test contact';
        contactForInsert.MailingState = 'IL';

        Contact newContact = TestUtility.generateContact();
        insert newContact;

        Contact contactForUpdate = newContact;
        contactForUpdate.MailingPostalCode = '12345';

        List<Contact> contactsList = new List<Contact>{
            contactForInsert, contactForUpdate
        };

        DBManager dbInstance = new DBManager();
        DBManager.PartialResult partialResult;

        Exception testException;
        System.Test.startTest();
        try {
            partialResult = dbInstance.addUpserts(contactsList).executePartialUpserts();
        } catch (Exception e) {
            testException = e;
        }
        System.Test.stopTest();

        TestUtility.assertNullException(testException);
        System.assertEquals(2, partialResult.upsertResults.size());

        Contact actualContactForInsert = [
            SELECT Id, LastName
            FROM Contact
            WHERE Id = :partialResult.upsertResults[0].Id
        ];

        Contact actualContactForUpdate = [
            SELECT Id, MailingPostalCode
            FROM Contact
            WHERE Id = :contactForUpdate.Id
        ];

        System.assertEquals(contactForInsert.LastName, actualContactForInsert.LastName);
        System.assertEquals(contactForUpdate.MailingPostalCode, actualContactForUpdate.MailingPostalCode);
    }
}