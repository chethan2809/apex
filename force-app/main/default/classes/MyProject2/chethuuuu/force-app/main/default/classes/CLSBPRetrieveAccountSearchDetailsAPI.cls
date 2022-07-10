global class CLSBPRetrieveAccountSearchDetailsAPI implements clcommon.PortalCustomRemoteAPI1 {
    global clcommon.Response invokeAction(String componentStrName,
                                          String[] disclosureNames,
                                          Map<String, Object> argumentsFromPortal) {
         // Init parameter.
        SavePoint dbSavePoint = Database.setSavepoint();
        clcommon.Response response = new clcommon.Response();
        List<Sobject> mapList = new List<Sobject>();        
        List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();                                      
        Map<String,Object> fields = new Map<String,Object>();
        system.debug('--argumentsFromPortal--'+argumentsFromPortal);
          try {
              
              String loggedInUserId = UserInfo.getUserId();
              
              List<Account> accountList =[SELECT Id,Name,Phone,clcommon__Legal_Entity_Type__r.Name FROM Account WHERE CreatedById=:loggedInUserId AND clcommon__Legal_Entity_Type__r.Name = 'Corporation'];
              List<Contact> contactList =[SELECT Id,Name,Phone,clcommon__Legal_Entity_Type__r.Name FROM Contact WHERE CreatedById=:loggedInUserId AND clcommon__Legal_Entity_Type__r.Name = 'Individual']; 
              if(contactList != null && contactList.size() > 0){
                  for(Contact con: contactList){
                      mapList.add(con);
                  }
              }
              
              if(accountList != null && accountList.size() > 0){ 
                  for(Account acc: accountList){
                      mapList.add(acc);
                  }
              }
              if(mapList != null && mapList.size() > 0){
                  for (Integer i = 0; i < mapList.size(); i++) {
                  respList.add(new clcommon.PortalCustomRemoteActionRecord(mapList.get(i)));
              }
              }
              
                
         } catch (Exception e) {
            system.debug(e.getMessage() + '---'+e.getStackTraceString());
            Database.rollback(dbSavePoint);
            response = CLSBPUtil.getErrorResponse(CLSBPPortalConstants.SOMETHING_WENT_WRONG);
            return response;
        }
       
        //respList.add(new clcommon.PortalCustomRemoteActionRecord('KEY_RESPONSE', fields));
        response = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
        return response;                                       
                                              
   }
    private String getNamespaceForObjectName(){
        String namespace = 'genesis';
        if(String.isEmpty(namespace)){
            return '';
        }else{
            return namespace+'__';
        }
    }

}