global class updateAccountContractEndDateBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        string contractStatusStr = 'Activated';
        string qryStr ='SELECT id, DirectContractEndDate__c,ia_crm__Intacct_Sync_Status__c,ia_crm__IntacctID__c,GUP_ID__c,Global_Id__c,(SELECT id, Status,startDate, EndDate FROM contracts  WHERE Status=:contractStatusStr) FROM Account';
        return database.getQueryLocator(qryStr);
    }
    global void execute(Database.batchablecontext bc, list<Account> scope){
        map<Id, Date> accountIDdcedateMap = new Map<Id, Date>();
        for(Account acc: scope){
            if(acc.Contracts.size()>0){
                set<Date> contractEndDateSet = new set<Date>();
                set<Date> cnctEndDateSet = new set<Date>();
                for(contract cncnt: acc.Contracts){
                    if(cncnt.StartDate<= system.today()){
                        if(cncnt.EndDate>= system.today())
                            contractEndDateSet.add(cncnt.EndDate);
                        else 
                            cnctEndDateSet.add(cncnt.EndDate);
                    }
                }
                if(contractEndDateSet.size()>0){
                    List<Date> contractEndDateList = new List<Date>();
                    contractEndDateList.addAll(contractEndDateSet);
                    contractEndDateList.sort();
                    integer farthestContractIndex;
                    farthestContractIndex = contractEndDateList.size()-1;
                    accountIDdcedateMap.put(acc.Id, contractEndDateList.get(farthestContractIndex));
                }
                else if(cnctEndDateSet.size()>0){
                    List<Date> cnctEndDateList = new List<Date>();
                    cnctEndDateList.addAll(cnctEndDateSet);
                    cnctEndDateList.sort();
                    integer farthestCnctIndex;
                    farthestCnctIndex = cnctEndDateList.size()-1;
                    accountIDdcedateMap.put(acc.Id, cnctEndDateList.get(farthestCnctIndex));
                }
            }
        }
        for(Account accRec: scope){
            accRec.DirectContractEndDate__c = (accountIDdcedateMap.containsKey(accRec.id) && accountIDdcedateMap.get(accRec.id)!=null)?accountIDdcedateMap.get(accRec.id):null;
            if(accRec.ia_crm__Intacct_Sync_Status__c=='' || accRec.ia_crm__Intacct_Sync_Status__c==null)
                accRec.ia_crm__IntacctID__c= accRec.GUP_ID__c+'-'+accRec.Global_Id__c;
        }
        try{
            update scope;
        }
        catch(exception ex){
            system.debug('error is '+ex.getMessage());
        }
    }
    global void finish (Database.batchablecontext bc){}
}