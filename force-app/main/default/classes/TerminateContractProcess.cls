// ---> Class 'TerminateContractProcess' which will invoked by Terminate_Contract component

//---->Author: Ramana 

//---->Date : 06/22/2020
public class TerminateContractProcess {
    @AuraEnabled
    public Static String Invoke(String recordId){
        
        String returnErrorMessage;
        try
        {
            Contract con =[Select Is_Terminated_Contract__c,Contract_Termination_Reason__c from Contract where id=:recordId];
            con.Is_Terminated_Contract__c=true;
            //	con.Contract_Termination_Reason__c  = terminationReason;
            update con;
            
            Approval.ProcessSubmitRequest  req =new Approval.ProcessSubmitRequest();
        	req.setObjectId(recordId);
        	req.setProcessDefinitionNameOrId('Contract_Approval_For_Termination');
        	Approval.ProcessResult result =Approval.process(req); 
            
            returnErrorMessage = 'Success';
        }
        catch(Exception error){
            
            returnErrorMessage = error.getMessage();
            system.debug('Error ---> '+returnErrorMessage);
        }
        
        return returnErrorMessage;
    }

}