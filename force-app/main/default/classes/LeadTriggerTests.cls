@IsTest
private class LeadTriggerTests
{
    private static LeadDB leadDbInstance = new LeadDB();

    @IsTest
    private static void leadTriggerTest()
    {
        Lead leadRecord = TestUtility.createLead();

        Lead lead = updateLead(leadRecord);
        lead.LeadSource = Leads.SOURCE_WEBSITE_MERCHANT;
        leadDbInstance.addUpdate(lead);
        leadDbInstance.executeUpdates();
        System.assert(lead.Id != null);
    }

    private static Lead updateLead(Lead leadRecord)
    {
        Lead lead = new Lead();
        lead.Id = leadRecord.Id;
        return lead;
    }
}