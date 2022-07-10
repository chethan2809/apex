public class PartyUtil{
    
    String partyId;
    public PartyUtil(String partyId){
        this.partyId = partyId;
    }
    
    public String deleteParty(){
        try{
            List<clcommon__Party__c> partyToBeDeleted = [Select Id,
                                                                  clcommon__Contact__c,
                                                                  clcommon__Account__c
                                                             From clcommon__Party__c
                                                            Where Id = :partyId limit 1];
                                                    
            deleteEmployment(partyToBeDeleted[0].clcommon__Contact__c);
            deleteIdentificationInfo(partyToBeDeleted[0].clcommon__Account__c);
            deleteIncome(partyToBeDeleted[0].clcommon__Contact__c);
            
            if(partyToBeDeleted != null && partyToBeDeleted.size() > 0){
                delete partyToBeDeleted;
            } 
            return 'Party deleted successfully.';
        }catch(Exception e){
            Throw (new CustomException(e.getMessage()+'----'+e.getStackTraceString()));
        }
        
    }
    void deleteEmployment(String contactId){
        List<genesis__Employment_Information__c> empToBeDeletedList = [Select Id 
                                                                         From genesis__Employment_Information__c
                                                                        Where genesis__Contact__c = :contactId];
                                                                        
        if(empToBeDeletedList != null && empToBeDeletedList.size() > 0){
            delete empToBeDeletedList;
        }
    
    }
    void deleteIdentificationInfo(String accountId){
        List<genesis__Identification_Information__c > IdentiInfoToBeDeletedList = [Select Id 
                                                                         From genesis__Identification_Information__c
                                                                        Where genesis__Account__c = :accountId];
                                                                        
        if(IdentiInfoToBeDeletedList != null && IdentiInfoToBeDeletedList.size() > 0){
            delete IdentiInfoToBeDeletedList;
        }
    
    }
    void deleteIncome(String contactId){
        List< genesis__Income__c> IncomeToBeDeletedList = [Select Id 
                                                             From genesis__Income__c
                                                            Where genesis__Contact__c = :contactId];
                                                                        
        if(IncomeToBeDeletedList != null && IncomeToBeDeletedList.size() > 0){
            delete IncomeToBeDeletedList;
        }
    
    }
}