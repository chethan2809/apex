public class DisbursalDistributionFilegenScheduler implements Schedulable {

    public DisbursalDistributionFilegenScheduler() {}

    public void execute(SchedulableContext sc) {
        clcommon.DynamicJobAPI6 apiHandle = clcommon.APIFactory.getDynamicJobAPI6();
        apiHandle.runOnce('CAN Loan Disbursal File Gen DAG');
    }
}