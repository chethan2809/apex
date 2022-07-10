@isTest
public class SchedulableRunOFACAccount_Test {
	@isTest
    static void scheduleTest(){
        test.startTest();
        SchedulableRunOFACAccount testsche = new SchedulableRunOFACAccount();
        String sch = '0 0 23 * * ?';
        system.schedule('Test Batch', sch, testsche);
        test.stopTest();
    }
}