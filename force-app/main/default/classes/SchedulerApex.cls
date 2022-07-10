global class SchedulerApex implements Schedulable {

 global void execute(SchedulableContext ctx) {
 OpportunityUpdateBatch oub=new OpportunityUpdateBatch(); //it avoids debug window
 Database.executeBatch(oub);

 } 
}