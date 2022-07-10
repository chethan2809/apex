public class FinCenContactMatchJob  implements Schedulable, Database.Batchable<SObject>, Database.Stateful {
    @TestVisible
    private static Origination_Settings__mdt defaultFinCenContactMatchSetting = CustomMetaDataHelper.defaultOriginationSetting;
    @TestVisible
    private List<Object> contactListWithField = new List<Object> ();
    @TestVisible
    private List<Object> accountListWithField = new List<Object> ();
    @TestVisible
    private Map<String, Object> matchedContactDetailsByContactId = new Map<String, Object>();
    @TestVisible
    private Map<String, String> documentParameters;
    @TestVisible
    private Integer totalSearches;

    public FinCenContactMatchJob(List<Object> contactListWithField, List<Object> accountListWithField, String fileName) {
        this.documentParameters = new Map<String, String>();
        this.contactListWithField = contactListWithField;
        this.accountListWithField = accountListWithField;
        this.documentParameters.put('fileName', fileName);
        this.documentParameters.put('recordCount', String.valueOf(contactListWithField.size() + accountListWithField.size()));
        matchedContactDetailsByContactId = new Map<String, Object>();
        this.totalSearches = 0;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date lastDateOfActivity = GeneralHelper.currentSystemDate.addDays(
            -Integer.valueOf(CustomSettingsHelper.generalSettings.Active_Days_For_FinCen_Record__c)
        );
        Integer lastFundedDays = CustomSettingsHelper.generalSettings != null &&
            CustomSettingsHelper.generalSettings.FinCen_Days_Since_Last_Funded_Date__c != null ?
                Integer.valueOf(CustomSettingsHelper.generalSettings.FinCen_Days_Since_Last_Funded_Date__c) : 0;
        Date lastFundedDate = CustomSettingsHelper.generalSettings != null &&
            CustomSettingsHelper.generalSettings.FinCen_Eligible_Last_Funded_Date__c != null ?
                CustomSettingsHelper.generalSettings.FinCen_Eligible_Last_Funded_Date__c : Date.newInstance(2014, 01, 01);
        Date eligibleFundedDate = GeneralHelper.currentSystemDate.addDays(-lastFundedDays);

        return Database.getQueryLocator([
            SELECT Id, Contact.Name, Contact.FirstName, Contact.LastName, Contact.MailingBuildingNumber__c, Contact.MailingStreet,
                Contact.MailingCity, Contact.MailingState, Contact.MailingCountry, Contact.MailingPostalCode, Contact.Birthdate,
                Contact.genesis__SSN__c
            FROM AccountContactRelation
            WHERE Account.Product_Type__c = :GeneralConstants.PRODUCT_TYPE_FLEXIBLE_AMZ_LOAN
            AND Account.Collections_status__c NOT IN :Accounts.INELIGIBLE_COLLECTION_STATUS
            AND
            (
                (Account.Original_Loan_Funded_Date__c < :lastFundedDate AND Account.Last_Date_of_Activity__c >= :lastDateOfActivity ) OR
                (Account.Original_Loan_Funded_Date__c >= :lastFundedDate AND ((Account.Legacy_Active_Contract__c = true OR Account.CLS_Active_Contract__c = true ) OR
                Account.Last_Date_of_Activity__c >= :lastDateOfActivity))
            )
       ]);
    }

    public void execute(Database.BatchableContext bc, List<AccountContactRelation> contactList) {
        totalSearches += contactList.size();
        FinCenRecordMatchManager.processContactRecordMatchedWithFinCen(contactList, contactListWithField, matchedContactDetailsByContactId);
    }

    public void execute(SchedulableContext sc) {
        if (defaultFinCenContactMatchSetting.FinCen_Contact_Match_Batch_Size__c == null) {
            throw new FinCenContactMatchJobException('FinCen_Contact_Match_Batch_Size__c is null');
        }
        Database.executeBatch(this, Integer.valueOf(defaultFinCenContactMatchSetting.FinCen_Contact_Match_Batch_Size__c));
    }

    public static void execute() {
        List<Object> contactByFieldName = new List<Object> ();
        List<Object> accountByFieldName = new List<Object> ();
        String fileName = '';
        FinCenContactMatchJob finCenContactMatchJobInstance = new FinCenContactMatchJob(contactByFieldName, accountByFieldName, fileName);
        finCenContactMatchJobInstance.execute(null);
    }

    public void finish(Database.BatchableContext bc) {
        documentParameters.put('totalSearches', String.valueOf(totalSearches));
        Integer accountBatchSize = defaultFinCenContactMatchSetting.FinCen_Account_Match_Batch_Size__c != null ?
            Integer.valueOf(defaultFinCenContactMatchSetting.FinCen_Account_Match_Batch_Size__c) : 10;
        Database.executeBatch(new FinCenAccountMatchJob(matchedContactDetailsByContactId, accountListWithField, documentParameters), accountBatchSize);
    }

    private class FinCenContactMatchJobException extends Exception {}
}