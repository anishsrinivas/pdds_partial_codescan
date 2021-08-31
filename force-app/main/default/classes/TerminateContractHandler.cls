// ---> Handler Class for 'TerminateContractTrigger' which will check if all the Subcrptions have Terminated date and update Contract Status

//---->Author: Ramana 

//---->Date : 06/22/2020
public class TerminateContractHandler {
    public static void Invoke(Map<Id,Opportunity> oldMap,Map<Id,Opportunity> newMap){
        //set < Id > updatedOpIds = new set < Id > ();
        set<Id> contracts =new set<Id>();
        for(opportunity opp:oldMap.values()){
            if (oldMap.get(opp.Id).StageName != newMap.get(opp.Id).StageName && newMap.get(opp.Id).StageName == 'Closed Won'&&
                newMap.get(opp.Id).SBQQ__AmendedContract__c!=null)
            {
                contracts.add(opp.SBQQ__AmendedContract__c);
            }
        }
        
   		//changes for PLAN-1023 - adding condition before firing SOQL
        if(contracts.size() > 0) {
            list<Contract> ConList =[Select id,status,(Select SBQQ__TerminatedDate__c from SBQQ__Subscriptions__r ) from Contract where id in :contracts ];
            
            List<SBQQ__Subscription__c> subToUpdate=new List<SBQQ__Subscription__c>();
            for(Contract c : ConList){
                Boolean flag = false;
                for(SBQQ__Subscription__c s:c.SBQQ__Subscriptions__r){
                  
                    If(s.SBQQ__TerminatedDate__c!=null){
                        flag=true;
                      }else{
                        flag= false;
                          Break;
                            }
                } 
                If(flag)
                c.Status='Terminated';
            }
            
           UPDATE ConList;
        }
        
    }
}