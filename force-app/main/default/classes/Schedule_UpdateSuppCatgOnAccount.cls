public class Schedule_UpdateSuppCatgOnAccount implements Schedulable{
    
    public void execute(SchedulableContext sc){
        
        database.executeBatch(new UpdateSupportCategoriesOnAccountBatch());
        
    }

}