/************************************************************************************************************************
* @author           Demandblue
* @version          1.0 
* @description      This Batch class is invoked from batch class 'BatchCreateBillOppForOneTimeProducts' to create Quotes
                    and Quotelines for the Billing opportunities created by batch class 'BatchCreateBillOppForOneTimeProducts'.[PLAN-1012]
                   
***************************************************************************************************************************
Version    	Date        	Team    	Comments
*********************************************************************************************
* 1         10 Aug 2021     asrinivas     Batch Class for creating Billing Quotes
*********************************************************************************************/
global class BatchCreateBillQuotesForOneTimeProducts implements Database.Batchable<sObject>,Database.Stateful {
    Set<Id> BillOppIds=new Set<Id>();
    Map<ID,SBQQ__Quote__c> bookingOppToOriginalQuoteMap = new Map<ID,SBQQ__Quote__c>();
    Map<Id,Id> oppLinkedBkoppMap = new Map<Id,Id>();
    list<SBQQ__Quote__c> BillingQuotes = new List<SBQQ__Quote__c>();
    List<SBQQ__Quoteline__c> quoteLineListFromPrevBatch = new List<SBQQ__Quoteline__c>();
    
    global BatchCreateBillQuotesForOneTimeProducts(Set<Id> BillOppIds,Map<ID,SBQQ__Quote__c> bookingOppToQuoteMap,
       List<SBQQ__Quoteline__c> quoteLineList ){
                                     
        this.BillOppIds= BillOppIds;
        this.bookingOppToOriginalQuoteMap=bookingOppToQuoteMap;
        this.quoteLineListFromPrevBatch=quoteLineList;                                                                                                                                      
                                        
    }

    global database.QueryLocator Start(database.BatchableContext bc){
        
        String query ='SELECT id ,AccountId,Linked_Booking_Opportunity__c FROM Opportunity where Id in :BillOppIds'; 
        RETURN database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> Billops){
        list<SBQQ__Quote__c> BillQuotes = new list<SBQQ__Quote__c>();
        
        for(Opportunity op : Billops){
            oppLinkedBkoppMap.put(op.Id,op.Linked_Booking_Opportunity__c);
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.SBQQ__Opportunity2__c=op.Id;
            Quote.SBQQ__Account__c=op.AccountId;
            Quote.SBQQ__StartDate__c=bookingOppToOriginalQuoteMap.get(op.Linked_Booking_Opportunity__c).SBQQ__StartDate__c;
            Quote.SBQQ__PrimaryContact__c=bookingOppToOriginalQuoteMap.get(op.Linked_Booking_Opportunity__c).SBQQ__PrimaryContact__c;
            Quote.SBQQ__SubscriptionTerm__c=bookingOppToOriginalQuoteMap.get(op.Linked_Booking_Opportunity__c).SBQQ__SubscriptionTerm__c;
            Quote.SBQQ__Primary__c=true;
            BillQuotes.add(Quote);
        }
        System.debug('BillQuotes from 2nd batch>>'+BillQuotes);

        if(BillQuotes.size()>0){
            Insert BillQuotes;
        }
      
        Map<Id,Id> bookingOpptoNewQuoteMap = new Map<Id,Id>();
        for(SBQQ__Quote__c currQuote : BillQuotes){
            bookingOpptoNewQuoteMap.put(oppLinkedBkoppMap.get(currQuote.SBQQ__Opportunity2__c), currQuote.id);
        }
        
         SBQQ.TriggerControl.disable();
        
        try{
         
        list<SBQQ__QuoteLine__c> quoteLinesToInsert = new list<SBQQ__QuoteLine__c>();

         for(SBQQ__QuoteLine__c quoteline: quoteLineListFromPrevBatch){
           System.debug('quoteline.SBQQ__Quote__r.SBQQ__Opportunity2__c >>' +quoteline.SBQQ__Quote__r.SBQQ__Opportunity2__c);     
               SBQQ__QuoteLine__c QL = new SBQQ__QuoteLine__c();
          	   QL.SBQQ__Quote__c=bookingOpptoNewQuoteMap.get(quoteline.SBQQ__Quote__r.SBQQ__Opportunity2__c);
               QL.SBQQ__Product__c=quoteline.SBQQ__Product__c;
               Ql.SBQQ__Quantity__c=quoteline.SBQQ__Quantity__c;
               Ql.SBQQ__ProductSubscriptionType__c=quoteline.SBQQ__ProductSubscriptionType__c;
               Ql.SBQQ__SubscriptionType__c=quoteline.SBQQ__SubscriptionType__c;
               QL.SBQQ__ListPrice__c=quoteline.SBQQ__ListPrice__c;
               QL.SBQQ__Discount__c=quoteline.SBQQ__Discount__c;
               QL.DDS_Product_Category__c=quoteline.DDS_Product_Category__c;
               QL.SBQQ__Description__c=quoteline.SBQQ__Description__c;
               QL.SBQQ__NetPrice__c=quoteline.SBQQ__NetPrice__c;
               QL.SBQQ__OptionType__c=quoteline.SBQQ__OptionType__c;
               QL.SBQQ__OptionLevel__c=quoteline.SBQQ__OptionLevel__c;
               QL.SBQQ__OriginalPrice__c=quoteline.SBQQ__OriginalPrice__c;
               QL.SBQQ__PartnerPrice__c=quoteline.SBQQ__PartnerPrice__c;
               QL.SBQQ__PricebookEntryId__c=quoteline.SBQQ__PricebookEntryId__c;
               QL.SBQQ__PriceEditable__c=quoteline.SBQQ__PriceEditable__c;
               QL.SBQQ__PricingMethodEditable__c=quoteline.SBQQ__PricingMethodEditable__c;
               QL.SBQQ__ProductOption__c=quoteline.SBQQ__ProductOption__c;
               QL.SBQQ__ProratedListPrice__c=quoteline.SBQQ__ProratedListPrice__c;
               QL.SBQQ__ProrateMultiplier__c=quoteline.SBQQ__ProrateMultiplier__c;
               QL.SBQQ__ProratedPrice__c=quoteline.SBQQ__ProratedPrice__c;
               QL.SBQQ__RegularPrice__c=quoteline.SBQQ__RegularPrice__c;
               QL.SBQQ__SubscriptionPricing__c=quoteline.SBQQ__SubscriptionPricing__c;
               QL.SBQQ__Number__c=quoteline.SBQQ__Number__c;
               QL.SBQQ__ComponentDiscountedByPackage__c=quoteline.SBQQ__ComponentDiscountedByPackage__c;

               quoteLinesToInsert.add(QL);
        }
        System.debug('quoteLinesList from 2nd batch>>'+quoteLinesToInsert);
        Insert quoteLinesToInsert;     
        }
        
        finally{
           SBQQ.TriggerControl.enable();
        } 

    }
    
    global void finish(database.BatchableContext bc){
	}
}