public class GAVMatrixDetailDB {

    public List<CAN_GAV_Matrix_Detail__c> getAllGAVMatrixDetails() {
        return [
            SELECT Id, Industry_Rating__c, SC4_Tier__c, Term__c, GAV__c
            FROM CAN_GAV_Matrix_Detail__c
        ];
    }

    public List<CAN_GAV_Matrix_Detail__c> getGAVMatrixDetailsByRandomNumber(Decimal randomNumberValue) {
        return [
            SELECT Id, Industry_Rating__c, SC4_Tier__c, Term__c, GAV__c
            FROM CAN_GAV_Matrix_Detail__c
            WHERE Min_Random_Number__c < :randomNumberValue
                AND Max_Random_Number__c >= :randomNumberValue
        ];
    }
}