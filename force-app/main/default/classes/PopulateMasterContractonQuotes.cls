public class PopulateMasterContractonQuotes {
    
Public static void PopulateMasterContract(Map<Id,Opportunity> oldmap,Map<Id,Opportunity> newmap){
    
      Id billingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Map<Id,Id> updatedOppsContractMap = new Map<Id,Id>();
        for(opportunity opp : newmap.values()){
            if(   oldmap.get(opp.Id).ContractId !=newmap.get(opp.Id).ContractId &&
                newmap.get(opp.Id).ia_crm__Change_Type__c=='New MRR' &&
              newmap.get(opp.Id).RecordTypeID==billingRecordTypeId && newmap.get(opp.Id).ContractId!=NULL){
                updatedOppsContractMap.put(opp.Linked_Booking_Opportunity__c,opp.ContractId);
                
            }
              }

    list<Opportunity> AddOnoplist = new list<Opportunity>();
    if(updatedOppsContractMap.size()>0){
         AddOnoplist= [select id,Linked_Booking_Opportunity__c,SBQQ__PrimaryQuote__c from Opportunity where 
                                  ia_crm__Change_Type__c='Add on MRR' and Linked_Booking_Opportunity__c in :updatedOppsContractMap.keySet()];
    }
    
    set<Id> QuoteIds = new Set<Id>();
    for(Opportunity op:AddOnoplist ){
        QuoteIds.add(op.SBQQ__PrimaryQuote__c);
    }

    
     list<SBQQ__Quote__c> AddonOppsQuotes = new list<SBQQ__Quote__c>();
    
    If(QuoteIds.Size()>0){
        AddonOppsQuotes=[select id,SBQQ__Opportunity2__r.Linked_Booking_Opportunity__c,SBQQ__MasterContract__c from SBQQ__Quote__c 
                                           where Id in :QuoteIds ];
    }
     
 
    for(SBQQ__Quote__c quote :AddonOppsQuotes ){
        
        
        System.debug('Result-->'+ updatedOppsContractMap.get(quote.SBQQ__Opportunity2__r.Linked_Booking_Opportunity__c));
        quote.SBQQ__MasterContract__c=updatedOppsContractMap.get(quote.SBQQ__Opportunity2__r.Linked_Booking_Opportunity__c);
    }
    Update AddonOppsQuotes;
                                             

}
}