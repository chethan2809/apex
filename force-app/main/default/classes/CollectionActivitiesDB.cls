public class CollectionActivitiesDB extends DBManager{
    public List<collect__Collection_Activity__c> getCollectionActivitiesByIds(Set<Id> activitityIds) {
        return [
            SELECT
            Id, Proof_of_Claim__c, Judgement_Entered__c, collect__Action__c, collect__Oldest_Due_Date__c,
            Demand_Letter_Sent__c, collect__Days_Past_Due__c, Debit_consolidator__c, Attorney_Assigned__c,
            Judgment_amount__c, collect__Loan_Account_Name__c, Court__c,
            Bankruptcy_Chapter__c, Legal_Department_contact__c, collect__Loan_Account_Id__c,
            Has_Attorney__c, Case_Number__c, collect__Completed__c, collect__Completion_Date__c
            FROM collect__Collection_Activity__c
            WHERE Id IN :activitityIds
        ];
    }
}