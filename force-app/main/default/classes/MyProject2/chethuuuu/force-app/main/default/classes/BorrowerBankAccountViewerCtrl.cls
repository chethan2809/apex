public class BorrowerBankAccountViewerCtrl {

    private static ApplicationDB applicationDBInstance = new ApplicationDB();
    private static BankAccountDB bankAccountDBInstance = new BankAccountDB();

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getApplicationById(Id applicationObjId) {
        List<genesis__Applications__c> applicationList = applicationDBInstance.getApplicationsByIds(new Set<Id> {applicationObjId});

        if(applicationList.isEmpty()) {
            throw new BorrowerBankAccountViewerCtrlException('There was no application found with Id ' + applicationObjId);
        }

        Map<String, Object> applicationMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(applicationList.get(0)));

        System.debug('applicationMap:' +applicationMap);
        return applicationMap;
    }

    @AuraEnabled(cacheable=true)
    public static List<Object> getBankAccountDetailsByAccountId(Id accountId) {
        List<loan__Bank_Account__c> bankAccountList = bankAccountDBInstance.getAllBankAccountsByAccountIds(new Set<Id> {accountId});

        List<Object> bankAccountObjectList = new List<Object>();
        for(loan__Bank_Account__c bankAccount : bankAccountList) {
            Map<String, Object> bankAccountMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(bankAccount));
            bankAccountObjectList.add(bankAccountMap);
        }
        return bankAccountObjectList;
    }

    @AuraEnabled
    public static String createBankAccount(Map<String, Object> bankObjectMap) {
        try {
            loan__Bank_Account__c bankObject = (loan__Bank_Account__c) JSON.deserialize(JSON.serialize(bankObjectMap) , loan__Bank_Account__c.class);
            bankAccountDBInstance.addInsert(bankObject).executeInserts();
            return 'Success';
        } catch (Exception ex){
            System.debug('***Error*** ' + ex.getMessage() + ex.getStackTraceString());
            return ex.getMessage();
        }
    }

    @AuraEnabled
    public static String updateBankAccount(List<Object> bankObjectList) {

        try {
            for(Object bankObject : bankObjectList) {
                Map<Object, Object> bankObjectMap = (Map<Object, Object>) bankObject;
                loan__Bank_Account__c bankAccountRecord = (loan__Bank_Account__c) JSON.deserialize(JSON.serialize(bankObjectMap) , loan__Bank_Account__c.class);
                bankAccountDBInstance.addUpdate(bankAccountRecord);
            }

            bankAccountDBInstance.executeUpdates();
            return 'Success';

        } catch (Exception ex){
            System.debug('***Error*** ' + ex.getMessage() + ex.getStackTraceString());
            return ex.getMessage();
        }
    }

    @AuraEnabled
    public static String assignBankAccountToApplication(Id applicationObjId, Id bankAccountObjId) {
        genesis__Applications__c applicationObject = new genesis__Applications__c(Id = applicationObjId);
        applicationObject.Bank_Account__c = bankAccountObjId;
        try{
            applicationDBInstance.addUpdate(applicationObject).executeUpdates();
            return 'Success';
        } catch (Exception ex){
            System.debug('***Error*** ' + ex.getMessage() + ex.getStackTraceString());
            return ex.getMessage();
        }
    }

    private class BorrowerBankAccountViewerCtrlException extends Exception {}
}