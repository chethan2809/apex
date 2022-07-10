@isTest
public class CollectionActivityTriggerTests {

    @isTest
    public static void ContractInsertMethod(){

        	collect__Collection_Activity__c colAct = new collect__Collection_Activity__c();
            colAct.Attorney_Assigned__c = 'Thompson Hine';
            colAct.Bankruptcy_Chapter__c = '7';
            colAct.Case_Number__c = 'Fake Case 7';
            colAct.collect__Account_Email__c = 'collectionActivity@gmail.com';
            colAct.collect__Action__c = 'Message';
            colAct.collect__Completed__c = False;

        	collect__Collection_Activity__c colAct2 = new collect__Collection_Activity__c();
            colAct2.Attorney_Assigned__c = 'Thompson Hine';
            colAct2.Bankruptcy_Chapter__c = '7';
            colAct2.Case_Number__c = 'Fake Case 7';
            colAct2.collect__Account_Email__c = 'collectionActivity@gmail.com';
            colAct2.collect__Action__c = 'Message';
            colAct2.collect__Completed__c = False;

        	Id userId = userinfo.getUserId();
        	CAN_General_Settings__c custSetting = new CAN_General_Settings__c();
        	custSetting.Disable_Collection_Activity_Trigger__c = true;
        	custSetting.SetupOwnerId = userId;
        	custSetting.Name = 'CAN General Settings (User)';

        Test.StartTest();
        	insert custSetting;
        	insert colAct;
        	custSetting.Disable_Collection_Activity_Trigger__c = false;
        	upsert custSetting;
        	colAct.collect__Account_Email__c = 'test.test@test.com';
        	update colAct;
        	insert colAct2;
        Test.stopTest();

		system.assert(custSetting != Null);
		system.assertEquals(False, colAct.collect__Completed__c);
        system.assertEquals('Thompson Hine',colAct2.Attorney_Assigned__c);

    }
}