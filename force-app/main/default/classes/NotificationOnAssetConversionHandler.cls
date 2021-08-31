/******************************************************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Name             NotificationOnAssetConversionHandler
* @description      This is handler class for Batch_NotificationOnAssetConversion class
********************************************************************************************************************************
Version     Date               Team          Comments
********************************************************************************************************************************
* 1         07 Nov 2020     Jeromia     Initial Development 
********************************************************************************************************************************/


public without sharing class NotificationOnAssetConversionHandler {
    
    // Get Asset Records and Process
    public static Set<Id> getAssetsOfBookingOpportunity(List<Asset> getAssetRecordsList){
        Set<Id> oppIdswithNotificationsNotSent = new  Set<Id>();
        Map<Id,List<Asset>> opportunityAndShippedAssetsMap = new Map<Id,List<Asset>>();
        Map<Id,List<Asset>> allOpportunitiesAndAssetsMap = new Map<Id,List<Asset>>();
        Set<Id> opportunitiesId = new Set<Id>(); 
        Set<Id> updateOpportunityAndSendNotification = new Set<Id>();   
        
        try{
            
            for(Asset asset:getAssetRecordsList){
                opportunitiesId.add(asset.Linked_Booking_Opportunity__c);
            }
            
            //PLAN 934 - Get Valid Opportunities
            Set<Id> bookingOppsWithNoEmailsSentRelatedToAsset = checkEmailMessages(opportunitiesId);
            
            // Map Opportunity and Related Assets marked as Shipped
            if(!bookingOppsWithNoEmailsSentRelatedToAsset.isEmpty()){
                List<Asset> allOpportunitiesAndAssetsList = [Select Id,Linked_Booking_Opportunity__c,Status 
                                                             From Asset 
                                                             Where Linked_Booking_Opportunity__c=:bookingOppsWithNoEmailsSentRelatedToAsset
                                                             WITH SECURITY_ENFORCED];
                allOpportunitiesAndAssetsMap = opportunityAndAssetMap(allOpportunitiesAndAssetsList);
                
                // Map Opportunity and All Related Assets with all status
                opportunityAndShippedAssetsMap = opportunityAndAssetMap(getAssetRecordsList);
                
                // Check if number of shipped assets and number of assets in an opportunity are same.If same send notification.
                for(Id oppIdShiped: opportunityAndShippedAssetsMap.KeySet()){
                    if(allOpportunitiesAndAssetsMap.containsKey(oppIdShiped)){
                        if(allOpportunitiesAndAssetsMap.get(oppIdShiped).size() == opportunityAndShippedAssetsMap.get(oppIdShiped).size()){
                            updateOpportunityAndSendNotification.add(oppIdShiped);
                        }
                    }
                }
                
            }
            //Send notification to Contact
            if(!updateOpportunityAndSendNotification.isEmpty()){
                oppIdswithNotificationsNotSent =  sendNotification(updateOpportunityAndSendNotification);
                
            }
            
            return oppIdswithNotificationsNotSent; 
        }catch(Exception e){
            system.debug('ERROR-->'+e);
            return oppIdswithNotificationsNotSent; 
        }
    }
    
    // Map Opportunity and Assets
    Public static Map<Id,List<Asset>> opportunityAndAssetMap(List<Asset> assetRecordsList){
        
        Map<Id,List<Asset>> opportunityAssetsMap = new Map<Id,List<Asset>>();
        try{
            
            for(Asset asset : assetRecordsList){
                if(opportunityAssetsMap.containskey(asset.Linked_Booking_Opportunity__c)){
                    List<Asset> assetRecord = opportunityAssetsMap.get(asset.Linked_Booking_Opportunity__c);
                    assetRecord.add(asset);
                    opportunityAssetsMap.put(asset.Linked_Booking_Opportunity__c,assetRecord);
                }else{
                    opportunityAssetsMap.put(asset.Linked_Booking_Opportunity__c,new List<Asset>{asset});
                }
            }  
            return opportunityAssetsMap;
        }catch(Exception e){
            system.debug('ERROR-->'+e);
            return opportunityAssetsMap;
        }
    }
    
    /* Send Notification to Opportunity Owner Contact if Owner is a Portal User.
* Send Notification to Opportunity Primary Quote's Contact if owner is a SF User.
* Choose Template accordingly
*/
    Public static Set<Id> sendNotification(Set<Id> opportunitiesToSendNotification){
        List<Messaging.SingleEmailMessage> listofEmails = new List<Messaging.SingleEmailMessage>();
        Set<Id> oppIdswithNotificationsNotSent = new Set<Id>();
        
        try{
            
            List<Opportunity> opportunitiesList = [Select Id,Owner.ContactId,Owner.Contact.Email,
                                                   SBQQ__PrimaryQuote__r.SBQQ__PrimaryContact__r.Email,SBQQ__PrimaryQuote__r.SBQQ__PrimaryContact__c,
                                                   Notify_Reseller_End_Customer__c FROM Opportunity 
                                                   WHERE Id=:opportunitiesToSendNotification
                                                   WITH SECURITY_ENFORCED];
            
            Reseller_Portal_Values__c resellerPortalValues = [SELECT Name,Reseller_Portal_Name__c,Reseller_Portal_Org_wide_Address__c 
                                                              FROM Reseller_Portal_Values__c 
                                                              Where Name = 'Reseller Portal Defaults' 
                                                              WITH SECURITY_ENFORCED
                                                              Limit 1];
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress 
                                          where Address =:resellerPortalValues.Reseller_Portal_Org_wide_Address__c
                                          WITH SECURITY_ENFORCED];
            
            EmailTemplate eM = [SELECT Id FROM EmailTemplate 
                                WHERE DeveloperName = 'Notification_to_Reseller' 
                                WITH SECURITY_ENFORCED
                                Limit 1];
            EmailTemplate eM1 = [SELECT Id FROM EmailTemplate
                                 WHERE DeveloperName = 'Notification_to_End_Customer' 
                                 WITH SECURITY_ENFORCED
                                 Limit 1];
            
            for(Opportunity opp:opportunitiesList){
                
                Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                List<String> sendingto = new List<String>();
                if(opp.Owner.ContactId==null){
                    sendingto.add(opp.SBQQ__PrimaryQuote__r.SBQQ__PrimaryContact__r.Email);
                    semail.setTemplateId(eM1.Id);
                    semail.setTargetObjectId(opp.SBQQ__PrimaryQuote__r.SBQQ__PrimaryContact__c);
                }else{
                    sendingto.add(opp.Owner.Contact.Email);
                    semail.setTemplateId(eM.Id);
                    semail.setTargetObjectId(opp.Owner.ContactId);
                }
                
                semail.setToAddresses(sendingto);
                semail.setSaveAsActivity(true);
                semail.setOrgWideEmailAddressId(owea.get(0).Id);
                semail.setWhatId(opp.Id);
                semail.setTreatTargetObjectAsRecipient(false);
                if(!sendingto.isEmpty()){
                    listofEmails.add(semail);
                }
            }
            
            //Send notification
            if(!ListofEmails.isEmpty()){
                system.debug('ListofEmails-->'+ListofEmails);
                oppIdswithNotificationsNotSent = sendEmailAndUpdateNotified(ListofEmails);
                
            }
            
            
            // send failed record ids
            return oppIdswithNotificationsNotSent;
        }Catch(Exception e){
            system.debug('ERROR-->'+e);
            return oppIdswithNotificationsNotSent;
        }
    }
    
    Public static Set<Id> sendEmailAndUpdateNotified( List<Messaging.SingleEmailMessage> listofEmails){
        
        Set<Id> oppIdswithNotificationsSent = new Set<Id>();
        Set<Id> oppIdswithNotificationsNotSent = new Set<Id>();
        try{
            
            Messaging.SendEmailResult[] result =  Messaging.sendEmail(ListofEmails,false);
            for( Integer i=0;i<result.size();i++){
                if (result.get(i).isSuccess()){
                    oppIdswithNotificationsSent.add(ListofEmails.get(i).getWhatId());
                }else if (!result.get(i).isSuccess()){
                    oppIdswithNotificationsNotSent.add(ListofEmails.get(i).getWhatId());
                }
            }  
            
            //Update checkbox for success records
            If(!oppIdswithNotificationsSent.isEmpty()){
                List<Opportunity> checkNotifyResellerEndCustomer = [Select Id,Notify_Reseller_End_Customer__c From Opportunity 
                                                                    Where Id=:oppIdswithNotificationsSent
                                                                    WITH SECURITY_ENFORCED];
                
                for(Opportunity opp:checkNotifyResellerEndCustomer){
                    opp.Notify_Reseller_End_Customer__c = True;
                }
                if(!checkNotifyResellerEndCustomer.isEmpty() && Schema.sObjectType.Opportunity.fields.Notify_Reseller_End_Customer__c.isUpdateable()){
                    Database.SaveResult[] updateCheckBoxResult = Database.update(checkNotifyResellerEndCustomer,false) ;
                    for( integer i=0; i<updateCheckBoxResult.size();i++){
                        if(!updateCheckBoxResult.get(i).isSuccess()){
                            oppIdswithNotificationsNotSent.add(checkNotifyResellerEndCustomer.get(i).Id);
                        }
                    }
                }
            }
            // send failed record ids
            return oppIdswithNotificationsNotSent;
        }Catch(Exception e){
            system.debug('ERROR-->'+e);
            return oppIdswithNotificationsNotSent;
        }
    }
    
    
    /*PLAN 934 - See the EmailMessages related to Linked Booking Opps.Skip the Opp if it contains Subject as
*1.Your Order Q- (OR)
*2.Assets have been added to the End Customer Account Account 
*/
    public static Set<Id> checkEmailMessages(Set<Id> bookingOppIds){
        
        Set<Id> bookingOppsWithNoEmailsSentRelatedToAsset = new Set<Id>();
        Map<Id,Boolean> oppIdAndBooelanToSendEmailMap = new Map<Id,Boolean>();
        
        try{
            //Get email messages
            List<Opportunity> OppandEmailMessagesList =[Select Id,Name,(Select Id,RelatedToId,Subject From Emails) from Opportunity Where Id =:bookingOppIds];
            //Map OppId and Boolean to add Opp valid to send email or not (True-->Valid, False-->Not Valid)
            for(Opportunity opp:OppandEmailMessagesList){
                system.debug('SIZE-->'+opp.Emails.size());
                system.debug('OPPANEM-->'+opp.Name);
                if(opp.Emails.size() > 0){
                    for(EmailMessage em: opp.Emails){
                        if(em.Subject != null && (!em.Subject.contains('Your Order Q-')) && (!em.Subject.contains('Assets have been added to the '))){
                            system.debug('OPPID-->'+em.RelatedToId + em.Subject);
                            oppIdAndBooelanToSendEmailMap.put(opp.Id,True);
                        }else{
                            system.debug('@@@@OPPID-->'+em.RelatedToId + em.Subject);
                            oppIdAndBooelanToSendEmailMap.put(opp.Id,False);
                            break;
                        }
                    } 
                }else{
                    oppIdAndBooelanToSendEmailMap.put(opp.Id,True);
                }
                
            }
            
            
            //Get Valid Opps and Opps with No Emails sent so far
            for(Id oppId:bookingOppIds){
                if((oppIdAndBooelanToSendEmailMap.containsKey(oppId) && oppIdAndBooelanToSendEmailMap.get(oppId) == True) ||
                   (!oppIdAndBooelanToSendEmailMap.containsKey(oppId))){
                       bookingOppsWithNoEmailsSentRelatedToAsset.add(oppId); 
                   }
            }
        }catch(Exception e){
            system.debug('Error-->'+e.getLineNumber() +'  '+e.getMessage());
        }    
        return bookingOppsWithNoEmailsSentRelatedToAsset;
    }
}