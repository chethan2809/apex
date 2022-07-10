public class ClawbackUtil {
    @TestVisible
    private static BrokerDB brokerDBInstance = new BrokerDB();
    @TestVisible
    private static CLContractDB clContractDBInstance = new CLContractDB();
    @TestVisible
    private static AccountDB accountDBInstance = new AccountDB();
    @TestVisible
    private static ClawbackDB clawbackDBInstance =  new ClawbackDB();

    public static void processClawBack(Map<Id, loan__Loan_Account__c> clawbackLoanAccountMap, Set<Id> brokerAccountIds) {
        List<loan__Broker__c> brokerList = brokerDBInstance.getBrokerListByLoanAccountIdsAndBrokerAccountIds(
            brokerAccountIds, clawbackLoanAccountMap.keySet()
        );
        List<loan__Broker__c> updatedBrokerList = new List<loan__Broker__c>();
        List<Clawback__c> clawbackList = new List<Clawback__c>();

        for(loan__Broker__c loanBrokerObj : brokerList) {
            String uniqueKey = loanBrokerObj.loan__Lending_Account__c + '_' + loanBrokerObj.loan__Account__c;
            if(clawbackLoanAccountMap.containsKey(loanBrokerObj.loan__Lending_Account__c)
                && clawbackLoanAccountMap.get(loanBrokerObj.loan__Lending_Account__c).Broker_Contact__r.AccountId == loanBrokerObj.loan__Account__c
                && loanBrokerObj.loan__Commission_Amount__c > 0.0
            ) {
                Clawback__c clawback = new Clawback__c(
                    Broker_Account__c = loanBrokerObj.loan__Account__c,
                    Lending_Account__c = loanBrokerObj.loan__Lending_Account__c,
                    Clawback_Amount__c = loanBrokerObj.loan__Commission_Amount__c
                );
                clawbackList.add(clawback);
                updatedBrokerList.add(new loan__Broker__c(Id = loanBrokerObj.Id, Is_Clawback__c = true));
            }
        }

        if(!clawbackList.isEmpty()) {
            clawbackDBInstance.addInserts(clawbackList);
            clawbackDBInstance.executeInserts();

            brokerDBInstance.addUpdates(updatedBrokerList);
            brokerDBInstance.executeUpdates();
        }
    }

    public static void updateTotalClawbackAmount(List<Clawback__c> clawbackList) {
        Set<Id> brokerAccountIds = new Set<Id>();

        for(Clawback__c clawBackObj : clawbackList) {
            brokerAccountIds.add(clawBackObj.Broker_Account__c);
        }

        Map<Id, Account> brokerAccMap = new Map<Id, Account>(accountDBInstance.getAccountByIds(brokerAccountIds));

        Decimal totalClawbackAmount = 0.0;
        for(Clawback__c clawBackObj : clawbackList) {
            if(brokerAccMap.containsKey(clawBackObj.Broker_Account__c)) {
                Account accountObj = brokerAccMap.get(clawBackObj.Broker_Account__c);
                totalClawbackAmount = accountObj.Total_Clawback_Amount__c;
                if(totalClawbackAmount == null) {
                    totalClawbackAmount = 0.0;
                }
                accountObj.Total_Clawback_Amount__c = totalClawbackAmount + clawBackObj.Clawback_Amount__c;
                accountDBInstance.addUpdate(accountObj);
            }
        }
        accountDBInstance.executeUpdates();
    }

}