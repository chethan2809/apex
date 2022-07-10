public class STIPSChecklistDB extends DBManager {

    public List<STIPS_Checklist__c> getSTIPSCheckListByApplicationIds(Set<Id> applicationIds) {
        return [
            SELECT Id, Name, Additional_Banks__c, Application__c, Bank_Verification_Call__c, Borrower_Interview__c, Competitor_Names__c,
                Competitors__c, Federal_Tax_ID__c, Guarantors_Whose_Identity_Not_Verified__c, Identification__c,
                Last_Four_Bank_Account_Number__c, Month_to_Date_Bank_Statement__c, Proof_of_Ownership__c, Verification_Call__c, Voided_Check__c,
                experian_fraud_check__c,business_loan_agreement__c,certification_of_beneficial_owners__c,refinance_agreement__c,third_party_agreement__c,
                proof_of_business_location__c
            FROM STIPS_Checklist__c
            WHERE Application__c IN :applicationIds
        ];
    }
}