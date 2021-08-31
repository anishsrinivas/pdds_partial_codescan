public without sharing class ResellerPriceBookController {
    
    @AuraEnabled
    public static Pricebook2 getPriceBook(){
        Pricebook2 getPB = new Pricebook2();
        try{
            User u = [Select Id,Contact.Account.Partner_Tier__c,Contact.Account.Price_Book__c From User Where Id=:userinfo.getUserId()];
            if(u.Contact.Account.Price_Book__c != null){
                getPB = [Select Id,Name,Description From Pricebook2 WHERE Id=:u.Contact.Account.Price_Book__c Limit 1];
            }else{
                getPB =  [Select Id,Name,Description From Pricebook2 WHERE IsStandard= True Limit 1];
            }
        }catch(Exception e){
            system.debug('ERROR-->'+e.getLineNumber()+'  '+e.getMessage());
        }
        return getPB;
    }
    
    @AuraEnabled
    public static string  getBaseURL(){
        String priceBookBaseURL;
        try{
            Reseller_Portal_Values__c resellerPortalValues = [SELECT Name,Reseller_Portal_Name__c,Reseller_Portal_Org_wide_Address__c 
                                                              FROM Reseller_Portal_Values__c 
                                                              Where Name = 'Reseller Portal Defaults' 
                                                              Limit 1];
            
            Id networkId = [Select Id From Network 
                            Where Name =:resellerPortalValues.Reseller_Portal_Name__c].Id;
            
            String loginURL = Network.getLoginUrl(networkId);
            priceBookBaseURL = loginURL.replace('login','detail');
            
        }catch(Exception e){
            system.debug('ERROR-->'+e.getLineNumber()+'  '+e.getMessage());
        }
        return priceBookBaseURL;
    }
}