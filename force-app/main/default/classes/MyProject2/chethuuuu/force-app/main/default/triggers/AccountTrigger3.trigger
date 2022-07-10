trigger AccountTrigger3 on Account (before insert,before update){
    for(Account accountObj:Trigger.New){
        System.debug('Trigger.New===>'+Trigger.New);
         System.debug('Industry===>'+accountObj.Industry);
         // System.debug('Type===>'+accountObj.Type);
        if(accountObj.Industry=='Banking'&& (accountObj.Type==null||accountObj.Type=='')){            //check once issues
            accountObj.addError(System.label.account_Error_Note);
            
        }
        
    }
    
}