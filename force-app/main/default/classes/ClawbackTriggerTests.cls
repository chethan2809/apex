@isTest
public class ClawbackTriggerTests {

    @isTest
    public static void ClawbackTriggerTestMethod(){

        Account brokerAccount = new Account();
        brokerAccount = TestUtility.createAccount();

       	Clawback__c clawback = new Clawback__c(
        	Broker_Account__c = brokerAccount.Id,
            Clawback_Amount__c = 100
       );

        Test.startTest();
        	insert clawback;
        Test.StopTest();

        system.assert(clawback != Null);
        system.assertEquals(100, clawback.Clawback_Amount__c);
    }
}