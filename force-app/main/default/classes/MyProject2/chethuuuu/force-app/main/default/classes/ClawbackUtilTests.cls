@isTest
public class ClawbackUtilTests {

    @TestSetup
    static void makeData(){
        TestUtility.runSetupData();

        loan__Loan_Payment_Spread__c canPaymentSpread =  new loan__Loan_Payment_Spread__c();
        canPaymentSpread.Name = 'CAN Payment Spread';
        insert canPaymentSpread;
        loan__Loan_Account__c contract = TestUtility.createContract();

    }

    @isTest
    public static void processClawBackTestMethod(){

        List<loan__Loan_Account__c> contract = new List<loan__Loan_Account__c>();
        Map<Id,loan__Loan_Account__c> loanAccountMap = new Map<Id,loan__Loan_Account__c>();

        contract = [SELECT id,loan__Account__c,Broker_Contact__c,Application__c,Application__r.Primary_Guarantor__c
                    FROM loan__Loan_Account__c];
        contract[0].Broker_Contact__c = contract[0].Application__r.Primary_Guarantor__c;
        update contract[0];

        Account acc = [SELECT id,loan__Broker__c
                       FROM Account
                       WHERE id =:contract[0].loan__Account__c
                       LIMIT 1];
        acc.loan__Broker__c = true;
        update acc;

        Contact cont = [SELECT id
                        FROM Contact
                        WHERE id =:contract[0].Broker_Contact__c
                        LIMIT 1];
        cont.AccountId = acc.id;
        update cont;
        Set<Id> brokerAccountIds = new Set<Id>();

		List<loan__Loan_Account__c> contract1 = new List<loan__Loan_Account__c>();
        contract1 = [SELECT id,loan__Account__c,Broker_Contact__c,Application__c,Application__r.Primary_Guarantor__c,
                     		Broker_Contact__r.AccountId
                     FROM loan__Loan_Account__c];
        loanAccountMap.put(contract1[0].Id, contract1[0]);
        brokerAccountIds.add(contract1[0].loan__Account__c);

        loan__Broker__c broker = new loan__Broker__c();
        broker.loan__Account__c = contract[0].loan__Account__c;
        broker.loan__Lending_Account__c = contract[0].Id;
		broker.Loan__Commission_Amount__c = 100;
		broker.Is_Bonus_Payment__c = false;
		broker.Is_Clawback__c = false;
        broker.Commission_Point__c = 50;
       	insert broker;

        Test.startTest();
        	ClawbackUtil.processClawBack(loanAccountMap,brokerAccountIds);
        Test.stopTest();

		System.assert(contract != Null);
        System.assertEquals(100, broker.Loan__Commission_Amount__c);
    }

    @isTest
    public static void updateTotalClawbackAmountMethod(){

        Account brokerAccount = [Select id
                                 FROM Account
                                 LIMIT 1];

        List<Clawback__c> clawbackLst = new List<Clawback__c>();
       	Clawback__c clawback = new Clawback__c(
        		Broker_Account__c = brokerAccount.Id,
                Clawback_Amount__c = 100
       	);
        clawbackLst.add(clawback);

        Account accRec = new Account();
        	accRec.Total_Clawback_Amount__c = 0;

        Test.startTest();
        	ClawbackUtil.updateTotalClawbackAmount(clawbackLst);
        Test.stopTest();

        System.assert(clawbackLst != Null);
        System.assertEquals(0, accRec.Total_Clawback_Amount__c);
    }
}