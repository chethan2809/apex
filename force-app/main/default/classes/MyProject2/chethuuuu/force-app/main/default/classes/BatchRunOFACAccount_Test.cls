@isTest
public class BatchRunOFACAccount_Test {

    @isTest
    static void batchTest(){

        ofacchecker__OFAC_Settings__c oSetting = new ofacchecker__OFAC_Settings__c();
        oSetting.Name = 'ThrottlingTimeLimit';
        oSetting.ofacchecker__Value__c = '750';
        oSetting.Name = 'NextOFACAccountBatchRunTime';
        oSetting.ofacchecker__Value__c = '10';
        insert oSetting;

        Account oAccount = TestUtility.generateAccount();
        oAccount.Name = 'Test Account';
        insert oAccount;

        test.startTest();
        BatchRunOFACAccount acc = new BatchRunOFACAccount('Select Id,Name from Account where Name = \'Test Account\'');
        Database.executeBatch(acc);
        test.stopTest();
    }
}