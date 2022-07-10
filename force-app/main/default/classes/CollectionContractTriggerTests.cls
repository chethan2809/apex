@isTest
private class CollectionContractTriggerTests {

    @isTest
    private static void contractInsertMethod(){

        collect__Loan_Account__c contractObj = new collect__Loan_Account__c ();

            contractObj.collect__ACH_On__c = False;
            contractObj.collect__Amount_to_Current__c = 100;
            contractObj.collect__Days_Past_Due__c = 200;
            contractObj.collect__Current_Payment_Amount__c = 500;
            contractObj.collect__Invalid_Data__c = false;

        Test.startTest();
            Id userId = userInfo.getUserId();
            CAN_General_Settings__c customSetting = new CAN_General_Settings__c();
            customSetting.Disable_Collection_Contract_Trigger__c = true;
            customSetting.SetupOwnerId = userId;
            customSetting.Name = 'CAN General Settings (User)';
            insert customSetting;

            CAN_General_Settings__c rec = [SELECT id,Disable_Collection_Contract_Trigger__c
                                           FROM CAN_General_Settings__c
                                           WHERE SetupOwnerId =:userId];
            rec.Disable_Collection_Contract_Trigger__c = true;
            upsert rec;
            insert contractObj;
        Test.stopTest();

        system.assert(contractObj != null);
        system.assertEquals(False, contractObj.collect__Invalid_Data__c);
    }

    @isTest
    public static void contractInsertTriggerMethod(){

        collect__Loan_Account__c contractObj = new collect__Loan_Account__c ();

            contractObj.collect__ACH_On__c = true;
            contractObj.collect__Amount_to_Current__c = 100;
            contractObj.collect__Days_Past_Due__c = 200;
            contractObj.collect__Current_Payment_Amount__c = 500;
            contractObj.collect__Invalid_Data__c = false;
            insert contractObj;

        Test.startTest();
            contractObj.collect__ACH_On__c = false;
            update contractObj;
        Test.stopTest();

        system.assert(contractObj != null);
        system.assertEquals(100, contractObj.collect__Amount_to_Current__c);
    }
}