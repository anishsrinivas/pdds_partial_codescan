/*
    Name             : PracticeProfileHandler
    Author Name      : asrinivas
    Created on       : 30-Aug-2021
    Last Modified    : 
    Last Modified By : 
    Description      : Trigger optimization as part of PLAN-1023.Added the code in PracticeProfileTriggerHandler to be executed as a job to
						improve performance
*/
public class PracticeProfileHandler implements Queueable{
    
    Public Map<Id,opportunity> opoldMap;
    Public Map<Id,opportunity> opnewMap;
    
    public PracticeProfileHandler(Map<Id,opportunity> mapOldOpps, Map<Id,opportunity> mapNewOpps){
        this.opoldMap = mapOldOpps;
        this.opnewMap = mapnewOpps;
    }
    
    public void execute(System.QueueableContext qc){
    	List<ContentDocumentLink> conDocLinks = new List<ContentDocumentLink>();
        List<ContentVersion> cVersions = new List<ContentVersion>();
        Set<Id> oppIds = new Set<Id>();
        Set<Id> primaryQuoteIds = new Set<Id>();
        Set<Id> quoteDocIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        Map<id,Id> quoteQuoteDocMap = new Map<Id,Id>();
        Map<Id,List<String>> oppFileTitleMap = new Map<Id,List<String>>();
        List<Current_Software__c> currentSoftwares = new  List<Current_Software__c>();
        Map<Id,List<String>> csOppCurrentPMSMap = new Map<Id,List<String>>();
        Map<Id,List<Decimal>> csOppQuantityMap = new Map<Id,List<Decimal>>();
        Map<Id,List<String>> csOppOtherPMSDetailMap = new Map<Id,List<String>>();
        Map<Id,String> oppAttTitleMap = new Map<Id,String>();
        Map<Id,Blob> oppAttMap = new Map<id,Blob>();
        Map<Id,Blob> practiceProfileFileMap = new map<id,Blob>();
        List<Messaging.SingleEmailMessage>  emailMessages = new List<Messaging.SingleEmailMessage>();
        List<Messaging.EmailFileAttachment> efas = new List<Messaging.EmailFileAttachment>();
        Map<id,Messaging.SingleEmailMessage> oppMessageMap = new Map<id,Messaging.SingleEmailMessage>();
        Set<Id> updatedopps = new Set<Id>();
        Id objectRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Booking').getRecordTypeId();
        
        Map<Id,List<String>> oppConFirstNameMap = new map<id,List<string>>();
        Map<Id,List<String>> oppConLastNameMap = new map<id,List<string>>();
        Map<Id,List<String>> oppConEmailMap = new map<id,List<string>>();
        Map<Id,List<String>> oppConPhoneMap = new map<id,List<string>>();
        Map<Id,List<String>> oppConTitleMap = new map<id,List<string>>();
        
        Map<String,String> commaLastNameMap = new Map<String,String>();
        Map<String,String> commaFirstNameMap = new Map<String,String>();
        Map<String,String> commaPhoneMap = new Map<String,String>();
        Map<String,String> commaTitleMap = new Map<String,String>();
        
        Map<Id,list<AccountContactRelation>> AccountAcrMap = new Map<Id,list<AccountContactRelation>>();
        
        for(Opportunity opp: opnewMap.Values()){
            
            If (opoldMap.get(opp.Id).Stagename != opnewMap.get(opp.Id).Stagename 
                && opnewMap.get(opp.Id).Stagename=='Closed Won' 
                && opnewMap.get(opp.Id).RecordTypeID==objectRecordTypeId
                && opnewMap.get(opp.Id).Claw_Back__c==false 
                && opnewMap.get(opp.Id).Reseller_Opp__c==false
                && opnewMap.get(opp.Id).Needs_Implementation__c=='Yes' ){
                    
                    updatedopps.add(opp.Id);
                }
        }
        
        List<Opportunity> opps = [Select id,name,recordtypeid,stagename,AccountId,Account.Name,Current_Imaging_Solution_Software__c,
                                  Account.Practice_Type__c,Services_Performed__c,SBQQ__PrimaryQuote__r.SBQQ__StartDate__c,Account.ordertype__c,
                                  Account.BillingStreet,Account.BillingCity,Account.BillingState,Account.BillingPostalCode,
                                  Account.BillingCountry,MRR_amt__c,Closed_Flag__c,Closed_Lost_Flag__c,Other_Notes_for_Onboarding__c,PP_Amount__c,owner.Email,Type,
                                  SalesLoft1__Primary_Contact__c,DDS_Payment__c,DDS_Statements__c,DDS_E_Statement__c,DDS_VBS__c,How_Many_Sensors_were_Sold__c,
                                  Claw_Back__c,Needs_Implementation__c,Owner.UserRole.DeveloperName,
                                  (Select id,name,Current__c,Opportunities__c,Other_PMS_Detail__c,Quantity__c
                                   from Current_Software__r) from opportunity where id in:updatedopps and Closed_Flag__c!=true];
        
        
        
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Practice Profile' limit 1]; 
        // Fetch the email ids to whom PP should be sent and which are stored in Custom Metadata
        List<Practice_Profile_Emails__mdt> PPEmails = [select DeveloperName,Email_Id__c from Practice_Profile_Emails__mdt 
                                                       where Email_Id__c!=NULL and Include_in_PP_email__c=true];
        
        For(Opportunity opp: opps ){
            
            accIds.add(opp.AccountId);
        }
        // Added for PLAN-849 to Display Related Contacts in PP PDF
        List<AccountContactRelation> AccConRelList=[select contactId,AccountId,contact.name,contact.FirstName,
                                                    contact.LastName,contact.Email,contact.Phone,contact.Title
                                                    from AccountContactRelation where AccountId in :accIds];
        
        
        Integer p=0;
        
        for(AccountContactRelation acr: AccConRelList){
            
            //Added for PLAN-859 
            if(!AccountAcrMap.containsKey(acr.AccountId)){
                AccountAcrMap.put(acr.accountId, new List<AccountContactRelation>{acr});
            }else{
                List<AccountContactRelation> acrclist=AccountAcrMap.get(acr.AccountId);
                acrclist.add(acr);
                AccountAcrMap.put(acr.AccountId, acrclist);
            }
            // End of Addition for PLAN-859
            if(oppConFirstNameMap.containsKey(acr.AccountId)) {
                List<String> firstNames = oppConFirstNameMap.get(acr.AccountId);
                // check if FirstName contains comma and remove comma
                if(acr.contact.FirstName!=NULL){
                    if(acr.contact.FirstName.contains(',')){
                        string originalFirstName =acr.contact.FirstName;
                        acr.contact.FirstName= acr.contact.FirstName.replaceAll(',','');
                        commaFirstNameMap.put(acr.contact.FirstName+p,originalFirstName);
                    }else{
                        commaFirstNameMap.put(acr.contact.FirstName+p,acr.contact.FirstName);
                    }
                }
                firstNames.add(acr.contact.FirstName);
                oppConFirstNameMap.put(acr.AccountId,firstNames);
            }
            
            else {
                // check if FirstName contains comma and remove comma
                if(acr.contact.FirstName!=NULL){
                    if(acr.contact.FirstName.contains(',')){
                        string originalFirstName =acr.contact.FirstName;
                        acr.contact.FirstName= acr.contact.FirstName.replaceAll(',','');
                        commaFirstNameMap.put(acr.contact.FirstName+p,originalFirstName);
                    }else{
                        commaFirstNameMap.put(acr.contact.FirstName+p,acr.contact.FirstName);
                    }
                }
                oppConFirstNameMap.put(acr.AccountId, new List<String> {acr.contact.FirstName});
                
            }
            
            if(oppConLastNameMap.containsKey(acr.AccountId)) {
                List<String> lastNames = oppConLastNameMap.get(acr.AccountId);
                // check if LastName contains comma and remove comma
                if(acr.contact.LastName.contains(',')){
                    string originalLastName =acr.contact.LastName;
                    acr.contact.Lastname= acr.contact.Lastname.replaceAll(',','');
                    commaLastNameMap.put(acr.contact.Lastname+p,originalLastName);
                }else{
                    commaLastNameMap.put(acr.contact.Lastname+p,acr.contact.Lastname);
                }
                lastNames.add(acr.contact.LastName);
                oppConLastNameMap.put(acr.AccountId,lastNames);
            }
            
            else {
                // check if LastName contains comma and remove comma
                if(acr.contact.LastName.contains(',')){
                    string originalLastName = acr.contact.LastName;
                    acr.contact.Lastname= acr.contact.Lastname.replaceAll(',','');
                    commaLastNameMap.put(acr.contact.Lastname+p,originalLastName);
                }else{
                    commaLastNameMap.put(acr.contact.Lastname+p,acr.contact.Lastname);
                }
                oppConLastNameMap.put(acr.AccountId, new List<String> {acr.contact.LastName});
                
            }
            
            if(oppConEmailMap.containsKey(acr.AccountId)) {
                List<String> emails = oppConEmailMap.get(acr.AccountId);
                emails.add(acr.contact.Email);
                oppConEmailMap.put(acr.AccountId,emails);
            }
            
            else {
                
                oppConEmailMap.put(acr.AccountId, new List<String> {acr.contact.Email});
                
            }
            
            if(oppConPhoneMap.containsKey(acr.AccountId)) {
                List<String> phones = oppConPhoneMap.get(acr.AccountId);
                if(acr.contact.Phone!=NULL){
                    // Check if Phone Contains comma and Remove comma
                    if(acr.contact.Phone.contains(',')){
                        string originalPhone = acr.contact.Phone;
                        acr.contact.Phone= acr.contact.Phone.replaceAll(',','');
                        commaPhoneMap.put(acr.contact.Phone+p,originalPhone);
                    }else{
                        commaPhoneMap.put(acr.contact.Phone+p,acr.contact.Phone);
                    }
                    
                }
                phones.add(acr.contact.Phone);
                oppConPhoneMap.put(acr.AccountId,phones);
            }
            
            else {
                if(acr.contact.Phone!=NULL){
                    // Check if Phone Contains comma and Remove comma
                    if(acr.contact.Phone.contains(',')){
                        string originalPhone = acr.contact.Phone;
                        acr.contact.Phone= acr.contact.Phone.replaceAll(',','');
                        commaPhoneMap.put(acr.contact.Phone+p,originalPhone);
                    }else{
                        commaPhoneMap.put(acr.contact.Phone+p,acr.contact.Phone);
                    }
                }
                oppConPhoneMap.put(acr.AccountId, new List<String> {acr.contact.Phone});
                
            }
            if(oppConTitleMap.containsKey(acr.AccountId)) {
                List<String> titles = oppConTitleMap.get(acr.AccountId);
                if(acr.contact.Title!=NULL){
                    // Check if Title Contains comma and Remove comma
                    if(acr.contact.Title.contains(',')){
                        string originalTitle = acr.contact.Title;
                        acr.contact.Title= acr.contact.Title.replaceAll(',','');
                        commaTitleMap.put(acr.contact.Title+p,originalTitle);
                    }else{
                        commaTitleMap.put(acr.contact.Title+p,acr.contact.Title);
                    }
                }
                titles.add(acr.contact.Title);
                oppConTitleMap.put(acr.AccountId,titles);
            }
            
            else {
                if(acr.contact.Title!=NULL){
                    // Check if Title Contains comma and Remove comma
                    if(acr.contact.Title.contains(',')){
                        string originalTitle = acr.contact.Title;
                        acr.contact.Title= acr.contact.Title.replaceAll(',','');
                        commaTitleMap.put(acr.contact.Title+p,originalTitle);
                    }else{
                        commaTitleMap.put(acr.contact.Title+p,acr.contact.Title);
                    }
                }
                oppConTitleMap.put(acr.AccountId, new List<String> {acr.contact.Title});
                
            }
            
            p=p+1; 
        }
        // End of addition for PLAN-849      
        
        for(Opportunity opp: opps){
            
            String oppRecordlink = URL.getSalesforceBaseUrl().toExternalForm()+'/' + opp.Id;
            
            oppIds.add(opp.Id);
            primaryQuoteIds.add(opp.SBQQ__PrimaryQuote__c);
            currentSoftwares.addAll(opp.Current_Software__r);
            //Check if Opportunity has atleast one currentSoftware
            if(currentSoftwares.size() == 0 ){        
                
                opnewMap.get(opp.Id).addError('Atleast one Current Software record must be present before closing an opportunity with stage Closed Won');
                
            }
            //Added for PLAN-859
            //Check if Opportunity Account has atleast one Related Contact
            if(!AccountAcrMap.containsKey(opp.AccountId)){
                
                opnewMap.get(opp.Id).addError('At least one Related Contact must be associated to the Account, if the Opportunity needs Implementation');
                
            }
            
            // end of Addition for PLAN-859
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            List<String> emailAddresses = new List<String>();
            List<String> ccEmailAddresses = new List<String>();
            String practiceProfileEmailBody = emailTemplate.Body;
            emailAddresses.add(opp.Owner.Email);
            // Added by Ramana to add emails stored in Custom metadata on 2-Feb-2021
            for(Practice_Profile_Emails__mdt ppe: PPEmails ){
                /*Added as Part of PLAN-810 if opportunity owner Role is 'Account Executive - Imaging' 
PP Email should go to Mike,Hannah and 'imagingimplementation@planetdds.com' */
                //Adding 'marketing@planetdds.com' to PP email when opportunity owner Role is 'Account Executive - Imaging' for PLAN-887
                //considering Mike's,Hannah's Id ,'imagingimplementation@planetdds.com' ,'marketing@planetdds.com' will be stored in Email_1,Email_3,Email_5, Email_6 respectively in 'Practice_Profile_Emails__mdt'
                
                if (opp.Owner.UserRole.DeveloperName =='Account_Executive_Imaging' || opp.Owner.UserRole.DeveloperName =='Director_of_Sales_Apteryx') { 
                    
                    if(ppe.DeveloperName =='Email_1' || ppe.DeveloperName =='Email_5'|| ppe.DeveloperName =='Email_3'||ppe.DeveloperName =='Email_6')
                    {
                        
                        emailAddresses.add(ppe.Email_Id__c);
                    } 
                     //Added 'atarn@planetdds.com'and'dnguyen@planetdds.com' to imaging implementation team as part of PLAN-985
                    else if(ppe.DeveloperName =='Email_8'||ppe.DeveloperName =='Email_9')                
                    {
                        ccEmailAddresses.add(ppe.Email_Id__c);
                    }
                    
                }else{
                    system.debug('ppe==='+ppe);
                    if(ppe.DeveloperName !='Email_5' && ppe.DeveloperName !='Email_6'&& ppe.DeveloperName !='Email_8' && ppe.DeveloperName !='Email_9' ){
                        // PLAN 943 to cc customersuccess@planetdds.com for Denticon
                        if(ppe.DeveloperName == 'Email_7'){
                            ccEmailAddresses.add(ppe.Email_Id__c);
                        }else{
                            emailAddresses.add(ppe.Email_Id__c);
                        }
                        
                    }
                    
                }
                // end of Addition
            }
            // end of Addition
            message.toAddresses = emailAddresses;
            // PLAN 943 to cc customersuccess@planetdds.com for Denticon
            if(!ccEmailAddresses.isEmpty()){
                message.ccaddresses = ccEmailAddresses;
            }
            message.subject = 'Practice Profile and Subscription Package for' + '  '+ opp.Name;
            practiceProfileEmailBody = practiceProfileEmailBody.replace('{!Opportunity.Account}',opp.Account.Name);
            practiceProfileEmailBody = practiceProfileEmailBody.replace('{!Opportunity.Name}',opp.Name);  
            practiceProfileEmailBody = practiceProfileEmailBody.replace('{!Opportunity.Link}',oppRecordlink);                                              
            message.setTemplateID(emailTemplate.Id); 
            message.setPlainTextBody(practiceProfileEmailBody);
            message.setTargetObjectId(opp.SalesLoft1__Primary_Contact__c);
            message.setTreatTargetObjectAsRecipient(false);
            message.setWhatId(opp.Id);
            oppMessageMap.put(opp.id,message);
            
        }
        
        
        for(Current_Software__c cs: currentSoftwares){
            
            if(csOppCurrentPMSMap.containsKey(cs.Opportunities__c)) {
                
                
                List<String> currentPms = csOppCurrentPMSMap.get(cs.Opportunities__c);
                currentPms.add(cs.Current__c);
                csOppCurrentPMSMap.put(cs.Opportunities__c, currentPms);
                
            }
            
            else {
                
                csOppCurrentPMSMap.put(cs.Opportunities__c, new List<String> {cs.Current__c});
                
                
            }
            
            if(csOppQuantityMap.containsKey(cs.opportunities__c)) {
                
                List<Decimal> quantities = new List<Decimal>();
                Decimal quantity;
                
                if(csOppQuantityMap.get(cs.Opportunities__c).size() == 1){
                    
                    quantity = csOppQuantityMap.get(cs.Opportunities__c)[0];
                    
                    quantities.add(quantity);
                    
                }
                
                else{
                    
                    quantities.addAll(csOppQuantityMap.get(cs.Opportunities__c));
                    
                    
                }
                
                
                quantities.add(cs.Quantity__c); 
                
                
                csOppQuantityMap.put(cs.Opportunities__c, quantities);
                
                
            }
            
            
            else {
                
                csOppQuantityMap.put(cs.Opportunities__c, new List<Decimal> {cs.Quantity__c});
                
                
            }
            
            
            
            
            
            if(csOppOtherPMSDetailMap.containsKey(cs.Opportunities__c)) {
                
                List<String> otherPms = csOppOtherPMSDetailMap.get(cs.Opportunities__c);
                otherPms.add(cs.Other_PMS_Detail__c);
                csOppOtherPMSDetailMap.put(cs.Opportunities__c, otherPms);
            }
            
            else {
                
                
                csOppOtherPMSDetailMap.put(cs.Opportunities__c, new List<String> {cs.Other_PMS_Detail__c});
                
                
                
            }
            
            
            
        }
        
        
        
        List<SBQQ__QuoteDocument__c> quoteDocs = [Select id,name,SBQQ__SignatureStatus__c,SBQQ__Quote__c,SBQQ__Opportunity__r.Account.Name
                                                  from SBQQ__QuoteDocument__c where
                                                  SBQQ__Quote__c in:primaryQuoteIds and SBQQ__SignatureStatus__c = 'Completed'];
        
        Map<Id,String> QuoteDocAccMap= new Map<Id,String>();
        
        for(SBQQ__QuoteDocument__c quoteDoc:quoteDocs){
            
            quoteDocIds.add(quoteDoc.Id);
            quoteQuoteDocMap.put(quoteDoc.SBQQ__Quote__c,quoteDoc.Id);
            QuoteDocAccMap.put(quoteDoc.Id,quoteDoc.SBQQ__Opportunity__r.Account.Name);
            
        }
        
        if(quoteDocIds.size() > 0){
            
            List<contentdocumentlink> cdls = [select contentdocumentId,contentdocument.title, contentdocument.lastmodifieddate, LinkedEntityId from contentdocumentlink  where linkedentityid in :quoteDocIds order by contentdocument.lastmodifieddate desc];
            List<contentdocumentlink> oppCdls = [Select contentdocumentId,contentdocument.title, LinkedEntityId from contentdocumentlink  where linkedentityid in :oppIds];
            
            for(contentdocumentlink oppCdl:oppCdls){
                
                if(oppFileTitleMap.containsKey(oppCdl.LinkedEntityId)) {
                    List<String> fileTitles = oppFileTitleMap.get(oppCdl.LinkedEntityId);
                    fileTitles.add(oppCdl.contentdocument.title);
                    oppFileTitleMap.put(oppCdl.LinkedEntityId, fileTitles);
                    
                } 
                
                else {
                    
                    oppFileTitleMap.put(oppCdl.LinkedEntityId, new List<String> {oppCdl.contentdocument.title});
                    
                }
                
                
            }
            
            Map<Id,Id> quoteDocFileMap = new Map<id,Id>();
            Map<Id,Id> docFileQuoteMap = new Map<Id,Id>();
            for(contentdocumentlink cdl : cdls) {
                
                
                if(!quoteDocFileMap.containsKey(cdl.LinkedEntityId)){ 
                    
                    quoteDocFileMap.put(cdl.LinkedEntityId,cdl.contentdocumentId);
                    docFileQuoteMap.put(cdl.contentdocumentId,cdl.LinkedEntityId);
                    
                }
                
                
                
                
            }
            
            
            
            List<ContentVersion> cvs = [Select id,Title,PathOnClient,VersionData,contentdocumentid from ContentVersion where contentdocumentid in:quoteDocFileMap.values()];
            
            for(ContentVersion cv: cvs){
                
                //Insert ContentVersion
                ContentVersion cVersion = new ContentVersion();
                cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
                String QuoteName= cv.title;         
                cVersion.Title = QuoteDocAccMap.get(docFileQuoteMap.get(cv.contentdocumentid))+' - '+QuoteName.removeEnd('_Completed.pdf')+ '.pdf';
                cVersion.PathOnClient = cv.PathOnClient;
                cVersion.versionData = cv.versionData;//File content
                cVersion.QuoteDocId__c = docFileQuoteMap.get(cv.contentdocumentid);
                
                cVersions.add(cVersion); 
                
            }
            
            Insert cVersions;
            
            Map<Id,Id> cvQuoteDocMap = new Map<Id,Id>();
            Map<Id,String> cvQuoteDocTitleMap = new Map<Id,String>();
            Map<Id,Blob> cvQuoteDocDataMap = new Map<id,blob>();
            
            List<contentversion> insCvs = [Select id,ContentdocumentId,versionData,Contentdocument.Title,QuoteDocId__c from ContentVersion where id in:cVersions];
            
            for(contentversion cv: insCvs){
                
                cvQuoteDocMap.put(cv.QuoteDocId__c,cv.ContentdocumentId);
                cvQuoteDocTitleMap.put(cv.QuoteDocId__c,cv.Contentdocument.Title);
                cvQuoteDocDataMap.put(cv.QuoteDocId__c,cv.versiondata);
                
                
            }
            
            
            for(opportunity opp: opps){
                
                
                //create ContentDocumentLink  record 
                ContentDocumentLink conDocLink = New ContentDocumentLink();
                conDocLink.LinkedEntityId = opp.Id; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
                conDocLink.ContentDocumentId = cvQuoteDocMap.get(quoteQuoteDocMap.get(opp.SBQQ__PrimaryQuote__c));
                conDocLink.shareType = 'V';
                oppAttTitleMap.put(opp.Id,cvQuoteDocTitleMap.get(quoteQuoteDocMap.get(opp.SBQQ__PrimaryQuote__c)));
                oppAttMap.put(opp.Id,cvQuoteDocDataMap.get(quoteQuoteDocMap.get(opp.SBQQ__PrimaryQuote__c)));
                
                
                
                
                if(!oppFileTitleMap.containsKey(opp.Id)){
                    
                    
                    conDocLinks.add(conDocLink);
                    
                    Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
                    efa1.setFileName(oppAttTitleMap.get(opp.Id));
                    efa1.setBody(oppAttMap.get(opp.Id));
                    efas.add(efa1);
                    
                    if(oppAttTitleMap.get(opp.Id)!= null && oppAttMap.get(opp.Id)!= null && opp.type=='New Business'){
                        
                        oppMessageMap.get(opp.id).setfileattachments(efas);
                        
                        emailMessages.add(oppMessageMap.get(opp.id));
                        
                        
                    }
                    
                    
                    
                }
                
                if(oppFileTitleMap.containsKey(opp.Id)){
                    
                    if(!oppFileTitleMap.get(opp.Id).contains(cvQuoteDocTitleMap.get(quoteQuoteDocMap.get(opp.SBQQ__PrimaryQuote__c)))){
                        
                        
                        conDocLinks.add(conDocLink);
                        
                        Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
                        efa1.setFileName(oppAttTitleMap.get(opp.Id));
                        efa1.setBody(oppAttMap.get(opp.Id));
                        efas.add(efa1);
                        
                        if(oppAttTitleMap.get(opp.Id)!= null && oppAttMap.get(opp.Id)!= null && opp.type=='New Business'){
                            
                            oppMessageMap.get(opp.id).setfileattachments(efas);
                            
                            emailMessages.add(oppMessageMap.get(opp.id));
                            
                            
                        }
                        
                        
                    }
                    
                }
                
                
                
            }
            
            try{
                
                insert conDocLinks;
                
            }
            
            catch(Exception e){ 
            }
        }
        
        List<contentversion> covs = new List<contentversion>();
        
        for(Opportunity opp : opps){
            String csOppCurrentPMS;
            String csOppQuantity;
            String csOppOtherPMSDetail;
            String oppConFirstName; 
            String oppConLastName; 
            String oppConEmail; 
            String oppConPhone; 
            String oppConTitle;
            
            if(csOppCurrentPMSMap.containsKey(opp.id)){        
                csOppCurrentPMS = string.join(csOppCurrentPMSMap.get(opp.Id),', ');
            }else{
                csOppCurrentPMS = '';
            }
            if(csOppQuantityMap.containsKey(opp.id)){
                csOppQuantity = string.join(csOppQuantityMap.get(opp.id),', ');   
            }else{   
                csOppQuantity = '';
            }
            if(csOppOtherPMSDetailMap.containsKey(opp.id)){   
                csOppOtherPMSDetail = string.join(csOppOtherPMSDetailMap.get(opp.id),', ');
            }else{
                csOppOtherPMSDetail = '';
            }
            if(oppConFirstNameMap.containsKey(opp.AccountId)){
                oppConFirstName = string.join(oppConFirstNameMap.get(opp.AccountId),', ');
            }else{
                oppConFirstName = '';   
            }
            if(oppConLastNameMap.containsKey(opp.AccountId)){
                oppConLastName = string.join(oppConLastNameMap.get(opp.AccountId),', ');
            }else{
                oppConLastName = '';
            }
            if(oppConEmailMap.containsKey(opp.AccountId)){
                oppConEmail = string.join(oppConEmailMap.get(opp.AccountId),', ');
            }else{
                oppConEmail = '';
            }
            if(oppConPhoneMap.containsKey(opp.AccountId)){
                oppConPhone = string.join(oppConPhoneMap.get(opp.AccountId),', ');
            }else{
                oppConPhone = '';
            }
            if(oppConTitleMap.containsKey(opp.AccountId)){
                oppConTitle = string.join(oppConTitleMap.get(opp.AccountId),', ');
            }else{
                oppConTitle ='';
            }
            
            String FORM_HTML_START = '<HTML><head><meta http-equiv=content-type content=text/html; charset="UTF-8"><link rel="stylesheet" href="/sfsites/c/resource/<PDFCSSStyle>"></head><BODY style="font-family: Arial, Helvetica, sans-serif;">';
            String FORM_HTML_END = '</BODY></HTML>';
            String pdfContent = '' + FORM_HTML_START;
            
            String globalPayment;
            
            if(opp.PP_Amount__c > 0){    
                globalPayment = 'True';
            }else{
                globalPayment = 'False';   
            }
            
            String currentImagingSolutionSoftware;
            String accPracticeType;
            string servicesPerformed;
            DateTime quoteStartDate;
            String dateOutput;
            Decimal mrrAmt;
            string otherNotesForOnboarding;
            string accAddress;
            string Payment;
            string Statements;
            string EStatements;
            string VBS;
            Decimal NoOfSensorsSold;
            
            currentImagingSolutionSoftware = opp.Current_Imaging_Solution_Software__c;
            accPracticeType = opp.Account.Practice_Type__c;
            servicesPerformed = opp.Services_Performed__c;
            quoteStartDate = opp.SBQQ__PrimaryQuote__r.SBQQ__StartDate__c;
            dateOutput = quoteStartDate.format('MM-dd-yyyy');
            mrrAmt = opp.MRR_amt__c;
            otherNotesForOnboarding = opp.Other_Notes_for_Onboarding__c;
            Payment=opp.DDS_Payment__c;
            Statements=opp.DDS_Statements__c;
            EStatements=opp.DDS_E_Statement__c;
            VBS=opp.DDS_VBS__c;
            NoOfSensorsSold=opp.How_Many_Sensors_were_Sold__c;
            
            if(Payment == null){
                Payment = '';
            }
            if(Statements == null){ 
                Statements = '';
            }
            if(EStatements == null){
                EStatements = '';
            }
            if(VBS == null){   
                VBS = '';
            }
            if(NoOfSensorsSold == null){
                NoOfSensorsSold=0;
            }
            if(currentImagingSolutionSoftware == null){   
                currentImagingSolutionSoftware = '';
            }
            if(accPracticeType == null){
                accPracticeType = '';
            }
            if(servicesPerformed == null){
                servicesPerformed = '';
            }
            if(otherNotesForOnboarding == null){
                otherNotesForOnboarding = '';
            }
            if(opp.Account.BillingStreet!= null){
                accAddress = opp.Account.BillingStreet + ',';
            }
            if(opp.Account.BillingCity!= null){
                if(accAddress!= null){
                    accAddress = accAddress + opp.Account.BillingCity + ',';
                }
                else{
                    accAddress = opp.Account.BillingCity;
                }
            }
            if(opp.Account.BillingState!= null){
                if(accAddress!= null){
                    accAddress = accAddress + opp.Account.BillingState + ',';
                }
                else{
                    accAddress = opp.Account.BillingState;
                }
            }
            if(opp.Account.BillingPostalCode!= null){
                if(accAddress!= null){
                    accAddress = accAddress + opp.Account.BillingPostalCode + ',';
                }
                else{
                    accAddress = opp.Account.BillingPostalCode;
                }
            }
            if(opp.Account.BillingCountry!= null){
                accAddress = accAddress + opp.Account.BillingCountry;
            }
            if(accAddress!= null){
                accAddress = accAddress.removeEnd(',');
            }
            if(accAddress == null){
                accAddress = '';
            }
            
            pdfContent += '<H2 style=\"margin:30px 0;font-size: 16px;font-weight: bold;margin-bottom: 8px; text-align: center; width:100%;\">Practice Profile_'+opp.Account.Name+'</H2>';
            
            //Added By Ramana on 29-12-2020 for PLAN-666
            String oppaccname=opp.Account.Name.replaceAll('<', '&lt;');
            oppaccname=oppaccname.replaceAll('>', '&gt;');
            String opname=opp.Name.replaceAll('<', '&lt;');
            opname=opname.replaceAll('>', '&gt;');
            otherNotesForOnboarding=otherNotesForOnboarding.replaceAll('<', '&lt;');
            otherNotesForOnboarding=otherNotesForOnboarding.replaceAll('>', '&gt;');
            accAddress=accAddress.replaceAll('<', '&lt;');
            accAddress=accAddress.replaceAll('>', '&gt;');
            //End of Addtion on 29-12-2020
            
            pdfContent = pdfContent + '<br style="height:20px;"/><P size="2">1.   ' + '<STRONG>Practice Name/PGID' + ': </STRONG>' + oppaccname + '</P>';
            pdfContent = pdfContent + '<P><font face="Arial, Helvetica, sans-serif" size="2">2.   ' + '<STRONG>Number of Locations: </STRONG>'+ opname +'</P>';
            pdfContent = pdfContent + '<P SIZE="2">3.   ' + '<STRONG>Current Imaging Solution Software:</STRONG> ' + currentImagingSolutionSoftware + '</P>';
            pdfContent = pdfContent + '<P size="2">4.   ' + '<STRONG>Organization Type (solo/ent/mob/snf):</STRONG> ' + accPracticeType + '</P>';
            pdfContent = pdfContent + '<P size="2">5.   ' + '<STRONG>Services Performed: </STRONG>' + servicesPerformed + '</P>';
            pdfContent = pdfContent + '<P size="2">6.   ' + '<STRONG>Desired Live Date (expectations): </STRONG>' + dateOutput + '</P>';
            pdfContent = pdfContent + '<P size="2">7.   ' + '<STRONG>Billing Address: </STRONG>' + accAddress + '</P>';
            pdfContent = pdfContent + '<P size="2">8.   ' + '<STRONG>Total anticipated MRR (for PGID): </STRONG>'+ mrrAmt + '</P>';
            pdfContent = pdfContent + '<P size="2">9.   ' + '<STRONG>Referred to Global Payment: </STRONG>'+ globalPayment + '</P>';
            pdfContent = pdfContent + '<P size="2">10. ' + '<STRONG>Other Notes for Onboarding: </STRONG>'+ otherNotesForOnboarding + '</P>';
            pdfContent = pdfContent + '<P size="2">11. ' + '<STRONG>Payment: </STRONG>'+ Payment + '</P>';
            pdfContent = pdfContent + '<P size="2">12. ' + '<STRONG>Statements: </STRONG>'+ Statements + '</P>';
            pdfContent = pdfContent + '<P size="2">13. ' + '<STRONG>EStatements: </STRONG>'+ EStatements + '</P>';
           
            pdfContent = pdfContent + '<P size="2">14. ' + '<STRONG># of Sensors: </STRONG>'+ NoOfSensorsSold + '</P>';
            
            //Split and Loop the data
            string[] csOppCurrentPMS1 = csOppCurrentPMS.Split(',');
            string[] csOppQuantity1 = csOppQuantity.Split(',');
            //Added By Ramana on 29-12-2020 for PLAN-666
            csOppOtherPMSDetail=csOppOtherPMSDetail.replaceAll('<', '&lt;');
            csOppOtherPMSDetail=csOppOtherPMSDetail.replaceAll('>', '&gt;');
            //End of Addtion on 29-12-2020
            string[] csOppOtherPMSDetail1 = csOppOtherPMSDetail.Split(',');
            //For Current Software                                    
            pdfContent = pdfContent + '<P size="2">15. <STRONG>Current Software:</STRONG></p><br><table width="100%" cellpadding="3" border="1" cellspacing="0"><thead><tr><td align="center"><STRONG>Current PMS</STRONG></td><td align="center"><STRONG>Quantity</STRONG></td><td align="center"><STRONG>Other PMS Details</STRONG></td></tr></thead><tbody>';
            String pdfSWLoopContent='';
            for(Integer i=0; i<csOppCurrentPMS1.size();i++){
                pdfSWLoopContent +='<tr><td align="center">'+csOppCurrentPMS1[i].trim()+'</td><td align="center">'+csOppQuantity1[i].trim()+'</td><td align="center">'+csOppOtherPMSDetail1[i].trim()+'</td></tr>';
            }
            pdfContent += pdfSWLoopContent+'</tbody></table>';
            //For Related Contacts
            
            //Added By Ramana on 29-12-2020 for PLAN-666
            oppConFirstName=oppConFirstName.replaceAll('<', '&lt;');
            oppConFirstName=oppConFirstName.replaceAll('>', '&gt;');
            oppConLastName=oppConLastName.replaceAll('<', '&lt;');
            oppConLastName=oppConLastName.replaceAll('>', '&gt;');
            csOppOtherPMSDetail=oppConTitle.replaceAll('<', '&lt;');
            csOppOtherPMSDetail=oppConTitle.replaceAll('>', '&gt;');
            //End of Addtion on 29-12-2020
            
            string[] oppConFirstName1 = oppConFirstName.Split(',');
            string[] oppConLastName1 = oppConLastName.Split(',');
            string[] oppConEmail1 = oppConEmail.Split(',');
            string[] oppConPhone1 = oppConPhone.Split(',');
            string[] oppConTitle1 = oppConTitle.Split(',');    
            
            pdfContent = pdfContent + '<br/><P size="2"><STRONG>16.  Related contacts:</STRONG></p><br><table width="100%" cellpadding="3" border="1" cellspacing="0"><thead><tr><td align="center"><STRONG>First Name</STRONG></td><td align="center"><STRONG>Last Name</STRONG></td><td align="center"><STRONG>Email</STRONG></td><td align="center"><STRONG>Phone</STRONG></td><td align="center"><STRONG>Title</STRONG></td></tr></thead><tbody>';
            String pdfRCLoopContent='';
            for(Integer i=0; i<oppConLastName1.size();i++){
                // Fetch Original(before removing Comma) FirstName ,LastName ,Phone,Title  
                String oppConFirstNameOriginal=commaFirstNameMap.get(oppConFirstName1[i].trim()+i);
                String oppConLastNameOriginal =commaLastNameMap.get(oppConLastName1[i].trim()+i);
                String oppConPhoneOriginal=commaPhoneMap.get(oppConPhone1[i].trim()+i);
                String oppConTitleOriginal=commaTitleMap.get(oppConTitle1[i].trim()+i);
                if(oppConFirstNameOriginal==NULL){
                    oppConFirstNameOriginal='';
                }
                if(oppConPhoneOriginal==NULL){
                    oppConPhoneOriginal='';
                }
                if(oppConTitleOriginal==NULL){
                    oppConTitleOriginal='';
                }
                pdfRCLoopContent +='<tr><td align="center">'+oppConFirstNameOriginal+'</td><td align="center">'+oppConLastNameOriginal+'</td><td align="center">'+oppConEmail1[i].trim()+'</td><td align="center">'+oppConPhoneOriginal+'</td><td align="center">'+oppConTitleOriginal+'</td></tr>';
            }
            pdfContent += pdfRCLoopContent+'</tbody></table>';
            //pdfContent +='Size-'+oppConFirstName1.size();
            //pdfContent +='PMS Size-'+csOppCurrentPMS1.size()+' qty-'+csOppQuantity1.size()+' PMSde -'+csOppOtherPMSDetail1.size();
            //pdfContent = pdfContent + '<P>' + 'Current Software' + ': '+ '<ul>'+'<li>'+'Current PMS'+ ': ' +csOppCurrentPMS+'</li>'+'<li>'+'Quantity'+ ': ' + csOppQuantity+'</li>'+'<li>'+'Other PMS Detail'+ ': '+ csOppOtherPMSDetail + '</li>' + '</ul>'+ '</P>';
            //pdfContent = pdfContent + '<P>' + 'Related contacts: '+ '<ul>'+'<li>'+'First Name'+ ': ' +oppConFirstName+'</li>'+'<li>'+'Last Name'+ ': ' + oppConLastName+'</li>'+'<li>'+'Email'+ ': '+ oppConEmail + '</li>' + '<li>'+'Phone'+': '+oppConPhone+'</li>'+'<li>'+'Title'+': '+oppConTitle+'</li>'+'</ul>'+ '</P>';
            
            
            pdfContent = pdfContent + FORM_HTML_END;
            
            //PageReference pdf = Page.TestPDF;
            
            ContentVersion cov = new ContentVersion();
            cov.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
            cov.Title = opp.Account.Name+' - '+'Practice Profile' + '.pdf';//Name of the file
            cov.PathOnClient = 'TestFile.pdf';
            cov.versionData = Blob.toPdf(pdfContent);
            //cov.versionData = pdf.getContent();
            cov.OppId__c = opp.Id;
            practiceProfileFileMap.put(opp.Id,cov.versionData);
            covs.add(cov);
            
        }
        
        insert covs;
        
        List<ContentVersion> convs = [Select id,OppId__c,contentdocumentid,contentdocument.title from contentversion where id in:covs];
        List<ContentdocumentLink> cDocLinks = new List<ContentdocumentLink>();
        Map<Id,Id> codOppMap = new Map<Id,Id>();
        Map<Id,String> codTitleOppMap = new Map<Id,String>();
        
        for(ContentVersion conv: convs){
            codOppMap.put(conv.OppId__c,conv.contentdocumentid);
            codTitleOppMap.put(conv.OppId__c,conv.contentdocument.title);
        }
        
        for(opportunity opp: opps){
            contentDocumentLink cDocLink = New ContentDocumentLink();
            cDocLink.LinkedEntityId = opp.Id;
            cDocLink.ContentDocumentId = codOppMap.get(opp.id);
            cDocLink.shareType = 'V';
            
            if(!oppFileTitleMap.containsKey(opp.Id)){
                
                
                cDocLinks.add(cDocLink);
                
                
                Messaging.EmailFileAttachment efa2 = new Messaging.EmailFileAttachment();
                efa2.setFileName(codTitleOppMap.get(opp.Id));
                efa2.setBody(practiceProfileFileMap.get(opp.Id));
                efas.add(efa2);
                
                if(codTitleOppMap.get(opp.Id)!= null && practiceProfileFileMap.get(opp.Id)!= null){
                    oppMessageMap.get(opp.id).setfileattachments(efas);
                    if(emailMessages.size() == 0){
                        emailMessages.add(oppMessageMap.get(opp.id));
                    }   
                }
            }
            
            if(oppFileTitleMap.containsKey(opp.Id)){
                
                if(!oppFileTitleMap.get(opp.Id).contains(codTitleOppMap.get(opp.id))){
                    cDocLinks.add(cDocLink);
                    Messaging.EmailFileAttachment efa2 = new Messaging.EmailFileAttachment();
                    efa2.setFileName(codTitleOppMap.get(opp.Id));
                    efa2.setBody(practiceProfileFileMap.get(opp.Id));
                    efas.add(efa2);
                    
                    if(codTitleOppMap.get(opp.Id)!= null && practiceProfileFileMap.get(opp.Id)!= null){
                        oppMessageMap.get(opp.id).setfileattachments(efas);
                        if(emailMessages.size() == 0 ){
                            emailMessages.add(oppMessageMap.get(opp.id));
                        }
                    }
                }
            }
        }
        
        try{
            insert cDocLinks;
            
        }catch(Exception e){
            
        }
        if(emailMessages.size() > 0){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailMessages);    
            if (results[0].success) {
                System.debug('The email was sent successfully.');
                
            } else {
                
                //System.debug('The email failed to send: ' + results[0].errors[0].emailMessages);
                
            }
            
        }
      
    }
    
}