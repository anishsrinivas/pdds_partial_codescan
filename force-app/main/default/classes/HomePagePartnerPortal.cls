/******************************************************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Name      		HomePagePartnerPortal
* @description 		This controller is used in Home Page of Partner Community.
********************************************************************************************************************************
Version    	Date        	   Team    	     Comments
********************************************************************************************************************************
* 1    		04 JAN 2021    	Jeromia    	Initial Development 
*********************************************************************************************************************************************/

public without sharing class HomePagePartnerPortal {

    @AuraEnabled
    public static boolean getOpportunityRecordsCount(){
        Integer oppRecordsCount = [Select Count() From Opportunity Where OwnerId =: userinfo.getUserId()];
        Boolean isRecordsNotFound;
        if(oppRecordsCount ==0){
           isRecordsNotFound = True; 
        }else{
            isRecordsNotFound = False;
        }
        
        return isRecordsNotFound;
    }
    
     @AuraEnabled
    public static boolean getLeadRecordsCount(){
        Integer leadRecordsCount = [Select Count() From Lead Where OwnerId =: userinfo.getUserId() and IsConverted = False];
        Boolean isRecordsNotFound;
        if(leadRecordsCount ==0){
           isRecordsNotFound = True; 
        }else{
            isRecordsNotFound = False;
        }
        
        return isRecordsNotFound;
    }
    
     @AuraEnabled
    public static boolean getQuoteRecordsCount(){
        Integer quoteRecordsCount = [Select Count() From SBQQ__Quote__c Where OwnerId =: userinfo.getUserId()];
        Boolean isRecordsNotFound;
        if(quoteRecordsCount ==0){
           isRecordsNotFound = True; 
        }else{
            isRecordsNotFound = False;
        }
        
        return isRecordsNotFound;
    }
}