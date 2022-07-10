public class AutomatedPaymentSetupTriggerHandler {

    @TestVisible
    private static AutomatedPaymentSetupDB automatedPaymentSetupDBInstance = new AutomatedPaymentSetupDB();
    @TestVisible
    private static CLContractDB clContractDBInstance = new CLContractDB();

    public void beforeInsert(List<loan__Automated_Payment_Setup__c> newAPSList) {
        for (loan__Automated_Payment_Setup__c automatedPayment : newAPSList) {
            if(automatedPayment.loan__Type__c == AutomatedPaymentSetups.APS_LOAN_TYPE_RECURRING) {
                loan__Loan_Account__c clContract = new loan__Loan_Account__c();
                clContract.Id = automatedPayment.loan__CL_Contract__c;
                clContract.ACH_Turned_off_Date__c = null;
                clContractDBInstance.addUpdate(clContract);
            }
        }

        try {
            clContractDBInstance.executeUpdates();
        } catch(Exception e) {
            ErrorLogs.createErrorLog(PortalConstants.ACH_ERROR_ORIGIN_TEXT, e.getMessage(), e.getStackTraceString(), null, 'Error', null, true);
        }
    }

    public void beforeUpdate(List<loan__Automated_Payment_Setup__c> newAPSList) {
        Date clsSystemDate = GeneralHelper.currentSystemDate;
        for (loan__Automated_Payment_Setup__c automatedPayment : newAPSList) {
            if(automatedPayment.loan__Type__c == AutomatedPaymentSetups.APS_LOAN_TYPE_RECURRING && !automatedPayment.loan__Active__c) {
                loan__Loan_Account__c clContract = new loan__Loan_Account__c();
                clContract.Id = automatedPayment.loan__CL_Contract__c;
                clContract.ACH_Turned_off_Date__c = clsSystemDate;
                clContractDBInstance.addUpdate(clContract);
            }
        }
        try {
            clContractDBInstance.executeUpdates();
        } catch(Exception e) {
            ErrorLogs.createErrorLog(PortalConstants.ACH_ERROR_ORIGIN_TEXT, e.getMessage(), e.getStackTraceString(), null, 'Error', null, true);
        }
    }

    public void afterUpdate(List<loan__Automated_Payment_Setup__c> newAPSList, Map<Id,loan__Automated_Payment_Setup__c> oldAPSMap) {

        DateTime clsSystemDate = GeneralHelper.currentSystemDate;
        Set<Id> contractIds = new Set<Id>();
        for(loan__Automated_Payment_Setup__c apsRecord : newAPSList) {
            Date recurringACHEndDate = GeneralHelper.getBusinessDate(apsRecord.loan__Recurring_ACH_End_Date__c);
            Boolean isSameDay = recurringACHEndDate == clsSystemDate;
            if(apsRecord.loan__Active__c != oldAPSMap.get(apsRecord.Id).loan__Active__c && apsRecord.loan__Active__c == false
                && isSameDay && apsRecord.loan__Type__c == AutomatedPaymentSetups.APS_LOAN_TYPE_RECURRING
            ) {
                contractIds.add(apsRecord.loan__CL_Contract__c);
            }
        }

        List<loan__Automated_Payment_Setup__c> apsRecordList = automatedPaymentSetupDBInstance.getAPSRecordsByContractIds(contractIds);
        for(loan__Automated_Payment_Setup__c apsRecord : apsRecordList) {
            Boolean isSameDay = apsRecord.loan__Setup_Date__c == apsRecord.loan__CL_Contract__r.loan__Disbursal_Date__c;

            if(CLContracts.LOAN_GOOD_AND_BAD_STATUSES.contains(apsRecord.loan__CL_Contract__r.loan__Loan_Status__c)
               && isSameDay && apsRecord.loan__CL_Contract__r.loan__la_matured_flag__c == false
            ) {
                apsRecord.loan__Amount_Type__c = AutomatedPaymentSetups.AMOUNT_TYPE;
                apsRecord.loan__Recurring_ACH_End_Date__c = apsRecord.loan__CL_Contract__r.loan__Last_Installment_Date__c.addDays(1);
                apsRecord.loan__Active__c = true;
                apsRecord.loan__Debit_Date__c = apsRecord.loan__CL_Contract__r.loan__Next_Installment_Date__c;
                apsRecord.loan__Debit_Day__c = apsRecord.loan__CL_Contract__r.loan__Next_Installment_Date__c.day();
                apsRecord.loan__Actual_Date__c = apsRecord.loan__Debit_Date__c;
                automatedPaymentSetupDBInstance.addUpdate(apsRecord);
            }
        }

        try {
            automatedPaymentSetupDBInstance.executeUpdates();
        } catch(Exception e) {
            ErrorLogs.createErrorLog(PortalConstants.ACH_ERROR_ORIGIN_TEXT, e.getMessage(), e.getStackTraceString(), null, 'Error', null, true);
        }
    }
}