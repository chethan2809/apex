public class FinCenAccountMatchJob implements Schedulable, Database.Batchable<SObject>, Database.Stateful {

    @TestVisible
    private static Origination_Settings__mdt defaultFinCenAccountMatchSetting = CustomMetaDataHelper.defaultOriginationSetting;
    @TestVisible
    private List<Object> accountListWithField = new List<Object> ();
    @TestVisible
    private Map<String, Object> matchedAccountDetailsByAccountId = new Map<String, Object>();
    @TestVisible
    private Map<String, Object> matchedContactDetailsByContactId = new Map<String, Object>();
    @TestVisible
    private Map<String, String> documentParameters;
    @TestVisible
    private Integer totalSearches;

    public FinCenAccountMatchJob(Map<String, Object> matchedContactDetailsByContactId, List<Object> accountListWithField, Map<String, String> documentParameters) {
        this.accountListWithField = accountListWithField;
        this.matchedAccountDetailsByAccountId = new Map<String, Object>();
        this.matchedContactDetailsByContactId = matchedContactDetailsByContactId;
        this.documentParameters = documentParameters;
        this.totalSearches = documentParameters.isEmpty() ? 0 : Integer.valueOf(documentParameters.get('totalSearches'));
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
                CustomSettingsHelper.generalSettings.FinCen_Eligible_Last_Funded_Date__c : Date.newInstance(2014, 1, 1);
        Date eligibleFundedDate = GeneralHelper.currentSystemDate.addDays(-lastFundedDays);

        return Database.getQueryLocator([
            SELECT Id, Name, Legal_Name__c, Business_Name__c, Doing_Business_As_Name__c, Merchant_ID__c, Business_Tax_ID__c,
                BillingBuildingNumber__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry
            FROM Account
            WHERE Product_Type__c = :GeneralConstants.PRODUCT_TYPE_FLEXIBLE_AMZ_LOAN
            AND Collections_status__c NOT IN :Accounts.INELIGIBLE_COLLECTION_STATUS
            AND
            (
                (Original_Loan_Funded_Date__c < :lastFundedDate AND Last_Date_of_Activity__c >= :lastDateOfActivity) OR
                (Original_Loan_Funded_Date__c >= :lastFundedDate AND ((Legacy_Active_Contract__c = true OR CLS_Active_Contract__c = true ) OR
                Last_Date_of_Activity__c >= :lastDateOfActivity))
            )
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Account> accountList) {
        totalSearches += accountList.size();
        FinCenRecordMatchManager.processAccountRecordMatchedWithFinCen(accountList, accountListWithField, matchedAccountDetailsByAccountId);
    }

    public void execute(SchedulableContext sc) {
        if (defaultFinCenAccountMatchSetting.FinCen_Account_Match_Batch_Size__c == null) {
            throw new FinCenAccountMatchJobException('FinCen_Account_Match_Batch_Size__c is null');
        }
        Database.executeBatch(this, Integer.valueOf(defaultFinCenAccountMatchSetting.FinCen_Account_Match_Batch_Size__c));
    }

    public static void execute() {
        List<Object> accountByFieldName = new List<Object> ();
        Map<String, Object> matchedContactDetailsByContactId = new Map<String, Object>();
        Map<String, String> documentParameters = new Map<String, String>();
        FinCenAccountMatchJob finCenAccountMatchJobInstance = new FinCenAccountMatchJob(matchedContactDetailsByContactId, accountByFieldName, documentParameters);
        finCenAccountMatchJobInstance.execute(null);
    }

    public void finish(Database.BatchableContext bc) {
        documentParameters.put('totalSearches', String.valueOf(totalSearches));
        FinCenRecordMatchManager.finCenReportAfterExecution(matchedAccountDetailsByAccountId, matchedContactDetailsByContactId, documentParameters);
    }

    private class FinCenAccountMatchJobException extends Exception {}
}