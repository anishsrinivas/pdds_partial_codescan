public with sharing class UpdateWeeklyScoreCalculationHandler { 
    
    
    public static void CalculationOnInsert( List < Account > accs)  {
    
        for (Account Accrec: accs) {            
            
            if((Accrec.Total_Hubspot_Score__c != NULL)){
                if(Accrec.Demand_Status__c == 'High'){
                Accrec.Weekly_account_score__c = Accrec.Total_Hubspot_Score__c + 75;    
                }
                else if(Accrec.Demand_Status__c == 'Medium'){
                Accrec.Weekly_account_score__c = Accrec.Total_Hubspot_Score__c + 50;    
                }
                else if(Accrec.Demand_Status__c == 'Low'){
                Accrec.Weekly_account_score__c = Accrec.Total_Hubspot_Score__c + 25;    
                }
                else{
                    Accrec.Weekly_account_score__c = Accrec.Total_Hubspot_Score__c;
                }
                
            }
            else{
                if(Accrec.Demand_Status__c == 'High'){
                Accrec.Weekly_account_score__c = 75;
                    Accrec.Total_Hubspot_Score__c = 0;
                }
                else if(Accrec.Demand_Status__c == 'Medium'){
                Accrec.Weekly_account_score__c = 50;
                    Accrec.Total_Hubspot_Score__c = 0;
                }
                else if(Accrec.Demand_Status__c == 'Low'){
                Accrec.Weekly_account_score__c = 25;  
                    Accrec.Total_Hubspot_Score__c = 0;
                }
                else{
                    Accrec.Weekly_account_score__c = 0;
                    Accrec.Total_Hubspot_Score__c = 0;
                }
            }
            
           
        }
            
}
    public static void CalculationOnUpdate( Map < Id, Account > AccRecOldMap, List < Account > accRecs)  {
       
        for (Account Accrec: accRecs) {
            
            if ((Accrec.Total_Hubspot_Score__c != AccRecOldMap.get(Accrec.id).Total_Hubspot_Score__c) &&
                (Accrec.Demand_Status__c == AccRecOldMap.get(Accrec.id).Demand_Status__c)){
                
                if((Accrec.Total_Hubspot_Score__c != NULL && AccRecOldMap.get(Accrec.id).Total_Hubspot_Score__c != NULL )){
                    Accrec.Weekly_account_score__c = AccRecOldMap.get(Accrec.id).Weekly_account_score__c + (Accrec.Total_Hubspot_Score__c - AccRecOldMap.get(Accrec.id).Total_Hubspot_Score__c);                
            }
                else if((Accrec.Total_Hubspot_Score__c != NULL && AccRecOldMap.get(Accrec.id).Total_Hubspot_Score__c == NULL )){
                    Accrec.Weekly_account_score__c = AccRecOldMap.get(Accrec.id).Weekly_account_score__c + (Accrec.Total_Hubspot_Score__c );                
            }
                else if((Accrec.Total_Hubspot_Score__c == NULL && AccRecOldMap.get(Accrec.id).Total_Hubspot_Score__c != NULL )){
                    Accrec.Weekly_account_score__c = AccRecOldMap.get(Accrec.id).Weekly_account_score__c - (AccRecOldMap.get(Accrec.id).Total_Hubspot_Score__c );                
            }
                else{
                    Accrec.Weekly_account_score__c = AccRecOldMap.get(Accrec.id).Weekly_account_score__c;
                }

            }
            if ((Accrec.Total_Hubspot_Score__c == AccRecOldMap.get(Accrec.id).Total_Hubspot_Score__c) &&
            (Accrec.Demand_Status__c != AccRecOldMap.get(Accrec.id).Demand_Status__c)){
                
                if((Accrec.Demand_Status__c == 'High') && (AccRecOldMap.get(Accrec.id).Demand_Status__c == 'Low')){
                    Accrec.Weekly_account_score__c = AccRecOldMap.get(Accrec.id).Weekly_account_score__c + 50;                
            }
                else if((Accrec.Demand_Status__c == 'High') && (AccRecOldMap.get(Accrec.id).Demand_Status__c == 'Medium')){
                    Accrec.Weekly_account_score__c = AccRecOldMap.get(Accrec.id).Weekly_account_score__c + 25;                
            }
                else if((Accrec.Demand_Status__c == 'High') && (String.isBlank(AccRecOldMap.get(Accrec.id).Demand_Status__c))){
                    Accrec.Weekly_account_score__c = AccRecOldMap.get(Accrec.id).Weekly_account_score__c + 75;                
            }
                else if((Accrec.Demand_Status__c == 'Medium') && (String.isBlank(AccRecOldMap.get(Accrec.id).Demand_Status__c))){
                    Accrec.Weekly_account_score__c = AccRecOldMap.get(Accrec.id).Weekly_account_score__c + 50;                
            }
                else if((Accrec.Demand_Status__c == 'Medium') && (AccRecOldMap.get(Accrec.id).Demand_Status__c == 'High')){
                    Accrec.Weekly_account_score__c = AccRecOldMap.get(Accrec.id).Weekly_account_score__c - 25;                
            }
                else if((Accrec.Demand_Status__c == 'Medium') && (AccRecOldMap.get(Accrec.id).Demand_Status__c == 'Low')){
                    Accrec.Weekly_account_score__c = AccRecOldMap.get(Accrec.id).Weekly_account_score__c + 25;                
            }
                else if((Accrec.Demand_Status__c == 'Low') && (String.isBlank(AccRecOldMap.get(Accrec.id).Demand_Status__c))){
                    Accrec.Weekly_account_score__c = AccRecOldMap.get(Accrec.id).Weekly_account_score__c + 25;                
            }
                else if((Accrec.Demand_Status__c == 'Low') && (AccRecOldMap.get(Accrec.id).Demand_Status__c == 'Medium')){
                    Accrec.Weekly_account_score__c = AccRecOldMap.get(Accrec.id).Weekly_account_score__c - 25;                
            }
                else if((Accrec.Demand_Status__c == 'Low') && (AccRecOldMap.get(Accrec.id).Demand_Status__c == 'High')){
                    Accrec.Weekly_account_score__c = AccRecOldMap.get(Accrec.id).Weekly_account_score__c - 50;                
            }
                else if(String.isBlank(Accrec.Demand_Status__c) && (AccRecOldMap.get(Accrec.id).Demand_Status__c == 'Low')){
                    Accrec.Weekly_account_score__c = AccRecOldMap.get(Accrec.id).Weekly_account_score__c - 25;                
            }
                else if(String.isBlank(Accrec.Demand_Status__c) && (AccRecOldMap.get(Accrec.id).Demand_Status__c == 'Medium')){
                    Accrec.Weekly_account_score__c = AccRecOldMap.get(Accrec.id).Weekly_account_score__c - 50;                
            }
                else{
                    Accrec.Weekly_account_score__c = AccRecOldMap.get(Accrec.id).Weekly_account_score__c - 75;
                }
                
            }
            
            if ((Accrec.Total_Hubspot_Score__c != AccRecOldMap.get(Accrec.id).Total_Hubspot_Score__c) &&
            (Accrec.Demand_Status__c != AccRecOldMap.get(Accrec.id).Demand_Status__c)){
                
                if((Accrec.Demand_Status__c == 'High') && (AccRecOldMap.get(Accrec.id).Demand_Status__c == 'Low')){
                    Accrec.Weekly_account_score__c = AccRecOldMap.get(Accrec.id).Weekly_account_score__c + (Accrec.Total_Hubspot_Score__c - AccRecOldMap.get(Accrec.id).Total_Hubspot_Score__c) + 50;                
            }
                else if((Accrec.Demand_Status__c == 'High') && (AccRecOldMap.get(Accrec.id).Demand_Status__c == 'Medium')){
                    Accrec.Weekly_account_score__c = AccRecOldMap.get(Accrec.id).Weekly_account_score__c + (Accrec.Total_Hubspot_Score__c - AccRecOldMap.get(Accrec.id).Total_Hubspot_Score__c) + 25;                
            }
                else if((Accrec.Demand_Status__c == 'High') && (String.isBlank(AccRecOldMap.get(Accrec.id).Demand_Status__c))){
                    Accrec.Weekly_account_score__c = AccRecOldMap.get(Accrec.id).Weekly_account_score__c + (Accrec.Total_Hubspot_Score__c - AccRecOldMap.get(Accrec.id).Total_Hubspot_Score__c) + 75;                
            }
                else if((Accrec.Demand_Status__c == 'Medium') && (String.isBlank(AccRecOldMap.get(Accrec.id).Demand_Status__c))){
                    Accrec.Weekly_account_score__c = AccRecOldMap.get(Accrec.id).Weekly_account_score__c + (Accrec.Total_Hubspot_Score__c - AccRecOldMap.get(Accrec.id).Total_Hubspot_Score__c) + 50;                
            }
                else if((Accrec.Demand_Status__c == 'Medium') && (AccRecOldMap.get(Accrec.id).Demand_Status__c == 'High')){
                    Accrec.Weekly_account_score__c = AccRecOldMap.get(Accrec.id).Weekly_account_score__c + (Accrec.Total_Hubspot_Score__c - AccRecOldMap.get(Accrec.id).Total_Hubspot_Score__c) - 25;                
            }
                else if((Accrec.Demand_Status__c == 'Medium') && (AccRecOldMap.get(Accrec.id).Demand_Status__c == 'Low')){
                    Accrec.Weekly_account_score__c = AccRecOldMap.get(Accrec.id).Weekly_account_score__c + (Accrec.Total_Hubspot_Score__c - AccRecOldMap.get(Accrec.id).Total_Hubspot_Score__c) + 25;                
            }
                else if((Accrec.Demand_Status__c == 'Low') && (String.isBlank(AccRecOldMap.get(Accrec.id).Demand_Status__c))){
                    Accrec.Weekly_account_score__c = AccRecOldMap.get(Accrec.id).Weekly_account_score__c + (Accrec.Total_Hubspot_Score__c - AccRecOldMap.get(Accrec.id).Total_Hubspot_Score__c) + 25;                
            }
                else if((Accrec.Demand_Status__c == 'Low') && (AccRecOldMap.get(Accrec.id).Demand_Status__c == 'Medium')){
                    Accrec.Weekly_account_score__c = AccRecOldMap.get(Accrec.id).Weekly_account_score__c + (Accrec.Total_Hubspot_Score__c - AccRecOldMap.get(Accrec.id).Total_Hubspot_Score__c) - 25;                
            }
                else if((Accrec.Demand_Status__c == 'Low') && (AccRecOldMap.get(Accrec.id).Demand_Status__c == 'High')){
                    Accrec.Weekly_account_score__c = AccRecOldMap.get(Accrec.id).Weekly_account_score__c + (Accrec.Total_Hubspot_Score__c - AccRecOldMap.get(Accrec.id).Total_Hubspot_Score__c) - 50;                
            }
                else if(String.isBlank(Accrec.Demand_Status__c) && (AccRecOldMap.get(Accrec.id).Demand_Status__c == 'Low')){
                    Accrec.Weekly_account_score__c = AccRecOldMap.get(Accrec.id).Weekly_account_score__c + (Accrec.Total_Hubspot_Score__c - AccRecOldMap.get(Accrec.id).Total_Hubspot_Score__c) - 25;                
            }
                else if(String.isBlank(Accrec.Demand_Status__c) && (AccRecOldMap.get(Accrec.id).Demand_Status__c == 'Medium')){
                    Accrec.Weekly_account_score__c = AccRecOldMap.get(Accrec.id).Weekly_account_score__c + (Accrec.Total_Hubspot_Score__c - AccRecOldMap.get(Accrec.id).Total_Hubspot_Score__c) - 50;                
            }
                else{
                    Accrec.Weekly_account_score__c = AccRecOldMap.get(Accrec.id).Weekly_account_score__c + (Accrec.Total_Hubspot_Score__c - AccRecOldMap.get(Accrec.id).Total_Hubspot_Score__c) - 75;
                }
               
            }
            
    }
                        
 }
    
    public static void resettingScore( List < Account > accs)  {

        for (Account accRec: accs) {
            
         if(Accrec.Weekly_account_score__c == NULL){
            accRec.Weekly_account_score__c = 0;
           }
       }
        
    }
    
}