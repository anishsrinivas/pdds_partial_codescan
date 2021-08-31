/******************************************************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Name      		Subscription_TriggerController
* @description 		This apex class is trigger from Subscription_Trigger to update Support End Date on Account
********************************************************************************************************************************
Version    	Date        	   Team    	     Comments
********************************************************************************************************************************
* 1    		26 May 2021    	Jeromia    	Initial Development 
*********************************************************************************************************************************************/


public class Subscription_TriggerController {
    
    public static void getSubscription(Set<Id> subIdSet,Set<Id> accountIdSet,Set<Id> endCustomerAccountIdSet ){
        
        
        Set<Id> AccountHavingNoSubscriptions= new Set<Id>(); 
        Set<Id> validSubIdSet = new Set<Id>();
        Set<Id> accountWithSubSet = new Set<Id>();
        Map<Id,List<SBQQ__Subscription__c>> revisedAndAmendedSubscriptionsMap = new  Map<Id,List<SBQQ__Subscription__c>>();
        Map<Id,Decimal> revisedSubscriptionAndQuanityMap = new Map<Id,Decimal>();
        Set<Id> amendedandRevisedSubscriptionIdSet = new Set<Id>();
        Map<Id,SBQQ__Subscription__c> subscriptionMap = new Map<Id,SBQQ__Subscription__c>();
        Map<Id,Date> AccountEndDateMap=new Map<Id,Date>();
        
        system.debug('subIdSet-->'+subIdSet);
        system.debug('accountIdSet-->'+accountIdSet);
        system.debug('endCustomerAccountIdSet-->'+endCustomerAccountIdSet);
        
        try{
            // Get revelant Subscription fields
            List<SBQQ__Subscription__c> subscriptionList = [Select Id,SBQQ__Account__c,End_Customer_Ship_To_Account__c,SBQQ__Contract__r.EndDate,SBQQ__Product__r.Product_License_Categories__c,SBQQ__Quantity__c
                                                            From SBQQ__Subscription__c
                                                            WHERE ID=:subIdSet];
            system.debug('subscriptionList-->'+subscriptionList);
            
            
            //Get XVWeb,Support Subscriptions of Active Contracts from related account and end customer account
            List<SBQQ__Subscription__c> validSubList = [Select Id,SBQQ__Account__c,End_Customer_Ship_To_Account__c,SBQQ__Contract__r.EndDate,SBQQ__Product__r.Product_License_Categories__c,SBQQ__RevisedSubscription__c,SBQQ__Quantity__c
                                                        From SBQQ__Subscription__c
                                                        Where (SBQQ__Account__c IN:accountIdSet OR SBQQ__Account__c IN:endCustomerAccountIdSet OR
                                                               End_Customer_Ship_To_Account__c IN:accountIdSet OR End_Customer_Ship_To_Account__c IN:endCustomerAccountIdSet) AND
                                                        SBQQ__Contract__r.Status = 'Activated' AND 
                                                        (SBQQ__Product__r.Product_License_Categories__c = 'XVWeb' OR SBQQ__Product__r.Product_License_Categories__c = 'Support')];
            
            
            system.debug('validSubList-->'+validSubList);
            
            // Amended and Revised Subscriptions
            for(SBQQ__Subscription__c s:validSubList){
                
                // Get all subscriptions in map
                subscriptionMap.put(s.Id,s);
                
                // Get Amended and Revised Subscriptions
                if(s.SBQQ__RevisedSubscription__c != null){
                    amendedandRevisedSubscriptionIdSet.add(s.Id);
                    amendedandRevisedSubscriptionIdSet.add(s.SBQQ__RevisedSubscription__c);
                    
                    // get revised subscription and corresponding amended subscriptions
                    if(revisedAndAmendedSubscriptionsMap.containsKey(s.SBQQ__RevisedSubscription__c)){
                        List<SBQQ__Subscription__c> sublist = revisedAndAmendedSubscriptionsMap.get(s.SBQQ__RevisedSubscription__c);
                        sublist.add(s);
                        revisedAndAmendedSubscriptionsMap.put(s.SBQQ__RevisedSubscription__c,sublist);
                    }else{
                        revisedAndAmendedSubscriptionsMap.put(s.SBQQ__RevisedSubscription__c,new List<SBQQ__Subscription__c>{s});
                    }
                }
            }
            system.debug('subscriptionMap-->'+subscriptionMap);
            system.debug('amendedandRevisedSubscriptionIdSet-->'+amendedandRevisedSubscriptionIdSet);
            system.debug('revisedAndAmendedSubscriptionsMap-->'+revisedAndAmendedSubscriptionsMap);
            
            // get revised subscription and total quantity of revised and amended subscriptions
            for(Id rId:revisedAndAmendedSubscriptionsMap.keySet()){
                Decimal amendedQuantity = 0;
                for(SBQQ__Subscription__c sId :revisedAndAmendedSubscriptionsMap.get(rId)){
                    amendedQuantity = sId.SBQQ__Quantity__c + amendedQuantity;
                    system.debug('amendedQuantity-->'+amendedQuantity);
                }
                amendedQuantity = amendedQuantity+subscriptionMap.get(rId).SBQQ__Quantity__c;
                
                revisedSubscriptionAndQuanityMap.put(rId,amendedQuantity);
            }
            system.debug('revisedSubscriptionAndQuanityMap-->'+revisedSubscriptionAndQuanityMap);
            
            /*Get Valid Subscription Ids
* For XVWeb,Support Subscriptions of Active Contract
* Get normal Subscriptions without Amendment
* If Amended/Revised Subscription, check the Quanity. If Quanity is > 0 then add revised sub Id
*/
            
            for(SBQQ__Subscription__c sb:validSubList){
                //Subscription not part of any amendment
                if(!amendedandRevisedSubscriptionIdSet.contains(sb.Id)){
                    validSubIdSet.add(sb.Id);
                }else{
                    //If amended sub,check quanity
                    if(sb.SBQQ__RevisedSubscription__c != null){
                        if(revisedSubscriptionAndQuanityMap.get(sb.SBQQ__RevisedSubscription__c) >0){
                            validSubIdSet.add(sb.SBQQ__RevisedSubscription__c);
                        }
                    }else{
                        //If revised sub,check quanity 
                        if(revisedSubscriptionAndQuanityMap.get(sb.Id) >0){
                            validSubIdSet.add(sb.Id);
                        }
                    }
                }
            }
            
            
            system.debug('validSubIdSet-->'+validSubIdSet);
            
            // For the Valid Subscriptions of Account and EndCustomer, get the Max End Date
            
            //Account as Subscription Account and End Customer as Subscription Account Comparison
            List<AggregateResult> accountSubscriptionList=[SELECT SBQQ__Account__r.Id ID,Max(SBQQ__Contract__r.EndDate) EndDate
                                                           FROM SBQQ__Subscription__c 
                                                           WHERE Id IN:validSubIdSet AND 
                                                           (SBQQ__Account__r.Id  IN: accountIdSet or SBQQ__Account__r.Id IN:endCustomerAccountIdSet)
                                                           Group By SBQQ__Account__r.Id ];
            
            system.debug('accountSubscriptionList-->'+ accountSubscriptionList);
            
            //Account as End Customer and End Customer as End Customer Comparison
            List<AggregateResult> endCustomerSubscriptionList=[SELECT End_Customer_Ship_To_Account__c ID,Max(SBQQ__Contract__r.EndDate) EndDate
                                                               FROM SBQQ__Subscription__c
                                                               WHERE Id IN:validSubIdSet AND 
                                                               (End_Customer_Ship_To_Account__c IN: endCustomerAccountIdSet or End_Customer_Ship_To_Account__c  IN: accountIdSet)
                                                               Group By End_Customer_Ship_To_Account__c];
            
            system.debug('endCustomerSubscriptionList-->'+ endCustomerSubscriptionList);
            
            //Get Max End date
            if(accountSubscriptionList.size()>0){
                for(AggregateResult ag : accountSubscriptionList){
                    AccountEndDateMap.put((Id)ag.get('ID'),(Date)ag.get('EndDate'));
                    accountWithSubSet.add((Id)ag.get('ID'));
                }
            }
            
            if(endCustomerSubscriptionList.size()>0){
                for(AggregateResult eag : endCustomerSubscriptionList){
                    if(!AccountEndDateMap.containskey((Id)eag.get('ID'))){
                        AccountEndDateMap.put((Id)eag.get('ID'),(Date)eag.get('EndDate'));
                        accountWithSubSet.add((Id)eag.get('ID'));
                    }
                    else if((Date)eag.get('EndDate') > AccountEndDateMap.get((Id)eag.get('ID'))){
                        AccountEndDateMap.put((Id)eag.get('ID'),(Date)eag.get('EndDate'));
                    }     
                }
            }       
            
            system.debug('AccountEndDateMap-->'+ AccountEndDateMap);
            
            // Update corresponding Account and End Customer with Max Support End Date 
            List<Account> AccountsToUpdate = [SELECT Id,Support_End_Date__c FROM Account WHERE id IN: accountWithSubSet];
            
            if(AccountsToUpdate.size()>0){
                for(Account accounttoupdate :AccountsToUpdate){
                    if(AccountEndDateMap.containskey(accounttoupdate.id)){
                        accounttoupdate.Support_End_Date__c=AccountEndDateMap.get(accounttoupdate.id);
                    }
                }
            }
            
            for(Id AccId: accountIdSet){
                if(!accountWithSubSet.contains(AccId)){
                    AccountHavingNoSubscriptions.add(AccId);
                }               
            }
            
            for(Id EndAccId: endCustomerAccountIdSet){
                if(!accountWithSubSet.contains(EndAccId)){
                    AccountHavingNoSubscriptions.add(EndAccId);
                }               
            }
            
            //If No subscriptions are there,update with empty support end date
            List<Account> AccountsHaveNoDirectContractEndDate = [SELECT Id,Support_End_Date__c FROM Account WHERE id IN: AccountHavingNoSubscriptions];
            for(Account AccountHaveNoDirectContractEndDate: AccountsHaveNoDirectContractEndDate){
                AccountHaveNoDirectContractEndDate.Support_End_Date__c=NULL;
                AccountsToUpdate.add(AccountHaveNoDirectContractEndDate);
            }
            
            if(!AccountsToUpdate.isEmpty()){
                Update AccountsToUpdate;
            }
            
        }catch(Exception e){
            system.debug('ERROR--->'+e);
        }
    }
}