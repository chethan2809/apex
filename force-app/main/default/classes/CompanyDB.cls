public class CompanyDB extends DBManager {

    public List<genesis__Company__c> getCompanies() {
        return [SELECT Id FROM genesis__Company__c WHERE Name = :GeneralConstants.COMPANY_NAME];
    }
}