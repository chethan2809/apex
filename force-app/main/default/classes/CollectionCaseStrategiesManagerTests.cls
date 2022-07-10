@isTest
private class CollectionCaseStrategiesManagerTests {
    @TestSetup
    static void makeData(){
        TestUtility.runSetupData();
        loan__Loan_Account__c  clContract = TestUtility.createContract();
    }

    @isTest
    private static void collectionCaseStrategiesManagerTest() {

        List<loan__Loan_Account__c> contractList = [
            SELECT Id, Name, loan__Loan_Amount__c, loan__Frequency_of_Loan_Payment__c, loan__Loan_Balance__c,
                Bank_Account__c, loan__Next_Installment_Date__c, Primary_Contact__c, loan__Account__c,
                loan__Product_Type__c, Percentage_Paid__c, Latest_Number_Of_Missed_Payments__c, loan__Loan_Status__c,
                Total_Unpaid_Due_Amount_To_Current__c, loan__Last_Payment_Date__c, loan__Disbursal_Date__c,
                loan__Expected_Disbursal_Date__c, Total_Outstanding_Repayment_Amount__c, loan__Total_Interest_Amortization_Based__c,
                loan__Disbursed_Amount__c, Remaining_Number_of_Payments__c, Return_Reason_Code__c,
                loan__Payment_Amount__c, Application__c, Application__r.Name, Return_Blocked_Account_Fee_Applied_Date__c,
                Return_Blocked_Account_Fee_Count__c, Return_ACH_Fee_Applied_Date__c, Return_ACH_Fee_Count__c,
                Is_Pre_Closure_Fee_Applied__c, Pre_Closure_Penalty_Amount__c, Outstanding_Repayment_Amount__c,
                 loan__Last_Installment_Date__c, Max_Number_Of_Missed_Payments__c, Type__c, loan__Last_Payment_Amount__c,
                loan__Last_Disbursal_Amount__c, loan__Number_of_Installments__c, loan__Delinquent_Amount__c,
                loan__Last_Disbursal_Date__c, Current_Payoff_Amount__c, loan__Previous_Installment_Date__c,
                loan__Pmt_Amt_Cur__c, loan__Principal_Remaining__c, loan__Number_of_Days_Overdue__c,
                loan__Account__r.SCRA__c, loan__Account__r.Confirmed_Fraud_Flag__c, loan__Account__r.Deceased__c,
                loan__Account__r.Cease_and_Desist__c, loan__Amount_to_Current__c, loan__Amount_Due_Till_Current__c,
                (SELECT Id, loan__Active__c, loan__CL_Contract__c FROM loan__Automated_Payment_Setup__r
                    WHERE loan__Active__c = true)
            FROM loan__Loan_Account__c
        ];

        DBManagerTestsStub collectionCaseStubInstance = new DBManagerTestsStub();
        CollectionCaseStrategiesManager.collectionCaseDBInstance = (CollectionCaseDB ) Test.createStub(CollectionCaseDB .class, collectionCaseStubInstance);

        Collection_Criteria__c collectionCriteria = new Collection_Criteria__c();
        collectionCriteria.Queue_Value__c = 1;
        collectionCriteria.Active__c = true;
        collectionCriteria.Evaluation_Criteria__c = 'SELECT Id FROM loan__Loan_Account__c';

        DBManagerTestsStub criteriaDBInstanceStubInstance = new DBManagerTestsStub();
        criteriaDBInstanceStubInstance.genericReturnObject = new List<Collection_Criteria__c> {collectionCriteria};
        CollectionCaseStrategies.collectionCriteriaDBInstance = (CollectionCriteriaDB) Test.createStub(CollectionCriteriaDB.class, criteriaDBInstanceStubInstance);

        Test.startTest();
            CollectionCaseStrategiesManager.createCollectionCaseStrategies(contractList);
        Test.stopTest();
    }
}