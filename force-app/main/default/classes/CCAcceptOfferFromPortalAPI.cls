public class CCAcceptOfferFromPortalAPI {

    public static CAN_Pricing_Detail__c createAcceptedPricingRecordFromBrokerPortal(CAN_Pricing_Detail__c canPricingDetailsFromPortal, Id applicationId){
        CAN_Pricing_Detail__c finalCanPricingRecord = new CAN_Pricing_Detail__c();
        finalCanPricingRecord = createAcceptedPricingRecordFromMerchantPortal(canPricingDetailsFromPortal, applicationId);
        finalCanPricingRecord.Standard_Commission__c = (Decimal)canPricingDetailsFromPortal.Standard_Commission__c;
        finalCanPricingRecord.Commission_Amount__c = (Decimal)canPricingDetailsFromPortal.Commission_Amount__c;
        finalCanPricingRecord.Max_Broker_Commission__c = (Decimal)canPricingDetailsFromPortal.Max_Broker_Commission__c;
        finalCanPricingRecord.Broker_Commission_Based_On__c = (String)canPricingDetailsFromPortal.Broker_Commission_Based_On__c;
        finalCanPricingRecord.Renewal_Amount_Commission__c = (String)canPricingDetailsFromPortal.Renewal_Amount_Commission__c;
        finalCanPricingRecord.Is_Flat_Renewal__c = (Boolean)canPricingDetailsFromPortal.Is_Flat_Renewal__c;
        return finalCanPricingRecord;
    }

    public static CAN_Pricing_Detail__c createAcceptedPricingRecordFromMerchantPortal(CAN_Pricing_Detail__c canPricingDetailsFromPortal, Id applicationId){
        CAN_Pricing_Detail__c finalCanPricingRecord = new CAN_Pricing_Detail__c();
        finalCanPricingRecord.Application__c = applicationId;
        finalCanPricingRecord.Selected_Amount__c = (Decimal)canPricingDetailsFromPortal.Selected_Amount__c;
        finalCanPricingRecord.Buy_Rate__c = (Decimal)canPricingDetailsFromPortal.Buy_Rate__c;
        finalCanPricingRecord.Pricing_Factor__c = (Decimal)canPricingDetailsFromPortal.Pricing_Factor__c;
        finalCanPricingRecord.Daily_Payment_Amount__c = (Decimal)canPricingDetailsFromPortal.Daily_Payment_Amount__c;
        finalCanPricingRecord.Number_Of_Daily_Payments__c = (Integer)canPricingDetailsFromPortal.Number_Of_Daily_Payments__c;
        finalCanPricingRecord.Weekly_Payment_Amount__c = (Decimal)canPricingDetailsFromPortal.Weekly_Payment_Amount__c;
        finalCanPricingRecord.Number_Of_Weekly_Payments__c = (Integer)canPricingDetailsFromPortal.Number_Of_Weekly_Payments__c;
        finalCanPricingRecord.Term__c = (Integer)canPricingDetailsFromPortal.Term__c;
        finalCanPricingRecord.Maximum_Term__c = (Decimal)canPricingDetailsFromPortal.Maximum_Term__c;
        finalCanPricingRecord.Maximum_Amount__c = (Decimal)canPricingDetailsFromPortal.Maximum_Amount__c;
        finalCanPricingRecord.Repayment_Amount__c = (Decimal)canPricingDetailsFromPortal.Repayment_Amount__c;
        finalCanPricingRecord.Loan_Type__c = canPricingDetailsFromPortal.Loan_Type__c;
        finalCanPricingRecord.SC4_Tier__c = canPricingDetailsFromPortal.SC4_Tier__c;
        finalCanPricingRecord.Industry_Rating__c = canPricingDetailsFromPortal.Industry_Rating__c;
        finalCanPricingRecord.GAV__c = (Decimal)canPricingDetailsFromPortal.GAV__c;
        finalCanPricingRecord.Annual_Volume__c = (Decimal)canPricingDetailsFromPortal.Annual_Volume__c;
        finalCanPricingRecord.Policy_Maximum_Amount__c = (Decimal)canPricingDetailsFromPortal.Policy_Maximum_Amount__c;
        finalCanPricingRecord.Daily_End_Date__c = (Date)canPricingDetailsFromPortal.Daily_End_Date__c;
        finalCanPricingRecord.Start_Date__c = (Date)canPricingDetailsFromPortal.Start_Date__c;
        finalCanPricingRecord.Weekly_End_Date__c = (Date)canPricingDetailsFromPortal.Weekly_End_Date__c;
        finalCanPricingRecord.Status__c = PortalConstants.MERCHANT_OFFER_ACCEPTED;
        finalCanPricingRecord.Ocrolus_Max_Daily_Payment__c = (Decimal)canPricingDetailsFromPortal.Ocrolus_Max_Daily_Payment__c;
        finalCanPricingRecord.Ocrolus_Maximum_Amount__c = (Decimal)canPricingDetailsFromPortal.Ocrolus_Maximum_Amount__c;
        finalCanPricingRecord.Maximum_Exception_Amount__c = (Decimal)canPricingDetailsFromPortal.Maximum_Exception_Amount__c;
        finalCanPricingRecord.Floor_Buy_Rate__c = (Decimal)canPricingDetailsFromPortal.Floor_Buy_Rate__c;
        finalCanPricingRecord.Max_GAV__c = (Decimal)canPricingDetailsFromPortal.Max_GAV__c;
        finalCanPricingRecord.Origination_Fee_Percentage__c = (Decimal)canPricingDetailsFromPortal.Origination_Fee_Percentage__c;
        finalCanPricingRecord.Overwrite_Policy_Default__c = (Boolean)canPricingDetailsFromPortal.Overwrite_Policy_Default__c;
        finalCanPricingRecord.Payment_Frequency__c = (String)canPricingDetailsFromPortal.Payment_Frequency__c;
        finalCanPricingRecord.Origination_Fee_Amount__c = (Decimal)canPricingDetailsFromPortal.Origination_Fee_Amount__c;
        finalCanPricingRecord.Pricing_Type__c = canPricingDetailsFromPortal.Pricing_Type__c;
        finalCanPricingRecord.Random_Number__c = canPricingDetailsFromPortal.Random_Number__c;
        return finalCanPricingRecord;
    }
}