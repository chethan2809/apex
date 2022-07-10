public class CLContractTriggerHandler {
    @TestVisible
    private static AutomatedPaymentSetupDB automatedPaymentSetupDBInstance = new AutomatedPaymentSetupDB();
    @TestVisible
    private static ChargeDB chargeDBInstance = new ChargeDB();
    @TestVisible
    private static CLContractDB contractDBInstance = new CLContractDB();
    @TestVisible
    private static ApplicationDB applicationDBInstance = new ApplicationDB();
    @TestVisible
    private static ContractConditionDB contractConditionDBInstance = new ContractConditionDB();
    @TestVisible
    private static AccountDB accountDBInstance = new AccountDB();

    public void beforeInsert(List<loan__Loan_Account__c> newLoanAccountList) {
        for(loan__Loan_Account__c loanAccount :newLoanAccountList) {
            CLContracts.setLoanAccountFieldsOnInsert(loanAccount);
        }
    }

    public void afterInsert(Map<Id, loan__Loan_Account__c> newLoanAccountMap) {
        Map<Id, Id> applicationIdToLoanId = new Map<Id, Id>();
        Map<Id, loan__Loan_Account__c> accountIdToLoanAccount = new Map<Id, loan__Loan_Account__c>();
        for(loan__Loan_Account__c loanAccount : newLoanAccountMap.values()) {
            applicationIdToLoanId.put(loanAccount.Application__c, loanAccount.Id);
            genesis__Applications__c application = new genesis__Applications__c(Id = loanAccount.Application__c);
            application.CLContract__c = loanAccount.Id;
            applicationDBInstance.addUpdate(application);
            accountIdToLoanAccount.put(loanAccount.loan__Account__c, loanAccount);
        }

        Map<Id, Account> accountMap = new Map<Id, Account>(accountDBInstance.getAccountByIds(accountIdToLoanAccount.keySet()));

        for(Account accountRecord : accountMap.values()) {
            loan__Loan_Account__c loanAccount = accountIdToLoanAccount.get(accountRecord.Id);
            Accounts.setContractApprovedRelatedFields(accountRecord, loanAccount.Broker_Account__c, loanAccount.Broker_Contact__c);
            accountDBInstance.addUpdate(accountRecord);
        }

        applicationDBInstance.executeUpdates();
        accountDBInstance.executeUpdates();
        CLContractManager.createContractCondition(newLoanAccountMap.keySet());
        CLContractManager.createLoanParties(applicationIdToLoanId);
        CLContractManager.createLoanDisbursalTransaction(newLoanAccountMap.keySet());
    }

    public void beforeUpdate(Map<Id, loan__Loan_Account__c> newMap, Map<Id, loan__Loan_Account__c> oldMap) {
        for(loan__Loan_Account__c loanAccount : newMap.values()) {
            loan__Loan_Account__c oldLoanAccount = oldMap.get(loanAccount.Id);
            if(CLContracts.isClosed(loanAccount, oldLoanAccount)) {
                loanAccount.loan__Next_Accrual_Entry_Date__c = null;
            }
        }
    }

    public void afterUpdate(Map<Id, loan__Loan_Account__c> newMap, Map<Id, loan__Loan_Account__c> oldMap){
        Set<Id> disbursalTransactionIdSet = new Set<Id>();
        Set<Id> concurrentDisbursedLoanIds = new Set<Id>();
        Set<Id> contractsIdsForAdjustLastPayment = new Set<Id>();
        Set<Id> cancelledContractAccountIds = new Set<Id>();
        List<loan__Charge__c> chargeList = new List<loan__Charge__c>();
        List<loan__Loan_Account__c> contractsForUpdate  = new List<loan__Loan_Account__c>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contractIdsForUUC = new Set<Id>();

        for(loan__Loan_Account__c loanAccount : newMap.values()) {
            loan__Loan_Account__c oldLoanAccount = oldMap.get(loanAccount.Id);
            accountIds.add(loanAccount.loan__Account__c);
            if(loanAccount.Total_Unpaid_Due_Amount_To_Current__c == oldLoanAccount.Total_Unpaid_Due_Amount_To_Current__c ) {
                CLContracts.setLatestMissedPaymentDate(loanAccount, contractsForUpdate);
            }
            ChargeManager.createReturnCharges(loanAccount, oldLoanAccount, chargeList);

            if(CLContracts.isFirstDisbursed(loanAccount, oldLoanAccount)) {
                ChargeManager.createInitialCharges(loanAccount, chargeList);
                loan__Automated_Payment_Setup__c recurringAps = AutomatedPaymentSetups.createRecurringAutomatedPaymentSetup(loanAccount);
                automatedPaymentSetupDBInstance.addInsert(recurringAps);
                disbursalTransactionIdSet.add(loanAccount.loan__Last_Transaction_Id__c);
            }

            if(CLContracts.isRepaymentScheduleGeneratedOnFirstDisbursal(loanAccount, oldLoanAccount)) {
                accountDBInstance.addUpdate(Accounts.setContractApprovedRelatedFields(loanAccount));
            }

            if(CLContracts.isConcurrentDisbursal(loanAccount, oldLoanAccount)) {
                disbursalTransactionIdSet.add(loanAccount.loan__Last_Transaction_Id__c);
                ChargeManager.createConcurrentOriginationFee(loanAccount, oldLoanAccount, chargeList);
                concurrentDisbursedLoanIds.add(loanAccount.Id);
            }

            if(CLContracts.isClosed(loanAccount, oldLoanAccount)) {
                accountDBInstance.addUpdate(Accounts.setClosedContractRelatedFields(loanAccount));
            }

            if(CLContracts.isCanceledWithinTenDays(loanAccount, oldLoanAccount)) {
                cancelledContractAccountIds.add(loanAccount.loan__Account__c);
            }

            if(CLContracts.isRepaymentScheduleGenerated(loanAccount, oldLoanAccount)) {
                contractsIdsForAdjustLastPayment.add(loanAccount.Id);
            }
        }
        Map<Id, Account> accountMap = new Map<Id, Account>(accountDBInstance.getAccountByIds(accountIds));

        for(loan__Loan_Account__c loanAccount : newMap.values()) {
            loan__Loan_Account__c oldLoanAccount = oldMap.get(loanAccount.Id);
            if(loanAccount.loan__Disbursed_Amount__c != oldLoanAccount.loan__Disbursed_Amount__c
                && loanAccount.loan__Disbursed_Amount__c >= CustomSettingsHelper.generalSettings.UCC_Filing_Eligible_Amount__c
                && accountMap.get(loanAccount.loan__Account__c).UCC_Status__c != GeneralConstants.UCC_STATUS_ACTIVE
                && !accountMap.get(loanAccount.loan__Account__c).UCC_Opt_Out__c
                && !loanAccount.loan__Invalid_Data__c){
                contractIdsForUUC.add(loanAccount.Id);
            }
        }

        if(!cancelledContractAccountIds.isEmpty()){
            for(Account accountRecord : accountDBInstance.getAccountByIds(cancelledContractAccountIds)) {
                accountDBInstance.addUpdate(Accounts.setCanceledContractRelatedFields(accountRecord));
            }
        }

        if(!disbursalTransactionIdSet.isEmpty()){
            BrokerManager.createBrokerAndCalculateCommission(disbursalTransactionIdSet);
        }

        if(!contractsIdsForAdjustLastPayment.isEmpty()){
            CLContractManager.adjustLastRepaymentSchedule(contractsIdsForAdjustLastPayment);
        }

        automatedPaymentSetupDBInstance.executeInserts();
        chargeDBInstance.addInserts(chargeList).executeInserts();
        contractDBInstance.addUpdates(contractsForUpdate).executeUpdates();
        accountDBInstance.executeUpdates();

        if(!concurrentDisbursedLoanIds.isEmpty()) {
            CLContractManager.adjustLoanPaymentAmountAction(concurrentDisbursedLoanIds);
        }
        if(!contractIdsForUUC.isEmpty()) {
            UCCFilingManager.createUCCFilingAsync(contractIdsForUUC);
        }
    }
}