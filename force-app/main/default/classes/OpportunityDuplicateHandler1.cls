// ---> Helper class For cloning any opportunity check Opportunity Name is unique and stage is other than Closed won and Closed Lost,Opportunity Clone to Record Type is Mandatory While Cloning,
//     Opportunity Should not be Contracted While Cloning, and Defaulting fields while clonning

//---->Author: Srikanth 

//---->Date : 30/03/2020


Public Class OpportunityDuplicateHandler1 {
    
    static final String cw = 'Closed Won';
    static final String cl = 'Closed Lost';
    static final String ct = 'Closed Won - Under Trial';
    static final String uniqueMessage = 'Opportunity name should be Unique';
    static final String stageMessage ='Stage should not be Closed-Won or Closed- Lost or Closed Won - Under Trial while Cloning';
    static final String recordTypeMessage ='For cloning please select record type';
    static final String contractedCheckMessage ='Opportunity Cannot be Contracted While Cloning';
    static final String changeTypeMessage ='For cloning please select Change type';
    
    //---> For checking Unique opportunity name and stage
    
    Public Static void opportunityDuplicateCheck(List<Opportunity> opps){
        
        Set<String> setName = new Set<String>();
        Set<Id> oppIds = new Set<Id>();
        Map<Id,Id> opRecTypeIdMap = new Map<Id,Id>();
        Map<Id,Opportunity> opResellerMap = new Map<Id,Opportunity>();
        Profile Prof = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String CurrentProflieName = Prof.Name;   
        
        For(Opportunity opp: opps){
            setName.add(opp.name);
            if(opp.Opportunity_Id__c!= null){
                oppIds.add(opp.Opportunity_Id__c);
            }
        }
        
        List<Opportunity> bookingOpps = [Select id,recordtypeId,Reseller_Opp__c,End_Customer_Ship_To_Account__r.Name,PO_Number__c
                                         from Opportunity where id in:oppIds]; 
        for(Opportunity opp: bookingOpps){
            opRecTypeIdMap.put(opp.Id,opp.RecordTypeId);
            opResellerMap.put(opp.Id,opp);
           
        }
        
        if(setName.size() > 0 ){
            List<Opportunity> lstAccount = [select name ,id from Opportunity where name in :setName];    
            Map<String ,Opportunity> mapNameWiseAccount = new Map<String,Opportunity>();
            
            For(Opportunity opp: lstAccount){
                mapNameWiseAccount.put(opp.name ,opp);
            }
            
            For(Opportunity opp:opps)
                //---> Check whether opportunity is cloning     
                if(opp.isclone()){
                    // ---> Check cloning opportunity name is unique
                    if(mapNameWiseAccount.containsKey(opp.name)){
                        opp.Name.addError(uniqueMessage);
                    }
                    
                    //---> Check opportunity stage is other than Closed Won/Lost
                    if((cw.equals(opp.StageName))||(cl.equals(opp.StageName)) || (ct.equals(opp.StageName))){
                        opp.StageName.addError(stageMessage);
                    } 
                    //---> Check opportunity Clone to Record Type is Selected when clonning From Booking to Billing       
                    Map<ID,Schema.RecordTypeInfo> recordtypeMap= opportunity.sObjectType.getDescribe().getRecordTypeInfosById();     
                    
                    if(recordtypeMap.get(opp.recordTypeID).getName().containsIgnoreCase('Booking') && 
                       CurrentProflieName!='Reseller Partner Community'){
                           if( opp.New_Record_Type__c == null  ){
                               opp.New_Record_Type__c.addError(recordTypeMessage);
                           }
                       }else if(recordtypeMap.get(opp.recordTypeID).getName().containsIgnoreCase('Booking') && 
                                CurrentProflieName == 'Reseller Partner Community'){
                                    // Empty PO number if Reseller Clone Booking Opp and if PO Number is not changed
                                    if(opResellerMap.get(opp.Opportunity_Id__c).PO_Number__c == opp.PO_Number__c){
                                    opp.PO_Number__c = '';
                                    }
                                }
                    
                    Map<ID,Schema.RecordTypeInfo> recordtypeMap1= opportunity.sObjectType.getDescribe().getRecordTypeInfosById();     
                    
                    if(recordtypeMap1.get(opp.recordTypeID).getName().containsIgnoreCase('Billing')){
                        if( opp.ia_crm__Change_Type__c == null ){
                            opp.ia_crm__Change_Type__c .addError(changeTypeMessage);
                        }
                    }
                    
                    //---> Check opportunity Contracted Should be Unchecked While Clonning         
                    if(opp.SBQQ__Contracted__c){
                        opp.SBQQ__Contracted__c.addError(contractedCheckMessage);
                    }
                    
                    //-->  Check if Clone from Booking to Billing and Populate Linked Booking Opportunity and Reseller flag from Booking Opportunity
                    
                    if(opp.Opportunity_Id__c!= null && opRecTypeIdMap.containsKey(opp.Opportunity_Id__c)){
                        
                        if(opp.New_Record_Type__c=='Billing' && 
                           recordtypeMap.get(opRecTypeIdMap.get(opp.Opportunity_Id__c)).getName().containsIgnoreCase('Booking') ){
                               
                               opp.Linked_Booking_Opportunity__c=opp.Opportunity_Id__c;
                               opp.Reseller_Opp__c=opResellerMap.get(opp.Opportunity_Id__c).Reseller_Opp__c;
                               // Populate Practice Location If Cloning from Booking to Billing
                               if(opp.DDS_Practice_Location__c == null && opp.PO_Number__c != null && opResellerMap.get(opp.Opportunity_Id__c).End_Customer_Ship_To_Account__c != null){            
                                   opp.DDS_Practice_Location__c = opResellerMap.get(opp.Opportunity_Id__c).End_Customer_Ship_To_Account__r.Name +'  '+opp.PO_Number__c;
                               }   
                               
                           }else if((opp.New_Record_Type__c=='Booking' && 
                                     recordtypeMap.get(opRecTypeIdMap.get(opp.Opportunity_Id__c)).getName().containsIgnoreCase('Booking')) &&
                                    (opp.Reseller_Opp__c == True)){
                                        // Empty PO number if Cloning from Booking to Booking and if PO Number is not changed
                                        if(opResellerMap.get(opp.Opportunity_Id__c).PO_Number__c == opp.PO_Number__c){
                                            opp.PO_Number__c = '';
                                        }
                                    }
                    }
                    //--> Defaulting fields while clonning as Per PLAN-712
                    opp.Sales_Qualified_Appointment__c=false;
                    opp.Closed_Flag__c=false;
                    opp.Notify_Reseller_End_Customer__c=false;
                    opp.Includes_Asset_Product__c=false;
                    opp.Source_Apteryx_Id__c=NULL;
                    opp.Legacy_Opp_Number__c=NULL;  
                }
        }
    }
}