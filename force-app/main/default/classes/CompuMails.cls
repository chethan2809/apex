public class CompuMails {

    public static final String CREDIT_FREEZE_LOCK_INACCESSIBLE = 'Credit_Freeze_Lock_Inaccessible';
    public static final String APP_DECLINE_SOLE_PROP = 'Application_Decline_Sole_Prop';
    public static final String APP_DECLINE_NONSOLE_PROP = 'Application_Decline_Nonsole_Prop';
    public static final String ABANDON_APPLICATION = 'Abandon_Application';
    public static final Set<Integer> DEFAULT_FICO_SCORE = new Set<Integer> {9000, 9001, 9002, 9003};

    public static List<String> buildCompuMailWrapperForExperian(List<clcommon__Party__c> partyList, Map<Id, Account> accountMap, Map<Id, genesis__Applications__c> applicationMap, Map<Id, DateTime> applicationIdToLastEnquiryDateMap) {
        List<String> csvRowValues = new List<String>();

        for(clcommon__Party__c party : partyList){
            genesis__Applications__c application = applicationMap.get(party.genesis__Application__c);
            Map<String, Compumail_Template_ID_mapping__mdt> compuMailTemplateIDMapping = CustomMetaDataHelper.compuMailTemplateIDMapping;
            String businessDBAName = getBusinessDBAName(application.genesis__Account__c, accountMap);
            String merchantID = accountMap.get(application.genesis__Account__c).Merchant_ID__c;
            String personalGuarantor = party.clcommon__Contact__r.Name;
            String letterID = compuMailTemplateIDMapping.get(CREDIT_FREEZE_LOCK_INACCESSIBLE).Template_ID__c;

            List<String> csvIndividualRowValues = new List<String>{
                validateStringValue(letterID),
                validateStringValue(String.valueOf(application.Name)),
                validateStringValue(String.valueOf(personalGuarantor != null ? personalGuarantor : '')),
                validateStringValue(String.valueOf(accountMap.get(application.genesis__Account__c).BillingStreet)),
                validateStringValue(String.valueOf(accountMap.get(application.genesis__Account__c).BillingBuildingNumber__c != null ? accountMap.get(application.genesis__Account__c).BillingBuildingNumber__c : '')),
                validateStringValue(String.valueOf(accountMap.get(application.genesis__Account__c).BillingCity)),
                validateStringValue(String.valueOf(accountMap.get(application.genesis__Account__c).BillingState)),
                validateStringValue(String.valueOf(accountMap.get(application.genesis__Account__c).BillingPostalCode)),
                validateStringValue(String.valueOf('')),
                validateStringValue(String.valueOf(merchantID != null ? merchantID : '')),
                validateStringValue(String.valueOf(businessDBAName != null ? businessDBAName : '')),
                validateStringValue((applicationIdToLastEnquiryDateMap.containsKey(application.Id) && (applicationIdToLastEnquiryDateMap.get(application.Id) != null))
                                        ? (String.valueOf(applicationIdToLastEnquiryDateMap.get(application.Id).date().addDays(30)))
                                        : ''
                                    )
            };
            csvRowValues.add(String.join(csvIndividualRowValues, ','));
        }
        return csvRowValues;
    }

    public static List<String> buildCompuMailWrapperForAAN(List<clcommon__Party__c> partyList, Map<Id, Account> accountMap, Map<Id, genesis__Applications__c> applicationMap) {
        List<String> csvRowValues = new List<String>();

        for(clcommon__Party__c party : partyList){
            genesis__Applications__c application = applicationMap.get(party.genesis__Application__c);
            Map<String, Compumail_Template_ID_mapping__mdt> compuMailTemplateIDMapping = CustomMetaDataHelper.compuMailTemplateIDMapping;
            String businessDBAName = getBusinessDBAName(application.genesis__Account__c, accountMap);
            String merchantID = accountMap.get(application.genesis__Account__c).Merchant_ID__c;
            String personalGuarantor = party.clcommon__Contact__r.Name;
            String letterID;
            String ficoScore = '';
            String keyFactors = '';
            if(application.AAN_Letter_Sent__c){
                if(application.Business_Type__c == GeneralConstants.LEGAL_TYPE_SOLE_PROP){
                    letterID = compuMailTemplateIDMapping.get(APP_DECLINE_SOLE_PROP).Template_ID__c;
                } else {
                    letterID = compuMailTemplateIDMapping.get(APP_DECLINE_NONSOLE_PROP).Template_ID__c;
                }
            }

            if(DEFAULT_FICO_SCORE.contains(Integer.valueOf(party.clcommon__Contact__r.FICO_MKT__c))) {
                ficoScore = 'Not Scored';
                keyFactors = 'File Not Scored because subject does not have sufficient credit';
            } else {
                ficoScore = String.valueOf(Integer.valueOf(party.clcommon__Contact__r.FICO_MKT__c));
                keyFactors = String.valueOf(party.clcommon__Contact__r.Reasons_for_Credit_Score__c);
            }

            List<String> csvIndividualRowValues = new List<String>{
                validateStringValue(letterID),
                validateStringValue(String.valueOf(application.Name)),
                validateStringValue(String.valueOf(personalGuarantor != null ? personalGuarantor : '')),
                validateStringValue(String.valueOf(accountMap.get(application.genesis__Account__c).BillingStreet)),
                validateStringValue(String.valueOf(accountMap.get(application.genesis__Account__c).BillingBuildingNumber__c != null ? accountMap.get(application.genesis__Account__c).BillingBuildingNumber__c : '')),
                validateStringValue(String.valueOf(accountMap.get(application.genesis__Account__c).BillingCity)),
                validateStringValue(String.valueOf(accountMap.get(application.genesis__Account__c).BillingState)),
                validateStringValue(String.valueOf(accountMap.get(application.genesis__Account__c).BillingPostalCode)),
                validateStringValue(String.valueOf('')),
                validateStringValue(String.valueOf(merchantID != null ? merchantID : '')),
                validateStringValue(String.valueOf(businessDBAName != null ? businessDBAName : '')),
                validateStringValue(application.Business_Type__c == GeneralConstants.LEGAL_TYPE_SOLE_PROP
                    && party.clcommon__Contact__r.Last_Consumer_Credit_Pull__c != null
                    ? String.valueOf(party.clcommon__Contact__r.Last_Consumer_Credit_Pull__c) : ''
                ),
                validateStringValue(String.valueOf((application.Business_Type__c == GeneralConstants.LEGAL_TYPE_SOLE_PROP && ficoScore != null ? ficoScore : '0'))),
                validateStringValue(String.valueOf(application.Business_Type__c == GeneralConstants.LEGAL_TYPE_SOLE_PROP ? keyFactors : ''))
            };
            csvRowValues.add(String.join(csvIndividualRowValues, ','));
        }
        return csvRowValues;
    }

    public static List<String> buildCompuMailWrapperForAbandonApplication(List<clcommon__Party__c> partyList, Map<Id, Account> accountMap, Map<Id, genesis__Applications__c> applicationMap) {
        List<String> csvRowValues = new List<String>();

        for(clcommon__Party__c party : partyList){
            genesis__Applications__c application = applicationMap.get(party.genesis__Application__c);
            Map<String, Compumail_Template_ID_mapping__mdt> compuMailTemplateIDMapping = CustomMetaDataHelper.compuMailTemplateIDMapping;
            String businessDBAName = getBusinessDBAName(application.genesis__Account__c, accountMap);
            String merchantID = accountMap.get(application.genesis__Account__c).Merchant_ID__c;
            String personalGuarantor = party.clcommon__Contact__r.Name;
            String letterID = compuMailTemplateIDMapping.get(ABANDON_APPLICATION).Template_ID__c;

            List<String> csvIndividualRowValues = new List<String>{
                validateStringValue(letterID),
                validateStringValue(String.valueOf(application.Name)),
                validateStringValue(String.valueOf(personalGuarantor != null ? personalGuarantor : '')),
                validateStringValue(String.valueOf(accountMap.get(application.genesis__Account__c).BillingStreet)),
                validateStringValue(String.valueOf(accountMap.get(application.genesis__Account__c).BillingBuildingNumber__c != null ? accountMap.get(application.genesis__Account__c).BillingBuildingNumber__c : '')),
                validateStringValue(String.valueOf(accountMap.get(application.genesis__Account__c).BillingCity)),
                validateStringValue(String.valueOf(accountMap.get(application.genesis__Account__c).BillingState)),
                validateStringValue(String.valueOf(accountMap.get(application.genesis__Account__c).BillingPostalCode)),
                validateStringValue(String.valueOf('')),
                validateStringValue(String.valueOf(merchantID != null ? merchantID : '')),
                validateStringValue(String.valueOf(businessDBAName != null ? businessDBAName : '')),
                validateStringValue(String.valueOf(application.Last_Status_Update_Date__c.date().addDays(30)))
            };
            csvRowValues.add(String.join(csvIndividualRowValues, ','));
        }
        return csvRowValues;
    }

    @TestVisible
    private static String validateStringValue(String value) {
        String stringValue = (String)value;
        if (stringValue == null) {
            return null;
        }
        return stringValue.replaceAll('\n','').replaceAll('\r','').escapeCSV();
    }

    @TestVisible
    private static String getBusinessDBAName(Id accountId, Map<Id, Account> accountMap) {
        String businessDBAName;
        if(accountMap.get(accountId).Doing_Business_As_Name__c != null) {
            businessDBAName = accountMap.get(accountId).Doing_Business_As_Name__c;
        } else {
            businessDBAName = accountMap.get(accountId).Legal_Name__c;
        }
        return businessDBAName;
    }
}