public class CLProductDB extends DBManager {

    public List<clcommon__CL_Product__c> getAllProducts() {
        return [
            SELECT Id, clcommon__Product_Name__c, loan__Lending_Product__c, loan__Lending_Product__r.loan__Default_Number_of_Installments__c,
                loan__Lending_Product__r.loan__Min_Loan_Amount__c, loan__Lending_Product__r.loan__Max_Loan_Amount__c,
                loan__Lending_Product__r.loan__Frequency_of_Loan_Payment__c
            FROM clcommon__CL_Product__c
            WHERE clcommon__Product_Name__c = :GeneralConstants.PRODUCT_NAME_DEFAULT
        ];
    }
}