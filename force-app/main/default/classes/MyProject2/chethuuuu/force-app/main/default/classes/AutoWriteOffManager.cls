public class AutoWriteOffManager {
    @TestVisible
    private static CLContractDB clContractDBInstance = new CLContractDB();
    @TestVisible
    private static AutomatedPaymentSetupDB automatedPaymentSetupDBInstance = new AutomatedPaymentSetupDB();
    @TestVisible
    private static ChargeDB chargeDBInstance = new ChargeDB();
    @TestVisible
    private static LoanOfficeNameDB loanOfficeNameDBInstance = new LoanOfficeNameDB();

    public static void setContractFieldsWhenAutoWriteOffEligible(List<loan__Loan_Account__c> clContractList) {
        loan__Office_Name__c loanOfficeName = loanOfficeNameDBInstance.getLoanOfficeName().get(0);

        for(loan__Loan_Account__c loanAccount : clContractList) {
            loan__Loan_Account__c loanAccountShell = new loan__Loan_Account__c(Id = loanAccount.Id);
            if(loanAccount.Auto_WriteOff_Date__c == null) {
                loanAccountShell.Auto_WriteOff_Date__c = GeneralHelper.currentSystemDate.addDays(
                    Integer.valueOf(loanOfficeName.loan__Write_Off_Suggestion_Days__c)
                );
                loanAccountShell.loan__Accrual_Entry_Stop_Indicator__c = true;
                loanAccountShell.loan__Accrual_Stop_Indicator__c = true;
                loanAccountShell.Write_off_Applicable__c = true;
            } else if(loanAccount.Auto_WriteOff_Date__c != null && loanAccount.Auto_WriteOff_Date__c > GeneralHelper.currentSystemDate) {
                loanAccountShell.Auto_WriteOff_Date__c = null;
                loanAccountShell.loan__Accrual_Entry_Stop_Indicator__c = false;
                loanAccountShell.loan__Accrual_Stop_Indicator__c = false;
                loanAccountShell.Write_off_Applicable__c = false;
            }

            clContractDBInstance.addUpdate(loanAccountShell);
        }

        clContractDBInstance.executeUpdates();
    }

    public static void handleAutoWriteOff(List<loan__Loan_Account__c> clContractList) {
        Map<Id, loan__Loan_Account__c> clContractMap = new Map<Id, loan__Loan_Account__c> (clContractList);

        Set<Id> contractIdsForWriteOff = new Set<Id> ();

        for (loan__Loan_Account__c loanAccount : clContractList) {
            if(loanAccount.Auto_WriteOff_Date__c != null && loanAccount.Auto_WriteOff_Date__c <= GeneralHelper.currentSystemDate) {
                contractIdsForWriteOff.add(loanAccount.Id);

                if(loanAccount.Auto_WriteOff_Date__c < loanAccount.loan__Last_Installment_Date__c && loanAccount.loan__Fee_Set__c != null) {
                    chargeDBInstance.addInsert(AutoWriteOffs.createChargesOnWrittenOff(loanAccount));
                }

                loan__Loan_Account__c loanAccountShell = new loan__Loan_Account__c(Id = loanAccount.Id);
                loanAccountShell.Is_Auto_Write_Off_Batch__c = true;
                clContractDBInstance.addUpdate(loanAccountShell);
            }
        }

        chargeDBInstance.executeInserts();
        clContractDBInstance.executeUpdates();

        if(!contractIdsForWriteOff.isEmpty()) {
            autoWriteOffCLContract(contractIdsForWriteOff);
        }
    }

    public static void autoWriteOffCLContract(Set<Id> clContractIds) {
        String queryString = 'SELECT Id, Name FROM loan__Loan_Account__c';
        queryString = queryString + ' WHERE Id IN  (\'' + String.join((Iterable<String>)clContractIds, '\',\'') +'\')';
        loan.AutoWriteOffJob autoWriteoffJob = new loan.AutoWriteOffJob(queryString);
        Database.executeBatch(autoWriteoffJob);
    }
}