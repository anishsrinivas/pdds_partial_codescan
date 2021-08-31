public without sharing class CustomReportDataController {
    
    @AuraEnabled(cacheable=true)
    public static List<Contract> fetchReportDataForDenticon(){
        List<Contract> finalData = new List<Contract>();
       /* List<Contract> contractResults = [select AccountId, Account.Name, Account.Global_Id__c, Account.GUP_ID__c, Account.PGID__c, Account.PGID_OID__c, Account.GUP_flag__c,ContractNumber
                                               from Contract where status='Activated' and 
                                               Id in 
                                               (select SBQQ__Contract__c from SBQQ__Subscription__c where SBQQ__ProductName__c like '%Denticon%' and SBQQ__Product__r.ProductCode like 'CPQ%')    and AccountId not in (select SBQQ__Account__c   from SBQQ__Subscription__c where SBQQ__ProductName__c like '%Dentiray%' and SBQQ__Product__r.ProductCode like 'CPQ%')];
        
       */
        Map<ID, Account> nonResellerAccts = new Map<ID, Account>([select Id from Account where Id  not in (select regular_account__c from Reseller_End_Customer_Rel__c) and ordertype__c<>'Reseller']);
        /*
        Map<String, Contract> excludedContracts = new Map<String, Contract>();
        for(Contract contract : [select AccountId from Contract where status='Activated' and 
                                               AccountId in 
                                               (select SBQQ__Account__c   from SBQQ__Subscription__c where SBQQ__ProductName__c like '%Dentiray%' and SBQQ__Product__r.ProductCode like 'CPQ%')])
        {
            excludedContracts.put(contract.AccountId, contract);
        }
        
        for(Contract currContract : [select AccountId, Account.Name, Account.Practice_Type__c, Account.AccountSource, Account.Phone, Account.Website,ContractNumber
                                               from Contract where status='Activated' and 
                                               Id in 
                                               (select SBQQ__Contract__c from SBQQ__Subscription__c where SBQQ__ProductName__c like '%Denticon%' and SBQQ__Product__r.ProductCode like 'CPQ%')]){
            Id acctId = currContract.AccountId;
            if(nonResellerAccts.keySet().contains(acctId) && !excludedContracts.keySet().contains(acctId)){
                finalData.add(currContract);
            }
        } 
        */

        for(Contract currContract : [select AccountId, Account.Name, Account.Practice_Type__c, Account.AccountSource, Account.Phone, Account.Website,ContractNumber
                                               from Contract where status='Activated' and 
                                               Id in 
                                               (select SBQQ__Contract__c from SBQQ__Subscription__c where SBQQ__Product__r.Product_License_Categories__c ='Denticon')    and AccountId not in (select SBQQ__Account__c   from SBQQ__Subscription__c where SBQQ__ProductName__c like '%Dentiray%' )])
        {
            Id acctId = currContract.AccountId;
            if(nonResellerAccts.keySet().contains(acctId)){
                finalData.add(currContract);
            }
        } 
        
        return finalData;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Asset> fetchReportDataForXVLite(){
        List<Asset> finalData = new List<Asset>();
        Map<String, Asset>  xvLiteExcludedAssets = new Map<String, Asset>();
        for(Asset asset : [Select  AccountId
                                            from Asset where
                                            Product2.Product_License_Categories__c  in ('XV3','XV4','XVWeb')
                                            and Status not in ('Obsolete') and AccountId not in (select regular_account__c from Reseller_End_Customer_Rel__c) and Account.ordertype__c<>'Reseller'])
        {
            xvLiteExcludedAssets.put(asset.AccountId, asset); 
        }
                           
        
        for(Asset includedAsset : [Select  AccountId, Account.Name, Product2.Product_License_Categories__c,Account.Global_Id__c, Account.GUP_ID__c, Account.PGID__c, Account.PGID_OID__c, Account.GUP_flag__c,Account.ordertype__c,Name,SerialNumber, License_Count__c, status, Quantity, PurchaseDate, Price, Subscription_Value__c, NetTotal__c,License_Type__c, Account.ia_crm__IntacctID__c,End_Customer_Ship_To_Account__c,Contact.Name
                                            from Asset where
                                            Product2.Product_License_Categories__c  in ('XVLite')
                                            and Status not in ('Obsolete') and AccountId not in (select regular_account__c from Reseller_End_Customer_Rel__c) and Account.ordertype__c<>'Reseller'])
        {
            String acctId = includedAsset.AccountId;
            if(!xvLiteExcludedAssets.keySet().contains(acctId)){
                finalData.add(includedAsset);
            }
        }
        System.debug('XVLite Data::>>'+xvLiteExcludedAssets.keySet());
        
        return finalData;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Asset> fetchReportDataForXV3(){
        List<Asset> finalData = new List<Asset>();
        Map<String, Asset>  xv3ExcludedAssets = new Map<String, Asset>();
        for(Asset asset : [Select  AccountId from Asset where
                                         Product2.Product_License_Categories__c  in ('XV4','XVWeb')
                           and Status not in ('Obsolete') and AccountId not in (select regular_account__c from Reseller_End_Customer_Rel__c) and Account.ordertype__c<>'Reseller'])
        {
            xv3ExcludedAssets.put(asset.AccountId, asset); 
        }                  
        
        for(Asset includedAsset : [Select  AccountId, Account.Name, Product2.Product_License_Categories__c,Account.Global_Id__c, Account.GUP_ID__c, Account.PGID__c, Account.PGID_OID__c, Account.GUP_flag__c,Account.ordertype__c,Name,SerialNumber, License_Count__c, Status, Quantity, PurchaseDate, Price, Subscription_Value__c, NetTotal__c,License_Type__c, Account.ia_crm__IntacctID__c,End_Customer_Ship_To_Account__c,Contact.Name
                                         from Asset where
                                         Product2.Product_License_Categories__c  in ('XV3')
                                         and Status not in ('Obsolete') and AccountId not in (select regular_account__c from Reseller_End_Customer_Rel__c) and Account.ordertype__c<>'Reseller'])
        {
            String acctId = includedAsset.AccountId;
            if(!xv3ExcludedAssets.keySet().contains(acctId)){
                finalData.add(includedAsset);
            }
        }
        System.debug('XV3 Data::>>'+xv3ExcludedAssets.keySet());
        return finalData;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Asset> fetchReportDataForXV4(){
        List<Asset> finalData = new List<Asset>();
        Map<String, Asset>  xv4ExcludedAssets = new Map<String, Asset>();
        for(Asset asset : [Select  AccountId from Asset where
                                         Product2.Product_License_Categories__c  in ('XVWeb')
                                         and Status not in ('Obsolete') and AccountId not in (select regular_account__c from Reseller_End_Customer_Rel__c) and Account.ordertype__c<>'Reseller'])
        {
            xv4ExcludedAssets.put(asset.AccountId, asset); 
        } 
        
        for(Asset includedAsset : [Select  AccountId, Account.Name, Product2.Product_License_Categories__c,Account.Global_Id__c, Account.GUP_ID__c, Account.PGID__c, Account.PGID_OID__c, Account.GUP_flag__c,Account.ordertype__c,Name,SerialNumber, License_Count__c, status, Quantity, PurchaseDate, Price, Subscription_Value__c, NetTotal__c,License_Type__c, Account.ia_crm__IntacctID__c,End_Customer_Ship_To_Account__c,Contact.Name
                                         from Asset where
                                         Product2.Product_License_Categories__c  in ('XV4')
                                         and Status not in ('Obsolete') and AccountId not in (select regular_account__c from Reseller_End_Customer_Rel__c) and Account.ordertype__c<>'Reseller'])
        {
            Id acctId = includedAsset.AccountId;
            if(!xv4ExcludedAssets.keySet().contains(acctId)){
                finalData.add(includedAsset);
            }
        }
        System.debug('XV4 Data>>'+xv4ExcludedAssets.keySet());
        return finalData;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Asset> fetchReportDataForXVWeb(){
        List<Asset> finalData = [Select  AccountId, Account.Name, Product2.Product_License_Categories__c,Account.Global_Id__c, Account.GUP_ID__c, Account.PGID__c, Account.PGID_OID__c, Account.GUP_flag__c,Account.ordertype__c,Name,SerialNumber, License_Count__c, status, Quantity, PurchaseDate, Price, Subscription_Value__c, NetTotal__c,License_Type__c, Account.ia_crm__IntacctID__c,End_Customer_Ship_To_Account__c,Contact.Name
                           from Asset where
                           Product2.Product_License_Categories__c  in ('XVWeb')
                           and Status not in ('Obsolete') and AccountId not in (select regular_account__c from Reseller_End_Customer_Rel__c) and Account.ordertype__c<>'Reseller'];
        return finalData;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Asset> fetchReportDataForDV34(){
        List<Asset> finalData = new List<Asset>();        
        Map<String, Asset>  dv34ExcludedAssets = new Map<String, Asset>();
        for(Asset asset : [Select  AccountId from Asset where
                                          Product2.Product_License_Categories__c  in ('DCV 3.5')
                                          and Status not in ('Obsolete') and AccountId not in (select regular_account__c from Reseller_End_Customer_Rel__c) and Account.ordertype__c<>'Reseller'])
        {
            dv34ExcludedAssets.put(asset.AccountId, asset); 
        } 
        
        for(Asset includedAsset : [Select  AccountId, Account.Name, Product2.Product_License_Categories__c,Account.Global_Id__c, Account.GUP_ID__c, Account.PGID__c, Account.PGID_OID__c, Account.GUP_flag__c,Account.ordertype__c,Name,SerialNumber, License_Count__c, status, Quantity, PurchaseDate, Price, Subscription_Value__c, NetTotal__c,License_Type__c, Account.ia_crm__IntacctID__c,End_Customer_Ship_To_Account__c,Contact.Name
                            from Asset where
                            Product2.Product_License_Categories__c  in ('DCV 3.4')
                            and Status not in ('Obsolete') and AccountId not in (select regular_account__c from Reseller_End_Customer_Rel__c) and Account.ordertype__c<>'Reseller'])
        {   
            Id acctId = includedAsset.AccountId;
            if(!dv34ExcludedAssets.keySet().contains(acctId)){
                finalData.add(includedAsset);
            }
         
        }
        System.debug('DCV3.4 Data>>'+dv34ExcludedAssets.keySet());
        return finalData;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Asset> fetchReportDataForDCV35(){
        List<Asset> finalData = [Select  AccountId, Account.Name, Product2.Product_License_Categories__c, Account.Global_Id__c, Account.GUP_ID__c, Account.PGID__c, Account.PGID_OID__c, Account.GUP_flag__c,Account.ordertype__c,Name,SerialNumber, License_Count__c, status, Quantity, PurchaseDate, Price, Subscription_Value__c, NetTotal__c,License_Type__c, Account.ia_crm__IntacctID__c,End_Customer_Ship_To_Account__c,Contact.Name
                            from Asset where
                            Product2.Product_License_Categories__c  in ('DCV 3.5')
                            and Status not in ('Obsolete') and AccountId not in (select regular_account__c from Reseller_End_Customer_Rel__c) and Account.ordertype__c<>'Reseller'];
        System.debug('DCV3.5 Data>>'+finalData);
        return finalData;
    }
    

}