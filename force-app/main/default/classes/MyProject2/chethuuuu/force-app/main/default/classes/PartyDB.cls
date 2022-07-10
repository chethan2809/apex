public class PartyDB extends DBManager {
    public List<clcommon__Party__c> getPartiesByApplicationIdsAndPartyTypeId(Set<Id> applicationIds, Id partyTypeId){
        return [
            SELECT Id, clcommon__Account__c, clcommon__Contact__c, genesis__Application__c
            FROM clcommon__Party__c
            WHERE genesis__Application__c IN :applicationIds
                AND clcommon__Type__c = :partyTypeId
        ];
    }

    public List<clcommon__Party__c> getPartiesByApplicationIdsAndPartyTypeIds(Set<Id> applicationIds, Set<Id> partyTypeIds) {
        return [
            SELECT Id, clcommon__Contact__r.Email, clcommon__Contact__r.Name, genesis__Application__c, clcommon__Type__c, clcommon__Account__c,
                genesis__Application__r.Owner.Name, clcommon__Contact__c, clcommon__isPrimary__c, clcommon__Type__r.Name,
                genesis__Application__r.genesis__Account__r.Merchant_ID__c, genesis__Application__r.genesis__Account__r.Name, genesis__Application__r.Decline_Reasons__c, genesis__Application__r.genesis__Account__r.Business_Name__c,
                genesis__Application__r.genesis__Account__r.Business_Tax_ID__c, genesis__Application__r.Name, genesis__Application__r.genesis__Account__r.BillingAddress, genesis__Application__r.genesis__Account__r.Industry,
                genesis__Application__r.Business_Type__c, genesis__Application__r.Business_Start_Date__c, genesis__Application__r.Broker_Contact__c, genesis__Application__r.Broker_Contact__r.Account.Name,
                genesis__Application__r.genesis__Account__r.BillingStreet, genesis__Application__r.genesis__Account__r.BillingCity,
                genesis__Application__r.genesis__Account__r.BillingState, genesis__Application__r.genesis__Account__r.BillingPostalCode,
                genesis__Application__r.genesis__Account__r.BillingCountry, clcommon__Account__r.BillingStreet, clcommon__Account__r.BillingCity, clcommon__Account__r.BillingState, clcommon__Account__r.BillingPostalCode,
                clcommon__Account__r.BillingCountry, clcommon__Account__r.BillingBuildingNumber__c, clcommon__Account__r.Name, clcommon__Contact__r.FirstName, clcommon__Contact__r.LastName,
                clcommon__Contact__r.Last_Consumer_Credit_Pull__c, clcommon__Account__r.Email_cc__c,
                genesis__Application__r.Confirmed_Fraud_Flag__c, clcommon__Account__r.Confirmed_Fraud_Flag__c,
                clcommon__Contact__r.Confirmed_Fraud_Flag__c, clcommon__Contact__r.FICO_MKT__c,
                clcommon__Contact__r.Reasons_for_Credit_Score__c, clcommon__Contact__r.Last_Date_of_Inquiry__c,
                Credit_Report_Message__c, Last_Date_of_Inquiry__c
            FROM clcommon__Party__c
            WHERE genesis__Application__c IN :applicationIds
                AND clcommon__Type__c IN :partyTypeIds
        ];
    }

    public List<clcommon__Party__c> getAllPartiesByApplicationIds(Set<Id> applicationIds) {
        return [
            SELECT Id, clcommon__Account__c, clcommon__Contact__c, genesis__Application__c, clcommon__Type__c, clcommon__Type__r.Name, CL_Contract__c
            FROM clcommon__Party__c
            WHERE genesis__Application__c IN :applicationIds
        ];
    }

    public List<clcommon__Party__c> getBorrowerAndPrimanyGuarantorByApplicationIds(Set<Id> applicationIds) {
        return [
            SELECT Id, clcommon__Account__c, clcommon__Contact__c, genesis__Application__c, clcommon__Type__c, clcommon__isPrimary__c,
                genesis__Application__r.genesis__Account__c
            FROM clcommon__Party__c
            WHERE genesis__Application__c IN :applicationIds
                AND (
                    clcommon__Type__c = :OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BORROWER)
                    OR (clcommon__Type__c = :OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_GUARANTOR)
                        AND clcommon__isPrimary__c = true
                    )
                )
        ];
    }

    public List<clcommon__Party__c> getRecentApplicationsListForBrokerPortalDashboard(Set<Id> brokerIds) {
        return [
            SELECT Id, Name, clcommon__Account__r.Name, genesis__application__r.Id, genesis__application__r.Name,
                genesis__Application__r.genesis__Contact__c, genesis__Application__r.genesis__Contact__r.clcommon__Legal_Entity_Type__c,
                genesis__Application__r.genesis__Account__r.clcommon__Legal_Entity_Type__c, genesis__application__r.genesis__Account__r.Name,
                genesis__application__r.genesis__Status__c, clcommon__Type__c, genesis__application__r.portal_bucket__c,
                genesis__application__r.genesis__Loan_Amount__c, genesis__application__r.CreatedDate, genesis__Application__r.Type__c,
                clcommon__Contact__r.Name, genesis__Application__r.Overall_Status__c
            FROM clcommon__Party__c
            WHERE genesis__application__r.OwnerId =:brokerIds
                AND clcommon__Type__c = :OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BROKER)
                AND (genesis__Application__r.Type__c = :PortalConstants.LOAN_TYPE_NEW
                    OR (genesis__Application__r.Type__c = :PortalConstants.LOAN_TYPE_RENEWAL
                        AND genesis__application__r.genesis__Status__c = :PortalConstants.APPLICATION_CLOSED_APPROVED)
                    OR genesis__Application__r.Type__c = :PortalConstants.LOAN_TYPE_CONCURRENT)
            ORDER BY genesis__Application__r.Name DESC LIMIT 5
        ];
    }

    public List<clcommon__Party__c> getApplicationsListForBrokerPortalOnCategories(Set<String> buckets, Set<Id> brokerIds) {
        return [
            SELECT Id, Name, clcommon__Account__r.Name, genesis__application__r.Id, genesis__application__r.Name,
                genesis__Application__r.genesis__Contact__c, genesis__Application__r.genesis__Contact__r.clcommon__Legal_Entity_Type__c,
                genesis__Application__r.genesis__Account__r.clcommon__Legal_Entity_Type__c, genesis__application__r.genesis__Account__r.Name,
                genesis__application__r.genesis__Status__c, genesis__application__r.portal_bucket__c, clcommon__Type__c,
                genesis__application__r.genesis__Loan_Amount__c, genesis__application__r.CreatedDate, genesis__Application__r.Type__c,
                clcommon__Contact__r.Name, genesis__Application__r.Overall_Status__c, genesis__Application__r.Decline_Reasons__c
            FROM clcommon__Party__c
            WHERE genesis__application__r.portal_bucket__c = :buckets
                AND genesis__application__r.OwnerId =:brokerIds
                AND clcommon__Type__c = :OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BROKER)
                AND (genesis__Application__r.Type__c = :PortalConstants.LOAN_TYPE_NEW
                    OR (genesis__Application__r.Type__c = :PortalConstants.LOAN_TYPE_RENEWAL
                        AND genesis__application__r.genesis__Status__c = :PortalConstants.APPLICATION_CLOSED_APPROVED)
                    OR genesis__Application__r.Type__c = :PortalConstants.LOAN_TYPE_CONCURRENT)
            ORDER BY genesis__Application__r.Name DESC
        ];
    }


    public List<clcommon__Party__c> getApplicationsListForBrokerPortalOnCategoryFunded(Set<String> buckets, Set<Id> brokerIds, Date lastNinetyDays) {
        return [
            SELECT Id, Name, clcommon__Account__r.Name, genesis__application__r.Id, genesis__application__r.Name,
                genesis__Application__r.genesis__Contact__c, genesis__Application__r.genesis__Contact__r.clcommon__Legal_Entity_Type__c,
                genesis__Application__r.genesis__Account__r.clcommon__Legal_Entity_Type__c, genesis__application__r.genesis__Account__r.Name,
                genesis__application__r.genesis__Status__c, genesis__application__r.portal_bucket__c, clcommon__Type__c,
                genesis__application__r.genesis__Loan_Amount__c, genesis__application__r.CreatedDate, genesis__Application__r.Type__c,
                clcommon__Contact__r.Name, genesis__Application__r.Overall_Status__c, genesis__Application__r.Decline_Reasons__c
            FROM clcommon__Party__c
            WHERE genesis__application__r.portal_bucket__c = :buckets
                AND genesis__application__r.OwnerId =:brokerIds
                AND clcommon__Type__c = :OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BROKER)
                AND (genesis__Application__r.Type__c = :PortalConstants.LOAN_TYPE_NEW
                    OR (genesis__Application__r.Type__c = :PortalConstants.LOAN_TYPE_RENEWAL
                        AND genesis__application__r.genesis__Status__c = :PortalConstants.APPLICATION_CLOSED_APPROVED)
                    OR genesis__Application__r.Type__c = :PortalConstants.LOAN_TYPE_CONCURRENT)
                AND genesis__application__r.Contract_Approved_Date__c >= :lastNinetyDays
            ORDER BY genesis__Application__r.Name DESC
        ];
    }

    public List<clcommon__Party__c> getApplicationsListForBrokerPortalOnCategoryClosedDeclined(Set<String> buckets, Set<Id> brokerIds, Date lastNinetyDays) {
        return [
            SELECT Id, Name, clcommon__Account__r.Name, genesis__application__r.Id, genesis__application__r.Name,
                genesis__Application__r.genesis__Contact__c, genesis__Application__r.genesis__Contact__r.clcommon__Legal_Entity_Type__c,
                genesis__Application__r.genesis__Account__r.clcommon__Legal_Entity_Type__c, genesis__application__r.genesis__Account__r.Name,
                genesis__application__r.genesis__Status__c, genesis__application__r.portal_bucket__c, clcommon__Type__c,
                genesis__application__r.genesis__Loan_Amount__c, genesis__application__r.CreatedDate, genesis__Application__r.Type__c,
                clcommon__Contact__r.Name, genesis__Application__r.Overall_Status__c, genesis__Application__r.Decline_Reasons__c
            FROM clcommon__Party__c
            WHERE genesis__application__r.portal_bucket__c = :buckets
                AND genesis__application__r.OwnerId =:brokerIds
                AND clcommon__Type__c = :OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BROKER)
                AND (genesis__Application__r.Type__c = :PortalConstants.LOAN_TYPE_NEW
                    OR (genesis__Application__r.Type__c = :PortalConstants.LOAN_TYPE_RENEWAL
                        AND genesis__application__r.genesis__Status__c = :PortalConstants.APPLICATION_CLOSED_APPROVED)
                    OR genesis__Application__r.Type__c = :PortalConstants.LOAN_TYPE_CONCURRENT)
                AND genesis__application__r.Application_Declined_Date__c >= :lastNinetyDays
            ORDER BY genesis__Application__r.Name DESC
        ];
    }
    public List<clcommon__Party__c> getALLApplicationsListForBrokerPortal(Set<Id> brokerIds) {
        return [
            SELECT Id, Name, clcommon__Account__r.Name, genesis__application__r.Id, genesis__application__r.Name,
                genesis__Application__r.genesis__Contact__c, genesis__Application__r.genesis__Contact__r.clcommon__Legal_Entity_Type__c,
                genesis__Application__r.genesis__Account__r.clcommon__Legal_Entity_Type__c, genesis__application__r.genesis__Account__r.Name,
                genesis__application__r.genesis__Status__c, genesis__application__r.portal_bucket__c,
                genesis__application__r.genesis__Loan_Amount__c, clcommon__Type__c, genesis__application__r.CreatedDate,
                genesis__Application__r.Type__c, clcommon__Contact__r.Name, genesis__Application__r.Overall_Status__c
            FROM clcommon__Party__c
            WHERE genesis__application__r.OwnerId =:brokerIds
                AND clcommon__Type__c = :OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BROKER)
                AND (genesis__Application__r.Type__c = :PortalConstants.LOAN_TYPE_NEW
                    OR (genesis__Application__r.Type__c = :PortalConstants.LOAN_TYPE_RENEWAL
                        AND genesis__application__r.genesis__Status__c = :PortalConstants.APPLICATION_CLOSED_APPROVED)
                    OR genesis__Application__r.Type__c = :PortalConstants.LOAN_TYPE_CONCURRENT)
            ORDER BY genesis__Application__r.Name DESC
        ];
    }

    public List<clcommon__Party__c> getALLApplicationsListForBrokerPortalAdvancedFilter(Set<Date> fromDate, Set<Date> toDate,
                                                                                        Set<Integer> minLoanAmount,
                                                                                        Set<Integer> maxLoanAmount,
                                                                                        Set<String> applicationIds,
                                                                                        Set<String> accounts,
                                                                                        Set<Id> brokerIds) {
        return [
            SELECT genesis__application__r.Id, genesis__application__r.Name, genesis__application__r.genesis__Status__c,
                genesis__application__r.genesis__Account__r.Name, genesis__application__r.genesis__Loan_Amount__c,
                genesis__application__r.CreatedDate, clcommon__Account__r.Name, clcommon__Type__c, genesis__Application__r.Type__c,
                clcommon__Contact__r.Name, genesis__Application__r.Overall_Status__c
            FROM clcommon__Party__c
            WHERE (clcommon__Type__c = :OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BROKER)
                AND (genesis__application__r.OwnerId = :brokerIds)
                AND (genesis__application__r.createdDate >= :fromDate
                AND genesis__application__r.CreatedDate <= :toDate)
                AND (genesis__application__r.genesis__Loan_Amount__c >= :minLoanAmount
                AND genesis__application__r.genesis__Loan_Amount__c <= :maxLoanAmount)
                AND (genesis__application__r.Name LIKE :applicationIds
                AND genesis__application__r.genesis__Account__r.Name LIKE :accounts))
                AND (genesis__Application__r.Type__c = :PortalConstants.LOAN_TYPE_NEW
                    OR (genesis__Application__r.Type__c = :PortalConstants.LOAN_TYPE_RENEWAL
                        AND genesis__application__r.genesis__Status__c = :PortalConstants.APPLICATION_CLOSED_APPROVED)
                    OR genesis__Application__r.Type__c = :PortalConstants.LOAN_TYPE_CONCURRENT)
            ORDER BY genesis__application__r.createdDate DESC
        ];
    }

    public List<clcommon__Party__c> getBorrowerAndGuarantorsByApplicationIds(Set<Id> applicationIds) {
        return [
            SELECT Id, clcommon__Account__c, clcommon__Contact__c, genesis__Application__c, genesis__Application__r.genesis__Account__c, clcommon__Type__r.Name,
                clcommon__Type__c, clcommon__isPrimary__c, clcommon__Account__r.Name, clcommon__Contact__r.FirstName, clcommon__Contact__r.LastName
            FROM clcommon__Party__c
            WHERE genesis__Application__c IN :applicationIds
                AND (
                    clcommon__Type__c = :OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BORROWER)
                    OR clcommon__Type__c = :OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_GUARANTOR))
        ];
    }

    public List<clcommon__Party__c> getBorrowerGuarantorsAndContactBeneficialOwnersByApplicationIds(Set<Id> applicationIds) {
        return [
            SELECT Id, clcommon__Account__c, clcommon__Contact__c, genesis__Application__c, genesis__Application__r.genesis__Account__c,
                clcommon__Type__c, clcommon__isPrimary__c
            FROM clcommon__Party__c
            WHERE genesis__Application__c IN :applicationIds
                AND (
                    clcommon__Type__c = :OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BORROWER)
                    OR clcommon__Type__c = :OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_GUARANTOR)
                    OR (clcommon__Type__c = :OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_CONTACT)
                        AND Beneficial_Owner_Type__c != 'N/A'
                    )
                )
        ];
    }

    public List<clcommon__Party__c> getGuarantorsAndContactBeneficialOwnersByApplicationIds(Set<Id> applicationIds) {
        return [
            SELECT Id, clcommon__Account__c, clcommon__Contact__c, clcommon__Contact__r.FirstName, clcommon__Contact__r.LastName,
                genesis__Application__c, clcommon__Type__c, clcommon__isPrimary__c
            FROM clcommon__Party__c
            WHERE genesis__Application__c IN :applicationIds
                AND (clcommon__Type__c = :OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_GUARANTOR)
                    OR (clcommon__Type__c = :OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_CONTACT)
                        AND Beneficial_Owner_Type__c != 'N/A'
                    )
                )
        ];
    }

    public List<clcommon__Party__c> getAdditionalGuarantorsAndContactBeneficialOwnersByApplicationIds(Set<Id> applicationIds) {
        return [
            SELECT Id, clcommon__Account__c, clcommon__Contact__c, genesis__Application__c, clcommon__Type__c,
                Beneficial_Owner_Type__c
            FROM clcommon__Party__c
            WHERE genesis__Application__c IN :applicationIds
                AND ((clcommon__Type__c = :OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_GUARANTOR)
                        AND clcommon__isPrimary__c = false
                    )
                    OR clcommon__Type__c = :OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_CONTACT)
                )
        ];
    }

    public List<clcommon__Party__c> getCompetitorPartiesByApplicationIds(Set<Id> applicationIds) {
        return [
            SELECT Id, clcommon__Account__c, clcommon__Contact__c, genesis__Application__c, clcommon__Type__c, Competitor_Amount__c,
            Competitor_Bank_Account__r.loan__Bank_Name__c, Competitor_Bank_Account__r.loan__Bank_Account_Number__c,
            Competitor_Bank_Account__r.loan__Routing_Number__c
            FROM clcommon__Party__c
            WHERE genesis__Application__c IN :applicationIds
                AND clcommon__Type__c = :OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_COMPETITOR)
                    AND isDeleted = false
        ];
    }

    public List<clcommon__Party__c> getPartiesByApplicationAndAccountIds(Set<Id> applicationIds, Set<Id> accountIds) {
        return [
            SELECT Id, Name
            FROM clcommon__Party__c
            WHERE genesis__Application__c IN :applicationIds
            AND clcommon__Account__c = :accountIds
        ];
    }

    public List<clcommon__Party__c> getGuarantorPartiesByApplicationIds(Set<Id> applicationIds) {
        return [
            SELECT Id, clcommon__Account__c, clcommon__Contact__c
            FROM clcommon__Party__c
            WHERE genesis__Application__c IN :applicationIds
                AND clcommon__Type__c = :OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_GUARANTOR)
        ];
    }

    public List<clcommon__Party__c> getFraudBorrowerANDGuarantorPartiesByAccountContactIds(Set<Id> accountAndContactIds) {
        return [
            SELECT Id, genesis__Application__c, genesis__Application__r.Name, genesis__Application__r.Confirmed_Fraud_Flag__c,
                clcommon__Account__c, clcommon__Account__r.Confirmed_Fraud_Flag__c, clcommon__Contact__c,
                clcommon__Contact__r.Confirmed_Fraud_Flag__c, clcommon__Type__c
            FROM clcommon__Party__c
            WHERE ((clcommon__Type__c = :OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BORROWER)
                    AND clcommon__Account__c IN :accountAndContactIds
                    AND clcommon__Account__r.Confirmed_Fraud_Flag__c = true)
                OR (clcommon__Type__c = :OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_GUARANTOR)
                    AND clcommon__Contact__c IN :accountAndContactIds
                    AND clcommon__Contact__r.Confirmed_Fraud_Flag__c = true))
                AND genesis__Application__r.Confirmed_Fraud_Flag__c = true
            ORDER BY genesis__Application__c
        ];
    }

    public List<clcommon__Party__c> getGuarantorANDBrokerPartiesByApplicationIds(Set<Id> applicationIds) {
        return [
            SELECT Id, clcommon__Account__c, clcommon__Contact__c, clcommon__Type__r.Name
            FROM clcommon__Party__c
            WHERE genesis__Application__c IN :applicationIds
            AND clcommon__Type__c IN (:OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_GUARANTOR),
                :OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BROKER))
        ];
    }

    public List<clcommon__Party__c> getPartiesByIds(Set<Id> partyIds){
        return[
            SELECT Id, Competitor_Bank_Account__r.loan__Bank_Name__c, Competitor_Bank_Account__r.loan__Bank_Account_Number__c,
                Competitor_Bank_Account__r.loan__Routing_Number__c
            FROM clcommon__Party__c
            WHERE Id IN:partyIds
        ];
    }
}