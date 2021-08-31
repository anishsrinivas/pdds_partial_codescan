/************************************************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Status           Development Completed
* @description      This  Batch class is Invoked from PracticeProfileTrigger when a 'non-Claw Back' Booking Opportunity
                    with type as 'New Business' Is Closed Won.This Class will Check the Quantity of Bundles in the 
                    respective Booking Opportunity Quote and Creates as many of Billing Opportunities as Of Bundle Quanity
                    and Invokes 'BatchCreateBillingQuotes'.
                   
***************************************************************************************************************************
Version    	Date        	Team    	Comments
***************************************************************************************************************************
* 1         20 Nov 2020     Ramana     Batch Class for creating Billing Opportunities
***************************************************************************************************************************/
global class BatchCreateBillOpportunities implements Database.Batchable<sObject>,Database.Stateful {
    Set<Id> OppIds=new Set<Id>();
    set<Id> BillopIds= new Set<Id>();
    set<Id> QuoteIds = new set<Id>();
    Map<ID,SBQQ__Quote__c> opbookquotemap = new Map<ID,SBQQ__Quote__c>();
    list<SBQQ__Quote__c> Quotelist = new list<SBQQ__Quote__c>();
    Map<String,list<SBQQ__Quoteline__c>> QuotelineMap = new Map<String,list<SBQQ__Quoteline__c>>();
    global BatchCreateBillOpportunities(Set<Id> OppIds){
        this.OppIds= OppIds;
    }

    global database.QueryLocator Start(database.BatchableContext bc){
        
        Id bookingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Booking').getRecordTypeId();
        String query ='SELECT id ,Stagename,SBQQ__PrimaryQuote__c FROM Opportunity where RecordTypeId=:bookingRecordTypeId and Id IN :OppIds'; 
        RETURN database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Opportunity> oplist){
        Set<Id> opIds = new Set<Id>();
        Id billingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        
        Map<Id,Id> BookBillMap = new Map<Id,Id>();
        Map<String,BillingOppsAutomation__c> BillingOppsCSMap=BillingOppsAutomation__c.getAll(); 
        String productsCodeToNeglect = BillingOppsCSMap.get('Automation').Product_Codes__c;
        List<String> productsCodeToNeglectList =  productsCodeToNeglect.split(','); 
        
        for(Opportunity op:oplist){
         opIds.add(op.Id);
        }
        
       if(oppIds.size()>0){
            list<Opportunity> Billingopps=[select Id,Linked_Booking_Opportunity__c from Opportunity where RecordTypeId=:billingRecordTypeId
                                           and Linked_Booking_Opportunity__c!=NULL
                                           and Linked_Booking_Opportunity__c in : opIds];
              for(Opportunity op: Billingopps){
            BookBillMap.put(op.Linked_Booking_Opportunity__c,op.Id);
        }
        }
        
        
        for(opportunity opp : oplist ){
            if(!BookBillMap.containskey(opp.Id) ){
              QuoteIds.add(opp.SBQQ__PrimaryQuote__c);  
            }
            
        }


       list<SBQQ__QuoteLine__c> Quotelinelist = new list<SBQQ__QuoteLine__c>();        
        if(QuoteIds.Size()>0){
            
            Quotelinelist=[select SBQQ__Quantity__c,SBQQ__Number__c,SBQQ__Discount__c,SBQQ__Product__c,DDS_Location__c,SBQQ__ListPrice__c,DDS_Bundle_Net_Total_Monthly__c,
                           SBQQ__SubscriptionType__c,
                           SBQQ__ProductSubscriptionType__c,DDS_Product_Category__c,DDS_Quote_Account__c,SBQQ__BundledQuantity__c,SBQQ__DefaultSubscriptionTerm__c,
                           SBQQ__Description__c,SBQQ__NetPrice__c,SBQQ__OptionType__c,
                           SBQQ__OptionLevel__c,SBQQ__OriginalPrice__c,SBQQ__PartnerPrice__c,SBQQ__PricebookEntryId__c,
                           SBQQ__PriceEditable__c,SBQQ__PricingMethodEditable__c,
                           SBQQ__ProductOption__c,SBQQ__ProratedListPrice__c,SBQQ__ProrateMultiplier__c,SBQQ__ProratedPrice__c,
                           SBQQ__RegularPrice__c,SBQQ__SubscriptionPricing__c , SBQQ__RequiredBy__r.SBQQ__Product__c,
                           SBQQ__RequiredBy__c,SBQQ__ComponentDiscountedByPackage__c,SBQQ__Bundle__c,
                           SBQQ__Quote__r.SBQQ__Opportunity2__c
                           from SBQQ__QuoteLine__c 
                           where SBQQ__Quote__c in :QuoteIds and (SBQQ__Bundle__c=true  or SBQQ__RequiredBy__c!=NULL) AND 
                           (NOT(SBQQ__ProductCode__c IN: productsCodeToNeglectList))
                           ];
        
        }
        
        Integer Index =1;
        for(SBQQ__QuoteLine__c QuoteLine :Quotelinelist ){
            
            if(QuoteLine.SBQQ__Bundle__c==true){
                
                decimal Quanty = QuoteLine.SBQQ__Quantity__c;
                ID headerId= QuoteLine.Id;
                integer p=0;
                String OpId=QuoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__c;
                for(p=1;p<=Quanty;p++){
                list<SBQQ__Quoteline__c> qllist= new list<SBQQ__Quoteline__c>();    
                for(SBQQ__QuoteLine__c ql :Quotelinelist ){
                    
                    If(ql.Id==headerId || ql.SBQQ__RequiredBy__c==headerId){
                        
                        qllist.add(ql);
                    }
                    
                }
                  QuotelineMap.put(Index+OpId,qllist);
                  Index=Index+1;
                }
          
                
            }
            
           
            
        }

        if(QuoteIds.Size()>0){
         Quotelist=[select id,SBQQ__Opportunity2__c,
                                        SBQQ__Account__c,
                                        SBQQ__Opportunity2__r.Name,
                                        SBQQ__Opportunity2__r.LeadSource,SBQQ__Opportunity2__r.Sales_Qualified_Appointment__c,
                                        SBQQ__Opportunity2__r.ABM__c,
                                        SBQQ__Opportunity2__r.Pricebook2Id,
                                        SBQQ__Opportunity2__r.Lead_Created_Date__c,SBQQ__Opportunity2__r.Referral_Account__c,
                                        SBQQ__Opportunity2__r.Referral_Contact__c,SBQQ__Opportunity2__r.DDS_Proposal_Notes__c,
                                        SBQQ__Opportunity2__r.DDS_Description__c,SBQQ__Opportunity2__r.DDS_Notes__c,
                                        SBQQ__Opportunity2__r.SalesLoft1__Primary_Contact__c,
                                        SBQQ__Opportunity2__r.Closedate,SBQQ__Opportunity2__r.OwnerId,
                                        SBQQ__StartDate__c,SBQQ__PrimaryContact__c,SBQQ__SubscriptionTerm__c,
                                        (select SBQQ__Quantity__c,SBQQ__Number__c,SBQQ__Discount__c,SBQQ__Product__c,DDS_Location__c,SBQQ__ListPrice__c,DDS_Bundle_Net_Total_Monthly__c,
                                         SBQQ__SubscriptionType__c,SBQQ__ProductSubscriptionType__c,DDS_Product_Category__c,DDS_Quote_Account__c,SBQQ__BundledQuantity__c,SBQQ__DefaultSubscriptionTerm__c,
                                         SBQQ__Description__c,SBQQ__NetPrice__c,SBQQ__OptionType__c,SBQQ__OptionLevel__c,SBQQ__OriginalPrice__c,SBQQ__PartnerPrice__c,
                                         SBQQ__PricebookEntryId__c,SBQQ__PriceEditable__c,SBQQ__PricingMethodEditable__c,SBQQ__ProductOption__c,SBQQ__ProratedListPrice__c,SBQQ__ProrateMultiplier__c,SBQQ__ProratedPrice__c,
                                         SBQQ__RegularPrice__c,SBQQ__SubscriptionPricing__c from SBQQ__LineItems__r where SBQQ__Bundle__c=true AND 
                           				(NOT(SBQQ__ProductCode__c IN: productsCodeToNeglectList))) from  SBQQ__Quote__c where ID in :QuoteIds];
        
    }
        

        list<Opportunity> Billops = new list<Opportunity>();
        Decimal TotalBundleQty=0;
        Map<id,Decimal> QuoteQuantityMap=new Map<id,Decimal>();
        for (SBQQ__Quote__c Qt : Quotelist){
            
            for(SBQQ__Quoteline__c q:Qt.SBQQ__LineItems__r){
                TotalBundleQty+= q.SBQQ__Quantity__c;
            }
            QuoteQuantityMap.put(Qt.Id,TotalBundleQty);
       
        }


        for (SBQQ__Quote__c Qt : Quotelist){

            opbookquotemap.put(Qt.SBQQ__Opportunity2__c,Qt);
            Decimal i;
            for(i=1;i<=QuoteQuantityMap.get(Qt.Id);i++){
                Opportunity op = new Opportunity();
                op.AccountId=Qt.SBQQ__Account__c;
                op.RecordTypeId=billingRecordTypeId;
                op.name=Qt.SBQQ__Opportunity2__r.Name+':'+' '+'Location'+ ' '+ i +':' +' '+'Billing';
                op.StageName='Investigating';
                op.Closedate=Qt.SBQQ__Opportunity2__r.Closedate;
                op.Linked_Booking_Opportunity__c=Qt.SBQQ__Opportunity2__c;
                op.OwnerId=Qt.SBQQ__Opportunity2__r.OwnerId; 
                op.SalesLoft1__Primary_Contact__c= Qt.SBQQ__Opportunity2__r.SalesLoft1__Primary_Contact__c;
                op.LeadSource=Qt.SBQQ__Opportunity2__r.LeadSource;
                op.Sales_Qualified_Appointment__c=Qt.SBQQ__Opportunity2__r.Sales_Qualified_Appointment__c;
                op.ABM__c=Qt.SBQQ__Opportunity2__r.ABM__c;
                op.Lead_Created_Date__c=Qt.SBQQ__Opportunity2__r.Lead_Created_Date__c;
                op.Referral_Account__c=Qt.SBQQ__Opportunity2__r.Referral_Account__c;
                op.Referral_Contact__c=Qt.SBQQ__Opportunity2__r.Referral_Contact__c;
                op.DDS_Proposal_Notes__c=Qt.SBQQ__Opportunity2__r.DDS_Proposal_Notes__c;
                op.DDS_Description__c=Qt.SBQQ__Opportunity2__r.DDS_Description__c;
                op.DDS_Notes__c=Qt.SBQQ__Opportunity2__r.DDS_Notes__c;
                op.Pricebook2Id=Qt.SBQQ__Opportunity2__r.Pricebook2Id;
                op.Is_Created_By_Batch__c=true;
                // Added for PLAN-707
                op.MRR_Type__c='Growth';
                // End of Addition
                if(i>1){
                  op.ia_crm__Change_Type__c='Add on MRR';  
                }else{
                    op.ia_crm__Change_Type__c='New MRR'; 
                }
                            
                Billops.add(op);
            }
            
        }
        

        If(Billops.size()>0){
           Insert Billops; 
        }
        
        
        for(Opportunity op : Billops){
            
            BillopIds.add(op.Id);
            
          
            
        }
        
       


    }
    global void finish(database.BatchableContext bc){
      
        If(BillopIds.size()>0  ){
            database.executeBatch(new BatchCreateBillingQuotes(BillopIds,opbookquotemap,QuotelineMap),1);
            //changes for PLAN-1012 starts
            database.executeBatch(new BatchCreateBillOppForOneTimeProducts(new List<Id>(QuoteIds)),1);
			//changes for PLAN-1012 ends
             
        }
    
                                                    
               
      }
}