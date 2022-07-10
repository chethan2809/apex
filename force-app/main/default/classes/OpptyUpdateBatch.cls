global class OpptyUpdateBatch implements database.batchable<Sobject>{
    //start method
    global Database.QueryLocator start(Database.BatchableContext bc){
        string query='SELECT id,Name FROM Opportunity';
        return Database.getQueryLocator(query); 
    }
    //execute method
    global void execute(Database.BatchableContext bc,List<Opportunity>opptyList){
        System.debug('opptyList====>'+opptyList);
        for(Opportunity opportunityObj:opptyList){
        opportunityObj.Name='Batch Apex Calling';
        opportunityObj.LeadSource='Web';

            }
        Update opptyList;
      System.debug('opptyList====>'+opptyList);  
    }                                                                                         //batch1
    //finish method
    global void finish(Database.BatchableContext bc){
        
    }
}