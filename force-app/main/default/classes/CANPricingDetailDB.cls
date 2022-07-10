public class CANPricingDetailDB extends DBManager {

    public List<CAN_Pricing_Detail__c> getUnArchivedPricingDetailsByApplicationIds(Set<Id> applicationIds) {
        return [
            SELECT Id, Status__c, Application__c, term_audit_complete__c
            FROM CAN_Pricing_Detail__c
            WHERE Application__c IN :applicationIds
                AND Status__c != :CANPricingDetails.STATUS_ARCHIVED
        ];
    }

    public List<CAN_Pricing_Detail__c> getCANPricingRecordByApplicationId(Id applicationId, String status){
        return [
            SELECT Id, Term__c, Application__r.Id, Selected_Amount__c, Standard_Commission__c, Status__c,
                Payment_Frequency__c, Opportunity__c
            FROM CAN_Pricing_Detail__c
            WHERE Application__c = :applicationId
                AND Status__C = :status
        ];
    }

    public List<CAN_Pricing_Detail__c> getCANPricingListByIds(Set<Id> pricingIds){
        return [
            SELECT Id, Application__c, Selected_Amount__c, Buy_Rate__c, Daily_Payment_Amount__c, Number_Of_Daily_Payments__c,
                Weekly_Payment_Amount__c, Number_Of_Weekly_Payments__c, Standard_Commission__c, Commission_Amount__c,
                Term__c, Maximum_Term__c, Maximum_Amount__c, Repayment_Amount__c, Loan_Type__c, SC4_Tier__c,
                Industry_Rating__c, GAV__c, Annual_Volume__c, Policy_Maximum_Amount__c, Daily_End_Date__c, Start_Date__c,
                Weekly_End_Date__c, Status__c, Ocrolus_Max_Daily_Payment__c, Ocrolus_Maximum_Amount__c, Payment_Frequency__c,
                Maximum_Exception_Amount__c, Max_Broker_Commission__c, Renewal_Amount_Commission__c, Broker_Commission_Based_On__c,
                Is_Flat_Renewal__c, Auto_Accept_ExceptionEligible__c, Floor_Buy_Rate__c, Max_GAV__c, Origination_Fee_Percentage__c,
                Overwrite_Policy_Default__c, Origination_Fee_Amount__c, Oldest_Unpaid_Due_As_Of_Today__c, Pricing_Factor__c,
                Opportunity__c, Pricing_Type__c, Random_Number__c
            FROM CAN_Pricing_Detail__c
            WHERE Id IN :pricingIds
        ];
    }

    public List<CAN_Pricing_Detail__c> getCANPricingListByApplicationIdsAndStatuses(
        Set<Id> applicationIds, Set<String> statuses
    ){
        return [
            SELECT Id, Application__c, Selected_Amount__c, Buy_Rate__c, Daily_Payment_Amount__c, Number_Of_Daily_Payments__c,
                Weekly_Payment_Amount__c, Number_Of_Weekly_Payments__c, Standard_Commission__c, Commission_Amount__c,
                Term__c, Maximum_Term__c, Maximum_Amount__c, Repayment_Amount__c, Loan_Type__c, SC4_Tier__c,
                Industry_Rating__c, GAV__c, Annual_Volume__c, Policy_Maximum_Amount__c, Daily_End_Date__c, Start_Date__c,
                Weekly_End_Date__c, Status__c, Ocrolus_Max_Daily_Payment__c, Ocrolus_Maximum_Amount__c, Payment_Frequency__c,
                Maximum_Exception_Amount__c, Max_Broker_Commission__c, Renewal_Amount_Commission__c, Broker_Commission_Based_On__c,
                Is_Flat_Renewal__c, Auto_Accept_ExceptionEligible__c, Floor_Buy_Rate__c, Max_GAV__c, Origination_Fee_Percentage__c,
                Overwrite_Policy_Default__c, Origination_Fee_Amount__c, Oldest_Unpaid_Due_As_Of_Today__c, Pricing_Factor__c,
                Opportunity__c, Pricing_Type__c, Random_Number__c
            FROM CAN_Pricing_Detail__c
            WHERE Application__c IN :applicationIds
                AND Status__c IN :statuses
            ORDER BY CreatedDate DESC
        ];
    }

    public List<CAN_Pricing_Detail__c> getCANPricingByApplicationId(Id applicationId){
        return [
            SELECT Id, Name, Application__c, Selected_Amount__c, Buy_Rate__c, Daily_Payment_Amount__c, Number_Of_Daily_Payments__c,
                Weekly_Payment_Amount__c, Number_Of_Weekly_Payments__c, Standard_Commission__c, Commission_Amount__c,
                Term__c, Maximum_Term__c, Maximum_Amount__c, Repayment_Amount__c, Loan_Type__c, SC4_Tier__c,
                Industry_Rating__c, GAV__c, Annual_Volume__c, Policy_Maximum_Amount__c, Daily_End_Date__c, Start_Date__c,
                Weekly_End_Date__c, Status__c, Ocrolus_Max_Daily_Payment__c, Ocrolus_Maximum_Amount__c, Payment_Frequency__c,
                Maximum_Exception_Amount__c, Max_Broker_Commission__c, Renewal_Amount_Commission__c, Broker_Commission_Based_On__c,
                Is_Flat_Renewal__c, Auto_Accept_ExceptionEligible__c, Floor_Buy_Rate__c, Max_GAV__c, Origination_Fee_Percentage__c,
                Overwrite_Policy_Default__c, Origination_Fee_Amount__c, Oldest_Unpaid_Due_As_Of_Today__c, Pricing_Factor__c,
                Opportunity__c, Pricing_Type__c, Random_Number__c, LastModifiedDate
            FROM CAN_Pricing_Detail__c
            WHERE Application__c = :applicationId
            AND (Status__c = :CANPricingDetails.STATUS_SENT_TO_CUSTOMER
            OR Status__c = :CANPricingDetails.STATUS_ACCEPTED)
            ORDER BY LastModifiedDate DESC
            LIMIT 1
        ];
    }
}