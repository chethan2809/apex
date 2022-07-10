@RestResource(urlMapping='/v1/healthcheck/*')
global class HealthCheckAPI {
    
    @HttpPost
    global static void processHealthCheckRequest(){
        RestResponse response = RestContext.response;
        RestRequest request = RestContext.request;
        //get the last index of the URI to check the request type
        string requestName = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        System.debug('-------->'+requestName);
        Integer failedJobsCount = 0; 
        Boolean isJobProcessing= false;
        healthCheckWrapper hWrap;
        
        //return null if the request body is null
        if(APIHelpers.isRequestBodyEmpty(request, response)) {
            return;
        }
        
        String requestBody = APIHelpers.sanitizeString(request.requestBody.toString());
        //create a map for the input received from the request body
        Map<String, Object> requesthealthMap = (Map<String, Object>) APIHelpers.objectValidation(
            JSON.deserializeUntyped(requestBody), 'Map', 'Request body'
        ); 
        //get the current system date
        Date currentSystemDate = GeneralHelper.currentSystemDate;
        system.debug('System date---->'+currentSystemDate);
        //format the date received as string in the request body
        Date formattedDate = GeneralHelper.getDateFromUntypedString(string.valueOf(requesthealthMap.get('Date')),0,1,2,'-');
        //check whether the date sent is in sync with the system date    
        if(date.valueOf(formattedDate) != date.valueOf(currentSystemDate)){
            //return;
        }
        
        //condition to check whether the body contains only Date as the key value and also the request URI is hacing EODJobs
        if(requesthealthMap.keySet().size() ==1 && requesthealthMap.containsKey('Date') && requestName =='EODJobs'){
            //Get the DAG Schedule record for the end of day jobs
            List<clcommon__DAG_Schedule__c> DAGSchedules = [SELECT id, clcommon__DAG_Name__c FROM clcommon__DAG_Schedule__c
                                                      WHERE clcommon__DAG_Name__c='CAN Start of Day Dynamic Jobs' LIMIT 1];
            //get the DAG logging records for the DAG schedule for the requested date
            List<clcommon__DAG_Logging__c> DAGLogging = [SELECT id,clcommon__Start_Time__c,clcommon__Status__c FROM clcommon__DAG_Logging__c
                                                   WHERE DAY_ONLY(clcommon__Start_Time__c) =:formattedDate AND clcommon__DAG__c =:DAGSchedules[0].Id LIMIT 1];        
            
            List<failedJobWrapper> fJList = new List<failedJobWrapper>();
            //get the job logging records for the DAG logging record 
            for(clcommon__Job_Logging__c job : [SELECT id, clcommon__Label__c,clcommon__Status__c,clcommon__Log__c,CreatedDate FROM clcommon__Job_Logging__c WHERE clcommon__DAG_Logging__c=:DAGLogging[0].id]){
                //check for the status of the job logging
                if(job.clcommon__Status__c == 'Failure' || job.clcommon__Status__c == 'Aborted'){
                   	//create a lis of failed jobs in wrapper and add it to a list
                    failedJobWrapper fJW = new failedJobWrapper();
                    
                    fJW.name = job.clcommon__Label__c;
                    fJW.Status = job.clcommon__Status__c;
                  fJW.error = job.clcommon__Log__c;
                    fJW.dtTime = String.valueOf(job.CreatedDate); 
                    failedJobsCount++;
                    fJList.add(fJW); 
                }else if(job.clcommon__Status__c =='Processing'){
                    isJobProcessing= true;
                }
            }
             //check if there are any failures in jobs      
            if(failedJobsCount >0){
                hWrap = new healthCheckWrapper('Failed','Job(s) have failed',fJList);
                response.statusCode = 400;
            }else if(isJobProcessing){
                hWrap = new healthCheckWrapper('Jobs in progress','All Job(s) have been succeded');
                response.statusCode = 403;
            }else{
                hWrap = new healthCheckWrapper('Jobs succeeded','All Job(s) have been succeded');
                response.statusCode = 200;
            }
            
        }else{
            //details if the request body is wrong or the URI is not containing the EODJobs
            hWrap= new healthCheckWrapper('Incorrect details','Send Proper input');
        }
        //Serialisze the wrapper to form a string
        string resp = JSON.serialize(hWrap,true);
        string respBdy =resp.replaceAll('failedJobsList', 'Failed Job list').replaceAll('dtTime','datetime');
        //pass the details as Blob to the response body
        response.responseBody = Blob.valueOf(respBdy);
    }
    
    //Wrapper class for creating response for the request 
    global class healthCheckWrapper{
        string Status;
        string Description;
        List<failedJobWrapper> failedJobsList;
        
        //constructor if there are no failure jobs
        public healthCheckWrapper(string status, string description){
            this.Status = status;
            this.Description =description;            
        }
        //constructor if there are failure jobs
        public healthCheckWrapper(string status, string description, List<failedJobWrapper> failedJobsList){
            this.Status = status;
            this.Description =description;
            this.failedJobsList= failedJobsList;
        }
    }
    //wrapper class for creating list of failed jobs to pass in the response
    global class failedJobWrapper{
        string name;
        string Status;
        string error;
        string dtTime;
    }
}