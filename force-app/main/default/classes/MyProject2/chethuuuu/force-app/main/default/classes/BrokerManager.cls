public class BrokerManager {
    @TestVisible
    private static BrokerDB brokerDBInstance = new BrokerDB();
    @TestVisible
    private static CLContractDB clContractDBInstance = new CLContractDB();
    @TestVisible
    private static LoanDisbursalTransactionsDB disbursalTransactionDBInstance = new LoanDisbursalTransactionsDB();
    @TestVisible
    private static AccountDB accountDBInstance = new AccountDB();
    @TestVisible
    private static ContactDB contactDBInstance = new ContactDB();
    @TestVisible
    private static LoanDisbursalTxnDistributionDB loanDisbursalTxnDistributionDBInstance = new LoanDisbursalTxnDistributionDB();
    private static Map<Id,Account> brokerAccountMap = new Map<Id,Account>();
    private static Map<Id,loan__Loan_Account__c> lendingAccountMap = new Map<Id,loan__Loan_Account__c>();
    private static Map<Id,loan__Loan_Disbursal_Transaction__c> disbursalTransactionMap = new Map<Id,loan__Loan_Disbursal_Transaction__c>();
    private static List<loan__Broker__c> brokerList = new List<loan__Broker__c>();
    private static Map<Id, List<loan__Disbursal_Txn_Distribution__c>> disbursalDistributionTxnsByLoanAccountId = new Map<Id, List<loan__Disbursal_Txn_Distribution__c>>();

    @future
    public static void createBrokerAndCalculateCommission(Set<Id> disbursalTransactionIds){
        for(loan__Loan_Disbursal_Transaction__c loanDisbursalTransactions :
        disbursalTransactionDBInstance.getLoanDisbursalTransactionsByIds(disbursalTransactionIds)
        ) {
            if(loanDisbursalTransactions.loan__Loan_Account__r.Broker_Contact__c != null) {
                loan__Broker__c loanBroker = new loan__Broker__c();
                loanBroker.loan__Account__c = loanDisbursalTransactions.loan__Loan_Account__r.Broker_Contact__r.AccountId;
                loanBroker.loan__Contact__c = loanDisbursalTransactions.loan__Loan_Account__r.Broker_Contact__c;
                loanBroker.loan__Commission_Plan__c = ServicingHelper.BrokerCommissionPlans.get(0).Id;
                loanBroker.loan__Calculation_Method__c = loanDisbursalTransactions.loan__Loan_Account__r.Broker_Contact__r.Account.Commision_Based_On__c;
                loanBroker.loan__Lending_Account__c = loanDisbursalTransactions.loan__Loan_Account__c;
                loanBroker.Disbursal_Transaction__c = loanDisbursalTransactions.Id;
                brokerList.add(loanBroker);
            }
        }

        if(!brokerList.isEmpty()) {
            try {
                calculateCommission(brokerList);
                brokerDBInstance.addInserts(brokerList);
                brokerDBInstance.executeInserts();
            } catch (Exception exp) {
                ErrorLogs.createErrorLog('Broker Creation and Commission Calculation', exp.getMessage() + exp.getStackTraceString(), JSON.serialize(brokerList),
                null, 'Error', null, true);
            }
        }
    }

    public static void calculateCommission(List<loan__Broker__c > brokerList)
    {
        Decimal commAmount = 0.0;
        Double loanAmount = 0.0;
        String type = '';
        Set<Id> lendingAccountIdSet = new Set<Id>();
        Set<Id> brokerAccountIdSet = new Set<Id>();
        Set<Id> disbursalTransactionIdSet = new Set<Id>();
        List<loan__Loan_Disbursal_Transaction__c> disbursalTransactionsList = new List<loan__Loan_Disbursal_Transaction__c>();
        Map<Id,Integer> disbursalTransactionCountMap = new Map<Id,Integer>();
        List<loan__Broker__c> renewalBrokerList = new List<loan__Broker__c>();
        List<loan__Broker__c> concurrentBrokerList = new List<loan__Broker__c>();
        List<loan__Broker__c> newBrokerList = new List<loan__Broker__c>();

        for(loan__Broker__c brokerObj : brokerList)
        {
            lendingAccountIdSet.add(brokerObj.loan__Lending_Account__c);
            if(String.isNotBlank(brokerObj.loan__Account__c))
            {
                brokerAccountIdSet.add(brokerObj.loan__Account__c);
            }

            if(String.isNotBlank(brokerObj.Disbursal_Transaction__c))
            {
                disbursalTransactionIdSet.add(brokerObj.Disbursal_Transaction__c);
            }
        }

        if(!lendingAccountIdSet.isEmpty())
        {
            lendingAccountMap = new Map<Id,loan__Loan_Account__c>(clContractDBInstance.getLoanAccountsByIds(lendingAccountIdSet));
            disbursalTransactionsList = disbursalTransactionDBInstance.getDisbursalTransactionsListByLoanAccountIds(lendingAccountIdSet);
            for (loan__Loan_Disbursal_Transaction__c dt : disbursalTransactionsList)
            {
                if(!disbursalTransactionCountMap.containsKey(dt.loan__Loan_Account__c)){
                    disbursalTransactionCountMap.put(dt.loan__Loan_Account__c,1);
                }
                else{
                    disbursalTransactionCountMap.put(dt.loan__Loan_Account__c,disbursalTransactionCountMap.get(dt.loan__Loan_Account__c) + 1);
                }
            }
        }

        if(!brokerAccountIdSet.isEmpty())
        {
            brokerAccountMap = new Map<Id,Account>(accountDBInstance.getAccountByIds(brokerAccountIdSet));
        }

        if(!disbursalTransactionIdSet.isEmpty())
        {
            disbursalTransactionMap = new Map<Id,loan__Loan_Disbursal_Transaction__c>(disbursalTransactionDBInstance.getLoanDisbursalTransactionsByIds(disbursalTransactionIdSet));
            disbursalDistributionTxnsByLoanAccountId = new Map<Id, List<loan__Disbursal_Txn_Distribution__c>>();
            for (loan__Disbursal_Txn_Distribution__c distributionTransaction :
                    loanDisbursalTxnDistributionDBInstance.getLoanDisbursalTxnDistributionsByDisbursalIds(
                        disbursalTransactionIdSet, Brokers.FUNDED_SOURCES_ON_GROSS_AMOUNT
                    )
            ) {
                if(disbursalDistributionTxnsByLoanAccountId.containsKey
                    (
                        distributionTransaction.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__c
                    )
                ) {
                    disbursalDistributionTxnsByLoanAccountId.get
                    (
                        distributionTransaction.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__c).add(distributionTransaction
                    );
                } else {
                    disbursalDistributionTxnsByLoanAccountId.put
                    (
                        distributionTransaction.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__c,
                        new List<loan__Disbursal_Txn_Distribution__c> {distributionTransaction}
                    );
                }
            }
        }
        for(loan__Broker__c brokerObj : brokerList)
        {
            // Scenario 1 & 2: Validating is broker is active and broker is eligible to receive commission.
            if(String.isNotBlank(brokerObj.loan__Lending_Account__c)
               && lendingAccountMap.containsKey(brokerObj.loan__Lending_Account__c)
               && String.isNotBlank(lendingAccountMap.get(brokerObj.loan__Lending_Account__c).Type__c)
               && brokerAccountMap.containsKey(brokerObj.loan__Account__c)
               && brokerAccountMap.get(brokerObj.loan__Account__c).Is_Broker_Active__c
               && brokerAccountMap.get(brokerObj.loan__Account__c).Commission_Eligible__c)
            {
                if(GeneralConstants.LOAN_TYPE_NEW == lendingAccountMap.get(brokerObj.loan__Lending_Account__c).Type__c)
                {
                    if(disbursalTransactionCountMap.containsKey(brokerObj.loan__Lending_Account__c) && disbursalTransactionCountMap.get(brokerObj.loan__Lending_Account__c) == 1)
                    {
                        newBrokerList.add(brokerObj);
                    }else  if(disbursalTransactionCountMap.containsKey(brokerObj.loan__Lending_Account__c) && disbursalTransactionCountMap.get(brokerObj.loan__Lending_Account__c) > 1)
                    {
                        concurrentBrokerList.add(brokerObj);
                    }
                }else if(GeneralConstants.LOAN_TYPE_RENEWAL == lendingAccountMap.get(brokerObj.loan__Lending_Account__c).Type__c)
                {
                    renewalBrokerList.add(brokerObj);
                }
                /*else if(CONCURRENT_TYPE.equalsIgnoreCase(lendingAccountMap.get(brokerObj.loan__Lending_Account__c).Type__c)){}*/
            }else
            {
                if(!brokerAccountMap.get(brokerObj.loan__Account__c).Is_Broker_Active__c)
                {
                    brokerObj.Commission_Calculation_Message__c = 'Broker is not in active state to calculate commission.';
                    brokerObj.Commission_Point__c = 0.0;
                    brokerObj.loan__Commission_Amount__c = 0.0;
                    brokerObj.Commission_Payable__c = 0.0;
                }else if(!brokerAccountMap.get(brokerObj.loan__Account__c).Commission_Eligible__c)
                {
                    brokerObj.Commission_Calculation_Message__c = 'Broker is not eligible to receive commission.';
                    brokerObj.Commission_Point__c = 0.0;
                    brokerObj.loan__Commission_Amount__c = 0.0;
                    brokerObj.Commission_Payable__c = 0.0;
                }
            }
        }

        calculateNewTypeCommission(newBrokerList);
        calculateRenewalTypeCommission(renewalBrokerList);
        calculateConcurrentTypeCommission(concurrentBrokerList);
        adjustClawbackOnBrokerAccount(brokerList);
    }

    private static void adjustClawbackOnBrokerAccount(List<loan__Broker__c> brokerList)
    {
         Map<Id,Account> updatedBrokerAccountMap = new Map<Id,Account>();
        Account brokerAccountObject;
        boolean isAmountAdjusted = false;
        for(loan__Broker__c brokerObj : brokerList)
        {
            if(updatedBrokerAccountMap.containsKey(brokerObj.loan__Account__c))
            {
                brokerAccountObject = updatedBrokerAccountMap.get(brokerObj.loan__Account__c);
            }else if(brokerAccountMap.containsKey(brokerObj.loan__Account__c))
            {
                brokerAccountObject = brokerAccountMap.get(brokerObj.loan__Account__c);
            }else
            {
                brokerAccountObject = null;
            }
            if(String.isNotBlank(brokerObj.loan__Account__c)
               && brokerAccountObject != null
               && brokerAccountObject.Total_Clawback_Amount__c > 0.0)
            {
                isAmountAdjusted = false;
                if(brokerAccountObject.Total_Clawback_Amount__c >= brokerObj.loan__Commission_Amount__c)
                {
                    brokerAccountObject.Total_Clawback_Amount__c = brokerAccountObject.Total_Clawback_Amount__c-brokerObj.loan__Commission_Amount__c;
                    brokerObj.Commission_Payable__c = 0.0;
                    isAmountAdjusted = true;
                }else if(brokerAccountObject.Total_Clawback_Amount__c>=brokerObj.Flat_Referral_Fee__c)
                {
                    brokerAccountObject.Total_Clawback_Amount__c = brokerAccountObject.Total_Clawback_Amount__c-brokerObj.Flat_Referral_Fee__c;
                    brokerObj.Commission_Payable__c = 0.0;
                    isAmountAdjusted = true;
                }else if(brokerAccountObject.Total_Clawback_Amount__c<brokerObj.loan__Commission_Amount__c)
                {
                    brokerObj.Commission_Payable__c = brokerObj.loan__Commission_Amount__c-brokerAccountObject.Total_Clawback_Amount__c;
                    brokerAccountObject.Total_Clawback_Amount__c = 0.0;
                    isAmountAdjusted = true;
                }else if(brokerAccountObject.Total_Clawback_Amount__c<brokerObj.Flat_Referral_Fee__c)
                {
                    brokerObj.Commission_Payable__c = brokerObj.loan__Commission_Amount__c-brokerAccountObject.Total_Clawback_Amount__c;
                    brokerAccountObject.Total_Clawback_Amount__c = 0.0;
                    isAmountAdjusted = true;
                }
                if(isAmountAdjusted)
                {
                    if(!updatedBrokerAccountMap.containsKey(brokerAccountObject.Id))
                    {
                        updatedBrokerAccountMap.put(brokerAccountObject.Id,brokerAccountObject);
                    }
                }
            }
        }

        if(!updatedBrokerAccountMap.values().isEmpty())
        {
            accountDBInstance.addUpdates(updatedBrokerAccountMap.values());
            accountDBInstance.executeUpdates();
        }

    }

    /* New Loan Commission Calculation */
    private static List<loan__Broker__c> calculateNewTypeCommission(List<loan__Broker__c> brokerList)
    {
        Set<Id> customerAccountIdSet = new Set<Id>();
        if(!brokerList.isEmpty())
        {
            for(loan__Broker__c broObj : brokerList)
            {
                if(brokerAccountMap.containsKey(broObj.loan__Account__c)
                   && lendingAccountMap.containsKey(broObj.loan__Lending_Account__c))
                {
                    customerAccountIdSet.add(lendingAccountMap.get(broObj.loan__Lending_Account__c).loan__Account__c);
                }
            }

            if(!customerAccountIdSet.isEmpty())
            {
                Map<Id,loan__Loan_Account__c> loanAccMap = new Map<Id,loan__Loan_Account__c>(
                    clContractDBInstance.getClosedLoanAccountsByCustomerAccountIds(customerAccountIdSet));
                for(loan__Broker__c broObj : brokerList)
                {
                    // Validating any loan has been closed within 90 days for same borrower.
                    if(brokerAccountMap.containsKey(broObj.loan__Account__c)
                       && lendingAccountMap.containsKey(broObj.loan__Lending_Account__c)
                       && loanAccMap.containsKey(lendingAccountMap.get(broObj.loan__Lending_Account__c).Id))
                    {
                        if(loanAccMap.get(lendingAccountMap.get(broObj.loan__Lending_Account__c).Id).loan__Closed_Date__c.daysBetween(Date.today()) <= 90)
                        {
                            commissionBasedOnField(broObj);
                        }else if(loanAccMap.get(lendingAccountMap.get(broObj.loan__Lending_Account__c).Id).loan__Closed_Date__c.daysBetween(Date.today()) > 90)
                        {
                            broObj.Commission_Calculation_Message__c = 'Broker commission is not calculating since the previous loan was paid off 90 days before. ';
                            broObj.Commission_Point__c = 0.0;
                            broObj.loan__Commission_Amount__c = 0.0;
                            broObj.Commission_Payable__c = 0.0;
                        }
                    }else if(brokerAccountMap.containsKey(broObj.loan__Account__c)
                       && lendingAccountMap.containsKey(broObj.loan__Lending_Account__c)
                       && !loanAccMap.containsKey(lendingAccountMap.get(broObj.loan__Lending_Account__c).Id))
                    {
                        commissionBasedOnField(broObj);
                    }
                }
            }
        }
        return brokerList;
    }

    /* Concurrent Loan Commission Calculation */
    private static List<loan__Broker__c> calculateConcurrentTypeCommission(List<loan__Broker__c> brokerList)
    {
        if(!brokerList.isEmpty())
        {
            Set<Id> loanIdSet = new Set<Id>();
            for(loan__Broker__c brokerObj : brokerList)
            {
                loanIdSet.add(brokerObj.loan__Lending_Account__c);
            }

            Map<Id,loan__Broker__c> prevBrokerMap = new Map<Id,loan__Broker__c>();

            if(loanIdSet.size()>0)
            {
                for (loan__Broker__c prevBrokerRecord : brokerDBInstance.getBrokerListByLoanAccountIds  (loanIdSet))
                {
                    if(!prevBrokerMap.containsKey(prevBrokerRecord.loan__Lending_Account__c))
                    {
                        prevBrokerMap.put(prevBrokerRecord.loan__Lending_Account__c,prevBrokerRecord);
                    }
                }
            }

            if(!prevBrokerMap.isEmpty())
            {
                for(loan__Broker__c brokerObj : brokerList)
                {
                    // Scenario 7 : Deriving Flat referral fee from broker account and adding to broker record.
                    if(prevBrokerMap.containsKey(brokerObj.loan__Lending_Account__c) && prevBrokerMap.get(brokerObj.loan__Lending_Account__c).Flat_Referral_Fee__c > 0)
                    {
                        brokerObj.Flat_Referral_Fee__c = prevBrokerMap.get(brokerObj.loan__Lending_Account__c).Flat_Referral_Fee__c;
                        brokerObj.Commission_Calculation_Message__c = 'Flat Referral Fee updated Successfully.';
                        brokerObj.loan__Commission_Amount__c = brokerObj.Flat_Referral_Fee__c;
                        brokerObj.Commission_Payable__c = prevBrokerMap.get(brokerObj.loan__Lending_Account__c).Flat_Referral_Fee__c;
                    //  BR 16 Concurrent loans scenario : Same commission structure for the brokers % of the additional funding amount for Concurrent loan.
                    } else if(prevBrokerMap.containsKey(brokerObj.loan__Lending_Account__c)
                             && prevBrokerMap.get(brokerObj.loan__Lending_Account__c).Commission_Point__c > 0
                             && disbursalTransactionMap.containsKey(brokerObj.Disbursal_Transaction__c)
                            )
                    {
                        brokerObj.loan__Commission_Amount__c = disbursalTransactionMap.get(brokerObj.Disbursal_Transaction__c).loan__Disbursed_Amt__c*(prevBrokerMap.get(brokerObj.loan__Lending_Account__c).Commission_Point__c/100);
                        brokerObj.Commission_Point__c = prevBrokerMap.get(brokerObj.loan__Lending_Account__c).Commission_Point__c;
                        brokerObj.Commission_Payable__c = brokerObj.loan__Commission_Amount__c;
                        brokerObj.Commission_Calculation_Message__c = 'Broker Commission calculated Successfully.';
                    }
                }
            }
        }
        return brokerList;
    }

    /* Renewal Loan Commission Calculation */
    private static List<loan__Broker__c> calculateRenewalTypeCommission(List<loan__Broker__c> brokerList)
    {
        List<loan__Broker__c> newFirstFundingBrokerList = new List<loan__Broker__c>();
        Set<Id> customerAccountIdSet = new Set<Id>();
        Decimal totalAmount;
        List<loan__Disbursal_Txn_Distribution__c> distributionTxnList = new List<loan__Disbursal_Txn_Distribution__c> ();
        if(!brokerList.isEmpty())
        {
            for(loan__Broker__c broObj : brokerList)
            {
                if(brokerAccountMap.containsKey(broObj.loan__Account__c)
                    && lendingAccountMap.get(broObj.loan__Lending_Account__c).Broker_Standard_Commission__c<=brokerAccountMap.get(broObj.loan__Account__c).Renewal_Max_Broker_Commission__c
                ){
                    distributionTxnList = disbursalDistributionTxnsByLoanAccountId.get(broObj.loan__Lending_Account__c);
                    // Scenario 10 : Gross Amount(Loan amount from CL Contract record with flat renewal commission % from broker account record)
                    if(brokerAccountMap.get(broObj.loan__Account__c).Renewal_Amount_Commission__c=='Gross Amount' && lendingAccountMap.containsKey(broObj.loan__Lending_Account__c))
                    {
                        totalAmount = calculateDisbursalDistributionTxnFields(distributionTxnList, Brokers.FUNDED_SOURCES_ON_GROSS_AMOUNT);
                        broObj.Commission_Point__c = lendingAccountMap.get(broObj.loan__Lending_Account__c).Broker_Standard_Commission__c;
                        broObj.loan__Commission_Amount__c = totalAmount*(lendingAccountMap.get(broObj.loan__Lending_Account__c).Broker_Standard_Commission__c/100);
                        broObj.Commission_Payable__c = broObj.loan__Commission_Amount__c;
                        broObj.Commission_Calculation_Message__c = 'Broker Commission calculated Successfully.';
                     // Scenario 4 : Net Amount(Disbursement amount) with flat renewal commission % from broker account record)
                    }else if(brokerAccountMap.get(broObj.loan__Account__c).Renewal_Amount_Commission__c == 'Net Amount' && lendingAccountMap.containsKey(broObj.loan__Lending_Account__c))
                    {
                        totalAmount = calculateDisbursalDistributionTxnFields(distributionTxnList, Brokers.FUNDED_SOURCES_ON_NET_AMOUNT);
                        broObj.Commission_Point__c = lendingAccountMap.get(broObj.loan__Lending_Account__c).Broker_Standard_Commission__c;
                        broObj.loan__Commission_Amount__c = totalAmount*(lendingAccountMap.get(broObj.loan__Lending_Account__c).Broker_Standard_Commission__c/100);
                        broObj.Commission_Payable__c = broObj.loan__Commission_Amount__c;
                        broObj.Commission_Calculation_Message__c = 'Broker Commission calculated Successfully.';
                    }
                } else if(brokerAccountMap.containsKey(broObj.loan__Account__c) && lendingAccountMap.get(broObj.loan__Lending_Account__c).Broker_Standard_Commission__c != null
                    && brokerAccountMap.get(broObj.loan__Account__c).Renewal_Max_Broker_Commission__c != null
                    && lendingAccountMap.get(broObj.loan__Lending_Account__c).Broker_Standard_Commission__c>brokerAccountMap.get(broObj.loan__Account__c).Renewal_Max_Broker_Commission__c)
                {
                    broObj.Commission_Point__c = 0.0;
                    broObj.loan__Commission_Amount__c = 0.0;
                    broObj.Commission_Payable__c = 0.0;
                    broObj.Commission_Calculation_Message__c = 'Broker commission is calculating more than Renewal Maximum Commission %. ';

                }
            }
        }
        return brokerList;
    }

    private static void commissionBasedOnField(loan__Broker__c broObj) {
        if(brokerAccountMap.containsKey(broObj.loan__Account__c)
           && brokerAccountMap.get(broObj.loan__Account__c).Commision_Based_On__c == Brokers.COMMISSION_CALC_METHOD_FLAT) {
            // Scenario 7: Updating flat referral fee amount if commission type selected as Flat at broker account level.
            broObj.Flat_Referral_Fee__c = brokerAccountMap.get(broObj.loan__Account__c).Flat_Referral_Fee__c;
            broObj.loan__Commission_Amount__c = broObj.Flat_Referral_Fee__c;
            broObj.Commission_Point__c = 0.0;
            broObj.Commission_Payable__c = broObj.Flat_Referral_Fee__c;
            broObj.Commission_Calculation_Message__c = 'Flat Referral Fee updated Successfully.';
        } else if(brokerAccountMap.containsKey(broObj.loan__Account__c)
            && brokerAccountMap.get(broObj.loan__Account__c).Commision_Based_On__c == Brokers.COMMISSION_CALC_METHOD_PERCENTAGE
            && disbursalTransactionMap.containsKey(broObj.Disbursal_Transaction__c)
        ) {
            if(lendingAccountMap.get(broObj.loan__Lending_Account__c).Broker_Standard_Commission__c != null) {
                broObj.Commission_Point__c = lendingAccountMap.get(broObj.loan__Lending_Account__c).Broker_Standard_Commission__c;
                broObj.loan__Commission_Amount__c = disbursalTransactionMap.get(broObj.Disbursal_Transaction__c).loan__Disbursed_Amt__c*(lendingAccountMap.get(broObj.loan__Lending_Account__c).Broker_Standard_Commission__c/100);
                broObj.Commission_Payable__c = broObj.loan__Commission_Amount__c;
                broObj.Commission_Calculation_Message__c = 'Broker Commission calculated Successfully.';
            } else {
                broObj.Commission_Point__c = 0.0;
                broObj.loan__Commission_Amount__c = 0.0;
                broObj.Commission_Payable__c = 0.0;
                broObj.Commission_Calculation_Message__c = 'Broker commission is not calculating due to no valid Broker Commission % found.';
            }
        }
    }

    private static Decimal calculateDisbursalDistributionTxnFields(
        List<loan__Disbursal_Txn_Distribution__c> distributionTxnList, Set<String> fundedSources
    ) {
        Decimal totalDisbursalDistributionTxn = 0;
        for (loan__Disbursal_Txn_Distribution__c disbursalTxn : distributionTxnList) {
            if(fundedSources.contains(disbursalTxn.Funded_Source__c)) {
                totalDisbursalDistributionTxn += disbursalTxn.loan__Distribution_Amount__c;
            }
        }
        return totalDisbursalDistributionTxn;
    }
}