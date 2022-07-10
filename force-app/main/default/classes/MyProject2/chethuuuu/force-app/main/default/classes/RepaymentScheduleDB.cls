public class RepaymentScheduleDB extends DBManager {
    public List<loan__repayment_schedule__c> getRepyamnetScheculeByLoanId(Id loanId) {
        return [
            SELECT Id,
                Due_Date_For_Portal__c,
                loan__Due_Amount__c,
                loan__Balance__c,
                loan__loan_account__r.Name
            FROM loan__repayment_schedule__c
            WHERE loan__loan_account__c =:loanId AND 
            (loan__Is_Archived__c = false or loan__isPaid__c = true)
        ];
    }

    public List<ContentVersion> deleteContentDocument(Id contentVersionId) {
        return [
            SELECT Id,
            contentdocumentid
            FROM ContentVersion
            WHERE Id =:contentVersionId
        ];
    }
}