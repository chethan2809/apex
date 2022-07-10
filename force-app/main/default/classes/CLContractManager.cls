public class CLContractManager {

    @TestVisible
    private static CLContractDB clContractDBInstance = new CLContractDB();
    @TestVisible
    private static PartyDB partyDBInstance = new PartyDB();
    @TestVisible
    private static CoBorrowerDB coBorrowerDBInstance = new CoBorrowerDB();
    @TestVisible
    private static LoanDisbursalTxnDistributionDB loanDisbursalTxnDistributionInstance = new LoanDisbursalTxnDistributionDB();
    @TestVisible
    private static LoanDisbursalTransactionsDB loanDisbursalTransactionsDBInstance = new LoanDisbursalTransactionsDB();
    @TestVisible
    private static RepaymentScheduleDB repaymentScheduleDBInstance = new RepaymentScheduleDB();
    @TestVisible
    private static ContractConditionDB contractConditionDBInstance = new ContractConditionDB();
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

    public static void createLoanDisbursalTransaction(Set<Id> loanAccountIds) {
        List<loan__Loan_Account__c> loanAccountList = clContractDBInstance.getLoanAccountsAndItsCompetitorPartiesByIds(loanAccountIds);
        List<loan__Disbursal_Txn_Distribution__c> totalDisbursalDistributionList = new List<loan__Disbursal_Txn_Distribution__c>();
        Set<String> loanNames = new  Set<String>();

        for(loan__Loan_Account__c loanAccount :loanAccountList) {
            Decimal disbursalAmount = loanAccount.Application__r.genesis__Loan_Amount__c;
            List<loan__Disbursal_Txn_Distribution__c> disbursalDistributionList = new List<loan__Disbursal_Txn_Distribution__c>();

            Id investorId = CustomSettingsHelper.generalSettings.Default_Investor_Account_Id__c;
            if(investorId == null) {
                throw new CLContractManagerException('There is no default Investor exist in the system');
            }

            loan__Loan_Disbursal_Transaction__c disbursal = LoanDisbursalTransactions.createLoanDisbursalTransaction(
                disbursalAmount, loanAccount.Id, ServicingHelper.paymentModeIdByName.get(GeneralConstants.PAYMENT_MODE_ACH), null,
                loanAccount.loan__Expected_Disbursal_Date__c
            );
            disbursal.Investor_Account__c = investorId;

            if(loanAccount.Application__r.Type__c == GeneralConstants.LOAN_TYPE_RENEWAL &&
                loanAccount.Application__r.Oldest_Unpaid_Due_As_Of_Today__c != null && loanAccount.Application__r.Oldest_Unpaid_Due_As_Of_Today__c > 0
            ) {
                String fundedSource = loanAccount.Application__r.CAN_Pay_Off_Type__c == GeneralConstants.PRODUCT_TYPE_LOAN?
                    LoanDisbursalTxnDistributions.FUNDED_SOURCE_REPURCHASE : LoanDisbursalTxnDistributions.FUNDED_SOURCE_CROSSOVER;
                loan__Disbursal_Txn_Distribution__c unpaidAmountDueDistribution = LoanDisbursalTxnDistributions.createLoanDisbursalTxnDistribution(
                    loanAccount.Application__r.Oldest_Unpaid_Due_As_Of_Today__c, ServicingHelper.canBankAccount.Id,
                    ServicingHelper.paymentModeIdByName.get(GeneralConstants.PAYMENT_MODE_ACH),
                    LoanDisbursalTxnDistributions.DISTRIBUTION_TYPE, fundedSource
                );
                disbursalDistributionList.add(unpaidAmountDueDistribution);
                disbursalAmount -= loanAccount.Application__r.Oldest_Unpaid_Due_As_Of_Today__c;
            }

            List<clcommon__Party__c> partyList = loanAccount.Parties__r;
            if(!partyList.isEmpty()){
                for(clcommon__Party__c party : partyList) {
                    loan__Disbursal_Txn_Distribution__c competitorDistribution = LoanDisbursalTxnDistributions.createLoanDisbursalTxnDistribution(
                        party.Competitor_Amount__c, party.Competitor_Bank_Account__c,
                        party.competitor_payment_mode__c, LoanDisbursalTxnDistributions.DISTRIBUTION_TYPE,
                        LoanDisbursalTxnDistributions.FUNDED_SOURCE_COMPETITOR
                    );
                    disbursalDistributionList.add(competitorDistribution);
                    disbursalAmount -= party.Competitor_Amount__c;
                }
            }

            if(disbursalAmount > 0) {
                loan__Disbursal_Txn_Distribution__c borrowerDistribution = LoanDisbursalTxnDistributions.createLoanDisbursalTxnDistribution(
                    disbursalAmount, loanAccount.Bank_Account__c, ServicingHelper.paymentModeIdByName.get(GeneralConstants.PAYMENT_MODE_ACH),
                    LoanDisbursalTxnDistributions.DISTRIBUTION_TYPE, LoanDisbursalTxnDistributions.FUNDED_SOURCE_MERCHANT
                );
                disbursalDistributionList.add(borrowerDistribution);
            }

            totalDisbursalDistributionList.addAll(disbursalDistributionList);
            loanNames.add(loanAccount.Name);

            loanDisbursalTransactionsDBInstance.executeInserts(disbursal, disbursalDistributionList);
        }

        Integer disbursalDistributionIndex = 0;

        for(loan__Disbursal_Txn_Distribution__c distribution : loanDisbursalTxnDistributionInstance.getLoanDisbursalTxnDistributionsByLoanNames(loanNames)) {
            loan__Disbursal_Txn_Distribution__c insertedDisbursalDistribution = totalDisbursalDistributionList.get(disbursalDistributionIndex);
            distribution.loan__Bank_Account__c = insertedDisbursalDistribution.loan__Bank_Account__c;
            distribution.Funded_Source__c = insertedDisbursalDistribution.Funded_Source__c;
            loanDisbursalTxnDistributionInstance.addUpdate(distribution);
            disbursalDistributionIndex++;
        }

        loanDisbursalTxnDistributionInstance.executeUpdates();

    }

    public static void createLoanParties(Map<Id, Id> applicationIds){
        for(clcommon__Party__c party :partyDBInstance.getAllPartiesByApplicationIds(applicationIds.keySet())) {
            party.CL_Contract__c = applicationIds.get(party.genesis__Application__c);
            partyDBInstance.addUpdate(party);

            loan__Coborrower__c coBorrower = CoBorrowers.createCoBorrower(party);
            coBorrowerDBInstance.addInsert(coBorrower);
        }
        partyDBInstance.executeUpdates();
        coBorrowerDBInstance.executeInserts();
    }

    public static void adjustLastRepaymentSchedule(Set<Id> loanAccountIds) {
        for(loan__Loan_Account__c loanAccount :clContractDBInstance.getLoanAccountsAndItsLastRepaymentScheduleByIds(loanAccountIds)) {
            if(loanAccount.loan__Repayment_Schedule__r.isEmpty()) {
                continue;
            }

            loan__Repayment_Schedule__c lastRepaymentSchedule = loanAccount.loan__Repayment_Schedule__r.get(0);
            Decimal diffPaymentAmount = ((loanAccount.loan__Disbursed_Amount__c * loanAccount.Pricing_Factor__c) - loanAccount.loan__Disbursed_Amount__c) - loanAccount.loan__Total_Interest_Amortization_Based__c;

            lastRepaymentSchedule.loan__Due_Interest__c += diffPaymentAmount;
            lastRepaymentSchedule.loan__Due_Amount__c += diffPaymentAmount;
            repaymentScheduleDBInstance.addUpdate(lastRepaymentSchedule);

        }
        repaymentScheduleDBInstance.executeUpdates();
    }

    @future
    public static void adjustLoanPaymentAmountAction(Set<Id> loanAccountIds) {
        for(loan__Loan_Account__c loanAccount : clContractDBInstance.getLoanAccountsByIds(loanAccountIds)) {
            Decimal paymentAmount = (loanAccount.loan__Last_Disbursal_Amount__c * loanAccount.Pricing_Factor__c) / loanAccount.Remaining_Number_of_Payments__c;
            paymentAmount += loanAccount.loan__Payment_Amount__c;
            loan.LoanActionFactory factory = new loan.LoanActionFactory();
            loan.LoanAction10 loanAction = factory.getLoanAction10API();
            loanAction.changePaymentAmount(loanAccount.Id, GeneralHelper.currentSystemDate, paymentAmount, false);
        }
    }

    @future
    public static void createContractCondition(Set<Id> clContractIds) {
        try {
            for (Id loanAccountId : clContractIds) {
                contractConditionDBInstance.addInsert(ContractConditions.createContractCondition(loanAccountId));
            }
            contractConditionDBInstance.executeInserts();
        } catch (Exception ex) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'Create Contract Condition Failed', ex.getMessage(), 'Id: ' + clContractIds.toString() + ' Stack Trace: ' + ex.getStackTraceString(),
                null, ErrorLogs.ERROR, null, false
            );
            errorLogDBInstance.addInsert(errorLog).executeInserts();
        }
    }

    private class CLContractManagerException extends Exception {}
}