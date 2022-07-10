global class MPE_BatchJobStatus implements Database.Batchable<sObject>,Schedulable
{

global Database.QueryLocator start(Database.BatchableContext BC) {
    String st = 'Queued';
    String query = 'SELECT ApexClassId,CompletedDate,Id,JobItemsProcessed,JobType,MethodName,NumberOfErrors,Status,TotalJobItems,ExtendedStatus FROM AsyncApexJob where Status !=:st AND CompletedDate =Today';
    return Database.getQueryLocator(query);
  }
   global void execute(SchedulableContext SC)
   {
        MPE_BatchJobStatus ds=new MPE_BatchJobStatus();
        database.executebatch(ds);
   }
  global void Execute(Database.BatchableContext bc,LIST<SObject> scope)
   {

     }
    global void finish(Database.BatchableContext BC){

        List<AsyncApexJob> listAsyncJobs = new List<AsyncApexJob>([SELECT ApexClassId,CompletedDate,Id,JobItemsProcessed,JobType,MethodName,NumberOfErrors,
            Status,TotalJobItems,ExtendedStatus FROM AsyncApexJob WHERE CompletedDate =Today AND Status!='Queued']);
        System.debug('00listAsyncJobs'+listAsyncJobs);
            String strBody = '';
        if (listAsyncJobs != null && listAsyncJobs.size() > 0) {
            strBody = '<html><body><table>';
            strBody += '<tr><td>ID</td>' + '<td>ApexClassId</td>'  + '<td>CompletedDate</td>>'+ '<td>JobsProcessed</td>' + '<td>JobType</td>' + '<td>NumberOfErrors</td>' + '<td>Error</td>'  + '<td>TotalJobItems</td>'+ '<td>Status</td>' + '</tr>';
            for (AsyncApexJob objAsyncJob:listAsyncJobs) {
                strBody += '<tr><td>' + objAsyncJob.Id + '</td><td>' + objAsyncJob.ApexClassId + '</td><td>' + objAsyncJob.CompletedDate + '</td><td>' + objAsyncJob.JobItemsProcessed + '</td><td>' + objAsyncJob.JobType + '</td><td>' + objAsyncJob.NumberOfErrors + '</td><td>' + objAsyncJob.ExtendedStatus + '</td><td>' + objAsyncJob.TotalJobItems + '</td><td>' + objAsyncJob.Status + '</td></tr>';
            }
            strBody += '</table></body></html>';
        }
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        attach.setFileName('BatchJobs.xls');
        attach.body = Blob.valueOf(strBody);

        // Send an email to the Apex job's submitter notifying of job completion.
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'kskk053@gmail.com'};// we are getting email from custom label
        mail.setToAddresses(toAddresses);
        mail.setSubject('ApexJobs');
        mail.setHtmlBody('PFA');
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });
        mails.add(mail);
        if(!mails.isEmpty()) {
            Messaging.SendEmail(mails);
        }
    }

}