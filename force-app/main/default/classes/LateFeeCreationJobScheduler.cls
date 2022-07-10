public class LateFeeCreationJobScheduler implements Schedulable {

    public void execute(SchedulableContext sc) {
        Date fifthBusinessDay = GeneralHelper.getNBusinessDate(GeneralHelper.currentSystemDate, 4);

        if(CustomSettingsHelper.generalSettings.Late_fee_job_time__c == null) {
            throw new LateFeeCreationJobSchedulerException('Late_fee_job_time__c is null');
        }

        List<String> lateFeeTime = CustomSettingsHelper.generalSettings.Late_fee_job_time__c.split(':');

        if(lateFeeTime.size() == 3) {
            System.schedule(
                'LateFeeCreationJob_' + String.valueOf(Math.random()),
                GeneralHelper.getAsyncCronExpressionByDate(fifthBusinessDay, lateFeeTime.get(0), lateFeeTime.get(1), lateFeeTime.get(2)),
                new LateFeeCreationJob()
            );
        } else {
            throw new LateFeeCreationJobSchedulerException('Late_fee_job_time__c is invalid');
        }
    }

    private class LateFeeCreationJobSchedulerException extends Exception {}
}