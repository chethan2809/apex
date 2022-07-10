public class MaxAmountAndMaxTermMappingDB {

    public List<CAN_Max_Amount_And_Max_Term_Mapping__c> getMaxAmountAndMaxTermMappings() {
        return [
            SELECT Id, Maximum_Term__c, Maximum_Amount_Multi_Location__c, Maximum_Amount_Single_Location__c, Industry_Rating__c, SC4_Tier__c,
                Loan_Type__c, Pricing_Type__c
            FROM CAN_Max_Amount_And_Max_Term_Mapping__c
        ];
    }

    public List<CAN_Max_Amount_And_Max_Term_Mapping__c> getMaxAmountAndMaxTermMappingsByRandomNumber(Decimal randomNumberValue) {
        return [
            SELECT Id, Maximum_Term__c, Maximum_Amount_Multi_Location__c, Maximum_Amount_Single_Location__c, Industry_Rating__c, SC4_Tier__c,
                Loan_Type__c, Pricing_Type__c
            FROM CAN_Max_Amount_And_Max_Term_Mapping__c
            WHERE Min_Random_Number__c < :randomNumberValue
                AND Max_Random_Number__c >= :randomNumberValue
        ];
    }
}