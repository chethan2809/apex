@isTest
public class OnDemandDisbursementACHFileGenJobTests {

    @TestSetup
    static void makeData(){
        TestUtility.runSetupData();
        TestUtility.createContract();
    }

    @isTest
    private static void onDemandDisbursementACHFileGenJob (){

        loan__Loan_Disbursal_Transaction__c disbursalTransaction = [
            SELECT Id, loan__Disbursal_Date__c, loan__Cleared__c, loan__Reversed__c, loan__Loan_Account__c, loan__Loan_Account__r.name
            FROM loan__Loan_Disbursal_Transaction__c LIMIT 1
        ];

        loan__Disbursal_Txn_Distribution__c disbursalDistributionTxn = new loan__Disbursal_Txn_Distribution__c(loan__Loan_Disbursal_Transaction__c = disbursalTransaction.Id);
        disbursalDistributionTxn.loan__Loan_Disbursal_Transaction__c = disbursalTransaction.Id;
        disbursalDistributionTxn.loan__Distribution_Amount__c = 10000;
        disbursalDistributionTxn.loan__Reversed__c = false;
        disbursalDistributionTxn.Funded_Source__c = 'Merchant';
        disbursalDistributionTxn.loan__Sent_To_ACH_On__c = GeneralHelper.currentSystemDate;
        disbursalDistributionTxn.loan__Name_of_Entity__c = disbursalTransaction.loan__Loan_Account__r.name;
        insert disbursalDistributionTxn;

        Exception ex;

        Test.startTest();
        try{
            OnDemandDisbursementACHFileGenJob demandJob = new OnDemandDisbursementACHFileGenJob();
            Database.executeBatch(demandJob, 200);
        }
        catch(Exception e) {
            ex = e;
        }
        Test.stopTest();

        System.assertEquals(false, disbursalDistributionTxn.loan__Sent_to_ACH__c);
    }
}