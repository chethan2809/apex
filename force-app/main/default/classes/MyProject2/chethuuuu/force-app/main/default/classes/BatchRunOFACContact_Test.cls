@isTest
public class BatchRunOFACContact_Test {

    @isTest
    static void batchTest(){

        ofacchecker__OFAC_Settings__c oSetting = new ofacchecker__OFAC_Settings__c();
        oSetting.Name = 'ThrottlingTimeLimit';
        oSetting.ofacchecker__Value__c = '750';
        oSetting.Name = 'NextOFACContactBatchRunTime';
        oSetting.ofacchecker__Value__c = '10';
        insert oSetting;

        Account oAccount = TestUtility.generateAccount();
        oAccount.Name = 'Test Account';
        insert oAccount;

        Contact oContact = TestUtility.generateContact();
        oContact.FirstName = 'Marisol';
        oContact.LastName = 'Testcase';
        oContact.AccountId = oAccount.Id;
        insert oContact;

        test.startTest();
        BatchRunOFACContact acc = new BatchRunOFACContact('Select Id,FirstName,LastName,Name from Contact where FirstName = \'Marisol\'');
        Database.executeBatch(acc);
        test.stopTest();
    }
}