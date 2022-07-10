public class Leads
{
    public static final String SOURCE_EMAIL = 'Email';
    public static final String SOURCE_MERCHANT_PORTAL = 'Merchant Portal';
    public static final String SOURCE_MERCHANT_PHONE = 'Merchant Phone';
    public static final String SOURCE_BROKER_MERCHANT_PHONE = 'Broker Phone For Merchant';
    public static final String SOURCE_WEBSITE_BROKER = 'Website Broker';
    public static final String SOURCE_WEBSITE_MERCHANT = 'Website Merchant';
    public static final String SOURCE_BROKER_PORTAL = 'Broker Portal';
    public static final String SOURCE_BROKER_PHONE = 'Broker Phone';
    public static final String SOURCE_CUSTOMER_REFERRAL = 'Customer Referral';
    public static final String OPEN_NEW_LEAD = 'Open - New Lead';
    public static final String WORKING_CONTACTED = 'Working - Contacted';
    public static final String WORKING_NOT_CONTACTED = 'Working - Not Contacted';
    public static final String CLOSED_CONVERTED = 'Closed - Converted';
    public static final String CLOSED_NOT_CONVERTED = 'Closed - Not Converted';
    public static final String LEGAL_INDIVIDUAL_ENTITY_TYPE = 'Individual';
    public static final String LEGAL_BUSINESS_ENTITY_TYPE = 'Business';
    public static final String ERROR_LEAD = 'ErrorLead';
    public static final String ERROR_COMPANY = 'Error Company';
    public static final String MERCHANT = 'Merchant';
    public static final String GUARANTOR = 'Guarantor';
    public static final String BROKER = 'Broker';
    public static final String ERROR_MESSAGE_EMAIL = 'Email';
    public static final String ERROR_MESSAGE_LEAD_SOURCE = 'Lead Source';
    public static final String ERROR_MESSAGE_MOBILE_PHONE = 'Mobile Number';
    public static final String ERROR_MESSAGE_TITLE = 'Title';
    public static final String ERROR_MESSAGE_DOB = 'DOB';
    public static final String ERROR_MESSAGE_BIZ_START_DATE = 'Biz Start Date';
    public static final String ERROR_MESSAGE_INDUSTRY = 'Industry';
    public static final String ERROR_MESSAGE_BIZ_STRUCTURE = 'Biz Structure';
    public static final String ERROR_MESSAGE_COUNTRY = 'Country & Business Address';
    public static final String ERROR_MESSAGE_BROKER_CONTACT = 'Broker Contact';
    public static final String ERROR_MESSAGE_TAX_ID = 'Tax Id';
    public static final String ERROR_MESSAGE_INDUSTRY_PROHIBITED = 'Selected Industry type is prohibited';
    public static final String ERROR_MESSAGE_AGE_MUST_18 = 'Age Must be 18 Years Old';
    public static final String ERROR_MESSAGE_MUST_OWNER_CEO_PARTNER = 'Title Must be owner, executive or partner. Cant be lower level employee';
    public static final String ERROR_MESSAGE_MUST_BE_UNITED_STATES = 'Business Address Country Must be United States';
    public static final String ERROR_MESSAGE_HOW_MUCH_DO_YOU_NEED = 'How Much $ Do You Need';
    public static final String ERROR_MESSAGE_BUSINESS_ZIP_CODE_TOO_LONG = 'Correct Business Address Zip/Postal Code, Zip/Postal code too long';
    public static final String ERROR_MESSAGE_PERSONAL_ZIP_CODE_TOO_LONG = 'Correct Personal Address Zip/Postal Code, Zip/Postal code too long';
    public static final String LEAD_STAGE_APP_SUBMITTED = 'App Submitted';
    public static final String LEAD_SUB_STATUS_SCORE_PENDING = 'Score Pending';
    public static Boolean mandatoryCheck;
    public static Boolean qualifyCheck;

    public static void leadMandatoryInformationCheck(Lead leadRecord, String status)
    {
        mandatoryCheck = true;
        String errorString = '';
        if(leadRecord.LeadSource == null)
        {
            mandatoryCheck = false;
            errorString += ERROR_MESSAGE_LEAD_SOURCE;
        }
        else if(leadRecord.Lead_Type__c == MERCHANT && leadRecord.Status == status)
        {
            if(leadRecord.Email == null) {
                mandatoryCheck = false;
                errorString += ERROR_MESSAGE_EMAIL;
            }
            if(leadRecord.Title__c == null) {
                mandatoryCheck = false;
                errorString += errorString != '' ? ', ' + ERROR_MESSAGE_TITLE : ERROR_MESSAGE_TITLE;
            }
            if(leadRecord.LeadSource != SOURCE_MERCHANT_PORTAL && leadRecord.DOB__c == null) {
                mandatoryCheck = false;
                errorString += errorString != '' ? ', ' + ERROR_MESSAGE_DOB : ERROR_MESSAGE_DOB;
            }
            if(leadRecord.Biz_Start_Date__c == null) {
                mandatoryCheck = false;
                errorString += errorString != '' ? ', ' + ERROR_MESSAGE_BIZ_START_DATE : ERROR_MESSAGE_BIZ_START_DATE;
            }
            if(leadRecord.Industry == null) {
                mandatoryCheck = false;
                errorString += errorString != '' ? ', ' + ERROR_MESSAGE_INDUSTRY : ERROR_MESSAGE_INDUSTRY;
            }
            if(leadRecord.Biz_Structure__c == null) {
                mandatoryCheck = false;
                errorString += errorString != '' ? ', ' + ERROR_MESSAGE_BIZ_STRUCTURE : ERROR_MESSAGE_BIZ_STRUCTURE;
            }
            if(leadRecord.Country == null) {
                mandatoryCheck = false;
                errorString += errorString != '' ? ', ' + ERROR_MESSAGE_COUNTRY : ERROR_MESSAGE_COUNTRY;
            }
            if((leadRecord.LeadSource == SOURCE_EMAIL || leadRecord.LeadSource == SOURCE_BROKER_MERCHANT_PHONE)
                && leadRecord.Broker_Contact__c == null) {
                mandatoryCheck = false;
                errorString += errorString != '' ? ', ' + ERROR_MESSAGE_BROKER_CONTACT : ERROR_MESSAGE_BROKER_CONTACT;
            }
        }
        else if(leadRecord.Lead_Type__c == BROKER && leadRecord.Status == status)
        {
            if(leadRecord.Email == null) {
                mandatoryCheck = false;
                errorString += errorString != '' ? ', ' + ERROR_MESSAGE_EMAIL : ERROR_MESSAGE_EMAIL;
            }
        }
        if(leadRecord.MobilePhone == null && leadRecord.Status == status) {
            mandatoryCheck = false;
            errorString += errorString != '' ? ', ' + ERROR_MESSAGE_MOBILE_PHONE : ERROR_MESSAGE_MOBILE_PHONE;
        }
        if(leadRecord.PostalCode != null && leadRecord.PostalCode.length() > 10) {
            mandatoryCheck = false;
            errorString += errorString != '' ? ', ' + ERROR_MESSAGE_BUSINESS_ZIP_CODE_TOO_LONG : ERROR_MESSAGE_BUSINESS_ZIP_CODE_TOO_LONG;
        }
        if(leadRecord.Postal_Code__c != null && leadRecord.Postal_Code__c.length() > 10) {
            mandatoryCheck = false;
            errorString += errorString != '' ? ', ' + ERROR_MESSAGE_PERSONAL_ZIP_CODE_TOO_LONG : ERROR_MESSAGE_PERSONAL_ZIP_CODE_TOO_LONG;
        }

        if(!mandatoryCheck)
        {
            leadRecord.addError('Please Enter ' + errorString);
        }
    }

    public static void leadRecordFieldsAssign(Lead leadRecord, List<Contact> contactList)
    {
        if(leadRecord.Lead_Type__c == MERCHANT) {
            leadRecord.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        } else if (leadRecord.Lead_Type__c == BROKER){
            leadRecord.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        }
        if(!contactList.isEmpty()) {
            leadRecord.Broker_Contact__c = contactList[0].Id;
        }
    }

    public static void leadQualificationCriteria(Lead leadRecord, String status)
    {
        if(leadRecord.Lead_Type__c == BROKER && leadRecord.Status == status) {
            if(leadRecord.Tax_ID__c == null) {
                leadRecord.addError('Please Enter ' + ERROR_MESSAGE_TAX_ID);
            }
        }
        else if(leadRecord.Lead_Type__c == MERCHANT && leadRecord.Status == status)
        {
            if(leadRecord.DOB__c != null)
            {
                Integer totalDays = Date.valueOf(leadRecord.DOB__c).daysBetween(system.today());
                Integer age = (integer)(math.Floor(totalDays/365.2425));

                qualifyCheck = true;
                String errorString = '';
                if(OriginationHelper.canIndustryProfile.ContainsKey(leadRecord.Industry) &&
                    OriginationHelper.canIndustryProfile.get(leadRecord.Industry).Industry_Rating__c == 'Prohibited')
                {
                    qualifyCheck = false;
                    errorString += ERROR_MESSAGE_INDUSTRY_PROHIBITED;
                }
                if(age < 18) {
                    qualifyCheck = false;
                    errorString +=  errorString != '' ? ', ' + ERROR_MESSAGE_AGE_MUST_18 : ERROR_MESSAGE_AGE_MUST_18;
                }
                if(leadRecord.Title__c == 'Other') {
                    qualifyCheck = false;
                    errorString += errorString != '' ? ', ' + ERROR_MESSAGE_MUST_OWNER_CEO_PARTNER : ERROR_MESSAGE_MUST_OWNER_CEO_PARTNER;
                }
                if(leadRecord.Country != 'United States' && leadRecord.Country != 'US' && leadRecord.Country != 'USA') {
                    qualifyCheck = false;
                    errorString += errorString != '' ? ', ' + ERROR_MESSAGE_MUST_BE_UNITED_STATES : ERROR_MESSAGE_MUST_BE_UNITED_STATES;
                }
                if(leadRecord.How_much_do_you_Need__c == null) {
                    qualifyCheck = false;
                    errorString += errorString != '' ? ', ' + ERROR_MESSAGE_HOW_MUCH_DO_YOU_NEED : ERROR_MESSAGE_HOW_MUCH_DO_YOU_NEED;
                }
                if(leadRecord.Tax_ID__c == null && leadRecord.LeadSource != SOURCE_MERCHANT_PORTAL) {
                    qualifyCheck = false;
                    errorString += errorString != '' ? ', ' + ERROR_MESSAGE_TAX_ID : ERROR_MESSAGE_TAX_ID;
                }
                if(leadRecord.LeadSource == SOURCE_BROKER_PORTAL && leadRecord.Broker_Contact__c == null
                    && leadRecord.Portal_Lead_Converted__c == false) {
                    qualifyCheck = false;
                    errorString += errorString != '' ? ', ' + ERROR_MESSAGE_BROKER_CONTACT : ERROR_MESSAGE_BROKER_CONTACT;
                }
                if(!qualifyCheck)
                {
                    leadRecord.addError(errorString);
                    leadRecord.Status = CLOSED_NOT_CONVERTED;
                }
                if(OriginationHelper.canIndustryProfile.ContainsKey(leadRecord.Industry)) {
                    leadRecord.loan__SICCode__c = OriginationHelper.canIndustryProfile.get(leadRecord.Industry).Digit_Code__c;
                    leadRecord.SIC_Description__c = OriginationHelper.canIndustryProfile.get(leadRecord.Industry).Description__c;
                }
            } else {
                leadMandatoryInformationCheck(leadRecord, Leads.CLOSED_CONVERTED);
            }
        }
    }

    private class LeadException extends Exception {}
}