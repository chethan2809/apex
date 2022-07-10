public class PartnerGetApplicationStatus {
    public static final String STIPS_CHECK_LIST = 'STIPSChecklist';
    public static final Map<String, String> APPLICATION_DETAILS_RESPONSE_MAP = new Map<String, String>{
        'Name' => 'Name',
        'Stage' => 'Overall_Status__c',
        'Decline Reasons' => 'Decline_Reasons__c'
    };
    public static final Set<String> REQUEST_KEYS_TO_VALIDATE = new Set<String>{
        'application',
        'partnerEmail',
        'partnerAPIKey'
    };
    public static final Map<String, String> PRICING_DETAILS_RESPONSE_MAP = new Map<String, String>{
        'Maximum Term' => 'Maximum_Term__c'
    };
    public static final Map<String, String> STIPS_CHECKLIST_RESPONSE_MAP = new Map<String, String>{
        'Additional Banks' => 'Additional_Banks__c',
        'Bank Verification Call' => 'Bank_Verification_Call__c',
        'Borrower Interview' => 'Borrower_Interview__c',
        'Competitors' => 'Competitors__c',
        'Federal Tax ID' => 'Federal_Tax_ID__c',
        'Identification' => 'Identification__c',
        'Month to Date Bank Statement' => 'Month_to_Date_Bank_Statement__c',
        'Proof of Ownership' => 'Proof_of_Ownership__c',
        'Verification Call' => 'Verification_Call__c',
        'Voided Check' => 'Voided_Check__c',
        'Experian Fraud Check' => 'experian_fraud_check__c',
	    'Business Loan Agreement' => 'business_loan_agreement__c',
	    'Certification of Beneficial Owners Form' => 'certification_of_beneficial_owners__c',
	    'Refinance Agreement' => 'refinance_agreement__c',
	    'Third Party Agreement' => 'third_party_agreement__c',
        'Proof of Business Location' => 'proof_of_business_location__c'
    };

    public static genesis__Applications__c validateRequest(RestRequest request) {
        String applicationName = request.params.get(PartnerAPIConstants.APPLICATION);
        String partnerEmail = request.params.get(PartnerAPIConstants.PARTNER_EMAIL);
        String partnerAPIKey = request.params.get(PartnerAPIConstants.PARTNER_API_KEY);

        Map<String, Object> responseData = PartnerAPIHelpers.genericPartnerAPIValidation(partnerEmail, applicationName, partnerAPIKey);
        genesis__Applications__c application = (genesis__Applications__c) responseData.get(PartnerAPIConstants.APPLICATION_DETAILS);

        return application;
    }

    public static Map<String, Object> buildResponse(List<CAN_Pricing_Detail__c> canPricingDetailRecord, List<STIPS_Checklist__c> stipsChecklist, genesis__Applications__c application) {
        Map<String, Object> resultMap = new Map<String, Object>();
        Map<String, Object> constructedResponse = new Map<String, Object>();
        if(application.Decline_Reasons__c == null) {
            application.Decline_Reasons__c = '';
        }
        if(application.Decline_Reasons__c == null) {
            application.Decline_Reasons__c = '';
        }
        constructedResponse = PartnerAPIHelpers.constructResponseMap(application, PartnerGetApplicationStatus.APPLICATION_DETAILS_RESPONSE_MAP);
        resultMap.put(PartnerAPIConstants.APPLICATION_DETAILS, constructedResponse);

        if(!canPricingDetailRecord.isEmpty()){
            constructedResponse = PartnerAPIHelpers.constructResponseMap(canPricingDetailRecord.get(0), PartnerGetApplicationStatus.PRICING_DETAILS_RESPONSE_MAP);
            constructedResponse.put(PartnerAPIConstants.MINIMUM_TERM, CANPricingDetails.DEFAULT_MINIMUM_TERM);
            resultMap.put(PartnerAPIConstants.PRICING_DETAILS, constructedResponse);
        }
        else{
            resultMap.put(PartnerAPIConstants.PRICING_DETAILS, null);
        }

        if(!stipsChecklist.isEmpty()) {
            STIPS_Checklist__c stipsCheck = stipsChecklist.get(0);
            Map<String, String> stips = new Map<String, String>();
            if(stipsCheck.Federal_Tax_ID__c) {
                stips.put('Federal_Tax_ID__c', stipsCheck.Federal_Tax_ID__c ? 'Federal Tax ID' : '');
            } else {
                STIPS_CHECKLIST_RESPONSE_MAP.remove('Federal Tax ID');
            }
            if(stipsCheck.Month_to_Date_Bank_Statement__c) {
                stips.put('Month_to_Date_Bank_Statement__c', stipsCheck.Month_to_Date_Bank_Statement__c ? 'Month to Date Bank Statement' : '');
            } else {
                STIPS_CHECKLIST_RESPONSE_MAP.remove('Month to Date Bank Statement');
            }
            if(stipsCheck.Borrower_Interview__c) {
                stips.put('Borrower_Interview__c', stipsCheck.Borrower_Interview__c ? 'Additional Information Needed - Financial Services Charge-Off' : '');
            } else {
                STIPS_CHECKLIST_RESPONSE_MAP.remove('Borrower Interview');
            }
            if(stipsCheck.Proof_of_Ownership__c) {
                stips.put('Proof_of_Ownership__c', stipsCheck.Proof_of_Ownership__c ? 'Proof of Ownership' : '');
            } else {
                STIPS_CHECKLIST_RESPONSE_MAP.remove('Proof of Ownership');
            }
            if(stipsCheck.Identification__c) {
                stips.put('Identification__c', stipsCheck.Identification__c ? 'Driver\'s License or Government Issued ID ' + (
                String.valueOf(stipsCheck.Guarantors_Whose_Identity_Not_Verified__c) != null ? 'for ' + String.valueOf(stipsCheck.Guarantors_Whose_Identity_Not_Verified__c) : '') : '');
            } else {
                STIPS_CHECKLIST_RESPONSE_MAP.remove('Identification');
            }
            if(stipsCheck.Voided_Check__c) {
                stips.put('Voided_Check__c', stipsCheck.Voided_Check__c ? 'Voided Check for Acct # ending ' + (
                String.valueOf(stipsCheck.Last_Four_Bank_Account_Number__c) != null ? String.valueOf(stipsCheck.Last_Four_Bank_Account_Number__c) + ' or Voided Check for the primary bank account' : '') : '');
            } else {
                STIPS_CHECKLIST_RESPONSE_MAP.remove('Voided Check');
            }
            if(stipsCheck.Competitors__c) {
                stips.put('Competitors__c', stipsCheck.Competitors__c ? 'Payoff Letter for Competitors ' + (
                String.valueOf(stipsCheck.Competitor_Names__c) != null ? String.valueOf(stipsCheck.Competitor_Names__c)  : '') + ' (Total payoff must not exceed 50% of the Max Funding Amount)' : '');
            } else {
                STIPS_CHECKLIST_RESPONSE_MAP.remove('Competitors');
            }
            if(stipsCheck.Additional_Banks__c) {
                stips.put('Additional_Banks__c', stipsCheck.Additional_Banks__c ? '12 months of most recent bank statements, if funding amount >= $150,000' : '');
            } else {
                STIPS_CHECKLIST_RESPONSE_MAP.remove('Additional Banks');
            }
            if(stipsCheck.Bank_Verification_Call__c) {
                stips.put('Bank_Verification_Call__c', stipsCheck.Bank_Verification_Call__c ? 'Bank Verification Call or Decision Logic Signup' : '');
            } else {
                STIPS_CHECKLIST_RESPONSE_MAP.remove('Bank Verification Call');
            }
            if(stipsCheck.Verification_Call__c) {
                stips.put('Verification_Call__c', stipsCheck.Verification_Call__c ? 'Terms Verification Call if funding >= 175,000' : '');
            } else {
                STIPS_CHECKLIST_RESPONSE_MAP.remove('Verification Call');
            }

            if(stipsCheck.experian_fraud_check__c) {
                stips.put('experian_fraud_check__c', stipsCheck.experian_fraud_check__c ? 'Verification Call (Experian Fraud Alert)' : '');
            } else {
                STIPS_CHECKLIST_RESPONSE_MAP.remove('Experian Fraud Check');
            }

            if(stipsCheck.business_loan_agreement__c) {
                stips.put('business_loan_agreement__c', stipsCheck.business_loan_agreement__c ? 'Business Loan Agreement' : '');
            } else {
                STIPS_CHECKLIST_RESPONSE_MAP.remove('Business Loan Agreement');
            }

            if(stipsCheck.certification_of_beneficial_owners__c) {
                stips.put('certification_of_beneficial_owners__c', stipsCheck.certification_of_beneficial_owners__c ? 'Certification of Beneficial Owners Form' : '');
            } else {
                STIPS_CHECKLIST_RESPONSE_MAP.remove('Certification of Beneficial Owners Form');
            }

            if(stipsCheck.refinance_agreement__c) {
                stips.put('refinance_agreement__c', stipsCheck.refinance_agreement__c ? 'Refinance Agreement' : '');
            } else {
                STIPS_CHECKLIST_RESPONSE_MAP.remove('Refinance Agreement');
            }

            if(stipsCheck.third_party_agreement__c) {
                stips.put('third_party_agreement__c', stipsCheck.third_party_agreement__c ? 'Third Party Agreement' : '');
            } else {
                STIPS_CHECKLIST_RESPONSE_MAP.remove('Third Party Agreement');
            }

            if(stipsCheck.proof_of_business_location__c) {
                stips.put('proof_of_business_location__c', stipsCheck.proof_of_business_location__c ? 'Proof of Business Location' : '');
            } else {
                STIPS_CHECKLIST_RESPONSE_MAP.remove('Proof of Business Location');
            }

            constructedResponse = PartnerAPIHelpers.constructResponseMap(stips, STIPS_CHECKLIST_RESPONSE_MAP);
            resultMap.put(STIPS_CHECK_LIST, constructedResponse);
        }
        else {
            resultMap.put(STIPS_CHECK_LIST, null);
        }

        return resultMap;
    }
}