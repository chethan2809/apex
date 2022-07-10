@IsTest
private class OpportunityTriggerTests
{
    private static OpportunityDB opportunityDBInstance = new OpportunityDB();

    @IsTest
    private static void opportunityTriggerTests()
    {
        Opportunity opportunity = TestUtility.createOpportunity();
        opportunity.Requested_Loan_Amount__c = 5001;
        opportunityDBInstance.addUpdate(opportunity);
        opportunityDBInstance.executeUpdates();

        System.assert(opportunity.Id != null);
    }
}