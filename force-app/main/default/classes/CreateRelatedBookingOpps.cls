Public Class CreateRelatedBookingOpps implements Queueable{

    Public Map<Id,opportunity> oldOppMap;
    Public Map<Id,opportunity> newOppMap;

    public CreateRelatedBookingOpps(Map<Id,opportunity> mapOldOpps, Map<Id,opportunity> mapNewOpps) { 
        this.oldOppMap = mapOldOpps;
        this.newOppMap = mapnewOpps;
    }

   Public Void execute(System.QueueableContext qc){

       
              List<Booking_Opportunity__c> insBookOpps = new List<Booking_Opportunity__c>();
              List<Booking_Opportunity__c> insBookingOpps = new List<Booking_Opportunity__c>();
              

              Set<Id> oldLinkedOppIds = new Set<Id>();
              Set<Id> newLinkedOppIds = new Set<Id>();
              Set<Id> contractIds = new Set<Id>();
              
              Set<Id> contChangeLinkedOppIds = new Set<Id>();
              Set<Id> contChangeContractIds = new Set<Id>();
              
              Map<Id,String> existingBookOppNameMap = new Map<Id,String>();
              Map<Id,String> existingBookOppNameContChangeMap = new Map<Id,String>();
                                        
              Id billingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();  
                   
              
       
              for(Opportunity opp: newOppMap.Values()){	 	
              
                  if((oldOppMap.get(opp.Id).Linked_Booking_Opportunity__c != null && 
                     newOppMap.get(opp.Id).Linked_Booking_Opportunity__c == null && opp.RecordTypeId == billingRecordTypeId ) || 
                     (oldOppMap.get(opp.Id).Linked_Booking_Opportunity__c != null &&
                      newOppMap.get(opp.Id).Linked_Booking_Opportunity__c!= null &&
                      oldOppMap.get(opp.Id).Linked_Booking_Opportunity__c!= 
                      newOppMap.get(opp.Id).Linked_Booking_Opportunity__c && opp.RecordTypeId == billingRecordTypeId) ||
                      (oldOppMap.get(opp.Id).Linked_Booking_Opportunity__c == null &&
                      newOppMap.get(opp.Id).Linked_Booking_Opportunity__c!= null &&
                      opp.RecordTypeId == billingRecordTypeId))
                      
                      {
              
                      
                         oldLinkedOppIds.add(oldOppMap.get(opp.Id).Linked_Booking_Opportunity__c);
                         newLinkedOppIds.add(opp.Linked_Booking_Opportunity__c);                   
                         contractIds.add(opp.ContractId);
                      
                      }
                                        
                  if(oldOppMap.get(opp.Id).ContractId == null && newOppMap.get(opp.Id).ContractId!= null &&
                     newOppMap.get(opp.Id).Linked_Booking_Opportunity__c!= null && opp.RecordTypeId == billingRecordTypeId){
                       
                       contChangeLinkedOppIds.add(opp.Linked_Booking_Opportunity__c);
                       contChangeContractIds.add(opp.ContractId);  
                    
                  
                  
                  }
                  
                        
              
              
              }
              
              
              List<Booking_Opportunity__c> deleteExistingBookingOpps = [Select id,name,Contract_Number__c,Opportunity_Name__c from
                                                                  Booking_Opportunity__c where Contract_Number__c in:contractIds and
                                                                  Opportunity_Name__c in:oldLinkedOppIds];
                                                                  
              List<Opportunity> otherBillingOpportunities = [Select id,name,Linked_Booking_Opportunity__c,ContractId from opportunity
                                                             where Linked_Booking_Opportunity__c in:oldLinkedOppIds and 
                                                             ContractId in:contractIds and
                                                             id not in:newOppMap.KeySet()];
                                                             
              List<Booking_Opportunity__c> delBookingOpps = new List<Booking_Opportunity__c>();
              Set<String> linkedBookingContractCheck = new Set<String>();
              
              for(Opportunity otherBillingOpportunity:otherBillingOpportunities){
              
                  linkedBookingContractCheck.add(otherBillingOpportunity.Linked_Booking_Opportunity__c + ',' +
                                                 otherBillingOpportunity.ContractId);
              
              }
              
              for(Booking_Opportunity__c deleteExistingBookingOpp: deleteExistingBookingOpps){
              
                  if(!linkedBookingContractCheck.contains(deleteExistingBookingOpp.Opportunity_Name__c + ',' +
                                                          deleteExistingBookingOpp.Contract_Number__c)){
                  
                       delBookingOpps.add(deleteExistingBookingOpp);
                  
                  }
              
              
              
              }
                                                                                                                    
              List<Booking_Opportunity__c> existingBookingOpps  = [Select id,name,Contract_Number__c,Opportunity_Name__c from
                                                                  Booking_Opportunity__c where Contract_Number__c in:contractIds and
                                                                  Opportunity_Name__c in:newLinkedOppIds];
          
             Set<String> checkExistingOpps = new Set<String>();
             for(Booking_Opportunity__c  existingBookingOpp:existingBookingOpps){
             
                         
                         String checkExistingOpp = existingBookingOpp.Contract_Number__c + ',' + existingBookingOpp.Opportunity_Name__c;
                         checkExistingOpps.add(checkExistingOpp);                
             
             
             }   
             
             List<opportunity> existingOpps = [Select id,name from opportunity where id in:newLinkedOppIds];
             
             for(Opportunity existingOpp: existingOpps){
              
                  existingBookOppNameMap.put(existingOpp.Id,existingOpp.Name);
              
              }
                           
             
             
           List<Booking_Opportunity__c> existingBookingOppsContChange = [Select id,name,Contract_Number__c,Opportunity_Name__c from
                                                                  Booking_Opportunity__c where Contract_Number__c in:contChangeContractIds and
                                                                  Opportunity_Name__c in:contChangeLinkedOppIds];
                                                                  
             Set<String> checkExistingOppsContChange = new Set<String>();
             for(Booking_Opportunity__c  existingBookingOppContChange:existingBookingOppsContChange){
             
                         
                         String checkExistingOppContChange = existingBookingOppContChange.Contract_Number__c + ',' + existingBookingOppContChange.Opportunity_Name__c;
                         checkExistingOppsContChange.add(checkExistingOppContChange);                
             
             
             }     
             
             List<opportunity> existingConChangeOpps = [Select id,name from opportunity where id in:contChangeLinkedOppIds];
             
             for(Opportunity existingConChangeOpp: existingConChangeOpps){
              
                  existingBookOppNameContChangeMap.put(existingConChangeOpp.Id,existingConChangeOpp.Name);
              
              }                                                                                                                                                                           
  
              for(Opportunity opp: newOppMap.Values()){
              				
              
                             if((oldOppMap.get(opp.Id).Linked_Booking_Opportunity__c != null &&
                                newOppMap.get(opp.Id).Linked_Booking_Opportunity__c!= null &&
                                oldOppMap.get(opp.Id).Linked_Booking_Opportunity__c!= 
                                newOppMap.get(opp.Id).Linked_Booking_Opportunity__c && opp.RecordTypeId == billingRecordTypeId) ||
                                (oldOppMap.get(opp.Id).Linked_Booking_Opportunity__c == null &&
                                 newOppMap.get(opp.Id).Linked_Booking_Opportunity__c!= null &&
                                 opp.RecordTypeId == billingRecordTypeId)){
                                
                                string bookingOppName= existingBookOppNameMap.get(newOppMap.get(opp.Id).Linked_Booking_Opportunity__c);
                                     
                                Booking_Opportunity__c insBookOpp = new Booking_Opportunity__c();
                                insBookOpp.Contract_Number__c = newOppMap.get(opp.Id).ContractId;
                                insBookOpp.Opportunity_Name__c = newOppMap.get(opp.Id).Linked_Booking_Opportunity__c;
                                insBookOpp.Name =bookingOppName.length()>80?bookingOppName.substring(0, 80):bookingOppName;
                                
                                String checkExistingOpp = insBookOpp.Contract_Number__c + ',' + insBookOpp.Opportunity_Name__c;

                                if(!checkExistingOpps.contains(checkExistingOpp)){
                                
                                      insBookOpps.add(insBookOpp); 
                                
                                }                         
                            
                            }
                            
                             if(oldOppMap.get(opp.Id).ContractId == null && newOppMap.get(opp.Id).ContractId!= null &&
                                newOppMap.get(opp.Id).Linked_Booking_Opportunity__c!= null && opp.RecordTypeId == billingRecordTypeId){
                     			   
                                   string bookOppContName=existingBookOppNameContChangeMap.get(newOppMap.get(opp.Id).Linked_Booking_Opportunity__c);
                                       
                                   Booking_Opportunity__c insBookingOpp = new Booking_Opportunity__c();
                                   insBookingOpp.Contract_Number__c = newOppMap.get(opp.Id).ContractId;
                                   insBookingOpp.Opportunity_Name__c = newOppMap.get(opp.Id).Linked_Booking_Opportunity__c;
                                   insBookingOpp.Name = bookOppContName.length()>80?bookOppContName.substring(0, 80):bookOppContName;
                                   
                                   String checkExistingOppContChange = insBookingOpp.Contract_Number__c + ',' + insBookingOpp.Opportunity_Name__c;

                                    if(!checkExistingOppsContChange.contains(checkExistingOppContChange)){
                                      
                                      insBookingOpps.add(insBookingOpp);
                                      
                                    }
                                   
                                   
                            }
                                   
                          
              
              }
              
              if(delBookingOpps.size() > 0){
              
                    delete delBookingOpps;
              
              
              }
              
              if(insBookOpps.size()> 0){
              
                  insert insBookOpps;
              
              
              }
              
              
              if(insBookingOpps.size() > 0){
              
              
                  insert insBookingOpps;
              
              
              }

   }

}