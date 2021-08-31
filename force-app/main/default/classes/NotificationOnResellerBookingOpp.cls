public class NotificationOnResellerBookingOpp {

@InvocableMethod

public static void sendEmailNotification(List<Id> OpportunityIds){

    //Variable Declaration

    List<Messaging.SingleEmailMessage> listofEmails = new List<Messaging.SingleEmailMessage>();
    
    Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();  
              
    List<String> sendingto = new List<String>();
    

        try{
                List<Opportunity> opportunitiesList = [Select   Id,
                                                                SBQQ__PrimaryQuote__c,
                                                                SBQQ__PrimaryQuote__r.SBQQ__PrimaryContact__c
                                                       FROM Opportunity 
                                                       WHERE Id=:OpportunityIds];
                  
                Reseller_Portal_Values__c resellerPortalValues = [SELECT Name,Reseller_Portal_Name__c,Reseller_Portal_Org_wide_Address__c,SF_Admin__c 
                                                              FROM Reseller_Portal_Values__c 
                                                              Where Name = 'Reseller Portal Defaults' 
                                                              Limit 1];
                                                              
                OrgWideEmailAddress[] owea = [select Id,Address,DisplayName from OrgWideEmailAddress 
                                          where Address =:resellerPortalValues.SF_Admin__c ];
                                          
                                          System.debug('Address:'+owea.get(0).Address);
            
                EmailTemplate template = [SELECT Id FROM EmailTemplate 
                                WHERE DeveloperName = 'Notification_For_Booking_Opp_Template' 
                                Limit 1];            

                //Add Recipients
                
                 sendingto.add(''+owea.get(0).Address+'');
                
                //Email Message           
                    
                for(Opportunity opp:opportunitiesList){
                
                emailMessage.setTemplateId(template.Id);
                
                System.debug('Contact:'+opp.SBQQ__PrimaryQuote__r.SBQQ__PrimaryContact__c);
                
                emailMessage.setTargetObjectId(opp.SBQQ__PrimaryQuote__r.SBQQ__PrimaryContact__c);
                emailMessage.setToAddresses(sendingto);
                emailMessage.setSaveAsActivity(true);
                emailMessage.setOrgWideEmailAddressId(owea.get(0).Id);
                emailMessage.setWhatId(opp .Id);
                emailMessage.setTreatTargetObjectAsRecipient(false);
                if(!sendingto.isEmpty()){
                    listofEmails.add(emailMessage);}
                    
                    }
                    
                //Send Notification
                
                Messaging.SendEmailResult[] results =  Messaging.sendEmail(listofEmails,false);
 
                 if (results[0].success) 
                 {        
                   System.debug('The email was sent successfully.');
                 } 
                 else 
                 {
                   System.debug('The email failed to send:' +  results[0].errors[0].message);
                  }
           
        }
        Catch(Exception e){   system.debug('ERROR-->'+e); }
      
    }  }