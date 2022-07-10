public class STIPSChecklists {
    public static STIPS_Checklist__c createSTIPSChecklist(Id applicationId) {
        STIPS_Checklist__c stipsChecklist = new STIPS_Checklist__c();
        stipsChecklist.Application__c = applicationId;
        return stipsChecklist;
    }

    public static void setDefaultSTIPSChecklistValues(STIPS_Checklist__c stipsDetail) {
        stipsDetail.Proof_of_Ownership__c = false;
        stipsDetail.Identification__c = false;
        stipsDetail.Guarantors_Whose_Identity_Not_Verified__c = null;
        stipsDetail.Federal_Tax_ID__c = false;
        stipsDetail.Borrower_Interview__c = false;
        stipsDetail.Voided_Check__c = false;
        stipsDetail.Competitors__c = false;
        stipsDetail.Competitor_Names__c =  null;
        stipsDetail.Bank_Verification_Call__c = false;
        stipsDetail.Month_to_Date_Bank_Statement__c = false;
        stipsDetail.Additional_Banks__c = false;
        stipsDetail.Verification_Call__c = false;
        stipsDetail.experian_fraud_check__c = false;
    }
}