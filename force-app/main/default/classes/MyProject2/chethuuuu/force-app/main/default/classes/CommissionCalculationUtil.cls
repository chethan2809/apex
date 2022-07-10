public class CommissionCalculationUtil {

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

    private static CommissionCalculationUtil instance = null;

    private static Map<Id,Account> brokerAccMap=new Map<Id,Account>();
    private static Map<Id,loan__Loan_Account__c> lendingAccMap=new Map<Id,loan__Loan_Account__c>();
    private static Map<Id,loan__Loan_Disbursal_Transaction__c> disbursalTransactionMap=new Map<Id,loan__Loan_Disbursal_Transaction__c>();

    public static CommissionCalculationUtil getInstance()
    {
        if(instance == null)
        {
            instance = new CommissionCalculationUtil();
        }
        return instance;
    }

    public void calculateCommission(List<loan__Broker__c> lBrokerList)
    {
        Decimal commAmount=0.0;
        Double loanAmount=0.0;
        String type='';
        Set<Id> lendingAccountIdSet=new Set<Id>();
        Set<Id> brokerAccountIdSet=new Set<Id>();
        Set<Id> disbursalTransactionIdSet=new Set<Id>();
        //System.debug('### loan__Loan_Account__c : '+lAccount);

        List<loan__Loan_Disbursal_Transaction__c> disbursalTransactionsList;
        Map<Id,Integer> disbursalTransactionCountMap=new Map<Id,Integer>();

        List<loan__Broker__c> renewalBrokerList=new List<loan__Broker__c>();
        List<loan__Broker__c> concurrentBrokerList=new List<loan__Broker__c>();
        List<loan__Broker__c> newBrokerList=new List<loan__Broker__c>();

        for(loan__Broker__c brokerObj : lBrokerList)
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

        if(lendingAccountIdSet.isEmpty()==false)
        {
            lendingAccMap=new Map<Id,loan__Loan_Account__c>(clContractDBInstance.getLoanAccountsByIds(lendingAccountIdSet));
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

        if(brokerAccountIdSet.isEmpty()==false)
        {
            brokerAccMap=new Map<Id,Account>(accountDBInstance.getAccountByIds(brokerAccountIdSet));
        }

        if(disbursalTransactionIdSet.isEmpty()==false)
        {
            disbursalTransactionMap = new Map<Id,loan__Loan_Disbursal_Transaction__c>(disbursalTransactionDBInstance.getLoanDisbursalTransactionsByIds(disbursalTransactionIdSet));
        }

        for(loan__Broker__c brokerObj : lBrokerList)
        {
            // Scenario 1 & 2: Validating is broker is active and broker is eligible to receive commision.
            if(String.isNotBlank(brokerObj.loan__Lending_Account__c)
               && lendingAccMap.containsKey(brokerObj.loan__Lending_Account__c)
               && String.isNotBlank(lendingAccMap.get(brokerObj.loan__Lending_Account__c).Type__c)
               && brokerAccMap.containsKey(brokerObj.loan__Account__c)
               && brokerAccMap.get(brokerObj.loan__Account__c).Is_Broker_Active__c
               && brokerAccMap.get(brokerObj.loan__Account__c).Commission_Eligible__c)
            {
                if(GeneralConstants.LOAN_TYPE_NEW.equalsIgnoreCase(lendingAccMap.get(brokerObj.loan__Lending_Account__c).Type__c))
                {
                    if(disbursalTransactionCountMap.containsKey(brokerObj.loan__Lending_Account__c) && disbursalTransactionCountMap.get(brokerObj.loan__Lending_Account__c)==1)
                    {
                        System.debug('### calculateCommission :: NEW_TYPE ');
                        newBrokerList.add(brokerObj);
                    }else  if(disbursalTransactionCountMap.containsKey(brokerObj.loan__Lending_Account__c) && disbursalTransactionCountMap.get(brokerObj.loan__Lending_Account__c)>1)
                    {
                        System.debug('### calculateCommission :: CONCURRENT_TYPE ');
                        concurrentBrokerList.add(brokerObj);
                    }
                }else if(GeneralConstants.LOAN_TYPE_RENEWAL.equalsIgnoreCase(lendingAccMap.get(brokerObj.loan__Lending_Account__c).Type__c))
                {
                    System.debug('### calculateCommission :: RENEWAL_TYPE ');
                    renewalBrokerList.add(brokerObj);
                }
                /*else if(GeneralConstants.LOAN_TYPE_CONCURRENT.equalsIgnoreCase(lendingAccMap.get(brokerObj.loan__Lending_Account__c).Type__c))
                {

                }*/
            }else
            {
                if(brokerAccMap.get(brokerObj.loan__Account__c).Is_Broker_Active__c==false)
                {
                    System.debug('### calculateCommission :: BROKER IS INACTIVE ');
                    brokerObj.Commission_Calculation_Message__c='Broker is not in active state to calculate commission.';
                    brokerObj.Commission_Point__c=0.0;
                    brokerObj.loan__Commission_Amount__c=0.0;
                    brokerObj.Commission_Payable__c=0.0;
                }else if(brokerAccMap.get(brokerObj.loan__Account__c).Commission_Eligible__c==false)
                {
                    System.debug('### calculateCommission :: COMMISSION NOT ELIGIBLE ');
                    brokerObj.Commission_Calculation_Message__c='Broker is not eligible to receive commission.';
                    brokerObj.Commission_Point__c=0.0;
                    brokerObj.loan__Commission_Amount__c=0.0;
                    brokerObj.Commission_Payable__c=0.0;
                }
            }
        }

        calculateNewTypeCommission(newBrokerList);
        calculateRenewalTypeCommission(renewalBrokerList);
        calculateConcurrentTypeCommission(concurrentBrokerList);

        adjustClawbackOnBrokerAccount(lBrokerList);
    }

    private void adjustClawbackOnBrokerAccount(List<loan__Broker__c> lBrokerList)
    {
         Map<Id,Account> updatedBrokerAccountMap=new Map<Id,Account>();
        Account brokerAccObj;
        boolean isAmountAdjusted=false;
        for(loan__Broker__c brokerObj : lBrokerList)
        {
            if(updatedBrokerAccountMap.containsKey(brokerObj.loan__Account__c))
            {
                brokerAccObj=updatedBrokerAccountMap.get(brokerObj.loan__Account__c);
            }else if(brokerAccMap.containsKey(brokerObj.loan__Account__c))
            {
                brokerAccObj=brokerAccMap.get(brokerObj.loan__Account__c);
            }else
            {
                brokerAccObj=null;
            }
            if(String.isNotBlank(brokerObj.loan__Account__c)
               && brokerAccObj!=null
               && brokerAccObj.Total_Clawback_Amount__c>0.0)
            {
                isAmountAdjusted=false;
                if(brokerAccObj.Total_Clawback_Amount__c>=brokerObj.loan__Commission_Amount__c)
                {
                    brokerAccObj.Total_Clawback_Amount__c=brokerAccObj.Total_Clawback_Amount__c-brokerObj.loan__Commission_Amount__c;
                    brokerObj.Commission_Payable__c=0.0;
                    isAmountAdjusted=true;
                }else if(brokerAccObj.Total_Clawback_Amount__c>=brokerObj.Flat_Referral_Fee__c)
                {
                    brokerAccObj.Total_Clawback_Amount__c=brokerAccObj.Total_Clawback_Amount__c-brokerObj.Flat_Referral_Fee__c;
                    brokerObj.Commission_Payable__c=0.0;
                    isAmountAdjusted=true;
                }else if(brokerAccObj.Total_Clawback_Amount__c<brokerObj.loan__Commission_Amount__c)
                {
                    brokerObj.Commission_Payable__c=brokerObj.loan__Commission_Amount__c-brokerAccObj.Total_Clawback_Amount__c;
                    brokerAccObj.Total_Clawback_Amount__c=0.0;
                    isAmountAdjusted=true;
                }else if(brokerAccObj.Total_Clawback_Amount__c<brokerObj.Flat_Referral_Fee__c)
                {
                    brokerObj.Commission_Payable__c=brokerObj.loan__Commission_Amount__c-brokerAccObj.Total_Clawback_Amount__c;
                    brokerAccObj.Total_Clawback_Amount__c=0.0;
                    isAmountAdjusted=true;
                }
                if(isAmountAdjusted)
                {
                    if(updatedBrokerAccountMap.containsKey(brokerAccObj.Id)==false)
                    {
                        updatedBrokerAccountMap.put(brokerAccObj.Id,brokerAccObj);
                    }
                }
            }
        }

        if(updatedBrokerAccountMap.values().isEmpty()==false)
        {
            accountDBInstance.addUpdates(updatedBrokerAccountMap.values());
            accountDBInstance.executeUpdates();
        }

    }

    /* New Loan Commission Calculation */
    private List<loan__Broker__c> calculateNewTypeCommission(List<loan__Broker__c> lBrokerList)
    {
        Set<Id> customerAccIdSet=new Set<Id>();
        if(lBrokerList.size()>0)
        {
            for(loan__Broker__c broObj : lBrokerList)
            {
                if(brokerAccMap.containsKey(broObj.loan__Account__c)
                   && lendingAccMap.containsKey(broObj.loan__Lending_Account__c))
                {
                    customerAccIdSet.add(lendingAccMap.get(broObj.loan__Lending_Account__c).loan__Account__c);
                }
            }

            if(customerAccIdSet.isEmpty()==false)
            {
                Map<Id,loan__Loan_Account__c> loanAccMap=new Map<Id,loan__Loan_Account__c>(
                    clContractDBInstance.getClosedLoanAccountsByCustomerAccountIds(customerAccIdSet));
                for(loan__Broker__c broObj : lBrokerList)
                {
                    // Validating any loan has been closed within 90 days for same borrower.
                    if(brokerAccMap.containsKey(broObj.loan__Account__c)
                       && lendingAccMap.containsKey(broObj.loan__Lending_Account__c)
                       && loanAccMap.containsKey(lendingAccMap.get(broObj.loan__Lending_Account__c).Id))
                    {
                        if(loanAccMap.get(lendingAccMap.get(broObj.loan__Lending_Account__c).Id).loan__Closed_Date__c.daysBetween(Date.today())<=90)
                        {
                            commissionBasedOnField(broObj);
                        }else if(loanAccMap.get(lendingAccMap.get(broObj.loan__Lending_Account__c).Id).loan__Closed_Date__c.daysBetween(Date.today())>90)
                        {
                            broObj.Commission_Calculation_Message__c='Broker commission is not calculating since the previous loan was paid off 90 days before. ';
                            broObj.Commission_Point__c=0.0;
                            broObj.loan__Commission_Amount__c=0.0;
                            broObj.Commission_Payable__c=0.0;
                        }
                    }else if(brokerAccMap.containsKey(broObj.loan__Account__c)
                       && lendingAccMap.containsKey(broObj.loan__Lending_Account__c)
                       && loanAccMap.containsKey(lendingAccMap.get(broObj.loan__Lending_Account__c).loan__Account__c)==false)
                    {
                        commissionBasedOnField(broObj);
                    }
                }
            }
        }
        return lBrokerList;
    }

    /* Concurrent Loan Commission Calculation */
    private List<loan__Broker__c> calculateConcurrentTypeCommission(List<loan__Broker__c> lBrokerList)
    {
        // List<loan__Broker__c> modifiedBrokerList=new List<loan__Broker__c>();
        if(lBrokerList.size()>0)
        {
            Set<Id> loanIdSet=new Set<Id>();
            for(loan__Broker__c brokerObj : lBrokerList)
            {
                loanIdSet.add(brokerObj.loan__Lending_Account__c);
            }

            Map<Id,loan__Broker__c> prevBrokerMap=new Map<Id,loan__Broker__c>();

            if(loanIdSet.size()>0)
            {
                for (loan__Broker__c prevBrokerRecord : brokerDBInstance.getBrokerListByLoanAccountIds(loanIdSet))
                {
                    if(prevBrokerMap.containsKey(prevBrokerRecord.loan__Lending_Account__c)==false)
                    {
                        prevBrokerMap.put(prevBrokerRecord.loan__Lending_Account__c,prevBrokerRecord);
                    }
                }
            }

            if(prevBrokerMap.size()>0)
            {
                for(loan__Broker__c brokerObj : lBrokerList)
                {
                    // Scenario 7 : Deriving Flat referral fee from broker account and adding to broker record.
                    if(prevBrokerMap.containsKey(brokerObj.loan__Lending_Account__c) && prevBrokerMap.get(brokerObj.loan__Lending_Account__c).Flat_Referral_Fee__c>0)
                    {
                        brokerObj.Flat_Referral_Fee__c=prevBrokerMap.get(brokerObj.loan__Lending_Account__c).Flat_Referral_Fee__c;
                        brokerObj.Commission_Calculation_Message__c='Flat Referral Fee updated Successfully.';
                        brokerObj.loan__Commission_Amount__c=0.0;
                        brokerObj.Commission_Payable__c=prevBrokerMap.get(brokerObj.loan__Lending_Account__c).Flat_Referral_Fee__c;
                    //  BR 16 Concurrent loans scenario : Same commission structure for the brokers % of the additional funding amount for Concurrent loan.
                    }else if(prevBrokerMap.containsKey(brokerObj.loan__Lending_Account__c)
                             && prevBrokerMap.get(brokerObj.loan__Lending_Account__c).Commission_Point__c>0
                             && disbursalTransactionMap.containsKey(brokerObj.Disbursal_Transaction__c)
                            )
                    {
                        brokerObj.loan__Commission_Amount__c=disbursalTransactionMap.get(brokerObj.Disbursal_Transaction__c).loan__Disbursed_Amt__c*(prevBrokerMap.get(brokerObj.loan__Lending_Account__c).Commission_Point__c/100);
                        brokerObj.Commission_Point__c=prevBrokerMap.get(brokerObj.loan__Lending_Account__c).Commission_Point__c;
                        brokerObj.Commission_Payable__c=disbursalTransactionMap.get(brokerObj.Disbursal_Transaction__c).loan__Disbursed_Amt__c*(prevBrokerMap.get(brokerObj.loan__Lending_Account__c).Commission_Point__c/100);
                        brokerObj.Commission_Calculation_Message__c='Broker Commission calculated Successfully.';
                    }
                }
            }
        }
        return lBrokerList;
    }

    /* Renewal Loan Commission Calculation */
    private List<loan__Broker__c> calculateRenewalTypeCommission(List<loan__Broker__c> lBrokerList)
    {
        List<loan__Broker__c> newFirstFundingBrokerList=new List<loan__Broker__c>();
        Set<Id> customerAccIdSet=new Set<Id>();
        if(lBrokerList.size()>0)
        {
            for(loan__Broker__c broObj : lBrokerList)
            {
                if(brokerAccMap.containsKey(broObj.loan__Account__c) && brokerAccMap.get(broObj.loan__Account__c).Is_Flat_Renewal__c)
                {
                    // Scenario 10 : Gross Amount(Loan amount from CL Contract record with flat renewal commission % from broker account record)
                    if(brokerAccMap.get(broObj.loan__Account__c).Renewal_Amount_Commission__c=='Gross Amount' && lendingAccMap.containsKey(broObj.loan__Lending_Account__c))
                    {
                        broObj.loan__Commission_Amount__c=lendingAccMap.get(broObj.loan__Lending_Account__c).loan__Loan_Amount__c*(brokerAccMap.get(broObj.loan__Account__c).Flat_Renewal_Commission__c/100);
                        broObj.Commission_Point__c=brokerAccMap.get(broObj.loan__Account__c).Flat_Renewal_Commission__c;
                        broObj.Commission_Payable__c=lendingAccMap.get(broObj.loan__Lending_Account__c).loan__Loan_Amount__c*(brokerAccMap.get(broObj.loan__Account__c).Flat_Renewal_Commission__c/100);
                        broObj.Commission_Calculation_Message__c='Broker Commission calculated Successfully.';
                     // Scenario 4 : Net Amount(Disbursment amount) with flat renewal commission % from broker account record)
                    }else if(brokerAccMap.get(broObj.loan__Account__c).Renewal_Amount_Commission__c=='Net Amount' && disbursalTransactionMap.containsKey(broObj.Disbursal_Transaction__c))
                    {
                        broObj.loan__Commission_Amount__c=disbursalTransactionMap.get(broObj.Disbursal_Transaction__c).loan__Disbursed_Amt__c*(brokerAccMap.get(broObj.loan__Account__c).Flat_Renewal_Commission__c/100);
                        broObj.Commission_Point__c=brokerAccMap.get(broObj.loan__Account__c).Flat_Renewal_Commission__c;
                        broObj.Commission_Payable__c=disbursalTransactionMap.get(broObj.Disbursal_Transaction__c).loan__Disbursed_Amt__c*(brokerAccMap.get(broObj.loan__Account__c).Flat_Renewal_Commission__c/100);
                        broObj.Commission_Calculation_Message__c='Broker Commission calculated Successfully.';
                    }
                } else if(brokerAccMap.containsKey(broObj.loan__Account__c) && brokerAccMap.get(broObj.loan__Account__c).Is_Flat_Renewal__c==false
                          && lendingAccMap.containsKey(broObj.loan__Lending_Account__c))
                {
                    customerAccIdSet.add(lendingAccMap.get(broObj.loan__Lending_Account__c).loan__Account__c);
                }
            }

            if(customerAccIdSet.size()>0)
            {
                Map<Id,loan__Broker__c> firstFundingBrokerMap=new Map<Id,loan__Broker__c>();
                for (loan__Broker__c prevBrokerRecord : brokerDBInstance.getBrokerListByCustomerAccountIds(customerAccIdSet))
                {
                    if(firstFundingBrokerMap.containsKey(prevBrokerRecord.loan__Lending_Account__r.loan__Account__c)==false)
                    {
                        firstFundingBrokerMap.put(prevBrokerRecord.loan__Lending_Account__r.loan__Account__c,prevBrokerRecord);
                    }
                }

                if(firstFundingBrokerMap.size()>0)
                {
                    for(loan__Broker__c broObj : lBrokerList)
                    {
                        if(brokerAccMap.containsKey(broObj.loan__Account__c)
                           && brokerAccMap.get(broObj.loan__Account__c).Is_Flat_Renewal__c==false
                           && firstFundingBrokerMap.containsKey(lendingAccMap.get(broObj.loan__Lending_Account__c).loan__Account__c)
                           && firstFundingBrokerMap.get(lendingAccMap.get(broObj.loan__Lending_Account__c).loan__Account__c).Commission_Point__c<=brokerAccMap.get(broObj.loan__Account__c).Renewal_Max_Broker_Commission__c)
                        {
                            // Scenario 8 : Gross Amount(Loan amount from CL Contract record with commission % of first funding on first(new) loan)
                            if(brokerAccMap.get(broObj.loan__Account__c).Renewal_Amount_Commission__c=='Gross Amount'
                               && lendingAccMap.containsKey(broObj.loan__Lending_Account__c))
                            {
                                broObj.loan__Commission_Amount__c=lendingAccMap.get(broObj.loan__Lending_Account__c).loan__Loan_Amount__c*((firstFundingBrokerMap.get(lendingAccMap.get(broObj.loan__Lending_Account__c).loan__Account__c).Commission_Point__c)/100);
                                broObj.Commission_Point__c=firstFundingBrokerMap.get(lendingAccMap.get(broObj.loan__Lending_Account__c).loan__Account__c).Commission_Point__c;
                                broObj.Commission_Payable__c=lendingAccMap.get(broObj.loan__Lending_Account__c).loan__Loan_Amount__c*((firstFundingBrokerMap.get(lendingAccMap.get(broObj.loan__Lending_Account__c).loan__Account__c).Commission_Point__c)/100);
                                broObj.Commission_Calculation_Message__c='Broker Commission calculated Successfully.';
                                // Scenario 9 : Net Amount(Disbursment amount) with commission % of first funding on first(new) loan.
                            }else if(brokerAccMap.get(broObj.loan__Account__c).Renewal_Amount_Commission__c=='Net Amount'
                                     && disbursalTransactionMap.containsKey(broObj.Disbursal_Transaction__c))
                            {
                                broObj.loan__Commission_Amount__c=disbursalTransactionMap.get(broObj.Disbursal_Transaction__c).loan__Disbursed_Amt__c*((firstFundingBrokerMap.get(lendingAccMap.get(broObj.loan__Lending_Account__c).loan__Account__c).Commission_Point__c)/100);
                                broObj.Commission_Point__c=firstFundingBrokerMap.get(lendingAccMap.get(broObj.loan__Lending_Account__c).loan__Account__c).Commission_Point__c;
                                broObj.Commission_Payable__c=disbursalTransactionMap.get(broObj.Disbursal_Transaction__c).loan__Disbursed_Amt__c*((firstFundingBrokerMap.get(lendingAccMap.get(broObj.loan__Lending_Account__c).loan__Account__c).Commission_Point__c)/100);
                                broObj.Commission_Calculation_Message__c='Broker Commission calculated Successfully.';
                            }
                        }else if(firstFundingBrokerMap.containsKey(lendingAccMap.get(broObj.loan__Lending_Account__c).loan__Account__c)
                                && firstFundingBrokerMap.get(lendingAccMap.get(broObj.loan__Lending_Account__c).loan__Account__c).Commission_Point__c>brokerAccMap.get(broObj.loan__Account__c).Renewal_Max_Broker_Commission__c)
                        {
                            broObj.Commission_Point__c=0.0;
                            broObj.loan__Commission_Amount__c=0.0;
                            broObj.Commission_Payable__c=0.0;
                            broObj.Commission_Calculation_Message__c='Broker commission is not calculating due to First funding Commission value is more than Renewal Maximum Commission %. ';
                        }
                    }
                }
            }
        }
        return lBrokerList;
    }

    private void commissionBasedOnField(loan__Broker__c broObj)
    {
        if(brokerAccMap.containsKey(broObj.loan__Account__c)
           && brokerAccMap.get(broObj.loan__Account__c).Commision_Based_On__c == Brokers.COMMISSION_CALC_METHOD_FLAT)
        {
            // Scenario 7: Updating flat referral fee amount if comission type selected as Flat at broker account level.
            broObj.Flat_Referral_Fee__c=brokerAccMap.get(broObj.loan__Account__c).Flat_Referral_Fee__c;
            broObj.loan__Commission_Amount__c=0.0;
            broObj.Commission_Point__c=0.0;
            broObj.Commission_Calculation_Message__c='Flat Referral Fee updated Successfully.';
        }else if(brokerAccMap.containsKey(broObj.loan__Account__c)
                 && brokerAccMap.get(broObj.loan__Account__c).Commision_Based_On__c == Brokers.COMMISSION_CALC_METHOD_PERCENTAGE
                 && disbursalTransactionMap.containsKey(broObj.Disbursal_Transaction__c))
        {
            if(brokerAccMap.get(broObj.loan__Account__c).Default_Broker_Commission__c<=brokerAccMap.get(broObj.loan__Account__c).New_Max_Broker_Commission__c)
            {
                broObj.Commission_Point__c=brokerAccMap.get(broObj.loan__Account__c).Default_Broker_Commission__c;
                broObj.loan__Commission_Amount__c=disbursalTransactionMap.get(broObj.Disbursal_Transaction__c).loan__Disbursed_Amt__c*(brokerAccMap.get(broObj.loan__Account__c).Default_Broker_Commission__c/100);
                broObj.Commission_Payable__c=disbursalTransactionMap.get(broObj.Disbursal_Transaction__c).loan__Disbursed_Amt__c*(brokerAccMap.get(broObj.loan__Account__c).Default_Broker_Commission__c/100);
                broObj.Commission_Calculation_Message__c='Broker Commission calculated Successfully.';
            }else
            {
                broObj.Commission_Point__c=0.0;
                broObj.loan__Commission_Amount__c=0.0;
                broObj.Commission_Payable__c=0.0;
                broObj.Commission_Calculation_Message__c='Broker commission is not calculating due to Default Broker Commission value is more than New Maximum Commission %. ';
            }
        }
    }
}