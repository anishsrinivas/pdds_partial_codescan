/*
 Description : This  class is Scheduled to run on 1st of Every Month at 12.00 AM PST which will Invoke
               the Batch Class 'BatchUpdateContractStatusExpired'.Since there may have Chances of Hitting
               'Two many SOQL Queries' Issue Due to to 'ContractAfter' CPQ Managed package trigger on Contract object,
               Batch size is given as 5 instead of Higher Batch Size.
               
               
 Author      : Ramana 

 Created Date: 07/30/2020
*/
public class ScheduleBatchupdateContractStatusExpired implements Schedulable{
    public void execute(SchedulableContext sc){
        
      database.executeBatch(new BatchUpdateContractStatusExpired(new List<String>()),5);
        
    }

}