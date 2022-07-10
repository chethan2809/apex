public class PricingMatrixDetailDB {

    public List<CAN_Pricing_Matrix_Detail__c> getAllPricingMatrixDetails() {
        return [
            SELECT Id, Loan_Type__c, Pricing_Type__c, Industry_Rating__c, SC4_Tier__c, Term__c, Pricing_Rate__c
            FROM CAN_Pricing_Matrix_Detail__c
        ];
    }

    public List<CAN_Pricing_Matrix_Detail__c> getPricingMatrixDetailsByRandomNumber(Decimal randomNumberValue) {
        return [
            SELECT Id, Loan_Type__c, Pricing_Type__c, Industry_Rating__c, SC4_Tier__c, Term__c, Pricing_Rate__c
            FROM CAN_Pricing_Matrix_Detail__c
            WHERE Min_Random_Number__c < :randomNumberValue
                AND Max_Random_Number__c >= :randomNumberValue
        ];
    }
}