/************************************************************************************************************************
* @author           Demandblue
* @version          1.0 
* @description      Whenever a Booking opportunity is closed own, another Billing Opportunity should be created, with
                    all One Time Products from the Booking quote can be added to this One Time Billing Quote, 
                    automatically when the Booking Opportunity is closed won.[PLAN-1012]
                   
***************************************************************************************************************************
Version     Date            Team        Comments
***************************************************************************************************************************
* 1         09 Aug 2021     asrinivas     Batch Class for creating Billing Opportunities for One Time Products
***************************************************************************************************************************/

global class BatchCreateBillOppForOneTimeProducts implements Database.Batchable<sObject>,Database.Stateful {
    List<Id> QuoteIds =new List<Id>();
    Set<Id> BillopIds= new Set<Id>();
    Map<ID,SBQQ__Quote__c> bookingOppToQuoteMap = new Map<ID,SBQQ__Quote__c>();
    List<SBQQ__Quote__c> Quotelist = new List<SBQQ__Quote__c>();
    Map<String,Set<SBQQ__Quoteline__c>> quoteToQuoteLineMap = new Map<String,Set<SBQQ__Quoteline__c>>();
    List<SBQQ__QuoteLine__c> Quotelinelist = new List<SBQQ__QuoteLine__c>(); 
    
    global BatchCreateBillOppForOneTimeProducts(List<Id> quoteIdSet){
        this.QuoteIds= quoteIdSet;
        System.debug('QuoteIds>>'+QuoteIds);
    }
	
    global database.QueryLocator start(Database.BatchableContext bc){
        System.debug('QuoteIds222>>'+QuoteIds);
        String query ='SELECT id FROM SBQQ__Quote__c where Id IN :QuoteIds LIMIT 1'; 
        return database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<SBQQ__Quote__c> arg){
        Id billingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        System.debug('billingRecordTypeId>>'+billingRecordTypeId);
        Map<Id,Id> BookBillMap = new Map<Id,Id>();
        Map<String,BillingOppsAutomation__c> BillingOppsCSMap=BillingOppsAutomation__c.getAll(); 
        String additionalproductsCodes = BillingOppsCSMap.get('Automation').Product_Codes__c;
        List<String> additionalproductsCodesList =  additionalproductsCodes.split(','); 
      
        List<SBQQ__QuoteLine__c> Quotelinelist1 = new List<SBQQ__QuoteLine__c>(); 
        List<SBQQ__QuoteLine__c> Quotelinelist2 = new List<SBQQ__QuoteLine__c>(); 
        System.debug('QuoteIds1111>>'+QuoteIds);
        if(QuoteIds.Size()>0){
            
            Quotelinelist=[select SBQQ__Quote__c,SBQQ__Quantity__c,SBQQ__Number__c,SBQQ__Discount__c,SBQQ__Product__c,DDS_Location__c,SBQQ__ListPrice__c,DDS_Bundle_Net_Total_Monthly__c,
                           SBQQ__SubscriptionType__c,
                           SBQQ__ProductSubscriptionType__c,DDS_Product_Category__c,DDS_Quote_Account__c,SBQQ__BundledQuantity__c,SBQQ__DefaultSubscriptionTerm__c,
                           SBQQ__Description__c,SBQQ__NetPrice__c,SBQQ__OptionType__c,
                           SBQQ__OptionLevel__c,SBQQ__OriginalPrice__c,SBQQ__PartnerPrice__c,SBQQ__PricebookEntryId__c,
                           SBQQ__PriceEditable__c,SBQQ__PricingMethodEditable__c,
                           SBQQ__ProductOption__c,SBQQ__ProratedListPrice__c,SBQQ__ProrateMultiplier__c,SBQQ__ProratedPrice__c,
                           SBQQ__RegularPrice__c,SBQQ__SubscriptionPricing__c , SBQQ__RequiredBy__r.SBQQ__Product__c,
                           SBQQ__RequiredBy__c,SBQQ__ComponentDiscountedByPackage__c,
                           SBQQ__Quote__r.SBQQ__Opportunity2__c
                           from SBQQ__QuoteLine__c 
                           where SBQQ__Quote__c in :QuoteIds and (SBQQ__SubscriptionType__c = 'One-time' AND SBQQ__SubscriptionPricing__c = NULL)
                           AND SBQQ__Quote__r.SBQQ__Opportunity2__r.Reseller_Opp__c = false AND SBQQ__RequiredBy__c = NULL AND DDS_Is_Bundle__c = false
                           ];
           /*
            Quotelinelist2 = [select SBQQ__Quote__c,SBQQ__Quantity__c,SBQQ__Number__c,SBQQ__Discount__c,SBQQ__Product__c,DDS_Location__c,SBQQ__ListPrice__c,DDS_Bundle_Net_Total_Monthly__c,
                           SBQQ__SubscriptionType__c,
                           SBQQ__ProductSubscriptionType__c,DDS_Product_Category__c,DDS_Quote_Account__c,SBQQ__BundledQuantity__c,SBQQ__DefaultSubscriptionTerm__c,
                           SBQQ__Description__c,SBQQ__NetPrice__c,SBQQ__OptionType__c,
                           SBQQ__OptionLevel__c,SBQQ__OriginalPrice__c,SBQQ__PartnerPrice__c,SBQQ__PricebookEntryId__c,
                           SBQQ__PriceEditable__c,SBQQ__PricingMethodEditable__c,
                           SBQQ__ProductOption__c,SBQQ__ProratedListPrice__c,SBQQ__ProrateMultiplier__c,SBQQ__ProratedPrice__c,
                           SBQQ__RegularPrice__c,SBQQ__SubscriptionPricing__c , SBQQ__RequiredBy__r.SBQQ__Product__c,
                           SBQQ__RequiredBy__c,SBQQ__ComponentDiscountedByPackage__c,
                           SBQQ__Quote__r.SBQQ__Opportunity2__c
                           from SBQQ__QuoteLine__c 
                           where SBQQ__Quote__c in :QuoteIds AND SBQQ__Quote__r.SBQQ__Opportunity2__r.Reseller_Opp__c = false 
                                  and (SBQQ__ProductCode__c IN :additionalproductsCodesList
                                 and (SBQQ__SubscriptionType__c = 'One-time' AND SBQQ__SubscriptionPricing__c = NULL))];
			
			Quotelinelist.addAll(Quotelinelist1);
        	Quotelinelist.addAll(Quotelinelist2);
*/
        System.debug('Quotelinelist>>'+Quotelinelist);
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
                                         SBQQ__RegularPrice__c,SBQQ__SubscriptionPricing__c from SBQQ__LineItems__r where (SBQQ__SubscriptionType__c = 'One-time' AND SBQQ__SubscriptionPricing__c = NULL)
                                         ) 
                                         from  SBQQ__Quote__c where SBQQ__Opportunity2__r.Reseller_Opp__c = false AND ID in :QuoteIds];
        System.debug('Quotelist>>'+Quotelist);
    }
        
        list<Opportunity> Billops = new list<Opportunity>();
       
        for (SBQQ__Quote__c Qt : Quotelist){

            bookingOppToQuoteMap.put(Qt.SBQQ__Opportunity2__c,Qt);
                Opportunity op = new Opportunity();
                op.AccountId=Qt.SBQQ__Account__c;
                op.RecordTypeId=billingRecordTypeId;
                op.name=Qt.SBQQ__Opportunity2__r.Name+': OneTime: '+'Billing';
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
                op.MRR_Type__c='Growth';
                op.ia_crm__Change_Type__c='New MRR';                              
                Billops.add(op);
        }
        

        If(Billops.size()>0){
           Insert Billops; 
        }
        
        System.debug('Billops>>'+Billops);
        for(Opportunity op : Billops){
            
            BillopIds.add(op.Id);
        }
        
    }
    
    global void finish(database.BatchableContext bc){
        If(BillopIds.size()>0  ){
            database.executeBatch(new BatchCreateBillQuotesForOneTimeProducts(BillopIds,bookingOppToQuoteMap,Quotelinelist),1); 
        }
    } 
}