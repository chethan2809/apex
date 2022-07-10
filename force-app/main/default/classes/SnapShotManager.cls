public class SnapShotManager {
    public static CLContractDB clContractDBInstance = new CLContractDB();

    public static Map<Id, Account> updateAccount(List<Account> accountList) {
        System.debug('00accountList'+accountList);
        Map<Id, Account> accountMap = new Map<Id, Account>(accountList);
        Map<Id, loan__Loan_Account__c> contractToAccountMap = new Map<Id, loan__Loan_Account__c>();
        Map<Id, Integer> accountIdToActiveContracts = new Map<Id, Integer>();
        List<loan__Loan_Account__c> clContractList = clContractDBInstance.getCLContractsAndItsReversedPaymentTxnsByAccountIds(
            (new Map<Id, Account>(accountList)).keySet()
        );

        for(loan__Loan_Account__c clContract : clContractList) {
            Id accountId = clContract.loan__Account__c;
            if(!contractToAccountMap.containsKey(accountId) && CLContracts.LOAN_CLOSED_STATUSES.contains(clContract.loan__Loan_Status__c)) {
                contractToAccountMap.put(accountId, clContract);
            } else if (CLContracts.LOAN_ACTIVE_STATUSES.contains(clContract.loan__Loan_Status__c)) {
                contractToAccountMap.put(accountId, clContract);
            }
            if(clContract.Total_Outstanding_Repayment_Amount__c > 0) {
                if(accountIdToActiveContracts.containsKey(accountId)) {
                    accountIdToActiveContracts.put(accountId, accountIdToActiveContracts.get(accountId) + 1);
                } else {
                    accountIdToActiveContracts.put(accountId, 1);
                }
            }
        }

        Map<Id, Account> accountMapForUpdate = new Map<Id, Account>();
        System.debug('00contractToAccountMap'+contractToAccountMap);
        for(Id accountId : contractToAccountMap.keySet()) {
            Account account = accountMap.get(accountId);
            loan__Loan_Account__c clContract = contractToAccountMap.get(accountId);

            setAccountFields(account, clContract);
            setLegacyMaxMissedPaymentField(account, clContract);
            setNegativeCANHistoryFields(account, clContract);
            setClosedContractFields(account, clContract);
            setNumberOfCLSActiveContracts(account, accountIdToActiveContracts);
            setBouncesFields(account, clContract);

            accountMapForUpdate.put(accountId, account);
        }

        return accountMapForUpdate;
    }

    private static void setAccountFields(Account account, loan__Loan_Account__c clContract) {
        account.Legacy_Amount_Past_Due__c = clContract.loan__Amount_Due_Till_Current__c;
        account.Legacy_Percent_Paid__c = clContract.Percentage_Paid__c;
        account.Legacy_Current_Balance__c = clContract.Original_Payoff_Amount__c;
        account.Legacy_Payoff_Balance__c = clContract.Current_Payoff_Amount__c;
        account.Legacy_Latest_Missed_Payment_Date__c = clContract.Latest_Missed_Payment_Date__c;
        account.Concurrent_Eligible_Amount__c = clContract.Concurrent_Eligible_Amount__c;
        account.Concurrent_Remaining_Amount__c = clContract.Concurrent_Remaining_Amount__c;
        account.Last_Date_of_Activity__c = clContract.loan__Last_Payment_Date__c;
        account.Current_Active_Contract_Number__c = clContract.Name;
        account.Legacy_Renewal_Eligible__c = clContract.Is_Renewal_Eligible__c;
        account.Legacy_GAV__c = clContract.Application__r.Annual_Volume__c;
        account.Current_Payment_Amount__c = clContract.loan__Pmt_Amt_Cur__c;
        account.Current_Contract_Type__c = clContract.Type__c;
        account.Current_Remaining_Payment_Days__c = clContract.Remaining_Number_of_Payments__c;
    }

    private static void setLegacyMaxMissedPaymentField(Account account, loan__Loan_Account__c clContract) {
        account.Legacy_Number_of_Current_Missed_Payments__c = account.Legacy_Number_of_Current_Missed_Payments__c != null ? account.Legacy_Number_of_Current_Missed_Payments__c : 0;
        account.Legacy_Number_of_Current_Missed_Payments__c =+ clContract.Latest_Number_Of_Missed_Payments__c;
        account.Legacy_Max_Missed_Payments__c = account.Legacy_Max_Missed_Payments__c != null ? account.Legacy_Max_Missed_Payments__c : 0;

        if(account.Legacy_Number_of_Current_Missed_Payments__c > account.Legacy_Max_Missed_Payments__c){
            account.Legacy_Max_Missed_Payments__c = account.Legacy_Number_of_Current_Missed_Payments__c;
        }
    }

    private static void setNegativeCANHistoryFields(Account account, loan__Loan_Account__c clContract) {
        if(clContract.loan__Loan_Status__c == CLContracts.LOAN_STATUS_CLOSED_WRITTEN_OFF) {
            account.Legacy_Negative_CAN_History__c = true;
            account.Negative_CAN_History_Reason__c = 'Written Off Contract';
        } else if((clContract.loan__Frequency_of_Loan_Payment__c == GeneralConstants.FREQUENCY_DAILY) && (clContract.Latest_Number_Of_Missed_Payments__c >= 20) ||
            (clContract.loan__Frequency_of_Loan_Payment__c == GeneralConstants.FREQUENCY_WEEKLY) && (clContract.Latest_Number_Of_Missed_Payments__c >= 4)
        ) {
            System.debug('0100clContract'+clContract);
            account.Legacy_Negative_CAN_History__c = true;
            account.Negative_CAN_History_Reason__c = 'Missed Payments';
        }
    }

    private static void setClosedContractFields(Account account, loan__Loan_Account__c clContract) {
        if(clContract.loan__Loan_Status__c == CLContracts.LOAN_STATUS_CLOSED_OBLIGATION_MET) {
            account.Legacy_Number_of_Current_Missed_Payments__c = 0;
            account.Legacy_Percent_Paid__c = clContract.Percentage_Paid__c;
            account.Legacy_Payoff_Balance__c = 0;
            account.Legacy_Current_Balance__c = 0;
            account.Legacy_Amount_Past_Due__c = 0;
            account.Concurrent_Eligible_Amount__c = 0;
            account.Concurrent_Remaining_Amount__c = 0;
        }
    }

    private static void setNumberOfCLSActiveContracts(Account account, Map<Id, Integer> accountIdToActiveContracts) {
        account.Number_of_Active_CLS_Contracts__c = (accountIdToActiveContracts.get(account.Id) == null) ? 0 : accountIdToActiveContracts.get(account.Id);
        account.CLS_Active_Contract__c = (account.Number_of_Active_CLS_Contracts__c > 0);
    }

    private static void setBouncesFields(Account account, loan__Loan_Account__c clContract) {
        account.Number_Of_Bounces_in_Last_60_Days__c = 0;
        account.Legacy_Average_Bounced_Number_1M__c = 0;
        account.Legacy_Average_Bounced_Number_12M__c = 0;
        for (loan__Loan_Payment_Transaction__c lpt : clContract.loan__Loan_Payment_Transactions__r) {
            if(lpt.loan__Reversed__c && lpt.Reversed_Date__c > GeneralHelper.currentSystemDate.addDays(-30)) {
                account.Legacy_Average_Bounced_Number_1M__c++;
            }
            if(lpt.loan__Reversed__c && lpt.Reversed_Date__c > GeneralHelper.currentSystemDate.addDays(-365)) {
                account.Legacy_Average_Bounced_Number_12M__c++;
            }
            if(lpt.loan__Reversed__c && lpt.Reversed_Date__c > GeneralHelper.currentSystemDate.addDays(-60)) {
                account.Number_Of_Bounces_in_Last_60_Days__c++;
            }
        }
    }
}