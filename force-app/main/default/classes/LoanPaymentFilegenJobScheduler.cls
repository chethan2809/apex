public class LoanPaymentFilegenJobScheduler implements Schedulable {

    public Boolean runNextJob = false;
    public Integer jobSize = 2000;

    public loanPaymentFilegenJobScheduler() {
        this.runNextJob = false;
        this.jobSize = 2000;
    }

    public loanPaymentFilegenJobScheduler(Boolean runNextJob, Integer jobSize) {
        this.runNextJob = runNextJob;
        this.jobSize = jobSize;
    }

    public void execute(SchedulableContext sc) {
        loan.LoanPaymentFilegenJob fileGenJob = new loan.LoanPaymentFilegenJob(runNextJob);
        Database.executeBatch(fileGenJob, jobSize);
    }
}