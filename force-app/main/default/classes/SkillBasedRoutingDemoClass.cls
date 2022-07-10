public class SkillBasedRoutingDemoClass {
    @InvocableMethod
    public static void routingCasesToAgents(LIst<String> caseIds){
        //Create PSR 
        //Add skills to the request for the case
        //Push it to queue
        List<Case> casesInserted = [SELECT id,subject from Case where ID IN: caseIds];
        LIst<Skill> allSkillsInDB = [SELECT id,MasterLabel from Skill];
        
        for(Case caseRec : casesInserted){
            PendingServiceRouting psr= new PendingServiceRouting();
            psr.workItemId = caseRec.Id;
            psr.RoutingType = 'SkillsBased';
            psr.RoutingPriority = 1;
            psr.CapacityWeight = 2;
            psr.ServiceChannelId = '0N9030000004CMC'; //USE YOUR OWN SERVICE CHANNEL ID
            psr.RoutingModel = 'LeastActive';
            psr.IsReadyForRouting = FALSE; //DRAFT state
            Insert psr; //DONE WITH MY FIRST STEP
            
            //FIND OUT THE SKILLS REQUIRED FOR A GIVEN CASE BASED ON ITS SUBJECT
            List<String> matchingSkillIds = new List<String>();
            for(Skill skillRec: allSkillsINDB){
                if(caseRec.Subject.contains(skillRec.MasterLabel)){
                    matchingSkillIds.add(skillRec.Id);
                }
            }
            
            List<SkillRequirement> skillReqsToInsert = new List<SkillRequirement>();
            //Associate matching skills with PSR request
            for(String matchingSkillId: matchingSkillIds){
                SkillRequirement skillRequ = new SkillRequirement();
                skillRequ.SkillId = matchingSkillId;
                skillRequ.RelatedRecordId = psr.id;
                skillRequ.SkillLevel = 5;
                skillReqsToInsert.add(skillRequ);
            }
            Insert skillReqsToInsert;
           
            //PUSH our request in to the queue
            psr.IsReadyForRouting = TRUE; 
            Update PSR;
        }
    }
}