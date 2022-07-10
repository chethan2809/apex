public class BrokerDB extends DBManager {
    public List<loan__Broker__c> getBrokerListByLoanAccountIds (Set<Id> loanAccountIds){
        return [
            SELECT Id,loan__Lending_Account__c,Commission_Point__c,Flat_Referral_Fee__c,
                   loan__Account__r.Flat_Referral_Fee__c
            FROM loan__Broker__c
            WHERE loan__Lending_Account__c IN : loanAccountIds
            ORDER BY loan__Lending_Account__c, CreatedDate Desc
        ];
    }

    public List<loan__Broker__c> getBrokerListByCustomerAccountIds (Set<Id> customerAccountIds){
        return [
            SELECT Id,loan__Lending_Account__c,Commission_Point__c,loan__Account__r.Flat_Referral_Fee__c,loan__Lending_Account__r.loan__Account__c
            FROM loan__Broker__c
            WHERE loan__Lending_Account__r.loan__Account__c IN : customerAccountIds
                AND loan__Lending_Account__r.Type__c =: GeneralConstants.LOAN_TYPE_NEW
            ORDER BY loan__Lending_Account__r.loan__Account__c, CreatedDate Asc
        ];
    }

    public List<loan__Broker__c> getBrokerListByLoanAccountIdsAndBrokerAccountIds (Set<Id> brokerAccountIds, Set<Id> loanAccountIds){
        return [
            SELECT Id,loan__Account__c,loan__Lending_Account__c,loan__Commission_Amount__c,
                    Flat_Referral_Fee__c,loan__Total_Commission_Paid_Amount__c,Commission_Payable__c
            FROM loan__Broker__c
            WHERE loan__Account__c IN: brokerAccountIds
                AND loan__Lending_Account__c IN: loanAccountIds
                AND loan__Commission_Amount__c > 0.0
                AND Is_Bonus_Payment__c = false
                AND Is_Clawback__c = false
            ORDER BY loan__Lending_Account__c,loan__Account__c,CreatedDate DESC
		];
    }
}