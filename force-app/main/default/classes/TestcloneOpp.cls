// ---> Test class For the Trigger 'cloneOpp' which Checks For cloning any opportunity, Opportunity Name is unique and stage is other than Closed won and Closed Lost and 'Clone to Record type' is not Null while Clonning Opportunity From Booking to Billing,Opportunity Should not be Contracted While Cloning

//---->Author: Ramana Gumma  

//---->Date : 30/03/2020
@isTest
public class TestcloneOpp {
    @isTest
    public Static void cloneTest(){
        
        BillingOppsAutomation__c bcs = new BillingOppsAutomation__c();
        bcs.name='Automation';
        bcs.IsActive__c=true;
        Insert bcs;
        //----------> Opportunity Test Data Creation
        list<Opportunity> oplist = new list<Opportunity>();
        list<Opportunity> CloneList = new list<Opportunity>();
        list<Opportunity> CloneList2 = new list<Opportunity>();
        integer i=0;
        for(i=1;i<=10;i++){
            Opportunity op = new Opportunity();
            if(i<=5){         
                op.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Booking').getRecordTypeId();
                op.name='Test'+i;
                op.StageName='Closed Won';
                op.CloseDate=system.today();
                op.On_boarding_Type__c='Fixed Cost';
                op.SBQQ__Contracted__c=True;
                op.DDS_Proposal_Notes__c='Test Notes';
                op.Type='Existing Business';
                op.PO_Number__c = 'RYTYSYS';
                op.Sales_Qualified_Appointment__c=true;
            }
            else{
                op.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
                op.name='Test'+i;
                op.StageName='Closed Lost';
                op.CloseDate=system.today();
                op.On_boarding_Type__c='Fixed Cost';
                op.SBQQ__Contracted__c=True;
                op.Type='Existing Business';
                op.Stage__c='Competitor';
                op.Competitor__c='Ace';
                op.Sales_Qualified_Appointment__c=true;
                op.PO_Number__c = 'RYTYSYS';
            }
            oplist.add(op);
        }
        test.startTest();
        //----> Opportunity Insertion
        insert oplist;
        //----> Clonning the Opportunities
        for(opportunity op2 : oplist){
            system.debug('ID-->'+op2.Opportunity_Id__c);
            cloneList.add(op2.clone());
        }
        List<Database.Error> errorResults=new List<Database.Error>();
        Database.SaveResult[] result = Database.insert(cloneList, false);
        //--->Capturing the Errors
        for(database.SaveResult d:result){
            
            errorResults.Addall(d.getErrors());
        }
        //------> Assertion Validation for the Errors
        System.assertEquals('Opportunity name should be Unique', (String)errorResults[0].getMessage());
        System.assertEquals('Stage should not be Closed-Won or Closed- Lost or Closed Won - Under Trial while Cloning', (String)errorResults[1].getMessage());
        System.assertEquals('For cloning please select record type', (String)errorResults[2].getMessage());
        System.assertEquals('Opportunity Cannot be Contracted While Cloning', (String)errorResults[3].getMessage());
        
        
        for(opportunity op3 : oplist){
            system.debug('ID-->'+op3.Opportunity_Id__c);
            Opportunity o = op3.clone();
            o.Opportunity_Id__c = op3.Id;
            o.Name = op3.Name+'Billing';
            o.StageName = 'Investigating';
            o.New_Record_Type__c = 'Billing';
            o.SBQQ__Contracted__c=false;
            o.ia_crm__Change_Type__c = 'New MRR';
            o.Competitor__c = null;
            o.Stage__c = null;
            o.Reseller_Opp__c = True;
            cloneList2.add(o);
        }
        Insert cloneList2;
        test.stopTest();
    }
}