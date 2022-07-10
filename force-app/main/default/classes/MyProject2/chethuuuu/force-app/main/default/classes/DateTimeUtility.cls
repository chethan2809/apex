public class DateTimeUtility {

    public DateTime getCurrentDateTime() {
        DateTime currentDateTime = DateTime.newInstance(GeneralHelper.currentSystemDate, DateTime.Now().Time());
        return currentDateTime;
    }
}