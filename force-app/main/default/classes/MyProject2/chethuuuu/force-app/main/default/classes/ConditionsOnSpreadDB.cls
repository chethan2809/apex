public class ConditionsOnSpreadDB {

    public List<loan__Conditions_On_Spread__c> getDefaultConditionsOnSpread() {
        return [
            SELECT Id
            FROM loan__Conditions_On_Spread__c
            WHERE loan__Parameter__c = 'True'
                AND loan__Operator__c = '='
                AND loan__Value__c = 'True'
            LIMIT 1
            FOR UPDATE
        ];
    }
}