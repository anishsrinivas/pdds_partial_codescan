public class UpdateAllAccountsForSuppLicenseCatg {
    
    public void getAllAccounts(){
        
       Map<Id, Account> allXVAccounts = new Map<Id,Account>();
        
        Map<Id,Account> acctsWithXVLiteAssets = new Map<Id,Account>([Select id,License_Support_Category__c from Account where id in (Select AccountId  from Asset where Product2.Product_License_Categories__c  in ('XVLite') and  Status not in ('Obsolete') ) and Id not in (select AccountId from Asset where Product2.Product_License_Categories__c in ('XV3','XV4') and  Status not in ('Obsolete') )]); 
        Map<Id,Account> acctsWithXVLiteAssetEndCust = new Map<Id,Account>([Select id,License_Support_Category__c from Account where id in (Select End_Customer_Ship_To_Account__c  from Asset where Product2.Product_License_Categories__c  in ('XVLite') and  Status not in ('Obsolete') ) and Id not in (select End_Customer_Ship_To_Account__c from Asset where Product2.Product_License_Categories__c in ('XV3','XV4') and  Status not in ('Obsolete') )]);
        Map<Id,Account> acctsWithXVLiteSub = new Map<Id,Account>([Select id,License_Support_Category__c from Account where Id in (select SBQQ__Account__c from SBQQ__Subscription__c where SBQQ__Product__r.Product_License_Categories__c in ('XVLite') and SBQQ__Contract__r.endDate > Today ) and Id not in (select SBQQ__Account__c from SBQQ__Subscription__c where SBQQ__Product__r.Product_License_Categories__c in ('XV3','XV4') and SBQQ__Contract__r.endDate > Today)]); 
        Map<Id,Account> acctsWithXVLiteSubEndCust = new Map<Id,Account>([Select id,License_Support_Category__c from Account where Id in (select End_Customer_Ship_To_Account__c from SBQQ__Subscription__c where SBQQ__Product__r.Product_License_Categories__c in ('XVLite') and SBQQ__Contract__r.endDate > Today ) and Id not in (select End_Customer_Ship_To_Account__c from SBQQ__Subscription__c where SBQQ__Product__r.Product_License_Categories__c in ('XV3','XV4') and SBQQ__Contract__r.endDate > Today )]); 
        Set<Id> allXVLite = new Set<Id>();
        allXVLite.addAll(acctsWithXVLiteAssets.keyset());
        allXVLite.addAll(acctsWithXVLiteAssetEndCust.keyset());
        allXVLite.addAll(acctsWithXVLiteSub.keyset());
        allXVLite.addAll(acctsWithXVLiteSubEndCust.keyset());
        
        allXVAccounts.putAll(acctsWithXVLiteAssets);
        allXVAccounts.putAll(acctsWithXVLiteAssetEndCust);
        allXVAccounts.putAll(acctsWithXVLiteSub);
        allXVAccounts.putAll(acctsWithXVLiteSubEndCust);
        
        System.debug('acctsWithXVLiteAssets>>'+allXVLite.size());
              
        Map<Id,Account> acctsWithXV3Assets = new Map<Id,Account>([Select id,License_Support_Category__c from Account where id in (Select AccountId  from Asset where Product2.Product_License_Categories__c  in ('XV3') and  Status not in ('Obsolete') ) and Id not in (select AccountId from Asset where Product2.Product_License_Categories__c in ('XV4') )]);
        Map<Id,Account> acctsWithXV3AssetEndCust = new Map<Id,Account>([Select id,License_Support_Category__c from Account where id in (Select End_Customer_Ship_To_Account__c  from Asset where Product2.Product_License_Categories__c  in ('XV3') and  Status not in ('Obsolete') ) and Id not in (select End_Customer_Ship_To_Account__c from Asset where Product2.Product_License_Categories__c in ('XV4') )]);
        Map<Id,Account> acctsWithXV3Sub = new Map<Id,Account>([Select id,License_Support_Category__c from Account where Id in (select SBQQ__Account__c from SBQQ__Subscription__c where SBQQ__Product__r.Product_License_Categories__c in ('XV3') and SBQQ__Contract__r.endDate > Today ) and Id not in (select SBQQ__Account__c from SBQQ__Subscription__c where SBQQ__Product__r.Product_License_Categories__c in ('XV4') and SBQQ__Contract__r.endDate > Today )]); 
        Map<Id,Account> acctsWithXV3SubEndCust = new Map<Id,Account>([Select id,License_Support_Category__c from Account where Id in (select End_Customer_Ship_To_Account__c from SBQQ__Subscription__c where SBQQ__Product__r.Product_License_Categories__c in ('XV3') and SBQQ__Contract__r.endDate > Today ) and Id not in (select End_Customer_Ship_To_Account__c from SBQQ__Subscription__c where SBQQ__Product__r.Product_License_Categories__c in ('XV4') and SBQQ__Contract__r.endDate > Today )  ]); 

        Set<Id> allXV3 = new Set<Id>();
        allXV3.addAll(acctsWithXV3Assets.keyset());
        allXV3.addAll(acctsWithXV3AssetEndCust.keyset());
        allXV3.addAll(acctsWithXV3Sub.keyset());
        allXV3.addAll(acctsWithXV3SubEndCust.keyset());
        
        allXVAccounts.putAll(acctsWithXV3Assets);
        allXVAccounts.putAll(acctsWithXV3AssetEndCust);
        allXVAccounts.putAll(acctsWithXV3SubEndCust);
        allXVAccounts.putAll(acctsWithXV3Sub);
        
        System.debug('allXV3>>'+allXV3.size());
        
        
        Map<Id,Account> acctsWithXV4Assets = new Map<Id,Account>([Select id,License_Support_Category__c from Account where id in (Select AccountId  from Asset where Product2.Product_License_Categories__c  in ('XV4') and  Status not in ('Obsolete') )]);
        Map<Id,Account> acctsWithXV4AssetEndCust = new Map<Id,Account>([Select id,License_Support_Category__c from Account where id in (Select End_Customer_Ship_To_Account__c  from Asset where Product2.Product_License_Categories__c  in ('XV4') and  Status not in ('Obsolete') )]);
        Map<Id,Account> acctsWithXV4Sub = new Map<Id,Account>([Select id,License_Support_Category__c from Account where Id in (select SBQQ__Account__c from SBQQ__Subscription__c where SBQQ__Product__r.Product_License_Categories__c in ('XV4') and SBQQ__Contract__r.endDate > Today )]); 
        Map<Id,Account> acctsWithXV4SubEndCust = new Map<Id,Account>([Select id,License_Support_Category__c from Account where Id in (select End_Customer_Ship_To_Account__c from SBQQ__Subscription__c where SBQQ__Product__r.Product_License_Categories__c in ('XV4') and SBQQ__Contract__r.endDate > Today )]); 
        Set<Id> allXV4 = new Set<Id>();
        allXV4.addAll(acctsWithXV4Assets.keyset());
        allXV4.addAll(acctsWithXV4AssetEndCust.keyset());
        allXV4.addAll(acctsWithXV4Sub.keyset());
        allXV4.addAll(acctsWithXV4SubEndCust.keyset());
        
        allXVAccounts.putAll(acctsWithXV4Assets);
        allXVAccounts.putAll(acctsWithXV4AssetEndCust);
        allXVAccounts.putAll(acctsWithXV4Sub);
        allXVAccounts.putAll(acctsWithXV4SubEndCust);
        
        System.debug('allXV4>>'+allXV4.size());
        
        Map<Id,Account> acctsWithXVWebSub = new Map<Id,Account>([Select id,License_Support_Category__c from Account where Id in (select SBQQ__Account__c from SBQQ__Subscription__c where SBQQ__Product__r.Product_License_Categories__c ='XVWeb' and SBQQ__Contract__r.endDate > Today )]); 
        Map<Id,Account> acctsWithXVWebSubEndCust = new Map<Id,Account>([Select id,License_Support_Category__c from Account where Id in (select End_Customer_Ship_To_Account__c from SBQQ__Subscription__c where SBQQ__Product__r.Product_License_Categories__c ='XVWeb' and SBQQ__Contract__r.endDate > Today )]); 
        Map<Id,Account> allXVWeb = new Map<Id,Account>();
        allXVWeb.putAll(acctsWithXVWebSub);
        allXVWeb.putAll(acctsWithXVWebSubEndCust);
        System.debug('allXVWeb>>'+allXVWeb.size());
		
        
        Map<Id, Account> acctsWithDenticonSub = new Map<Id,Account>([Select id,License_Support_Category__c from Account where Id in (select SBQQ__Account__c from SBQQ__Subscription__c where SBQQ__Product__r.Product_License_Categories__c ='Denticon' and SBQQ__Contract__r.endDate > Today )]);
        Map<Id, Account> acctsWithDenticonSubEndCust = new Map<Id,Account>([Select id,License_Support_Category__c from Account where Id in (select End_Customer_Ship_To_Account__c from SBQQ__Subscription__c where SBQQ__Product__r.Product_License_Categories__c ='Denticon' and SBQQ__Contract__r.endDate > Today )]);
        Map<Id, Account> allDenticon = new Map<Id, Account>();
        allDenticon.putAll(acctsWithDenticonSub);
        allDenticon.putAll(acctsWithDenticonSubEndCust);
        Map<Id, Account> acctsWithDentiraySub = new Map<Id,Account>([Select id,License_Support_Category__c from Account where Id in (select SBQQ__Account__c from SBQQ__Subscription__c where  SBQQ__ProductName__c like '%Dentiray%' and SBQQ__Contract__r.endDate > Today )]);
        Set<Id> acctsWithDentiraySubEndCust = new Map<Id,Account>([Select id,License_Support_Category__c from Account where Id in (select End_Customer_Ship_To_Account__c from SBQQ__Subscription__c where SBQQ__ProductName__c like '%Dentiray%' and SBQQ__Contract__r.endDate > Today )]).keyset();
        Set<Id> allDentiray = new Set<Id>();
        allDentiray.addAll(acctsWithDentiraySubEndCust);
        allDentiray.addAll(acctsWithDentiraySub.keyset());
        
        System.debug('allDenticon>>'+allDenticon.size());
        System.debug('allDentiray>>'+allDentiray.size());
        
        Map<Id, Account> acctToUpdate = new Map<Id,Account>();
        
        //set XVWeb as license category
        if(allXVWeb.size() > 0){
            for(Id currId : allXVWeb.keyset()){
                Account currAcct = allXVWeb.get(currId);
                currAcct.License_Support_Category__c = 'XVWeb';
                acctToUpdate.put(currId, currAcct);
            }
        }
        
        if(allXVAccounts.size() > 0){
            for(Id currId : allXVAccounts.keyset()){
                Account currAcct = allXVAccounts.get(currId);
                if(!allXVWeb.keyset().contains(currId)){ //if XVWeb already set, then no need to set any other license type
                    if(allXVLite.contains(currId) && !allXV3.contains(currId) && !allXV4.contains(currId)){
                        currAcct.License_Support_Category__c = 'XVLite';
                    }else if(allXV3.contains(currId) && !allXV4.contains(currId)){
                        currAcct.License_Support_Category__c = 'XV3';
                    }else if(allXV4.contains(currId)){
                        currAcct.License_Support_Category__c = 'XV4';
                    }
                    acctToUpdate.put(currId, currAcct);
                }
            }
        }
       
        List<String> licenseCategoriesList;
        if((allDenticon != null && allDenticon.size() > 0) ){
            
            for(Id currId : allDenticon.keyset()){
                licenseCategoriesList = new List<String>();
                Account currAcct = allDenticon.get(currId);
                if(acctToUpdate.keyset().contains(currId) && !(acctToUpdate.get(currId).License_Support_Category__c.contains('Denticon') || 
                                                             acctToUpdate.get(currId).License_Support_Category__c.contains('DenticonHasDentiray'))){
                    licenseCategoriesList.add(acctToUpdate.get(currId).License_Support_Category__c);
                }

                if(allDentiray.contains(currId)){
                    licenseCategoriesList.add('DenticonHasDentiray');
                }else  if(!allDentiray.contains(currId)){
                    licenseCategoriesList.add('Denticon');
                }
                else{
                    licenseCategoriesList.add('Denticon');
                }
                currAcct.License_Support_Category__c = String.join(licenseCategoriesList, ';');
                acctToUpdate.put(currId, currAcct);
            }
        }
        System.debug('acctToUpdate.size>>'+acctToUpdate.size()); 
        if(acctToUpdate.size() > 0 ){
            for(Account a :  acctToUpdate.values()){
            System.debug(a.id + '>>>' +a.License_Support_Category__c);     
            }
        	
        }
    }
    
}