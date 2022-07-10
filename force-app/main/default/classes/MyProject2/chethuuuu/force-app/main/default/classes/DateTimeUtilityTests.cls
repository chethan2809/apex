@isTest
public class DateTimeUtilityTests {
    private static DateTimeUtility DateTimeUtilityInstance = new DateTimeUtility();

    @isTest
    private static void getCurrentDateTime() {

    DateTime currentDateTime = DateTime.now().addSeconds(15);
    GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

    Test.startTest();
        DateTime actualDate = DateTimeUtilityInstance.getCurrentDateTime();
    Test.stopTest();

      DateTime actualDate2 = DateTime.newInstance(GeneralHelper.currentSystemDate, DateTime.Now().Time());
      System.assertEquals(actualDate,actualDate = DateTimeUtilityInstance.getCurrentDateTime());
    }
}