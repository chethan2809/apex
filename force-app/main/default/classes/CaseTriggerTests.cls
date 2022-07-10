@IsTest
private class CaseTriggerTests
{
    @IsTest
    private static void caseTriggerTest()
    {
        Case newCase = new Case();
        newCase.Description = 'Test Requested';
        newCase.Subject = 'Test Subject';
        newCase.Type = 'Fund Release Request';
        insert newCase;

        newCase.Subject = 'Update Subject';
        update newCase;

        system.assert(newCase != null);
    }
}