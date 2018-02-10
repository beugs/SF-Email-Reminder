/**
 * Email services are automated processes that use Apex classes
 * to process the contents, headers, and attachments of inbound
 * email.
 */
global class Schedule_RDV_email implements Schedulable{

	Datetime  meeting_date = null;
	Id to_email_id = null;
	Id currentEvent = null;
	String description = '';

	public Schedule_RDV_email(Datetime date_envoi,Id receivers_email, Id eventID){
		this.meeting_date = date_envoi;
   	    this.to_email_id = receivers_email;
   	    this.currentEvent = eventID;
	}

    global void sendEmail()
    {
   	    /* setting params in constructer to help use them later in the execute function as it is async */
	    Schedule_RDV_email scheduled_instance = new Schedule_RDV_email(this.meeting_date,this.to_email_id, this.currentEvent );
	    /*
	     * all created scheduled jobs will be found in setup => Monitor = > job = > scheduled Job
	     * schedule(jobName, cronExpression, schedulableClass)
	     * Job name should be unique
	     * this one to be used later when we program the mail to be sent one hours or more before the due date
	     *
	    */
		Integer intDelay = 6;



   		System.debug('Scheduling email to be sent ' + (intDelay == 0 ? 'immediately.' : intDelay + ' hour(s) prior to the appointment.') );
	    Datetime sendingDate = this.meeting_date.addHours(intDelay);
	    system.schedule( this.currentEvent , GetCRONExpression(sendingDate), scheduled_instance);
    }

    global void execute(SchedulableContext sc)
    {
   		AppointementReminderEmail appReminder = new AppointementReminderEmail(this.meeting_date, this.to_email_id, this.currentEvent );
	    appReminder.sendEmailReminder();
    }

   //extract CRON format from DateTime field type
   public static String GetCRONExpression(Datetime dt)
   {
    	return ('' + dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year());
   }
}
