/************************************************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Status           Development Completed
* @description      This class is Invoked from 'TerminateContractTrigger' on Opportunity and Creates Contract Header when an 
                    Opportunity with Billing Recordtype and with Only One-Time Products and Asset Conversion
                    is defined for atleast one Product is Closed Won
                    
                   
***************************************************************************************************************************
Version    	Date        	Team    	Comments
***************************************************************************************************************************
* 1         19 Jan 2021     Ramana     Handler Class for creating Contract Headers
***************************************************************************************************************************/

public without sharing class CreateContractHeader {
    Public Static void CreateContract(Map<Id,Opportunity> oldMap,Map<Id,Opportunity> newMap)
     {
    Set<Id> UpdatedOpIds = new Set<Id>();
    List<Contract> conlist = new List<Contract>();
    Id billingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();  
       
         for(Opportunity op:newMap.Values() ){
            
            If(oldMap.get(op.Id).Stagename!=newMap.get(op.Id).Stagename 
               && newMap.get(op.Id).Stagename=='Closed Won'
               && oldMap.get(op.Id).SBQQ__Contracted__c!=newMap.get(op.Id).SBQQ__Contracted__c
               && newMap.get(op.Id).SBQQ__Contracted__c==true 
               && op.RecordtypeId == billingRecordTypeId 
               && op.ia_crm__Change_Type__c=='New MRR'){
    
                  UpdatedOpIds.add(op.Id) ;
               }
                                            
                                        }
         if(UpdatedOpIds.Size()>0){
         List<Opportunity> OppsList =[select Id,AccountId,SBQQ__PrimaryQuote__c,SBQQ__PrimaryQuote__r.SBQQ__StartDate__c,
                                      SBQQ__PrimaryQuote__r.SBQQ__EndDate__c ,SBQQ__PrimaryQuote__r.SBQQ__SubscriptionTerm__c,
                                      (select id,OpportunityId,SBQQ__SubscriptionType__c,Product2.SBQQ__SubscriptionPricing__c, 
                                        Product2.SBQQ__AssetConversion__c from Opportunitylineitems) from Opportunity where
                                       Id in :UpdatedOpIds ];
         
         for(Opportunity opp : OppsList){
             Boolean flag= false;
             // Check if Opportunity has Only One-Time Products
             for(Opportunitylineitem opl :opp.Opportunitylineitems ){
                 
                 if(opl.SBQQ__SubscriptionType__c=='One-time' && opl.Product2.SBQQ__SubscriptionPricing__c==NULL ){
                     // As per PLAN-1014, removing check for Asset conversion behaviour
                     
                    // if(opl.Product2.SBQQ__AssetConversion__c!=NULL){
                         
                         flag=true;
                  //   }
                     
                 }else{
                    flag= false;
                      Break;
                        }
             }
             If(flag==true){
                 Contract con = new Contract();
                 con.AccountId=opp.AccountId;
                 con.StartDate=opp.SBQQ__PrimaryQuote__r.SBQQ__StartDate__c;
                 con.EndDate=opp.SBQQ__PrimaryQuote__r.SBQQ__EndDate__c;
                 con.SBQQ__Opportunity__c=opp.Id;
                 con.SBQQ__Quote__c=opp.SBQQ__PrimaryQuote__c;
                 con.ContractTerm=(Integer)opp.SBQQ__PrimaryQuote__r.SBQQ__SubscriptionTerm__c;
                 con.Contract_Created_For_One_Time_Products__c=true;
                 conlist.add(con);
             }
             
         }
         
         Insert conlist;
         
    }
}
}