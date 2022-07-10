@isTest
private class CLX_BusinessDaysTests {

    @isTest
    private static void businessHours(){
       BusinessHours  businessHours = [
           SELECT Id, Name
           FROM BusinessHours
            LIMIT 1
        ];

        CLX_BusinessDays businessDays = new CLX_BusinessDays();
        CLX_BusinessDays businessDaysInstance = new CLX_BusinessDays(businessHours.Name);

        Test.startTest();
            DateTime dateTime1 = businessDaysInstance.addDays(DateTime.now(),2);
            DateTime dateTime2 = businessDaysInstance.subtractDays(DateTime.now(),0);
            businessDaysInstance.getNextWorkingDay(DateTime.now());
            businessDaysInstance.isWorkingDay(DateTime.now());
            Integer nofDays = businessDaysInstance.getNoOfBusinessDaysBetweenDates(DateTime.now(), DateTime.now()+1);
        Test.stopTest();

        DateTime expectedDateTime = DateTime.Now();

        System.assert(dateTime1 != null);
        System.assert(dateTime2 != null);
        System.assert(nofDays != null);
    }
}