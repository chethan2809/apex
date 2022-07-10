public class CLCompanyDB extends DBManager {
    public List<clcommon__Company__c> getCLCompanies() {
        return [SELECT Id FROM clcommon__Company__c WHERE clcommon__Company_Name__c = :GeneralConstants.COMPANY_NAME];
    }
}