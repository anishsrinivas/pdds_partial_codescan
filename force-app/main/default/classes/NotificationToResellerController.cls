/******************************************************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Name             NotificationToResellerController
* @description      This class returns assets of linked booking opportunity
********************************************************************************************************************************
Version     Date               Team          Comments
********************************************************************************************************************************
* 1         08 Nov 2020     Jeromia     Initial Development 
********************************************************************************************************************************/


global without sharing class NotificationToResellerController{
    
    global Id oppId {get;set;}
    global List<Asset> getAssetRecords(){
        
        List<Asset> relatedAssets = [Select Id,Subscription_Value__c,NetTotal__c,Price,Linked_Booking_Opportunity__c,Linked_Booking_Opportunity__r.SBQQ__PrimaryQuote__r.SBQQ__PrimaryContact__c,
                                     Product2.ProductCode,Linked_Booking_Opportunity__r.Amount,Linked_Booking_Opportunity__r.DDS_Proposal_Notes__c,Account.BillingAddress,Account.ShippingAddress,
                                     Product2.Name,SerialNumber,Quantity,Product2.Family From Asset Where Linked_Booking_Opportunity__c=:oppId
                                     WITH SECURITY_ENFORCED];
        
        return relatedAssets ;
    }
    
    global Decimal getPreTaxSubTotal(){
        
        List<Asset> relatedAssets = getAssetRecords();
        Decimal preTaxSubTotalValue = 0.0;
        for(Asset a:relatedAssets){
            preTaxSubTotalValue = preTaxSubTotalValue +a.NetTotal__c;
        }
        return preTaxSubTotalValue ;
    }
global Boolean getTextMessage(){
        
        List<Asset> relatedAssets = getAssetRecords();
        Boolean isPopulateTextMessage = False;
        for(Asset a:relatedAssets){
            if(a.Product2.Family == 'Image Conversions'){
                isPopulateTextMessage = True;
            }
        }
        return isPopulateTextMessage ;
    }

}