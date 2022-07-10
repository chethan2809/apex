@isTest
private class PromiseToPayTriggerTests {

    @isTest
    private static void afterInsertUpdatePromiseToPay() {
        CAN_General_Settings__c generalSetting = new CAN_General_Settings__c();
        generalSetting.Name='test';
        generalSetting.Disable_Promise_To_Pay_Trigger__c = false;
        insert generalSetting;

        collect__Promise_To_Pay__c promiseToPay = new collect__Promise_To_Pay__c();
        promiseToPay.collect__Promise_Broken__c = true;
        promiseToPay.collect__Promise_To_Pay_Amount__c = 12;
        promiseToPay.collect__Promise_To_Pay_Date__c = Date.today();

        Exception ex;
        Test.startTest();
        try{
            insert promiseToPay;
        }
        catch(Exception e) {
            ex = e;
        }
        Test.stopTest();

        promiseToPay.collect__Promise_To_Pay_Amount__c = 20;
        update promiseToPay;

        List<collect__Promise_To_Pay__c> promiseToPayList = [
            SELECT Id, collect__Promise_To_Pay_Amount__c
            FROM collect__Promise_To_Pay__c
        ];

        System.assert(promiseToPay.Id != null);
        System.assertEquals(1, promiseToPayList.size());
        System.assertEquals(20, promiseToPayList[0].collect__Promise_To_Pay_Amount__c);
    }

    @isTest
    private static void generalSettingDisableTriggerTrue() {
        CAN_General_Settings__c generalSetting = new CAN_General_Settings__c();
        generalSetting.Name='test';
        generalSetting.Disable_Promise_To_Pay_Trigger__c = true;
        insert generalSetting;

        collect__Promise_To_Pay__c promiseToPay = new collect__Promise_To_Pay__c();
        promiseToPay.collect__Promise_Broken__c = true;
        promiseToPay.collect__Promise_To_Pay_Amount__c = 12;
        promiseToPay.collect__Promise_To_Pay_Date__c = Date.today();

        Exception ex;
        Test.startTest();
        try{
            insert promiseToPay;
        }
        catch(Exception e) {
            ex = e;
        }
        Test.stopTest();

        promiseToPay.collect__Promise_To_Pay_Amount__c = 20;
        update promiseToPay;

        List<collect__Promise_To_Pay__c> promiseToPayList = [
            SELECT Id, collect__Promise_To_Pay_Amount__c
            FROM collect__Promise_To_Pay__c
        ];

        System.assert(promiseToPay.Id != null);
        System.assertEquals(1, promiseToPayList.size());
        System.assertEquals(20, promiseToPayList[0].collect__Promise_To_Pay_Amount__c);

        List<CAN_General_Settings__c> canGeneralSettings = [
            SELECT Id, Disable_Promise_To_Pay_Trigger__c
            FROM CAN_General_Settings__c
        ];

        System.assert(generalSetting.Id != null);
        System.assertEquals(1, canGeneralSettings.size());
        System.assertEquals(generalSetting.Disable_Promise_To_Pay_Trigger__c, canGeneralSettings[0].Disable_Promise_To_Pay_Trigger__c);
    }
}