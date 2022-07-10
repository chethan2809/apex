global class OpportunityUpdateBatch implements database.batchable<Sobject>{
    //start method
    global Database.QueryLocator start(Database.BatchableContext bc){
        string query='SELECT id,Name FROM Opportunity';
        return Database.getQueryLocator(query); 
    }
    //execute method
    global void execute(Database.BatchableContext bc,List<Opportunity>opptyList){
        System.debug('opptyList====>'+opptyList);
        for(Opportunity opportunityObj:opptyList){
        opportunityObj.Name='Batch Cron';
            }
        Update opptyList;
      System.debug('opptyList====>'+opptyList);  
    }
    //finish method
    global void finish(Database.BatchableContext bc){
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('oppertunityUpdateBatch' + a.Status);
        mail.setPlainTextBody('records processed ' + a.TotalJobItems +   'with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        OpptyUpdateBatch oub=new OpptyUpdateBatch();
        Database.executeBatch(oub);
        
    }
}