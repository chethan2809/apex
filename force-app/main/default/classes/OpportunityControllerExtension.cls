public class OpportunityControllerExtension {
     //Constructor of the Class
     public OpportunityControllerExtension(ApexPages.StandardController ctrl) {
        stdController = ctrl;

        // initialize the refresh value as false
        refreshPage = false;
    }

    // DB Application Instance to get the applications related to the Opportunity
    public static ApplicationDB applicationDBInstance = new ApplicationDB();
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

    //Property for constructor of the controller
    public ApexPages.StandardController stdController { get; set; }
    public Boolean refreshPage { get; set; }

    //We get the Opportunity ID from the application
    Id oppID = ApexPages.currentPage().getParameters().get('Id');

    //Initialize object we are going to use in APEX to get data
    public List<genesis__Applications__c> applicationsList; //{get; set;}

    public List<genesis__Applications__c> getApplications() {

         applicationsList = applicationDBInstance.getActiveApplicationsByOpportunityIds(new Set<ID>{OppID});

    	return applicationsList;
	}


    public void saveApplication() {
     try {
     	List<genesis__Applications__c> listOfapplications = new List<genesis__Applications__c>();

	  for(genesis__Applications__c appl : applicationsList)
        {
          if(appl.Credit_Check_Consent__c){
              appl.Credit_Check_Consent__c = true;
          }
          else {
              appl.Credit_Check_Consent__c = false;
          }

          listOfapplications.add(appl);
        }

            applicationDBInstance.addUpdates(listOfapplications);
            applicationDBInstance.executeUpdates();

        	Apexpages.addMessage(new ApexPAges.Message(ApexPages.Severity.CONFIRM,'Record saved sucessfully!'));
        }
        catch(Exception e){
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'Update Application Error', e.getMessage() + e.getStackTraceString(), 'Error', null, ErrorLogs.ERROR,
                null, false
            );
              if(e.getMessage().contains('SIC code')) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'SIC code and/or Business Start Date should not be blank' ));
            }
            else {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() )); //'This is apex:pageMessages'));
            }
            errorLogDBInstance.addInsert(errorLog);
            errorLogDBInstance.executeInserts();
        }

        }

        private class ApplicationManagerException extends Exception {}

}