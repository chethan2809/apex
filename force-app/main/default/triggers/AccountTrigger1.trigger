trigger AccountTrigger1 on Account (before insert){
    for(Account accountObj:Trigger.New){
        System.debug('Trigger.New===>'+Trigger.New);
         System.debug('Industry===>'+accountObj.Industry);
         System.debug('Type===>'+accountObj.Type);
        if(accountObj.Industry=='Banking'&& (accountObj.Type==null||accountObj.Type=='')){
            accountObj.addError('Please give the value for Type field');
            
        }
        
    }
    

}