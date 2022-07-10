public class LoanPaymentTransactionCreationScheduler implements Schedulable {

    public loanPaymentTransactionCreationScheduler() {}

    public void execute(SchedulableContext sc) {
        clcommon.DynamicJobAPI6 apiHandle = clcommon.APIFactory.getDynamicJobAPI6();
        apiHandle.runOnce('CAN Loan Payment Transaction DAG');
    }
}