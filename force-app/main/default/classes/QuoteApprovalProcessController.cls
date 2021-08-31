/******************************************************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Name      		QuoteApprovalProcessController
* @description 		This class is being called from lightning component "QuoteApprovalProcess" controller to check 
                    if Proposal Notes and Quote lines Exist on Quote and then if Proposal Notes and Quote lines exist 
                    then to call appropriate Approval Process
                    
                   
********************************************************************************************************************************
Version    	Date        	   Team    	     Comments
********************************************************************************************************************************
* 1    		19 Mar 2021    	Ramana    	Initial Development 
*********************************************************************************************************************************************/

Public class QuoteApprovalProcessController {
    @AuraEnabled
    Public Static String validateQuote(String recordId){
        String result ='';
            SBQQ__Quote__c Quote=[select id,DDS_Proposal_Notes__c,(select id from SBQQ__LineItems__r) from SBQQ__Quote__c
                                 where Id=:recordId];
        
        if(quote.SBQQ__LineItems__r.Size()==0){
            result='No Quotelines';
        } else if(quote.DDS_Proposal_Notes__c==Null || quote.DDS_Proposal_Notes__c==''){
            result='No ProposalNotes';
        } 

        return result;
        }
    @AuraEnabled
    Public Static String submitForApproval(String recordId,String comments){
        String result ='';
        String ApprovalProcessName='';
        try{
            SBQQ__Quote__c Quote=[select id,DDS_Proposal_Notes__c,DDS_Is_Auto_Approval__c,
                                  DDS_DenticonSilverRequireApproval__c,DDS_DenticonGoldGramRequireApproval__c,
                                 DDS_DenticonGoldRayRequireDiscount__c,DDS_DenticonPlatinumRequireDiscount__c,
                                 DDS_DenticonStandaloneRequireDiscount__c,DDS_Denticon_Solo_Requires_Approval__c,
                                  DDS_Denticon_Enterprise_Require_Approval__c,DDS_Denticon_Implementa_Require_Approval__c,
                                  SBQQ__Status__c from SBQQ__Quote__c
                                 where Id=:recordId];
            String profileName =[SELECT Id, profile.Name FROM User WHERE Id =:UserInfo.getUserId()].profile.Name;
            
            if(quote.SBQQ__Status__c=='Approved' ){
                
                 return 'Already Approved';
            }
               
            if(Quote.DDS_Is_Auto_Approval__c==true && Quote.SBQQ__Status__c!='Approved'){
                
                ApprovalProcessName='Quote_Auto_Approval_Process';
                
            }else if(Quote.SBQQ__Status__c!='Approved' && profileName!='Reseller Partner Community' &&
                     (Quote.DDS_DenticonSilverRequireApproval__c>0 
                     || Quote.DDS_DenticonGoldGramRequireApproval__c>0
                     || Quote.DDS_DenticonGoldRayRequireDiscount__c>0
                     || Quote.DDS_DenticonStandaloneRequireDiscount__c>0
                     || Quote.DDS_DenticonPlatinumRequireDiscount__c>0
                     || Quote.DDS_Denticon_Solo_Requires_Approval__c>0
                     || Quote.DDS_Denticon_Enterprise_Require_Approval__c>0
                     ||Quote.DDS_Denticon_Implementa_Require_Approval__c>0)){
                     
                ApprovalProcessName='Approval_Process_For_Quote_Discount_V4';
                
            }
            Approval.ProcessSubmitRequest  req =new Approval.ProcessSubmitRequest();
            req.setObjectId(recordId);
            req.setProcessDefinitionNameOrId(ApprovalProcessName);
            req.setComments(comments);
            Approval.ProcessResult approvalResult =Approval.process(req);
            
            if(approvalResult.isSuccess())
                result = 'SUCCESS';
            else
                result = 'Failure';
            
        }catch (exception e){
            system.debug('exception-->'+e);
            result = 'Something Went Wrong';
            
        }
        
        return result;
    }
    
}