@isTest
public class SchedulableRunOFACContact_Test {
	@isTest
    static void scheduleTest(){
        test.startTest();
        SchedulableRunOFACContact testsche = new SchedulableRunOFACContact();
        String sch = '0 0 23 * * ?';
        system.schedule('Test Batch', sch, testsche);
        test.stopTest();
    }
}