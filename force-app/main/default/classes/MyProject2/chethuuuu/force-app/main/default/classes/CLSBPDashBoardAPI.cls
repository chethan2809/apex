global class CLSBPDashBoardAPI implements clcommon.PortalCustomRemoteAPI1 {
    global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> argumentsFromPortal) {
        SavePoint dbSavePoint = Database.setSavePoint();
        clcommon.Response response = new clcommon.Response();
        List<SObject> mapList = new List<SObject>();
        List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
        Map<String,Object> fields = new Map<String,Object>();
        String loggedInUserId = UserInfo.getUserId();
        try {
            if(argumentsFromPortal.containsKey(CLSBPPortalConstants.SELECTED_STATUS)){
               Map<String,Object> statusMap = (Map<String,Object>)JSON.deserializeUntyped((String)argumentsFromPortal.get(CLSBPPortalConstants.SELECTED_STATUS));
               String bucket = (String)statusMap.get(PortalConstants.RADIO_FILTER);
                /*
            List<String> statusList = new List<String>();
            if(selectedStatus.equalsIgnoreCase(CLSBPPortalConstants.SUBMITTED)){
                statusList.add('NEW-SUBMITTED');
                statusList.add('NEW - IN REVIEW');
                statusList.add('NEW - PRICING GENERATED');
                statusList.add('NEW - CREDIT PULLED');
            }else if(selectedStatus.equalsIgnoreCase(CLSBPPortalConstants.OUTSTANDING)){
                statusList.add('NEW - ENTERED');
                statusList.add('NEW – MORE INFO REQUIRED');
            }else if(selectedStatus.equalsIgnoreCase(CLSBPPortalConstants.COMPLETED)){
                statusList.add('APPROVED - APPROVED');
                statusList.add('APPROVED - CONVERTED TO CONTRACT');
                statusList.add('REJECTED');
                statusList.add('CANCELLED');
            }else if(selectedStatus.equalsIgnoreCase(CLSBPPortalConstants.ALL)){
                statusList.add('NEW-SUBMITTED');
                statusList.add('NEW - IN REVIEW');
                statusList.add('NEW - PRICING GENERATED');
                statusList.add('NEW - CREDIT PULLED');
                statusList.add('NEW - ENTERED');
                statusList.add('NEW – MORE INFO REQUIRED');
                statusList.add('APPROVED - APPROVED');
                statusList.add('APPROVED - CONVERTED TO CONTRACT');
                statusList.add('REJECTED');
                statusList.add('CANCELLED');
            }
*/
                List<clcommon__Party__c> appList;
                if(bucket.equalsIgnoreCase(CLSBPPortalConstants.RECENT)){
                 appList = [SELECT Id, Name, clcommon__Account__r.Name,
                                                    		genesis__application__r.Id,
                                                          	genesis__application__r.Name,
                                                            genesis__Application__r.genesis__Contact__c,
                                                            genesis__Application__r.genesis__Contact__r.clcommon__Legal_Entity_Type__c,
                                                            genesis__Application__r.genesis__Account__r.clcommon__Legal_Entity_Type__c,
															genesis__application__r.genesis__Account__r.Name,
                                                          genesis__application__r.genesis__CL_Purpose__r.Name,
                                                          genesis__application__r.genesis__Status__c,
                                                    	  genesis__application__r.Application_Portal_Status__c,
                            							  genesis__application__r.portal_bucket__c,
                                                          genesis__application__r.genesis__Loan_Amount__c,
                                                          genesis__application__r.CreatedDate
                                                    FROM clcommon__Party__c
                                                    WHERE genesis__application__r.OwnerId =:loggedInUserId
                                                   AND clcommon__type__r.Name = 'BROKER'
                                                   order by genesis__Application__r.Name DESC
                            					   LIMIT 5];
            }else if(!bucket.equalsIgnoreCase('All')){
                 appList = [SELECT Id, Name, clcommon__Account__r.Name,
                                                    		genesis__application__r.Id,
                                                          	genesis__application__r.Name,
                                                            genesis__Application__r.genesis__Contact__c,
                                                            genesis__Application__r.genesis__Contact__r.clcommon__Legal_Entity_Type__c,
                                                            genesis__Application__r.genesis__Account__r.clcommon__Legal_Entity_Type__c,
															genesis__application__r.genesis__Account__r.Name,
                                                          genesis__application__r.genesis__CL_Purpose__r.Name,
                                                          genesis__application__r.genesis__Status__c,
                                                    	  genesis__application__r.Application_Portal_Status__c,
                            							  genesis__application__r.portal_bucket__c,
                                                          genesis__application__r.genesis__Loan_Amount__c,
                                                          genesis__application__r.CreatedDate
                                                    FROM clcommon__Party__c
                                                    WHERE genesis__application__r.portal_bucket__c =:bucket
                                                    AND genesis__application__r.OwnerId =:loggedInUserId
                                                   AND clcommon__type__r.Name = 'BROKER'
                                                   order by genesis__Application__r.Name DESC];
            }else{
                appList = [SELECT Id, Name, clcommon__Account__r.Name,
                                                    		genesis__application__r.Id,
                                                          	genesis__application__r.Name,
                                                            genesis__Application__r.genesis__Contact__c,
                                                            genesis__Application__r.genesis__Contact__r.clcommon__Legal_Entity_Type__c,
                                                            genesis__Application__r.genesis__Account__r.clcommon__Legal_Entity_Type__c,
															genesis__application__r.genesis__Account__r.Name,
                                                          genesis__application__r.genesis__CL_Purpose__r.Name,
                                                          genesis__application__r.genesis__Status__c,
                                                    	  genesis__application__r.Application_Portal_Status__c,
                           								  genesis__application__r.portal_bucket__c,
                                                          genesis__application__r.genesis__Loan_Amount__c,
                                                          genesis__application__r.CreatedDate
                                                    FROM clcommon__Party__c
                                                    WHERE genesis__application__r.OwnerId =:loggedInUserId
                                                   AND clcommon__type__r.Name = 'BROKER'
                                                   order by genesis__Application__r.Name DESC];
            }
                if(appList != null && appList.size() > 0){
                    for(clcommon__Party__c app: appList){
                        mapList.add(app);
                        //respList.add(new clcommon.PortalCustomRemoteActionRecord(app));
                    }
                    for (Integer i = 0; i < mapList.size(); i++) {
                        respList.add(new clcommon.PortalCustomRemoteActionRecord(mapList.get(i)));
                    }
                }
            } else if(argumentsFromPortal.containsKey(CLSBPPortalConstants.SEARCH_DETAILS)){
                Date fromDate = null;
                Date toDate = null;
                integer minLoanAmount = null;
                integer maxLoanAmount = null;
                String application;
                String jan = '%%';
                String accountName;
                String acc = '%%';
                String status;
                String appStatus = '%%';
                List<Id> appIds = new List<Id>();
                Map<String,Object> searchMap = (Map<String,Object>)JSON.deserializeUntyped((String)argumentsFromPortal.get(CLSBPPortalConstants.SEARCH_DETAILS));
                if (searchMap.containsKey('Broker_Portal_Status__c') && searchMap.get('Broker_Portal_Status__c') != null){
                     status= String.valueOf(searchMap.get('Broker_Portal_Status__c'));
                     appStatus =  '%'+status+'%';
                }
                if (searchMap.containsKey('Application') && searchMap.get('Application') != null){
                     application= String.valueOf(searchMap.get('Application'));
                     jan =  '%'+application+'%';
                }
                if (searchMap.containsKey('Account') && searchMap.get('Account') != null){
                    accountName = String.valueOf(searchMap.get('Account'));
                    acc =  '%'+accountName+'%';
                }
                if (searchMap.containsKey('Startdate_Filter') && String.isNotBlank(String.valueOf(searchMap.get('Startdate_Filter')))){
                    fromDate= Date.valueOf(String.valueOf(searchMap.get('Startdate_Filter')));
                }
                if (searchMap.containsKey('Enddate_Filter') && String.isNotBlank(String.valueOf(searchMap.get('Enddate_Filter')))){
                    toDate= Date.valueOf(String.valueOf(searchMap.get('Enddate_Filter')));
                }
                if (searchMap.containsKey('MinAmount') && String.isNotBlank(String.valueOf(searchMap.get('MinAmount')))){
                    minLoanAmount = Integer.valueOf(String.valueOf(searchMap.get('MinAmount')));
                }
                if (searchMap.containsKey('MaxAmount') && String.isNotBlank(String.valueOf(searchMap.get('MaxAmount')))){
                    maxLoanAmount= Integer.valueOf(String.valueOf(searchMap.get('MaxAmount')));
                }
                List<clcommon__Party__c> sObjList;
                sObjList = [SELECT genesis__application__r.Id, genesis__application__r.Name,
                            genesis__application__r.genesis__CL_Purpose__r.Name,
                            genesis__application__r.genesis__Status__c, genesis__application__r.genesis__Account__r.Name,
                            genesis__application__r.genesis__Loan_Amount__c, genesis__application__r.CreatedDate, clcommon__Account__r.Name
                            from clcommon__Party__c
                            WHERE (clcommon__Type__r.Name= 'BROKER' AND (genesis__application__r.OwnerId =:loggedInUserId) AND
                            (genesis__application__r.createdDate>=:fromDate AND genesis__application__r.CreatedDate<=:toDate)
                            AND (genesis__application__r.genesis__Loan_Amount__c>=:minLoanAmount AND genesis__application__r.genesis__Loan_Amount__c<=:maxLoanAmount)
                            AND (genesis__application__r.Name LIKE :jan AND genesis__application__r.genesis__Account__r.Name LIKE:acc))
                            order by genesis__application__r.createdDate DESC];
                for (clcommon__Party__c parties : sObjList ) {
                    mapList.add(parties);
                }
                for (Integer i = 0; i < mapList.size(); i++) {
                    respList.add(new clcommon.PortalCustomRemoteActionRecord(mapList.get(i)));
                }
            }
        }catch (Exception e) {
            system.debug(e.getMessage() + '---'+e.getStackTraceString());
            Database.rollback(dbSavePoint);
            response = CLSBPUtil.getErrorResponse(PortalConstants.SOMETHING_WENT_WRONG_MESSAGE);
            return response;
        }
        //respList.add(new clcommon.PortalCustomRemoteActionRecord('KEY_RESPONSE', fields));
        response = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
        return response;
    }

}