/******************************************************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Name             Batch_NotificationOnAssetConversion
* @description      This Batch class will send notification to Reseller/EndCustomer for opportunities with all assets with status as shipped
********************************************************************************************************************************
Version     Date               Team          Comments
********************************************************************************************************************************
* 1         07 Nov 2020     Jeromia     Initial Development 
********************************************************************************************************************************/

global class Batch_NotificationOnAssetConversion implements Database.Batchable<sObject>,Database.Stateful {
    global Set<Id> opportunitiesFailedToSendNotification;
    
    // Get all Shipped Assets
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query ='SELECT End_Customer_Ship_To_Account__c,Id,Linked_Booking_Opportunity__c,Linked_Booking_Opportunity__r.Notify_Reseller_End_Customer__c,Linked_Booking_Opportunity__r.Owner.ContactId,Linked_Booking_Opportunity__r.SBQQ__PrimaryQuote__r.SBQQ__PrimaryContact__c,Product2Id,SerialNumber,Status FROM Asset WHERE Status = \'Shipped\' AND  Linked_Booking_Opportunity__c != null AND SerialNumber != null AND Linked_Booking_Opportunity__r.Notify_Reseller_End_Customer__c =False'+(Test.isRunningTest()?' LIMIT 200':'');
        return Database.getQueryLocator(query);
    }
    
    // Send Notification and Update it is notified on opportunity
    global void execute(Database.BatchableContext BC,List<Asset> assetList){
        if(!assetList.isEmpty()){
            opportunitiesFailedToSendNotification = NotificationOnAssetConversionHandler.getAssetsOfBookingOpportunity(assetList);  
        }
    }
    
    // Send failed opportunity record ids
    global void finish(Database.BatchableContext BC){
        Messaging.EmailFileAttachment[] emailAttList = new List<Messaging.EmailFileAttachment>();
        try{
            AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
                                JobItemsProcessed,
                                TotalJobItems, CreatedBy.Email
                                FROM AsyncApexJob
                                WHERE Id = :bc.getJobId()];
            if(opportunitiesFailedToSendNotification != null) {
                if(!opportunitiesFailedToSendNotification.isEmpty()) {
                    
                    String attName = 'Error Sending Asset Notifications' + system.now().format('YYYYMMDDhhmm') + '.csv';
                    String finalstr = 'OpportunityId,IsNotified\n';
                    
                    
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    for(Id oppId:opportunitiesFailedToSendNotification)
                    {
                        string recordString = '"'+oppId+'","'+'False'+'"\n';
                        finalstr = finalstr +recordString;
                    }
                    efa.setFileName(attName);
                    efa.setBody(Blob.valueOf(finalstr));
                    emailAttList.add(efa);
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setSubject( 'PDDS Reseller Batch Run Status' );
                    email.setToAddresses( new String[] {'planetddscpq@demandblue.com'} );
                    email.setHtmlBody( '<html> Attached Records are either failed to send Notification OR failed to update Notify Reseller / End Customer Checkbox in Linked Booking Opportunity' +
                                      '<br/> Please Verify !!</html>');
                    if(!emailAttList.isEmpty()){
                        email.setFileAttachments(emailAttList);}
                    
                    // Sends the email
                    Messaging.SendEmailResult [] r =Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                    
                    
                }
            }
        }catch(Exception e){
            system.debug('ERROR-->'+e);
        }
    }
}