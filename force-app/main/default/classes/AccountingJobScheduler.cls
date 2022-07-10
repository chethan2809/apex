public class AccountingJobScheduler implements Schedulable {

    public AccountingJobScheduler() {}

    public void execute(SchedulableContext sc) {
        String query = clcommon.QueryHelp.getDataMappingInitiatorQuery();
        clcommon.DataMapperInitiatorJob dataMapperInitiatorJobInstance = new clcommon.DataMapperInitiatorJob(query);
        Database.executeBatch(dataMapperInitiatorJobInstance, 1);
    }
}