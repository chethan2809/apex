@isTest
private class LoanDisbursalTransactionTriggerTest {
    private static PaymentModeDB paymentModeDBInstance = new PaymentModeDB();
    
    @isTest
    private static void LoanDisbursalTransactionTrigger(){
        TestUtility.runSetupData();
   //loan__Loan_Account__c contract = TestUtility.createContract();
            loan__Loan_Account__c loanaccount = new loan__Loan_Account__c();
        loanaccount.id=TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
    
    loan__Payment_Mode__c mode = new loan__Payment_Mode__c();
        mode.Name = 'test1';
    insert mode;
       
      loan__Loan_Disbursal_Transaction__c disbursalTransaction = new loan__Loan_Disbursal_Transaction__c();
     disbursalTransaction.loan__Mode_of_Payment__c = mode.Id;
      disbursalTransaction.loan__Loan_Account__c = loanaccount.Id;
          disbursalTransaction.loan__Disbursed_Amt__c = 100000;
        disbursalTransaction.loan__Transaction_Creation_Date__c = date.today();
         list<loan__Loan_Disbursal_Transaction__c> loandisbursaltransaction =[
            SELECT Id, loan__Mode_of_Payment__c,loan__Loan_Account__c
             FROM loan__Loan_Disbursal_Transaction__c];
         Exception ex;
        Test.startTest();
       // try {
            insert disbursalTransaction;
            //update disbursalTransaction;
       // } catch(Exception e) {
       //   ex = e;
       // }
        Test.stopTest();
      System.assert(disbursalTransaction!= null);    
}
    
   /* @isTest
    private static void LoanDisbursalTransactionTrigger1(){
        TestUtility.runSetupData();
   loan__Loan_Account__c loanaccount = TestUtility.createContract();
    loan__Payment_Mode__c mode = new loan__Payment_Mode__c();
    insert mode;
        loan__Loan_Disbursal_Transaction__c disbursalTransaction = new loan__Loan_Disbursal_Transaction__c();
      disbursalTransaction.loan__Mode_of_Payment__c = mode.Id;
      disbursalTransaction.loan__Loan_Account__c = loanacc.Id
          disbursalTransaction.loan__Disbursed_Amt__c = 10000;
        
         Exception ex;
        Test.startTest();
        try {
            insert disbursalTransaction;
            update disbursalTransaction;
        } catch(Exception e) {
            ex = e;
        }
        Test.stopTest();
     System.assert(disbursalTransaction!= null);    
}*/

}