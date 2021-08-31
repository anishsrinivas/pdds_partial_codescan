/*******************************************************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Status           Development Completed
* @description      This Batch class is Invoked from Class 'UpdateMasterContractonQuotes' 
                    to update the Master Contract field on Add on Opportunity Quotes.
********************************************************************************************************************************
Version    	Date        	Team    	Comments
*******************************************************************************************************************************
* 1         20 Nov 2020     Ramana      Batch Class for updating Master Contract on Quotes
********************************************************************************************************************************/
global class BatchUpdateMasterContractonQuotes implements Database.Batchable<sObject> {
   set<Id> AddonQuoteIds = new set<Id>();
   Map<Id,Id> OppsContractMap = new Map<Id,Id>();
   Map<Id,Id> OppsBookBillMap = new Map<Id,Id>();
    global BatchUpdateMasterContractonQuotes(set<Id> AddonQuoteIds,Map<Id,Id> OppsContractMap,Map<Id,Id> OppsBookBillMap){
        this.AddonQuoteIds= AddonQuoteIds;
        this.OppsContractMap= OppsContractMap;
        this.OppsBookBillMap= OppsBookBillMap;
    }

    global database.QueryLocator Start(database.BatchableContext bc){

        String query ='select id,SBQQ__Opportunity2__r.Linked_Booking_Opportunity__c,SBQQ__MasterContract__c from SBQQ__Quote__c where Id IN :AddonQuoteIds'; 
        RETURN database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<SBQQ__Quote__c> Quotelist){
      
    for(SBQQ__Quote__c quote : Quotelist ){
            
    quote.SBQQ__MasterContract__c=OppsContractMap.get(OppsBookBillMap.get(quote.SBQQ__Opportunity2__r.Linked_Booking_Opportunity__c));
        
    }
        
   Update Quotelist;        
    }
    global void finish(database.BatchableContext bc){
      

                                                    
               
      }
}