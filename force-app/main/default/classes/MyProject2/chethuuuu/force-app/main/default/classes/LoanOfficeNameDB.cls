public class LoanOfficeNameDB extends DBManager {

    public List<loan__Office_Name__c> getLoanOfficeName(){
        return [
            SELECT Id, loan__Current_System_Date__c
            FROM loan__Office_Name__c
            WHERE Name = :GeneralConstants.COMPANY_NAME
        ];
    }

}