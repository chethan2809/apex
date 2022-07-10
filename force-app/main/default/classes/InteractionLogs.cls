public class InteractionLogs
{
    public static void interactionLogMandatoryInformationCheck(Interaction_Log__c interactionLogRecord)
    {
        String actionCode = interactionLogRecord.Action_Code__c;
        String errorString = '';
        if(interactionLogRecord.Followup_Date__c < GeneralHelper.currentSystemDate) {
            errorString += CollectionCaseConstants.VALID_FOLLOW_UP_DATE ;
        }
        if(interactionLogRecord.Proof_of_Claim_File_By_Date__c < GeneralHelper.currentSystemDate) {
            errorString += CollectionCaseConstants.VALID_DATE + ' for ' + CollectionCaseConstants.BANKRUPTCY_PROOF_OF_CLAIM_FILE_BY_DATE + '. ';
        }
        if(interactionLogRecord.Proof_of_Claim_Filed_Date__c < GeneralHelper.currentSystemDate) {
            errorString += CollectionCaseConstants.VALID_DATE + ' for ' + CollectionCaseConstants.BANKRUPTCY_PROOF_OF_CLAIM_FILED_DATE +  '. ';
        }
        if(interactionLogRecord.Suit_Filed_Date__c < GeneralHelper.currentSystemDate) {
            errorString += CollectionCaseConstants.VALID_DATE + ' for ' + CollectionCaseConstants.SUIT_FILED_DATE +  '.  ';
        }
        if(interactionLogRecord.Last_Skip_Tracing_Date__c < GeneralHelper.currentSystemDate) {
            errorString += CollectionCaseConstants.VALID_DATE + ' for ' + CollectionCaseConstants.LAST_SKIP_TRACING_DATE + '. ';
        }
        if(interactionLogRecord.Inspection_Date__c < GeneralHelper.currentSystemDate) {
            errorString += CollectionCaseConstants.VALID_DATE + ' for ' + CollectionCaseConstants.INSPECTION_DATE + '. ';
        }
        if(interactionLogRecord.Site_Inspection_Completed_Date__c < GeneralHelper.currentSystemDate) {
            errorString += CollectionCaseConstants.VALID_DATE + ' for ' + CollectionCaseConstants.SITE_INSPECTION_COMPLETED_DATE + '. ';
        }
        if(interactionLogRecord.Judgment_Date__c < GeneralHelper.currentSystemDate) {
            errorString += CollectionCaseConstants.VALID_DATE + ' for ' + CollectionCaseConstants.JUDGMENT_DATE +  '. ';
        }
        if(interactionLogRecord.Judgment_Maturity_Date__c < GeneralHelper.currentSystemDate) {
            errorString += CollectionCaseConstants.VALID_DATE + ' for ' + CollectionCaseConstants.JUDGMENT_MATURITY_DATE + '. ';
        }
        switch on actionCode {

            when 'Bad Contact Info' {
                if(interactionLogRecord.Followup_Date__c == null) {
                    errorString += CollectionCaseConstants.FOLLOW_UP_DATE;
                }
            }
            when 'Contact Attempt' {
                if(interactionLogRecord.Followup_Date__c == null) {
                    errorString += CollectionCaseConstants.FOLLOW_UP_DATE;
                }
            }
            when 'Left Voicemail' {
                if(interactionLogRecord.Followup_Date__c == null) {
                    errorString += CollectionCaseConstants.FOLLOW_UP_DATE;
                }
            }
            when 'Gatekeeper' {
                if(interactionLogRecord.Followup_Date__c == null) {
                    errorString += CollectionCaseConstants.FOLLOW_UP_DATE;
                }
            }
            when 'Receivership Dissolution Found' {
                if(interactionLogRecord.Receivership_Dissolution__c == null) {
                errorString += CollectionCaseConstants.RECEIVERSHIP_DISSOLUTION;
                }
            }
            when 'Judgment Awarded' {
                if(interactionLogRecord.Judgment_Amount__c == null) {
                    errorString += CollectionCaseConstants.JUDGMENT_AMOUNT;
                }
                if(interactionLogRecord.Judgment_Date__c == null){
                    errorString += CollectionCaseConstants.JUDGMENT_DATE;
                }
                if(interactionLogRecord.Judgment_Maturity_Date__c == null) {
                    errorString += CollectionCaseConstants.JUDGMENT_MATURITY_DATE;
                }
                if(interactionLogRecord.Judgement_Rate_of_Interest__c == null) {
                    errorString += CollectionCaseConstants.JUDGEMENT_RATE_OF_INTEREST;
                }
            }
            when 'Debt Consolidator Found' {
                if(interactionLogRecord.Contact__c == null) {
                    errorString += CollectionCaseConstants.ATTORNEY_CONTACT;
                }
                if(interactionLogRecord.Debt_Consolidator__c == null) {
                    errorString += CollectionCaseConstants.DEBT_CONSOLIDATOR_FOUND;
                }
            }
            when 'Merchant Retained Attorney' {
                if(interactionLogRecord.Contact__c == null) {
                    errorString += CollectionCaseConstants.ATTORNEY_CONTACT;
                }
            }
        }
        if(!String.isEmpty(errorString)) {
            interactionLogRecord.addError('Please Enter ' + errorString);
        }
        subActionCodeCheck(interactionLogRecord);
    }

    public static void subActionCodeCheck(Interaction_Log__c interactionLogRecord)
    {
        String subActionCode = interactionLogRecord.Sub_Action_Code__c;
        String errorString = '';
        if(interactionLogRecord.Followup_Date__c < GeneralHelper.currentSystemDate) {
            errorString += CollectionCaseConstants.VALID_FOLLOW_UP_DATE;
        }
        switch on subActionCode {
            when 'Contacted' {
                if(interactionLogRecord.Followup_Date__c == null) {
                    errorString += CollectionCaseConstants.FOLLOW_UP_DATE;
                }
            }
            when 'Refusal To Pay' {
                if(interactionLogRecord.Followup_Date__c == null) {
                    errorString += CollectionCaseConstants.FOLLOW_UP_DATE;
                }
            }
            when 'Bankruptcy Filed' {
                if(interactionLogRecord.Case_Number__c == null) {
                    errorString += CollectionCaseConstants.CASE_NUMBER;
                }
                if(interactionLogRecord.Bankruptcy_Chapter__c == null) {
                    errorString += CollectionCaseConstants.BANKRUPTCY_CHAPTER;
                }
                if(interactionLogRecord.Parties_Associated__c == null) {
                    errorString += CollectionCaseConstants.PARTIES_ASSOCIATED;
                }
                if(interactionLogRecord.Proof_of_Claim_File_By_Date__c == null) {
                    errorString += CollectionCaseConstants.BANKRUPTCY_PROOF_OF_CLAIM_FILE_BY_DATE;
                }
            }
            when 'Bankruptcy Proof of Claim Filed' {
                if(interactionLogRecord.Bankruptcy_Proof_of_Claim_Filed__c == null) {
                    errorString += CollectionCaseConstants.BANKRUPTCY_PROOF_OF_CLAIM_FILED;
                }
                if(interactionLogRecord.Proof_of_Claim_Filed_Date__c == null) {
                    errorString += CollectionCaseConstants.BANKRUPTCY_PROOF_OF_CLAIM_FILED_DATE;
                }
            }
            when 'Bankruptcy In Process' {
                if(interactionLogRecord.Followup_Date__c == null) {
                    errorString += CollectionCaseConstants.FOLLOW_UP_DATE;
                }
            }
            when 'Bankruptcy Status Update' {
                if(interactionLogRecord.Bankruptcy_Status__c == null) {
                    errorString += CollectionCaseConstants.BANKRUPTCY_STATUS;
                }
            }
            when 'Fraud Alleged' {
                if(interactionLogRecord.Fraud_Alleged_Type__c == null) {
                    errorString += CollectionCaseConstants.FRAUD_ALLEGED_TYPE;
                }
            }
            when 'Fraud Confirmed' {
                if(!interactionLogRecord.Fraud_Confirmed__c) {
                    errorString += CollectionCaseConstants.FRAUD_CONFIRMED;
                }
            }
            when 'Move to Legal Counsel' {
                if(interactionLogRecord.Legal_Counsel_Type__c == null) {
                    errorString += CollectionCaseConstants.LEGAL_COUNSEL_TYPE;
                }
            }
            when 'Site Inspection Ordered' {
                if(interactionLogRecord.Demand_Letter_Attached__c == null) {
                    errorString += CollectionCaseConstants.DEMAND_LETTER_ATTACHED;
                }
                if(interactionLogRecord.Inspection_Date__c == null) {
                    errorString += CollectionCaseConstants.INSPECTION_DATE;
                }
            }
            when 'Site Inspection Findings' {
                if(interactionLogRecord.Business_Status__c == null) {
                    errorString += CollectionCaseConstants.BUSINESS_STATUS;
                }
                if(interactionLogRecord.Ownership_Change__c == null) {
                    errorString += CollectionCaseConstants.OWNERSHIP_CHANGE;
                }
                if(interactionLogRecord.Demand_Letter_Delivered__c == null) {
                    errorString += CollectionCaseConstants.DEMAND_LETTER_ATTACHED;
                }
                if(interactionLogRecord.Contact_Made_With_PG__c == null ) {
                    errorString += CollectionCaseConstants.CONTACT_MADE_WITH_PG;
                }
            }
            when 'Preparing Suit' {
                if(interactionLogRecord.Legal_Counsel_Type__c == null) {
                    errorString += CollectionCaseConstants.LEGAL_COUNSEL_TYPE;
                }
            }
            when 'Suit Filed' {
                if(interactionLogRecord.Suit_Filed_Date__c == null) {
                    errorString += CollectionCaseConstants.SUIT_FILED_DATE;
                }
                if(interactionLogRecord.Case_Number__c == null) {
                    errorString += CollectionCaseConstants.CASE_NUMBER;
                }
                if(interactionLogRecord.Court_Location__c == null) {
                    errorString += CollectionCaseConstants.COURT_LOCATION;
                }
                if(interactionLogRecord.Legal_Counsel_Type__c == null) {
                    errorString += CollectionCaseConstants.LEGAL_COUNSEL_TYPE;
                }
            }
        }
        if(!String.isEmpty(errorString)) {
            interactionLogRecord.addError('Please Enter ' + errorString);
        }
    }
}