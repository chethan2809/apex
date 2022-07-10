public class ApplicationDB extends DBManager {

    public ApplicationDB executeInserts(genesis__Applications__c application) {
        genesis.BorrowerAPI4 borrowerAPI = genesis.APIFactory.getBorrowerAPI4();
        borrowerAPI.createApplication(application, null, null);
        return this;
    }

    public List<genesis__Applications__c> getApplicationPartiesConsentById(Set<Id> applicationIds) {
        return [
            SELECT Id, Name, genesis__Status__c, Credit_Check_Consent__c, Electronic_Consent_Check__c, Portal_Stage__c,
                Portal_Sub_Stage__c,
                (SELECT Id,
                    genesis__Credit_Check_Consent__c,
                    clcommon__Electronic_Consent__c,
                    clcommon__Type__r.Name,
                    clcommon__Account__c
                FROM genesis__Parties__r)
            FROM genesis__Applications__c
            WHERE Id IN :applicationIds
        ];
    }

    public List<genesis__Applications__c> getApplicationsByIds(Set<Id> applicationIds) {
        return [
            SELECT Id, Name, Opportunity__c, genesis__Payment_Frequency__c, genesis__Loan_Amount__c, genesis__Term__c, Industry_Rating__c,
                SC4_Tier__c, Type__c, Business_Type__c, genesis__Account__c, genesis__Account__r.AnnualRevenue, Primary_Guarantor__c,
                Random_Number__c, genesis__Status__c, Decline_Reasons__c, Annual_Volume__c, Is_Manual_Score_Run__c,
                genesis__Expected_First_Payment_Date__c, Last_Status_Update_Date__c, genesis__Expected_Close_Date__c,
                genesis__Account__r.Legacy_Negative_CAN_History__c, Opportunity__r.Refinanced_CL_Contract__c,
                genesis__Account__r.BillingBuildingNumber__c, genesis__Account__r.Name, genesis__Account__r.BillingStreet,
                genesis__Account__r.BillingCity, genesis__Account__r.BillingState, genesis__Account__r.BillingPostalCode,
                genesis__Account__r.Legacy_Percent_Paid__c,
                Credit_Pull_Notification_Date__c, genesis__Expected_Start_Date__c, Auto_Renewed__c, Total_Competitors_Amount__c,
                Broker_Contact__c, Broker_Contact__r.Account.Default_Broker_Commission__c, Broker_Contact__r.Email,
                Broker_Contact__r.Account.New_Max_Broker_Commission__c, Broker_Contact__r.Account.Renewal_Amount_Commission__c,
                Broker_Contact__r.Account.Commision_Based_On__c, Broker_Contact__r.Account.Is_Flat_Renewal__c,
                Broker_Contact__r.Account.Flat_Renewal_Commission__c, Broker_Contact__r.Account.Flat_Referral_Fee__c,
                Broker_Contact__r.Account.Pricing_Partner_Type__c,
                Renewal_Concurrent_LoanAccount__r.Concurrent_Eligible_Amount__c, Origination_Fee_Percentage__c,
                Oldest_Unpaid_Due_As_Of_Today__c, Origination_Fee_Amount__c,
                Max_Broker_Commission__c, genesis__Maturity_Date__c, genesis__Interest_Rate__c, Pricing_Factor__c,
                Maximum_Funding_Amount__c, Is_EIS_Renewal__c, genesis__Account__r.Merchant_ID__c, genesis__Account__r.Business_Name__c,
                Broker_Contact__r.Account.Name, genesis__Account__r.Industry, Business_Start_Date__c, genesis__Account__r.BillingCountry,
                Primary_Guarantor__r.Name, Broker_Contact__r.Account.Email_cc__c, Opportunity__r.Offer_Notification_To_Broker__c,
                Opportunity__r.Offer_Notification_To_Guarantor__c, Sales_Rep__c, Sales_Rep__r.Email, Broker_Commission_Amount__c,
                Overall_Status__c, genesis__Account__r.Days_Since_Zero_Balance_Date__c, genesis__Account__r.Is_Exclusivity__c,
                Bank_Account__c, Bank_Account__r.Name, genesis__Account__r.Partner_Account_Manager__r.Email, Opportunity__r.Owner.Email,
                Broker_Account__r.Is_Broker_Active__c, Broker_Account__r.Enable_Secure_Partner_Links__c, Partner_Pricing_Generate_Doc_Count__c,
                Broker_Contact__r.Account.renewal_funding_notice__c, Broker_Contact__r.Account.Type
            FROM genesis__Applications__c
            WHERE Id IN :applicationIds
        ];
    }

    public List<genesis__Applications__c> getActiveApplicationsByOpportunityIds(Set<Id> opportunityIds) {
        Set<String> notInProgressStatuses = new Set<String> {Applications.STATUS_APPROVED, Applications.STATUS_DECLINED};

        return [
            SELECT Id, Name, genesis__Status__c, Credit_Check_Consent__c, Opportunity__c,
                Decline_Reasons__c, Overall_Status__c, genesis__Account__c
            FROM genesis__Applications__c
            WHERE genesis__Status__c NOT IN :notInProgressStatuses
                AND Opportunity__c IN :opportunityIds
        ];
    }

    public List<genesis__Applications__c> getApplicationListByBorrowerAccId(Set<Id> borrowerAccountIds) {
        return [
            SELECT Id, Name, genesis__Account__c,
                (SELECT Id,clcommon__Type__r.Name, clcommon__Type__c, clcommon__Account__c, clcommon__Contact__c,
                clcommon__Contact__r.Title__c, clcommon__Contact__r.FirstName, clcommon__Contact__r.LastName, clcommon__Contact__r.Email,
                clcommon__Contact__r.MobilePhone, clcommon__Contact__r.Birthdate, clcommon__Contact__r.genesis__SSN__c,
                clcommon__Contact__r.MailingStreet, clcommon__Contact__r.MailingBuildingNumber__c, clcommon__Contact__r.MailingCity,
                clcommon__Contact__r.MailingState, clcommon__Contact__r.MailingCountry, clcommon__Contact__r.MailingPostalCode
                FROM genesis__Parties__r
                WHERE clcommon__Type__c = :OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_GUARANTOR)
            ORDER BY CreatedDate ASC LIMIT 1)
            FROM genesis__Applications__c
            WHERE genesis__Account__c IN :borrowerAccountIds
            ORDER BY CreatedDate ASC LIMIT 1
          ];
    }

    public List<genesis__Applications__c> getInProgressApplicationsByAccountIds(Set<Id> accountIds) {
        Set<String> notInProgressStatuses = new Set<String> {Applications.STATUS_APPROVED, Applications.STATUS_DECLINED};
        return [
            SELECT Id, Name, genesis__Status__c, genesis__Account__c, Decline_Reasons__c, Type__c, Overall_Status__c
            FROM genesis__Applications__c
            WHERE genesis__Status__c NOT IN :notInProgressStatuses
                AND genesis__Account__c IN :accountIds
        ];
    }

    public List<genesis__Applications__c> getApplicationsWithPricingAndSTIPListByIds(Set<Id> applicationIds) {
        return [
            SELECT Id, Name, Bank_Account__c, Owner.Email, Owner.Name, Annual_Volume__c, SC4_Tier__c, Broker_Contact__r.Account.Name,
                Industry_Rating__c, Origination_Fee_Percentage__c, genesis__Account__r.Name, Type__c, Auto_Renewed__c, Maximum_Funding_Amount__c,
                genesis__Account__r.Merchant_ID__c, Sales_Rep__c, Sales_Rep__r.Email, Broker_Contact__c, Broker_Contact__r.Email,
                genesis__Requested_Loan_Amount__c, Max_Term__c, Buy_Rate__c, Pricing_Factor__c, Max_Broker_Commission__c,
                genesis__Payment_Frequency__c, Broker_Contact__r.Account.Email_cc__c, Opportunity__r.Offer_Notification_To_Broker__c,
                Opportunity__r.Offer_Notification_To_Guarantor__c, Broker_Account__r.Generate_Secure_Partner_Links__c,
                Partner_Pricing_Secure_Link__c,
            (
                SELECT Id, Application__c, Maximum_Amount__c
                FROM CAN_Pricing_Details__r
                WHERE Status__c =: CANPricingDetails.STATUS_SENT_TO_CUSTOMER
                LIMIT 1
            ),
            (
                SELECT Id, Application__c, Additional_Banks__c, Bank_Verification_Call__c,
                    Borrower_Interview__c, Competitors__c, Federal_Tax_ID__c, Identification__c,
                    Month_to_Date_Bank_Statement__c, Proof_of_Ownership__c, Verification_Call__c, Voided_Check__c,
                    Last_Four_Bank_Account_Number__c, Guarantors_Whose_Identity_Not_Verified__c, Competitor_Names__c,
                    experian_fraud_check__c,business_loan_agreement__c,certification_of_beneficial_owners__c,refinance_agreement__c,third_party_agreement__c,
                    proof_of_business_location__c
                FROM STIPS_Checklists__r
                LIMIT 1
            )
            FROM genesis__Applications__c
            WHERE Id
            IN :applicationIds
        ];
    }

    public List<genesis__Applications__c> getApplicationsByOpportunityIds(Set<Id> opportunityIds) {
        return [
            SELECT Id, Name, Opportunity__c, Sales_Rep__c
            FROM genesis__Applications__c
            WHERE Opportunity__c IN :opportunityIds
        ];
    }

    public List<genesis__Applications__c> getClosedAndApprovedApplicationsByAccountIds(Set<Id> accountIds) {
        return [
            SELECT Id, Name, genesis__Status__c, genesis__Account__c, Decline_Reasons__c
            FROM genesis__Applications__c
            WHERE genesis__Status__c = :Applications.STATUS_APPROVED
                AND genesis__Account__c IN :accountIds
        ];
    }

    public List<genesis__Applications__c> getPartnerApplicationByName(Set<String> applicationNames) {
        return [
            SELECT Id, Name, genesis__Status__c, Broker_Contact__r.Email, Decline_Reasons__c, Broker_Contact__c,
                Broker_Contact__r.AccountId, Broker_Contact__r.Account.Partner_API_Key__c, Overall_Status__c
            FROM genesis__Applications__c
            WHERE  Name IN :applicationNames
        ];
    }

    public List<genesis__Applications__c> getApplicationsByIdsAndBrokerIds(Set<Id> applicationIds, Set<Id> brokerUserIds) {
        return [
            SELECT Id, Name, OwnerId
            FROM genesis__Applications__c
            WHERE  Id IN :applicationIds
                AND OwnerId IN :brokerUserIds
        ];
    }

    public List<genesis__Applications__c> getApplicationsByBorrowerAccountIds(Set<Id> accountIds) {
        return [
            SELECT Id, Name, Is_Manual_Score_Run__c, genesis__Account__c, Overall_Status__c,
                Decline_Reasons__c, genesis__Status__c, Type__c
            FROM genesis__Applications__c
            WHERE genesis__Account__c IN :accountIds
        ];
    }

    public List<genesis__Applications__c> getDeclineApplicationByDeclineUntilAndBorrowerIds(Set<Id> accountId) {
        return [
            SELECT Id, Name, Decline_Reasons__c, decline_until_date__c, genesis__Account__c
            FROM genesis__Applications__c
            WHERE genesis__Account__c = :accountId
                    AND decline_until_date__c >= :GeneralHelper.currentSystemDate
            ORDER BY Name ASC LIMIT 1
          ];
    }
}