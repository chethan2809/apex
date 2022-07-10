public class EndOfDayScheduleJob implements Schedulable {
    public EndOfDayScheduleJob() {}

    public void execute(SchedulableContext sc) {
        clcommon.DynamicJobAPI6 apiHandle = clcommon.APIFactory.getDynamicJobAPI6();
        apiHandle.runOnce('CAN Start of Day Dynamic Jobs');
    }
}