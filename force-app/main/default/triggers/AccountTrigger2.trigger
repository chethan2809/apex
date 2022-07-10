trigger AccountTrigger2 on Account (before update){
    for(Account accountObj:Trigger.New){
        System.debug('Trigger.New===>'+Trigger.New);
        if(accountObj.Industry=='Banking'){        //this takes blank values
            accountObj.Rating='Hot';
            
        }
        
    }
    

}