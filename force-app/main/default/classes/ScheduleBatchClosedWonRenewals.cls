/*
 Description : This Schedule class is Scheduled to run on Last Day of Every Month at 11.30 PM PST and runs the Batch
              'BatchClosedWonRenewals' to Close Win Open Renewal Opportunities.Since there may be 'Too Many SOQL Queries'Issue 
               due to 'OpportunityAfter' CPQ Managed package trigger on Opportunity object,Batch size is given as 5 instead of Higher
               Batch Size.

 Author      : Ramana 

 Created Date: 08/17/2020
*/
public class ScheduleBatchClosedWonRenewals implements Schedulable{
    public void execute(SchedulableContext sc){
        
        database.executeBatch(new BatchClosedWonRenewals(new List<String>()),5);
        
    }

}