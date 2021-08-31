/******************************************************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Name             EditAllAssetsController
* @description      This is Apex controller for EditAllAssets_Account Component
********************************************************************************************************************************
Version     Date               Team          Comments
********************************************************************************************************************************
* 1         02 Feb 2021     Jeromia     Initial Development 
*********************************************************************************************************************************************/


public without sharing class EditAllAssetsController {
    
    public EditAllAssetsController(ApexPages.StandardSetController  stdController){
        
    }
    
    
    @AuraEnabled
    public static List<Asset> getAssets(Id recordId){
        // Get Asset Records
        List<Asset> assetsRecords =  new List<Asset>();
        try{
            if((String.valueOf(recordId)).startsWith('001')){
                assetsRecords = [SELECT AccountId,Account.Name,SBQQ__QuoteLine__c,ContactId,Contact.Name,End_Customer_Ship_To_Account__c,End_Customer_Ship_To_Account__r.Name,Id,
                                 InstallDate,License_Count__c,License_Type__c,Linked_Booking_Opportunity__c,Linked_Booking_Opportunity__r.Name,
                                 Name,Price,Product2Id,Product2.Name,PurchaseDate,Quantity,Description,
                                 SerialNumber,Status,Subscription_Value__c 
                                 FROM Asset 
                                 WHERE Status != 'Shipped' AND  Status != '' AND AccountId=:recordId];
            }else if((String.valueOf(recordId)).startsWith('006')){
                Opportunity getLinkedBookingOppId = [Select Id,Linked_Booking_Opportunity__c,StageName FROM Opportunity Where Id=:recordId];
                
                if(getLinkedBookingOppId.StageName == 'Closed Won'){
                    assetsRecords = [SELECT AccountId,Account.Name,ContactId,SBQQ__QuoteLine__c,Contact.Name,End_Customer_Ship_To_Account__c,End_Customer_Ship_To_Account__r.Name,Id,
                                     InstallDate,License_Count__c,License_Type__c,Linked_Booking_Opportunity__c,Linked_Booking_Opportunity__r.Name,
                                     Name,Price,Product2Id,Product2.Name,PurchaseDate,Quantity,Description,
                                     SerialNumber,Status,Subscription_Value__c 
                                     FROM Asset 
                                     WHERE (Status != 'Shipped' AND Status != '' AND Linked_Booking_Opportunity__c=:getLinkedBookingOppId.Linked_Booking_Opportunity__c )];        }
                
            }
        }catch(Exception e){
            system.debug('ERROR-->'+e.getLineNumber()+'  '+e.getMessage());
        }
        return assetsRecords;
    }
    
    @AuraEnabled
    public static void insertORUpdateORDeleteAssets(List<assetWrapper> saveAssets,List<assetWrapper> assetsToDelete){
        // Insert Or Update Asset records
        List<Asset>  insertAssets = new  List<Asset>(); 
        List<Asset>  updateAssets = new  List<Asset>(); 
        
        try{
            for(assetWrapper aw:saveAssets){
                Asset a = new Asset();
                a.Name = aw.Name;
                a.Quantity = aw.Quantity;
                if(aw.LinkedBookingOpportunity != ''){
                    a.Linked_Booking_Opportunity__c = aw.LinkedBookingOpportunity;}
                if(aw.AccountId != ''){
                    a.AccountId = aw.AccountId;}
                if(aw.ContactId != ''){
                    a.ContactId = aw.ContactId;}
                if(aw.Product2Id != ''){
                    a.Product2Id = aw.Product2Id;}
                if(aw.EndCustomerShipToAccount != ''){
                    a.End_Customer_Ship_To_Account__c = aw.EndCustomerShipToAccount;}
                system.debug('@@@@@'+aw.LicenseCount);
                a.License_Count__c = aw.LicenseCount;
                a.License_Type__c = aw.LicenseType;
                a.InstallDate = aw.InstallDate;
                a.PurchaseDate = aw.PurchaseDate;
                if(aw.SBQQQuoteLine != ''){
                    a.SBQQ__QuoteLine__c = aw.SBQQQuoteLine;}
                a.Price = aw.Price;
                a.Subscription_Value__c = aw.SubscriptionValue;
                a.SerialNumber = aw.SerialNumber;
                if(string.valueOf(aw.Id).left(3) == 'new'){
                    if( aw.SerialNumber != null && aw.SerialNumber != '' && aw.Status == 'Purchased'){
                        a.Status = aw.Status;
                    }else{
                        a.Status = aw.Status;
                    }
                    insertAssets.add(a);
                }else{
                    if( aw.SerialNumber != null && aw.SerialNumber != '' && aw.Status == 'Purchased'){
                        a.Status = 'Shipped';
                    }
                    a.Id = aw.Id;
                    updateAssets.add(a);
                }  
            }
            
            
            Set<Id> assetIds = new Set<Id>(); 
            for(assetWrapper ad :assetsToDelete){
                if(string.valueOf(ad.Id).left(3) != 'new'){
                    assetIds.add(ad.Id);
                }
            }
            
            if(!insertAssets.isEmpty()){
                Insert insertAssets;}
            
            if(!updateAssets.isEmpty()){
                system.debug('updateAssets-->'+updateAssets);
                Update updateAssets;}
            
            if(!assetIds.isEmpty()){
                Delete [Select Id From Asset Where Id=:assetIds];
            }
        }Catch(Exception e){
            system.debug('ERROR-->'+e);
        }
    }
    
    @AuraEnabled
    public static string returnURL(){
        // Get baseURL
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        baseUrl = baseUrl.replace('.my.', '.lightning.');
        return baseUrl;
    }    
    @AuraEnabled
    public static string getRecordName(Id recordId){
        // Get RecordName
        String recordName;
        try{
            if((String.valueOf(recordId)).startsWith('001')){
                recordName = 'Account Name: '+[Select Name From Account Where Id=:recordId].Name;
            }else if((String.valueOf(recordId)).startsWith('006')){
                recordName =  'Opportunity Name: '+[Select Name From Opportunity Where Id=:recordId].Name;
            }
        }catch(Exception e){
            system.debug('ERROR-->'+e.getLineNumber()+'  '+e.getMessage());
        }
        return recordName;
    }
    
    @AuraEnabled
    public static List<assetWrapper> modifyOriginalAssetsWithDraftedAssets(List<assetWrapper> originalAssets,List<assetWrapper> draftedAssets){
        Map<String,assetWrapper> draftedAssetsMap = new  Map<String,assetWrapper>();
        try{
            for(assetWrapper daw:draftedAssets){
                draftedAssetsMap.put(daw.Id,daw);
            }
            
            for(assetWrapper oaw:originalAssets){
                if(draftedAssetsMap.containsKey(oaw.Id)){
                    if(draftedAssetsMap.get(oaw.Id).Quantity != null){
                        oaw.Quantity = draftedAssetsMap.get(oaw.Id).Quantity;}
                    if(draftedAssetsMap.get(oaw.Id).SerialNumber != null){
                        oaw.SerialNumber = draftedAssetsMap.get(oaw.Id).SerialNumber;}
                    if(draftedAssetsMap.get(oaw.Id).InstallDate != null ){
                           oaw.InstallDate = draftedAssetsMap.get(oaw.Id).InstallDate;}
                    else if(draftedAssetsMap.get(oaw.Id).InstallDate != null && 
                            string.valueOf(draftedAssetsMap.get(oaw.Id).InstallDate) !=''){
                                oaw.InstallDate = null;
                           }
                    if(draftedAssetsMap.get(oaw.Id).LicenseCount != null ){
                        oaw.LicenseCount = draftedAssetsMap.get(oaw.Id).LicenseCount;}
                }
            }
        }catch(Exception e){
            system.debug('ERROR-->'+e);
        }
        return originalAssets;
    }
    
    public class assetWrapper{
        @AuraEnabled Public String Name {get;set;}
        @AuraEnabled Public String Status {get;set;}
        @AuraEnabled Public String Id {get;set;}
        @AuraEnabled Public String AccountName {get;set;}
        @AuraEnabled Public String AccountId {get;set;}
        @AuraEnabled Public String LinkedBookingOpportunityName {get;set;}
        @AuraEnabled Public String LinkedBookingOpportunity {get;set;}
        @AuraEnabled Public String Product2Id {get;set;}
        @AuraEnabled Public String ProductName {get;set;}
        @AuraEnabled  Public String ContactId {get;set;}
        @AuraEnabled Public String ContactName {get;set;}
        @AuraEnabled Public Integer Quantity {get;set;}
        @AuraEnabled Public Decimal Price {get;set;}
        @AuraEnabled Public String EndCustomerShipToAccount {get;set;}
        @AuraEnabled Public Decimal SubscriptionValue {get;set;}
        @AuraEnabled Public date InstallDate {get;set;}
        @AuraEnabled Public date PurchaseDate {get;set;}
        @AuraEnabled Public Integer LicenseCount {get;set;}
        @AuraEnabled Public String LicenseType {get;set;}
        @AuraEnabled Public String SerialNumber {get;set;}
        @AuraEnabled Public String SBQQQuoteLine {get;set;}
        
    }
    
}