public class AutomatedPaymentSetupManager {
    @TestVisible
    private static CLContractDB clContractDBInstance = new CLContractDB();

    public static List<loan__Loan_Account__c> updateAPSFieldIfAutoWriteOff(Map<Id, List<loan__Automated_Payment_Setup__c>> contractIdByAPSList){
        List<loan__Loan_Account__c> clContractList = clContractDBInstance.getLoanAccountsByIds(contractIdByAPSList.keySet());
        List<loan__Loan_Account__c> clContractShellList = new List<loan__Loan_Account__c>();
        for (loan__Loan_Account__c clContract : clContractList) {
            if(clContract.Is_Auto_Write_Off_Batch__c) {
                List<loan__Automated_Payment_Setup__c> apsList = contractIdByAPSList.get(clContract.Id);
                for (loan__Automated_Payment_Setup__c automatedPayment : apsList) {
                    automatedPayment.loan__Active__c = true;
                }

                loan__Loan_Account__c clContractShell = new loan__Loan_Account__c(Id = clContract.Id);
                clContractShell.Is_Auto_Write_Off_Batch__c = false;
                clContractShellList.add(clContractShell);
            }
        }
        return clContractShellList;
    }
}