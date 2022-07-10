global Without Sharing class AdvanceFilter implements clcommon.PortalCustomRemoteAPI1 {

   global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> params) {
        clcommon.Response res = new clcommon.Response();
        //loan.GlobalLoanUtilFacade loanUtil = new loan.GlobalLoanUtilFacade();
        //Date systemDate = loanUtil.getCurrentSystemDate();
        List<Sobject> mapList = new List<Sobject>();
        List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
        
        String keyword;
        String flag = '1';
        List<String> status = new List<String>();
        status.add('NEW - MORE INFO REQUIRED');
        status.add('NEW - ENTERED');
  
        List<String> completeApps = new List<String>();
        completeApps.add('APPROVED');
        completeApps.add('REJECTED');
        completeApps.add('APPROVED - CONDITIONAL');
        completeApps.add('COMPLETED');
        
        
        List<String> submittedApps = new List<String>();
        submittedApps.add('NEW-SUBMITTED');
        submittedApps.add('SUBMITTED');
        
        Date fromDate = null;
        Date toDate = null;
        integer minLoanAmount = null;
        integer maxLoanAmount = null;
        String rejected;
        String appNumber;
        String jan = '%%';
        String userAccountId;
        String accountName;
        String acc = '%%';
        String statusSubmitted;
        String statusNewEntered;
        String statusOffered;
        String appstatusFilter;
        List<Id> appIds = new List<Id>();
        Set<String> appStatus = new Set<String>();
        
     //   Set<String> portalStatus = picklistValues('genesis__Applications__c','Broker_Portal_Status__c');
        
        if (params.containskey('appNumber') && params.get('appNumber') != null){
            appNumber= String.valueOf(params.get('appNumber')); 
            jan =  '%'+appNumber+'%';
        }
        if (params.containskey('accountName') && params.get('accountName') != null){
            accountName = String.valueOf(params.get('accountName')); 
            acc =  '%'+accountName+'%';
        }
        if (params.containskey('keyword') && params.get('keyword') != null){
            keyword = String.valueOf(params.get('keyword'));
             
        }
        /*if (params.containskey('status') && params.get('status') != null){
            status= String.valueOf(params.get('status')).spli; 
        }*/
        if (params.containskey('accountName') && String.isNotBlank(String.valueOf(params.get('accountName')))){
            accountName= String.valueOf(params.get('accountName'));
        }
        if (params.containskey('fromDate') && String.isNotBlank(String.valueOf(params.get('fromDate')))){
            fromDate= Date.valueof(String.valueOf(params.get('fromDate')));
        }
        if (params.containskey('toDate') && String.isNotBlank(String.valueOf(params.get('toDate')))){
            toDate= Date.valueof(String.valueOf(params.get('toDate'))); 
        }
        if (params.containskey('minLoanAmount') && String.isNotBlank(String.valueOf(params.get('minLoanAmount')))){
            minLoanAmount = Integer.valueof(String.valueOf(params.get('minLoanAmount'))); 
        }
        if (params.containskey('maxLoanAmount') && String.isNotBlank(String.valueOf(params.get('maxLoanAmount')))){
            maxLoanAmount= Integer.valueof(String.valueOf(params.get('maxLoanAmount'))); 
 
        }
        if (params.containskey('flag') && params.get('flag') != null){
            flag = String.valueOf(params.get('flag')); 
            
        }
        if (params.containskey('userAccountId') && String.isNotBlank(String.valueOf(params.get('userAccountId')))){
            userAccountId = String.valueOf(params.get('userAccountId')); 
            System.debug('userAccountId ='+userAccountId ); 
        }
        if (params.containskey('appstatusFilter') && String.isNotBlank(String.valueOf(params.get('appstatusFilter')))){
            appstatusFilter= String.valueof(String.valueOf(params.get('appstatusFilter')));
             System.debug('statusSubmitted='+appstatusFilter); 
             appStatus.add(appstatusFilter);
        }
        /*if (params.containskey('statusSubmitted') && String.isNotBlank(String.valueOf(params.get('statusSubmitted')))){
            statusSubmitted= String.valueof(String.valueOf(params.get('statusSubmitted')));
             System.debug('statusSubmitted='+statusSubmitted); 
             appStatus.add(statusSubmitted);
        }
        if (params.containskey('statusNewEntered') && String.isNotBlank(String.valueOf(params.get('statusNewEntered')))){
            statusSubmitted= String.valueof(String.valueOf(params.get('statusNewEntered')));
             System.debug('statusNewEntered='+statusNewEntered); 
             appStatus.add(statusNewEntered);
        }
        if (params.containskey('statusOffered') && String.isNotBlank(String.valueOf(params.get('statusOffered')))){
            statusOffered = String.valueof(String.valueOf(params.get('statusOffered')));
             System.debug('statusOffered='+statusOffered); 
             appStatus.add(statusOffered);
        }*/
        
        List<clcommon__Party__c > partyLst =[SELECT id, 
                                                    clcommon__Account__r.Name,
                                                    genesis__Application__c,
                                                    genesis__Application__r.Name
                                             FROM clcommon__Party__c 
                                             WHERE clcommon__Account__c=:userAccountId
                                             AND clcommon__Type__r.Name = 'DEALER'];
        for(clcommon__Party__c  party:partyLst ){
            appIds.add(party.genesis__Application__c);
                
        }                       
        try{
            String dealer = 'DEALER';
            if(flag=='1'){
                List<clcommon__Party__c> sObjList;
                
                if(appStatus.size()>0){
                    sObjList = Database.query('SELECT Id,clcommon__Account__r.Name, genesis__application__r.Name,genesis__application__r.genesis__Account__r.Name,genesis__application__r.genesis__Status__c,genesis__application__r.genesis__Loan_Amount__c,genesis__application__r.CreatedDate FROM clcommon__Party__c where (clcommon__Type__r.Name=:dealer  AND (genesis__application__r.createdDate>=:fromDate AND genesis__application__r.createddate<=:toDate) AND (genesis__application__r.genesis__Loan_Amount__c>=:minLoanAmount AND genesis__application__r.genesis__Loan_Amount__c<=:maxLoanAmount) AND (genesis__application__r.Name LIKE :jan OR genesis__application__r.genesis__Account__r.name LIKE:acc) AND (genesis__application__r.genesis__Status__c IN: appStatus) AND (genesis__application__r.id IN:appIds) AND (genesis__application__c != null)) order by genesis__application__r.createddate DESC');
                }
                if(appStatus.size()== 0){
            //        sObjList = Database.query('SELECT Id,clcommon__Account__r.Name, genesis__application__r.Name,genesis__application__r.genesis__Account__r.Name,genesis__application__r.CL_Purpose_Name__c,genesis__application__r.genesis__Status__c,genesis__application__r.genesis__Loan_Amount__c,genesis__application__r.CreatedDate FROM clcommon__Party__c where (clcommon__Type__r.Name=:dealer  AND (genesis__application__r.createdDate>=:fromDate AND genesis__application__r.createddate<=:toDate) AND (genesis__application__r.genesis__Loan_Amount__c>=:minLoanAmount AND genesis__application__r.genesis__Loan_Amount__c<=:maxLoanAmount) AND (genesis__application__r.Name LIKE :jan OR genesis__application__r.genesis__Account__r.name LIKE:acc) AND (genesis__application__r.genesis__Status__c IN: portalStatus) AND (genesis__application__r.id IN:appIds) AND (genesis__application__c != null)) order by genesis__application__r.createddate DESC');
                }
                //List<clcommon__Party__c> sObjList = Database.query('SELECT Id,clcommon__Account__r.Name, genesis__application__r.Name,genesis__application__r.genesis__Account__r.Name,genesis__application__r.CL_Purpose_Name__c,genesis__application__r.genesis__Status__c,genesis__application__r.genesis__Loan_Amount__c,genesis__application__r.CreatedDate FROM clcommon__Party__c where (clcommon__Type__r.Name=:dealer  AND (genesis__application__r.createdDate>=:fromDate AND genesis__application__r.createddate<=:toDate) AND (genesis__application__r.genesis__Loan_Amount__c>=:minLoanAmount AND genesis__application__r.genesis__Loan_Amount__c<=:maxLoanAmount) AND (genesis__application__r.Name LIKE :jan OR genesis__application__r.genesis__Account__r.name LIKE:acc) AND (genesis__application__r.genesis__Status__c IN: status) AND (genesis__application__r.id IN:appIds) AND (genesis__application__c != null)) order by genesis__application__r.createddate DESC');
                //List<genesis__Applications__c> sobjList = Database.query('SELECT CRN_Number__c,(select id,name,clcommon__Type__r.name from genesis__Parties__r WHERE clcommon__Type__r.Name=:dealer),Name,CreatedDate,genesis__Account__r.name,CL_Purpose_Name__c,genesis__Status__c,genesis__Loan_Amount__c FROM genesis__Applications__c WHERE ((createdDate>=:fromDate AND createddate<=:toDate) AND (genesis__Loan_Amount__c>=:minLoanAmount AND genesis__Loan_Amount__c<=:maxLoanAmount) AND (CRN_Number__c LIKE :jan OR genesis__Account__r.name LIKE:acc) AND (id IN:appIds))');
                for (clcommon__Party__c ts : sObjList ) {
                    //System.debug('ts='+ts.Name+'enesis__Loan_Amount__c='+ts.genesis__Loan_Amount__c);
                    mapList.add(ts);        
                 }
                        
                 for (Integer i = 0; i < mapList.size(); i++) {
                     respList.add(new clcommon.PortalCustomRemoteActionRecord(mapList.get(i)));
                 }
                 res = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
                 res.status = 'SUCCESS';

            
            }else if(flag=='2'){
                  List<clcommon__Party__c> sObjList;
                  if(appStatus.size()>0){
                    sObjList = Database.query('SELECT Id,clcommon__Account__r.Name, genesis__application__r.Name, genesis__application__r.genesis__Account__r.Name,genesis__application__r.genesis__Status__c,genesis__application__r.genesis__Loan_Amount__c,genesis__application__r.CreatedDate FROM clcommon__Party__c where (clcommon__Type__r.Name=:dealer AND (genesis__application__r.createdDate>=:fromDate AND genesis__application__r.createddate<=:toDate) AND (genesis__application__r.genesis__Loan_Amount__c>=:minLoanAmount AND genesis__application__r.genesis__Loan_Amount__c<=:maxLoanAmount) AND (genesis__application__r.Name LIKE :jan) AND (genesis__application__r.genesis__Status__c IN: appStatus) AND (genesis__application__r.genesis__Account__r.name LIKE :acc) AND (genesis__application__r.id IN:appIds) AND (genesis__application__c != null)) order by genesis__application__r.createddate DESC');
                  }
                  
                  //Added by Sudha for TPT-474
                  if(appStatus.size()==0){
                  sObjList = Database.query('SELECT Id,clcommon__Account__r.Name, genesis__application__r.Name, genesis__application__r.genesis__Account__r.Name,genesis__application__r.genesis__Status__c,genesis__application__r.genesis__Loan_Amount__c,genesis__application__r.CreatedDate FROM clcommon__Party__c where (clcommon__Type__r.Name=:dealer AND (genesis__application__r.createdDate>=:fromDate AND genesis__application__r.createddate<=:toDate) AND (genesis__application__r.genesis__Loan_Amount__c>=:minLoanAmount AND genesis__application__r.genesis__Loan_Amount__c<=:maxLoanAmount) AND (genesis__application__r.Name LIKE :jan) AND (genesis__application__r.genesis__Status__c IN: status) AND (genesis__application__r.genesis__Account__r.name LIKE :acc) AND (genesis__application__r.id IN:appIds) AND (genesis__application__c != null)) order by genesis__application__r.createddate DESC');
                  }
                  
                  //List<clcommon__Party__c> sObjList = Database.query('SELECT Id,clcommon__Account__r.Name, genesis__application__r.Name, genesis__application__r.genesis__Account__r.Name,genesis__application__r.CL_Purpose_Name__c,genesis__application__r.genesis__Status__c,genesis__application__r.genesis__Loan_Amount__c,genesis__application__r.CreatedDate FROM clcommon__Party__c where (clcommon__Type__r.Name=:dealer AND (genesis__application__r.createdDate>=:fromDate AND genesis__application__r.createddate<=:toDate) AND (genesis__application__r.genesis__Loan_Amount__c>=:minLoanAmount AND genesis__application__r.genesis__Loan_Amount__c<=:maxLoanAmount) AND (genesis__application__r.genesis__Status__c IN:status) AND (genesis__application__r.Name LIKE :jan OR genesis__application__r.genesis__Account__r.name LIKE:acc) AND (genesis__application__r.id IN:appIds))');
                  //List<genesis__Applications__c> sobjList = Database.query('SELECT CRN_Number__c,(select id,name,clcommon__Type__r.name from genesis__Parties__r WHERE clcommon__Type__r.Name=:dealer),Name,CreatedDate,genesis__Account__r.name,CL_Purpose_Name__c,genesis__Status__c,genesis__Loan_Amount__c FROM genesis__Applications__c WHERE ((createdDate>=:fromDate AND createddate<=:toDate) AND (genesis__Loan_Amount__c>=:minLoanAmount AND genesis__Loan_Amount__c<=:maxLoanAmount) AND (genesis__Status__c IN:status) AND (CRN_Number__c LIKE :jan OR genesis__Account__r.name LIKE:acc) AND (id IN:appIds))');
                  for (clcommon__Party__c ts : sobjList ) {
                      //System.debug('ts='+ts.Name+'enesis__Loan_Amount__c='+ts.genesis__Loan_Amount__c);
                      mapList.add(ts);        
                   }
                        
                  for (Integer i = 0; i < mapList.size(); i++) {
                     respList.add(new clcommon.PortalCustomRemoteActionRecord(mapList.get(i)));
                 }
                 res = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
                 res.status = 'SUCCESS';

            }else if(flag == '3'){
                List<clcommon__Party__c> sObjList;
                if(appStatus.size()>0){
                    sObjList = Database.query('SELECT Id,clcommon__Account__r.Name, genesis__application__r.Name, genesis__application__r.genesis__Account__r.Name,genesis__application__r.genesis__Status__c,genesis__application__r.genesis__Loan_Amount__c,genesis__application__r.CreatedDate  FROM clcommon__Party__c where (clcommon__Type__r.Name=:dealer AND (genesis__application__r.createdDate>=:fromDate AND genesis__application__r.createddate<=:toDate) AND (genesis__application__r.genesis__Loan_Amount__c>=:minLoanAmount AND genesis__application__r.genesis__Loan_Amount__c<=:maxLoanAmount) AND (genesis__application__r.genesis__Status__c IN: appStatus) AND (genesis__application__r.Name LIKE :jan OR genesis__application__r.genesis__Account__r.name LIKE:acc) AND (genesis__application__r.id IN:appIds) AND (genesis__application__c != null)) order by genesis__application__r.createddate DESC');
                }
                
                if(appStatus.size() == 0){
                    sObjList = Database.query('SELECT Id,clcommon__Account__r.Name, genesis__application__r.Name, genesis__application__r.genesis__Account__r.Name,genesis__application__r.genesis__Status__c,genesis__application__r.genesis__Loan_Amount__c,genesis__application__r.CreatedDate  FROM clcommon__Party__c where (clcommon__Type__r.Name=:dealer AND (genesis__application__r.createdDate>=:fromDate AND genesis__application__r.createddate<=:toDate) AND (genesis__application__r.genesis__Loan_Amount__c>=:minLoanAmount AND genesis__application__r.genesis__Loan_Amount__c<=:maxLoanAmount) AND (genesis__application__r.genesis__Status__c IN:completeApps) AND (genesis__application__r.Name LIKE :jan OR genesis__application__r.genesis__Account__r.name LIKE:acc) AND (genesis__application__r.id IN:appIds) AND (genesis__application__c != null)) order by genesis__application__r.createddate DESC');
                }
                                                      
                //List<genesis__Applications__c> sobjList = Database.query('SELECT CRN_Number__c,CreatedDate,genesis__Account__r.name,CL_Purpose_Name__c,genesis__Status__c,genesis__Loan_Amount__c FROM genesis__Applications__c WHERE ((createdDate>=:fromDate AND createddate<=:toDate) AND (genesis__Loan_Amount__c>=:minLoanAmount AND genesis__Loan_Amount__c<=:maxLoanAmount) AND (genesis__Status__c IN:completeApps) AND (CRN_Number__c LIKE :jan OR genesis__Account__r.name LIKE:acc) AND (id IN:appIds))');
                for (clcommon__Party__c ts : sobjList ) {
                    //System.debug('ts='+ts.Name+'enesis__Loan_Amount__c='+ts.genesis__Loan_Amount__c);
                    mapList.add(ts);        
                 }
                        
                 for (Integer i = 0; i < mapList.size(); i++) {
                     System.debug('mapList.get(i)='+mapList.get(i));
                     respList.add(new clcommon.PortalCustomRemoteActionRecord(mapList.get(i)));
                 }
                 res = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
                 System.debug('res ='+res.content);
                 System.debug('res ='+res.response);
                 res.status = 'SUCCESS';
                 
             }else if(flag == '4'){
                
                List<clcommon__Party__c> sObjList = Database.query('SELECT Id,clcommon__Account__r.Name, genesis__application__r.Name, genesis__application__r.genesis__Account__r.Name,genesis__application__r.genesis__Status__c,genesis__application__r.genesis__Loan_Amount__c,genesis__application__r.CreatedDate  FROM clcommon__Party__c where (clcommon__Type__r.Name=:dealer AND genesis__application__r.id IN:appIds AND (genesis__application__c != null)) order by genesis__application__r.createddate DESC limit 4');
                
               // List<genesis__Applications__c> sobjList = Database.query('SELECT CRN_Number__c,(select id,name,clcommon__Type__r.name from genesis__Parties__r WHERE clcommon__Type__r.Name=:dealer),Name,CreatedDate,genesis__Account__r.name,CL_Purpose_Name__c,genesis__Status__c,genesis__Loan_Amount__c FROM genesis__Applications__c WHERE id IN:appIds order by createddate DESC limit 4');
                for (clcommon__Party__c ts : sobjList ) {
                    //System.debug('ts='+ts.Name+'enesis__Loan_Amount__c='+ts.genesis__Loan_Amount__c);
                    mapList.add(ts);        
                 }
                        
                 for (Integer i = 0; i < mapList.size(); i++) {
                     System.debug('mapList.get(i)='+mapList.get(i));
                     respList.add(new clcommon.PortalCustomRemoteActionRecord(mapList.get(i)));
                 }
                 res = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
                 System.debug('res ='+res.content);
                 System.debug('res ='+res.response);
                 res.status = 'SUCCESS';
             
             
             }else if(flag=='5'){
                List<clcommon__Party__c> sObjList;
                  if(appStatus.size()>0){
                      System.debug('appStatus='+appStatus);
                      sObjList = Database.query('SELECT Id,clcommon__Account__r.Name, genesis__application__r.Name, genesis__application__r.genesis__Account__r.Name,genesis__application__r.genesis__Status__c,genesis__application__r.genesis__Loan_Amount__c,genesis__application__r.CreatedDate FROM clcommon__Party__c where (clcommon__Type__r.Name=:dealer AND (genesis__application__r.createdDate>=:fromDate AND genesis__application__r.createddate<=:toDate) AND (genesis__application__r.genesis__Loan_Amount__c>=:minLoanAmount AND genesis__application__r.genesis__Loan_Amount__c<=:maxLoanAmount) AND (genesis__application__r.Name LIKE :jan) AND (genesis__application__r.genesis__Status__c IN: appStatus) AND (genesis__application__r.genesis__Account__r.name LIKE :acc) AND (genesis__application__r.id IN:appIds) AND (genesis__application__c != null)) order by genesis__application__r.createddate DESC');
                  }
                  if(appStatus.size()==0){
                    //Added by Sudha for TPT-474
                    sObjList = Database.query('SELECT Id,clcommon__Account__r.Name, genesis__application__r.Name, genesis__application__r.genesis__Account__r.Name,genesis__application__r.CL_Purpose_Name__c,genesis__application__r.genesis__Status__c,genesis__application__r.genesis__Loan_Amount__c,genesis__application__r.CreatedDate FROM clcommon__Party__c where (clcommon__Type__r.Name=:dealer AND (genesis__application__r.createdDate>=:fromDate AND genesis__application__r.createddate<=:toDate) AND (genesis__application__r.genesis__Loan_Amount__c>=:minLoanAmount AND genesis__application__r.genesis__Loan_Amount__c<=:maxLoanAmount) AND (genesis__application__r.Name LIKE :jan) AND (genesis__application__r.genesis__Status__c IN: appStatus) AND (genesis__application__r.genesis__Account__r.name LIKE :acc) AND (genesis__application__r.id IN:appIds) AND (genesis__application__c != null)) order by genesis__application__r.createddate DESC');
                  }

                  
                  for (clcommon__Party__c ts : sobjList ) {
                      mapList.add(ts);        
                   }
                        
                  for (Integer i = 0; i < mapList.size(); i++) {
                     System.debug('mapList.get(i)='+mapList.get(i));
                     respList.add(new clcommon.PortalCustomRemoteActionRecord(mapList.get(i)));
                 }
                 res = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
                 System.debug('res ='+res.content);
                 System.debug('res ='+res.response);
                 res.status = 'SUCCESS';

            }else if(flag=='6'){
                List<clcommon__Party__c> sObjList;
                  if(appStatus.size()>0){
                      System.debug('appStatus='+appStatus);
                      sObjList = Database.query('SELECT Id,clcommon__Account__r.Name, genesis__application__r.Name, genesis__application__r.genesis__Account__r.Name,genesis__application__r.genesis__Status__c,genesis__application__r.genesis__Loan_Amount__c,genesis__application__r.CreatedDate FROM clcommon__Party__c where (clcommon__Type__r.Name=:dealer AND (genesis__application__r.createdDate>=:fromDate AND genesis__application__r.createddate<=:toDate) AND (genesis__application__r.genesis__Loan_Amount__c>=:minLoanAmount AND genesis__application__r.genesis__Loan_Amount__c<=:maxLoanAmount) AND (genesis__application__r.Name LIKE :jan) AND (genesis__application__r.genesis__Status__c IN: appStatus) AND (genesis__application__r.genesis__Account__r.name LIKE :acc) AND (genesis__application__r.id IN:appIds) AND (genesis__application__c != null)) order by genesis__application__r.createddate DESC');
                  }
                  //Added by Sudha for TPT-474
                  if(appStatus.size() == 0){
                    sObjList = Database.query('SELECT Id,clcommon__Account__r.Name, genesis__application__r.Name, genesis__application__r.genesis__Account__r.Name,genesis__application__r.genesis__Status__c,genesis__application__r.genesis__Loan_Amount__c,genesis__application__r.CreatedDate FROM clcommon__Party__c where (clcommon__Type__r.Name=:dealer AND (genesis__application__r.createdDate>=:fromDate AND genesis__application__r.createddate<=:toDate) AND (genesis__application__r.genesis__Loan_Amount__c>=:minLoanAmount AND genesis__application__r.genesis__Loan_Amount__c<=:maxLoanAmount) AND (genesis__application__r.Name LIKE :jan) AND (genesis__application__r.genesis__Status__c IN: submittedApps) AND (genesis__application__r.genesis__Account__r.name LIKE :acc) AND (genesis__application__r.id IN:appIds) AND (genesis__application__c != null)) order by genesis__application__r.createddate DESC');
                  }
                  
                  for (clcommon__Party__c ts : sobjList ) {
                      mapList.add(ts);        
                   }
                        
                  for (Integer i = 0; i < mapList.size(); i++) {
                     System.debug('mapList.get(i)='+mapList.get(i));
                     respList.add(new clcommon.PortalCustomRemoteActionRecord(mapList.get(i)));
                 }
                 res = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
                 System.debug('res ='+res.content);
                 System.debug('res ='+res.response);
                 res.status = 'SUCCESS';

            }else{
                  res = new clcommon.Response();
                  res.status = clcommon.Constants.ERROR;
                  res.errorCode = clcommon.Constants.API_EXCEPTION;
                  res.errorMessage = 'Key Flag Needs to be pushed';
             }
            
           }Catch(Exception e){
               System.debug('message='+e.getMessage()+'line='+e.getLineNumber());
                  res = new clcommon.Response();
                  res.status = clcommon.Constants.ERROR;
                  res.errorCode = clcommon.Constants.API_EXCEPTION;
                  res.errorMessage = e.getMessage();    
           }
           return res;
       }  

        public static Set<String> picklistValues(String objectName, String fieldName) {
            Set<String> portalStatus = new Set<String>();

            List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(new List<String>{objectName});
        
            for(Schema.DescribeSobjectResult res : results) {
                for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                    if (entry.isActive()) {
                        portalStatus.add(entry.getValue());
                    }
                }
            }
            return portalStatus;
        }
      
}