public class CANMinAndMaxPricingDetailDB extends DBManager {

    public List<CAN_Min_And_Max_Pricing_Detail__c> getMinAndMaxPricingMapping() {
        return [
            SELECT Id, Name, max_price__c, min_price__c, sc4_tier__c, term__c
            FROM CAN_Min_And_Max_Pricing_Detail__c
        ];
    }
}