/******************************************************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Name             LeadTriggerController
* @description      This create a End Customer/Reseller Relationship Record
********************************************************************************************************************************
Version     Date               Team          Comments
********************************************************************************************************************************
* 1         07 Nov 2020     Jeromia     Initial Development 
*********************************************************************************************************************************************/

public without sharing class LeadTriggerController {
    
    
    /* Whenever a Lead is converted, a new End Customer/Reseller Relationship Record will be created.
* End Customer Account is ConvertedAccountId and Reseller Account is Lead Created user's AccountId
* If the Account is already a Reseller then it will just Convert the Lead without creating a junctionRecord.
* Also send notification to Lead CreatedBy User(Portal User)
* This functionality applies only when Leads Created by Poratl Users are converted.*/
    
    Public static void createResellerRelationship(List<Lead> convertedLeadList){
        try{
            Set<Id> leadIds = new Set<Id>();
            for(Lead l: convertedLeadList){
                leadIds.add(l.Id); 
            }
            
            // Query Converted Leads Created by Portal Users
            List<Lead> leadList = getLeadsCreatedbyResellers(leadIds);
            
            Set<Id> regularAccountIds = new Set<Id>();
            List<Lead> updateOpportunitiesOnConversion = new List<Lead>(); 
            
            for(Lead l: leadList){
                regularAccountIds.add(l.ConvertedAccountId); 
                if(l.ConvertedOpportunityId != null){
                    updateOpportunitiesOnConversion.add(l);
                }
            }
            
            if(!updateOpportunitiesOnConversion.isEmpty()){
                updateConvertedOpportunities(updateOpportunitiesOnConversion);
            }
            
            //Query junctionRecords of ConvertedAccountId.
            List<Reseller_End_Customer_Rel__c> regularResellerList = getJunctionRecordsofConvertedAccount(regularAccountIds);
            
            /* If junctionRecords already present for this Regular Account, then add the Lead CreatedUser's Account as a Reseller Account
only if the reseller account is not present.*/
            if(regularResellerList.isEmpty()){
                // If junctionRecords are not present then create a new Relationship.
                createResellerRelforAccountsWithoutJunctionRecords(leadList);
            }else{
                Map<Id, List<Id>> regularResellerMap =  convertRegularResellerListtoMap(regularResellerList);
                // If it is not already a Reseller then, create a End Customter/Reseller junctionRecord.
                createResellerRelforAccountswithJunctionRecords(regularResellerMap,leadList);
            }
        }catch(Exception e){
            system.debug('ERROR-->'+e.getLineNumber()+' '+e.getMessage());
        }
    }
    
    // Get Leads created by Portal Users
    Private static List<Lead> getLeadsCreatedbyResellers( Set<Id> leadIds){
        
        List<Lead> leadList = [Select Id,IsConverted,CreatedBy.Contact.Account.Price_Book__c,
                               CreatedBy.Contact.Account.Partner_Tier__c,ConvertedOpportunityId,ConvertedOpportunity.Name,Created_By_User_Account_Name__c ,
                               LeadSource,CreatedBy.Profile.Name,CreatedBy.Contact.AccountId,ConvertedAccountId,
                               CreatedBy.Email,ConvertedAccount.Name,CreatedBy.Name
                               From Lead 
                               Where Id=:leadIds AND IsConverted = True AND 
                               LeadSource = 'Reseller' AND 
                               CreatedBy.Profile.Name = 'Reseller Partner Community'
                              ];
        return leadList;
        
    }
    
    // Get EndCustomer-Reseller if any exists for ConvertedAccountId
    Private static List<Reseller_End_Customer_Rel__c> getJunctionRecordsofConvertedAccount(Set<Id> regularAccountIds){
        
        List<Reseller_End_Customer_Rel__c> regularResellerList = [Select Id,Regular_Account__c,Reseller_Account__c 
                                                                  From Reseller_End_Customer_Rel__c 
                                                                  Where Regular_Account__c=:regularAccountIds
                                                                 ];
        return regularResellerList;
        
    }
    
    // Map End Customer and Resellers for the ConvertedAccountId.
    Private static  Map<Id, List<Id>> convertRegularResellerListtoMap( List<Reseller_End_Customer_Rel__c> regularResellerList){
        Map<Id, List<Id>> regularResellerMap = new Map<Id, List<Id>>();
        try{ 
            for(Reseller_End_Customer_Rel__c rec : regularResellerList){
                if(regularResellerMap.containsKey(rec.Regular_Account__c)){
                    List<Id> accountId = regularResellerMap.get(rec.Regular_Account__c);
                    accountId.add(rec.Reseller_Account__c );
                    regularResellerMap.put(rec.Regular_Account__c, accountId);
                }else{
                    regularResellerMap.put(rec.Regular_Account__c, new List<Id> { rec.Reseller_Account__c });
                }
                
            }
            return regularResellerMap;
        }catch(Exception e){
            system.debug('ERROR--->'+e);
            return regularResellerMap;
        }
    }
    
    /* Insert new End-Customer/Reseller Relationship if Exisiting Account is chosen.
* Check if there are any Duplicates on Reseller Creation.
* If no Duplicates are there,Insert new End-Customer-Reseller Relationship with ConvertedAccountId as EndCustomer and 
* Lead CreatedBy User's Account as Reseller.Also send a notification email to Portal Users.
*/
    Private static void createResellerRelforAccountswithJunctionRecords( Map<Id, List<Id>> regularResellerMap, List<Lead> leadList){
        try{
            List<Reseller_End_Customer_Rel__c> resellerInsertList = new  List<Reseller_End_Customer_Rel__c>();
            Map<String,List<Lead>> userEmailandRegularAccountsMap = new Map<String,List<Lead>>();
            Set<String> nonDuplicateResellerAccounts = new Set<String>();
            List<Lead> duplicateLeadsCreatedByReseller = new List<Lead>();
            
            for(Lead l : leadList){
                if(!regularResellerMap.get(l.ConvertedAccountId).contains(l.CreatedBy.Contact.AccountId)){
                    Reseller_End_Customer_Rel__c recinsert = new Reseller_End_Customer_Rel__c();
                    recinsert.Regular_Account__c = l.ConvertedAccountId;
                    recinsert.Reseller_Account__c = l.CreatedBy.Contact.AccountId;
                    // To bulk check
                    String convertedaccountidandReselleraccountid = l.ConvertedAccountId+','+l.CreatedBy.Contact.AccountId;
                    
                    if(!nonDuplicateResellerAccounts.contains(convertedaccountidandReselleraccountid)){
                        nonDuplicateResellerAccounts.add(convertedaccountidandReselleraccountid);
                        resellerInsertList.add(recinsert);   
                        if(userEmailandRegularAccountsMap.containsKey(l.CreatedBy.Email)){
                            List<Lead> leadId = userEmailandRegularAccountsMap.get(l.CreatedBy.Email);
                            leadId.add(l);
                            userEmailandRegularAccountsMap.put(l.CreatedBy.Email,leadId);
                        }else{
                            userEmailandRegularAccountsMap.put(l.CreatedBy.Email, new List<Lead>{l});
                        }
                    }else{
                        duplicateLeadsCreatedByReseller.add(l);
                    }
                }else{
                    duplicateLeadsCreatedByReseller.add(l);
                }
            }
            
            if(!resellerInsertList.isEmpty() &&  Schema.sObjectType.Reseller_End_Customer_Rel__c.isCreateable()){
                Insert resellerInsertList;  
                sendEmailtoPoratlUser(userEmailandRegularAccountsMap);
            }
            if(!duplicateLeadsCreatedByReseller.isEmpty()){
                duplicateLeadsNotification(duplicateLeadsCreatedByReseller);
            }
        }catch(Exception e){
            system.debug('ERROR--->'+e);
        }
        
    }
    
    /* Insert new End-Customer/Reseller Relationship if new Account/Account with 0 Junction Records is chosen.
* Check if there are any Duplicates on Bulk of Reseller Creation.
* If no Duplicates are there,Insert new End-Customer-Reseller Relationship with ConvertedAccountId as EndCustomer and 
* Lead CreatedBy User's Account as Reseller.Also send a notification email to Portal Users.
*/
    Private static void createResellerRelforAccountsWithoutJunctionRecords( List<Lead> leadList){
        List<Reseller_End_Customer_Rel__c> resellerInsertList = new  List<Reseller_End_Customer_Rel__c>();
        Map<String,List<Lead>> userEmailandRegularAccountsMap = new Map<String,List<Lead>>();
        Set<String> nonDuplicateResellerAccounts = new Set<String>();
        try{
            for(Lead l : leadList){
                Reseller_End_Customer_Rel__c recinsert = new Reseller_End_Customer_Rel__c();
                recinsert.Regular_Account__c = l.ConvertedAccountId;
                recinsert.Reseller_Account__c = l.CreatedBy.Contact.AccountId;
                String convertedaccountidandReselleraccountid = l.ConvertedAccountId+','+l.CreatedBy.Contact.AccountId;
                
                if(!nonDuplicateResellerAccounts.contains(convertedaccountidandReselleraccountid)){
                    nonDuplicateResellerAccounts.add(convertedaccountidandReselleraccountid);
                    resellerInsertList.add(recinsert);
                    if(userEmailandRegularAccountsMap.containsKey(l.CreatedBy.Email)){
                        List<Lead> leadId = userEmailandRegularAccountsMap.get(l.CreatedBy.Email);
                        leadId.add(l);
                        userEmailandRegularAccountsMap.put(l.CreatedBy.Email,leadId);
                    }
                    else{
                        userEmailandRegularAccountsMap.put(l.CreatedBy.Email, new List<Lead>{l});
                    }
                }
            }
            if(!resellerInsertList.isEmpty() &&  Schema.sObjectType.Reseller_End_Customer_Rel__c.isCreateable()){
                Insert resellerInsertList;  
                sendEmailtoPoratlUser(userEmailandRegularAccountsMap);
            }
            
        }catch(Exception e){
            system.debug('ERROR--->'+e);
        }
    }
    
    // Send Email notification to Portal User (Lead Owner)
    Public static void sendEmailtoPoratlUser(Map<String,List<Lead>> userEmailandRegularAccountsMap){
        
        List<Messaging.SingleEmailMessage> listofEmails = new List<Messaging.SingleEmailMessage>();
        try{
            
            Reseller_Portal_Values__c resellerPortalValues = [SELECT Name,Reseller_Portal_Name__c,Reseller_Portal_Org_wide_Address__c 
                                                              FROM Reseller_Portal_Values__c 
                                                              Where Name = 'Reseller Portal Defaults' 
                                                              WITH SECURITY_ENFORCED
                                                              Limit 1];
            
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress 
                                          where Address =:resellerPortalValues.Reseller_Portal_Org_wide_Address__c
                                          WITH SECURITY_ENFORCED];
            Id networkId = [Select Id From Network 
                            Where Name =:resellerPortalValues.Reseller_Portal_Name__c
                            WITH SECURITY_ENFORCED].Id;
            
            String loginURL = Network.getLoginUrl(networkId);
            String accountBaseURL = loginURL.replace('login','detail');
            
            for(String s: userEmailandRegularAccountsMap.KeySet()){
                for(Lead l:userEmailandRegularAccountsMap.get(s)){
                    
                    Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                    List<String> sendingto = new List<String>();
                    sendingto.add(s);
                    
                    semail.setToAddresses(sendingto);
                    semail.setWhatId(l.ConvertedAccountId);
                    semail.setSaveAsActivity(true);
                    semail.setOrgWideEmailAddressId(owea.get(0).Id);
                    semail.subject = 'Account ' +l.ConvertedAccount.Name+ ' is available on the Partner Portal';
                    if(l.ConvertedOpportunityId != null){
                    semail.HTMLBody = '<html>Hi '+ l.CreatedBy.Name+ ','+
                        '<br/><br/>'+
                        'The following Account & Opportunity are available on your Partner Portal site. Please add a Primary Quote to the Opportunity link found below:'+
                        '<br/><br/>'+
                        '<b>Opportunity Link:</b> <a href="'+accountBaseURL+'/'+l.ConvertedOpportunityId+'">'+accountBaseURL+'/'+l.ConvertedOpportunityId+'</a>'+
                        '<br/><br/>'+
                        '<b>Account Name:</b> '+ l.ConvertedAccount.Name+
                        '</html>';
                    }else{
                         semail.HTMLBody = '<html>Hi '+ l.CreatedBy.Name+ ','+
                        '<br/><br/>'+
                        'The following Account is available on your Partner Portal site to add an Opportunity and Quote.'+
                        '<br/><br/>'+
                        '<b>Account Link:</b> <a href="'+accountBaseURL+'/'+l.ConvertedAccountId+'">'+accountBaseURL+'/'+l.ConvertedAccountId+'</a>'+
                        '<br/><br/>'+
                        '<b>Account Name:</b> '+ l.ConvertedAccount.Name+
                        '</html>';
                    }
                    if(!sendingto.isEmpty()){
                        listofEmails.add(semail); 
                    }
                }
            }
            
            if(!ListofEmails.isEmpty()){
                Messaging.sendEmail(ListofEmails);
            }   
        }catch(Exception e){
            system.debug('ERROR--->'+e);
        }
    }
    
    Private static void duplicateLeadsNotification(List<Lead> duplicateLeadList){
        
        List<Messaging.SingleEmailMessage> listofEmails = new List<Messaging.SingleEmailMessage>();        
        try{
            Reseller_Portal_Values__c resellerPortalValues = [SELECT Name,Reseller_Portal_Name__c,Reseller_Portal_Org_wide_Address__c 
                                                              FROM Reseller_Portal_Values__c 
                                                              Where Name = 'Reseller Portal Defaults' 
                                                              WITH SECURITY_ENFORCED
                                                              Limit 1];
            
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress 
                                          where Address =:resellerPortalValues.Reseller_Portal_Org_wide_Address__c
                                          WITH SECURITY_ENFORCED];
            
            List<GroupMember> apteryxResellerGroup = [SELECT UserOrGroupId FROM GroupMember Where Group.DeveloperName = 'Apteryx_Reseller_Lead_Group'];
            List<String> sendingto = new List<string>();
            for(GroupMember gm:apteryxResellerGroup){
                String userId = String.valueOf(gm.UserOrGroupId);
                if(userId.startsWith('005')){
                    sendingto.add(gm.UserOrGroupId);
                    
                }
            }        
            for(Lead l :duplicateLeadList){
                Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                
                semail.setToAddresses(sendingto);
                semail.setSaveAsActivity(true);
                semail.setWhatId(l.ConvertedAccountId);
                semail.setOrgWideEmailAddressId(owea.get(0).Id);
                semail.subject = 'Duplicate Lead Converted';
                semail.HTMLBody = '<html>Hi Team,'+
                    '</BR></BR>'+
                    'Duplicate Lead is Converted by Reseller!!'+
                    '</BR></BR>'+
                    '<b>Reseller Name:</b> '+l.CreatedBy.Name+
                    '</BR></BR>'+
                    '<b>Reseller Account:</b> '+l.Created_By_User_Account_Name__c+
                    '</BR></BR>'+
                    '<b>End-Customer Account:</b> '+ l.ConvertedAccount.Name+
                    '</html>';
                if(!sendingto.isEmpty()){
                    listofEmails.add(semail);
                }
                
            }
            
            if(!ListofEmails.isEmpty()){
                Messaging.sendEmail(ListofEmails);
            }  
        }catch(Exception e){
            system.debug('ERROR--->'+e);
        }
    }
    
    Private static void updateConvertedOpportunities(List<Lead> updateOpportunitiesOnConversion){
        try{
            Id standardPriceBookId = [Select Id From Pricebook2 WHERE IsStandard= True Limit 1].Id;
            List<Opportunity> updateOpportunity = new  List<Opportunity>();
            for(Lead l:updateOpportunitiesOnConversion){
                Opportunity opp = new Opportunity();
                opp.End_Customer_Ship_To_Account__c = l.ConvertedAccountId;
                opp.AccountId = l.CreatedBy.Contact.AccountId;
                opp.Name = (l.ConvertedAccount.Name).LEFT(100) + '-Booking';
                opp.Reseller_Opp__c = True;
                opp.id = l.ConvertedOpportunityId;
                opp.Pricebook2Id = (l.CreatedBy.Contact.Account.Price_Book__c != null? 
                                    l.CreatedBy.Contact.Account.Price_Book__c:standardPriceBookId);
                updateOpportunity.add(opp);
            }
            if(!updateOpportunity.isEmpty()){
                Update updateOpportunity;
            }
        }Catch(Exception e){
            system.debug('ERROR-->'+e);
        }
    }
}