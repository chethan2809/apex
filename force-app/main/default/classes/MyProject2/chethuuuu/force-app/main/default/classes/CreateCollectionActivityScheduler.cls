public class CreateCollectionActivityScheduler implements Schedulable {

    public CreateCollectionActivityScheduler() {
    }

    public void execute(SchedulableContext sc) {
        collect.CreateCollectionActivityDagJob collectionStrategyJob = new collect.CreateCollectionActivityDagJob();
        ID batchProcessID = Database.executeBatch(collectionStrategyJob);
    }
}