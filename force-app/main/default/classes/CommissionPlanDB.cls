public class CommissionPlanDB  extends DBManager {
    public List<loan__Commission_Plan__c> getCommissionPlanByIds () {
        return [
            SELECT Id, Name
            FROM loan__Commission_Plan__c
        ];
    }
}