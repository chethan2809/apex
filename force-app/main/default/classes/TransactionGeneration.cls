global without sharing class TransactionGeneration implements clcommon.PortalCustomRemoteAPI1 {
   global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> params) {
        clcommon.Response res = new clcommon.Response();
        loan.GlobalLoanUtilFacade loanUtil = new loan.GlobalLoanUtilFacade();
        Date systemDate = loanUtil.getCurrentSystemDate();
        List<Sobject> mapList = new List<Sobject>();
        List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
        String loanId;
        Date fromDate;
        Date endDate = systemDate;
        String orderByValue = 'loan__Transaction_Date__c desc';
        String dateLiterals;
        if (params.containskey('loanId') && params.get('loanId') != null){
            loanId = String.valueOf(params.get('loanId'));
            List<loan__Loan_Account__c> loanContract = new List<loan__Loan_Account__c>();
            if(fromDate == null){
                loanContract = [Select Id,
                                       Name,
                                       loan__Accrual_Start_Date__c 
                                FROM loan__Loan_Account__c WHERE id=:loanId];
                fromDate = loanContract[0].loan__Accrual_Start_Date__c;
            }
           
         }else{
               res = new clcommon.Response();
               res.status = clcommon.Constants.ERROR;
               res.errorCode = clcommon.Constants.API_EXCEPTION;
               res.errorMessage = 'Loan Id is Empty';    
               return res;
        }
        if(params.containskey('recentTransaction') && params.get('recentTransaction') != null){
            dateLiterals = String.valueof(params.get('recentTransaction'));
            System.debug('dateLiterals ='+dateLiterals);
            String SOQLQuery = 'select Id, Name, loan__Payment_Type__c, loan__Payment_Mode__r.Name, loan__Transaction_Date__c,loan__Transaction_Amount__c,loan__Cleared__c from loan__Loan_Payment_Transaction__c  where  loan__Loan_Account__c= :loanId AND loan__Transaction_Date__c='+ dateLiterals + ' order by ' + orderByValue;
            System.debug('SOQLQuery ='+SOQLQuery );     
            List<loan__Loan_Payment_Transaction__c> lptList = database.query(SOQLQuery);
            System.debug('lptList ='+lptList );                   
            for (loan__Loan_Payment_Transaction__c ts : lptList) {
                mapList.add(ts);        
             }
                    
                    
             for (Integer i = 0; i < mapList.size(); i++) {
                 respList.add(new clcommon.PortalCustomRemoteActionRecord(mapList.get(i)));
             }
             res = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
             System.debug('res ='+res.content);
             System.debug('res ='+res.response);
             res.status = 'SUCCESS';
        }
        else if(params.containskey('range') && params.get('range') != null){
            
            try{
                    
                    if (params.containskey('fromDate') && params.get('fromDate') != null) {
                        fromDate = Date.valueof(String.valueOf(params.get('fromDate')));
                    }
                    if (params.containskey('endDate') && params.get('endDate') != null) {
                        endDate= Date.valueof(String.valueOf(params.get('endDate')));
                        
                    }
                    if (params.containskey('orderBy') && params.get('orderBy') != null) {
                        orderByValue = String.valueOf(params.get('orderBy'));
                    }
                    System.debug('fromDate ='+fromDate +'endDate='+endDate);
                    
                    String SOQLQuery = 'select Id, Name, loan__Payment_Type__c, loan__Payment_Mode__r.Name, loan__Transaction_Date__c,loan__Transaction_Amount__c,loan__Cleared__c from loan__Loan_Payment_Transaction__c  where loan__Loan_Account__c= :loanId AND loan__Transaction_Date__c>=:fromDate AND  loan__Transaction_Date__c<=:endDate order by ' + orderByValue;
                 
                    List<loan__Loan_Payment_Transaction__c> lptList = database.query(SOQLQuery);
                    System.debug('lptList ='+lptList );                   
                    for (loan__Loan_Payment_Transaction__c ts : lptList) {
                        mapList.add(ts);        
                    }
                    
                    
                    for (Integer i = 0; i < mapList.size(); i++) {
                        respList.add(new clcommon.PortalCustomRemoteActionRecord(mapList.get(i)));
                    }
                    res = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
                    System.debug('res ='+res.content);
                    System.debug('res ='+res.response);
                    res.status = 'SUCCESS';
                
                }catch(Exception e){
                       System.debug('message='+e.getMessage()+'line='+e.getLineNumber());
                        res = new clcommon.Response();
                        res.status = clcommon.Constants.ERROR;
                        res.errorCode = clcommon.Constants.API_EXCEPTION;
                        res.errorMessage = e.getMessage();
                }

              
        }else{  
            try{
                   
                    System.debug('fromDate ='+fromDate +'endDate='+endDate);
                    
                    String SOQLQuery = 'select Id, Name, loan__Payment_Type__c, loan__Payment_Mode__r.Name, loan__Transaction_Date__c, loan__Transaction_Amount__c,loan__Cleared__c from loan__Loan_Payment_Transaction__c  where loan__Loan_Account__c= :loanId AND loan__Transaction_Date__c>=:fromDate AND  loan__Transaction_Date__c<=:endDate order by ' + orderByValue;
                    System.debug('SOQLQuery ='+SOQLQuery );
                    List<loan__Loan_Payment_Transaction__c> lptList = database.query(SOQLQuery);
                    System.debug('lptList ='+lptList );                   
                    for (loan__Loan_Payment_Transaction__c ts : lptList) {
                        mapList.add(ts);        
                    }
                    
                    
                    for (Integer i = 0; i < mapList.size(); i++) {
                        respList.add(new clcommon.PortalCustomRemoteActionRecord(mapList.get(i)));
                    }
                    res = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
                    System.debug('res ='+res.content);
                    System.debug('res ='+res.response);
                    res.status = 'SUCCESS';
                
                }catch(Exception e){
                       System.debug('message='+e.getMessage()+'line='+e.getLineNumber());
                        res = new clcommon.Response();
                        res.status = clcommon.Constants.ERROR;
                        res.errorCode = clcommon.Constants.API_EXCEPTION;
                        res.errorMessage = e.getMessage();
                }

        }
         return res;         
     }
}