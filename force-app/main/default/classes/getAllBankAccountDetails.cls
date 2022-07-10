public class getAllBankAccountDetails {

    @AuraEnabled
    public static List<Object> getBankAccountList(Id accountId, Boolean isChanged) {
        system.debug('Account Id is:' +accountId);

        List<loan__Bank_Account__c> bankAccountList =
            [
                SELECT Id, Name, loan__Bank_Account_Number__c, loan__Bank_Name__c,peer__Account_Age__c,loan__Account_Usage__c, loan__Account__c, loan__Active__c, loan__Contact__c, loan__Account_Type__c,
                loan__ACH_Code__c, peer__Allow_for_Direct_Credit__c, loan__Archived__c, peer__Branch_Code__c, loan__External_Id__c, loan__Master_Archive_Object__c, loan__Routing_Number__c,
                peer__Savings_Other__c, peer__Savings_Pensions__c, peer__Savings_No__c, loan__Signature_Line__c, loan__Summary__c, loan__Summary_Record_Id__c, peer__Working_Place_Type__c
                FROM loan__Bank_Account__c
                WHERE loan__Account__c =: accountId
            ];

            system.debug('bank Account List is:' +bankAccountList);

            List<Object> objList = new List<Object>();
            for(loan__Bank_Account__c bankAccount : bankAccountList) {
                Map<String, Object> bankAccountMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(bankAccount));
                objList.add(bankAccountMap);
            }
            return objList;
    }

    @AuraEnabled
    public static String updateBankAccount(Map<String, Object> bankObjectMap) {
        system.debug('bank objectmap:' +bankObjectMap);
        loan__Bank_Account__c bankObject = (loan__Bank_Account__c) JSON.deserialize(JSON.serialize(bankObjectMap) , loan__Bank_Account__c.class);
        String response = '';
        try {
            system.debug('checking:' +bankObject);
            update bankObject;
            response = 'Success';
        } catch (Exception ex){
           response = 'Exception while updating Bank Account record : ' + ex.getMessage();
        }

        return response;
    }

    @AuraEnabled
    public static String createBankAccount(Map<String, Object> bankObjectMap) {
        loan__Bank_Account__c bankObject = (loan__Bank_Account__c) JSON.deserialize(JSON.serialize(bankObjectMap) , loan__Bank_Account__c.class);
        String response = '';
        try {
            insert bankObject;
            response = 'Success';
        } catch (Exception ex){
            response  ='Exception while creating Bank Account record : ' + ex.getMessage();
        }
        return response;
    }

    @AuraEnabled
    public static String assignToBankApplication(Map<String, Object>  applicationMap) {

        system.debug('application id is:' +applicationMap);
        genesis__Applications__c applicationObject = (genesis__Applications__c) JSON.deserialize(JSON.serialize(applicationMap) , genesis__Applications__c.class);
        String response = '';
        system.debug('bank account object is: ' +applicationObject);
        try{
            update applicationObject;
            response = 'Success';
        } catch (Exception ex){
            response  ='Exception while Assigning Bank Account record to Application : ' + ex.getMessage();
        }
        return response;
    }

    @AuraEnabled
    public static genesis__Applications__c geApplicationDetails(Id urApplId){
        return [
            SELECT Name
            FROM genesis__Applications__c
            WHERE Id = :urApplId
        ];
    }
}