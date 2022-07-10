/*
 * ClassName: ExceptionLog
 * Description : General exception log class
 * Parameter: String
*/
public class ExceptionLog {
    
    public static void insertExceptionLog(Exception e,String message, String appId){
        
        clcommon__Log__c log = new clcommon__Log__c();
        log.clcommon__Message__c = message+':'+e.getMessage()+' at Line Number :'+e.getLineNumber()+
                                   ' ExceptionStackTrace:'+e.getStackTraceString();
        log.clcommon__Module_Acronym__c = 'Genesis';
        log.clcommon__Time__c = datetime.now();
        log.clcommon__Type__c = e.getTypeName();  
        insert log;
    }

}