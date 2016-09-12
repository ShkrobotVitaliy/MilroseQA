global class CreateBatchForPartnerReportsMonth implements Schedulable{

    global void execute(SchedulableContext sc) {
        CreateBatchForPartnerReportsMonth job = new CreateBatchForPartnerReportsMonth();
        job.execute();
    }

    //Execute method
    global void execute() {
    	Database.executeBatch( new CreateBatchFullRecalculation(), 2000 );
		Database.executeBatch( new CreateBatch1FullRecalculation(), 2000 );
		Database.executeBatch( new CreateBatch2FullRecalculation(), 2000 );
    }
}