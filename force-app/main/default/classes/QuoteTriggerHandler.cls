public class QuoteTriggerHandler {
    
    //Added By Vignesh
    public static void updateStartDate(list<SBQQ__Quote__c> Quoteslist){
        
        Id billingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        set<Id> quoteIds = new Set<Id>();
        List<SBQQ__Quote__c> updatedQuoteList = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c q: Quoteslist){
            if(q.SBQQ__Type__c=='Quote'||q.SBQQ__Type__c=='Amendment'){
                quoteIds.add(q.Id);
            }
            
        }
        List<SBQQ__Quote__c> quotes = [select id,SBQQ__StartDate__c,SBQQ__EndDate__c ,SBQQ__Type__c  from SBQQ__Quote__c 
                                          where SBQQ__Opportunity2__r.RecordTypeID=:billingRecordTypeId and Id IN:quoteIds];

            for(SBQQ__Quote__c quote: quotes){
                Date todayDate = System.today();
                Date firstDate = date.valueof(todayDate).toStartOfMonth();
                //System.debug(firstDate);
                Date nextmonth=todayDate.addmonths(1);
                Date firstDateNextMonth = date.valueof(nextmonth).toStartOfMonth();
                //System.debug(firstDateNextMonth);
                Integer day = todayDate.day();
                if(quote.SBQQ__Type__c=='Amendment'){
                    
                if(Day >= 1 && Day <= 15){
                    quote.SBQQ__StartDate__c = firstDate;
                }else{
                    if(firstDateNextMonth>quote.SBQQ__EndDate__c){
                       quote.SBQQ__StartDate__c = firstDate; 
                    }else{
                        quote.SBQQ__StartDate__c = firstDateNextMonth; 
                    }
                    
                }
                    
                }else {
                    
                 if(Day >= 1 && Day <= 15){
                    quote.SBQQ__StartDate__c = firstDate;
                }else{
                    
                    quote.SBQQ__StartDate__c = firstDateNextMonth;
                }
                    
                }
                
                updatedQuoteList.add(quote);
            }
            //System.debug(updatedQuoteList);
            if(updatedQuoteList.size() > 0 ){
                update updatedQuoteList;
            }
            
    }
     // Added by Ramana on 02-15-2021 as Part of PLAN-819
    // Check if the Quote created is First one for the Opportunity and Mark it as Primary
    Public static Void UpdatePrimarycheckbox(Map<Id,SBQQ__Quote__c> QuoteMap){
        Set<Id> oppIds = new Set<Id>();
        Map<Id,Integer> OppQuoteMap = new Map<Id,Integer>();
       List<SBQQ__Quote__c> quotelist=[select id,SBQQ__Primary__c,SBQQ__Opportunity2__c from SBQQ__Quote__c 
                                    where SBQQ__Type__c='Quote' and SBQQ__Primary__c=False and Id in
                                    :QuoteMap.keySet()];
        
        for(SBQQ__Quote__c qt : quotelist){
           oppIds.add(qt.SBQQ__Opportunity2__c);
        }
       List<Opportunity> oplist =[select id,(select id,name from SBQQ__Quotes2__r) from Opportunity 
                                  where Id in :oppIds];
       
        for(opportunity op :oplist ){
            Integer count=0;
            for(SBQQ__Quote__c Quote : op.SBQQ__Quotes2__r ){
                
                count=count+1;
                
            }
            OppQuoteMap.put(op.Id,count);
        }
                                   
        for (SBQQ__Quote__c  quote :quotelist){
            
            if(OppQuoteMap.get(quote.SBQQ__Opportunity2__c)==1){
                
                quote.SBQQ__Primary__c=true;
            }
        }
        Update quotelist;
    }
}