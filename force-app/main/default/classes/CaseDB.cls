public class CaseDB extends DBManager {
    public Case getCaseDetailsById(Id caseId, Id accountId){
        return [
            SELECT Type, Status, AccountId
            FROM Case
            WHERE Id = :caseId
            AND AccountId = :accountId
        ];
    }
}