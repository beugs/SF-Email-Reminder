/**
 * Email services are automated processes that use Apex classes
 * to process the contents, headers, and attachments of inbound
 * email.
 */
global class AppointementReminderEmail
{
	Datetime meeting_date;
	Id to_email_id;
	Id currentEventID;
	static final String contact_prefix_id = '003'; // SF prefix for contacts
	static final String lead_prefix_id    = '00Q'; // SF prefix for leads
	public AppointementReminderEmail(Datetime  rdvDate , Id receiversId, Id currentEventID)
	{
		 this.meeting_date = rdvDate;
         this.to_email_id = receiversId;
         this.currentEventID = currentEventID;
	}

 	public void sendEmailReminder()
 	{
		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		String receiversId_string = String.valueOf(this.to_email_id);
		String recipientEmail = '';

		if(String.isBlank(receiversId_string))
		{
			System.debug('No Recipient email found to notify for meeting occurring ' + meeting_date);
			return;
		}

		User contactOwner;
		/*if it start with 003 then it's a contact*/
		if(receiversId_string.startsWith(contact_prefix_id))
		{
			List<Contact> contacts = [ Select  Id, Name, Email, OwnerId from Contact where Id = :this.to_email_id];
			List<User> contactOwners = [ Select  Id, Name from User where Id = :contacts[0].OwnerId ];
			if(contactOwners == null || contactOwners.size()!=1)// got a problem
			{
				System.debug('No or more than 1 contactOwner found for ' + contacts[0].Email + '. Looking for OwnerID: ' + contacts[0].OwnerId + '. Contact owners length found: ' + contactOwners!=null ? ('' + contactOwners.size()) : 'null');
				return;
			}
			contactOwner = contactOwners[0];
			//message.setTargetObjectId(contacts[0].Id);
			recipientEmail = contacts[0].Email;
		}
		/*if it start with 00Q then it a lead */
		else if(receiversId_string.startsWith(lead_prefix_id))
		{
			List<Lead> leads = [ Select  Id, Name, Email, OwnerId from Lead where id = :this.to_email_id];
			List<User> contactOwners = [ Select  Id, Name from User where Id = :leads[0].OwnerId];
			contactOwner = contactOwners[0];
			recipientEmail = leads[0].Email;
		}
		else
		{
			System.debug('Unknown recipient type ' + receiversId_string);
			return;
		}
		List<Event> events = [ Select  Id, description, Subject from Event where Id = :this.currentEventID];
		String subject= !String.isBlank(events[0].Subject) ? '\n\n' + events[0].Subject + '\n\n' : '';
		String details = !String.isBlank(events[0].description) ? '\n\n' + events[0].description + '\n\n' : '';
		message.ToAddresses = new String[]{recipientEmail};
		message.optOutPolicy = 'FILTER'; // ?
		message.setSubject(subject)	;
		OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress];
		if ( owea.size() > 0 )
		{
		    message.setOrgWideEmailAddressId(owea.get(0).Id);
		}
		message.setPlainTextBody('   Hello, \n\n you have a meeting on + this.meeting_date.format('HH:mm')  + ' with Mr : ' + contactOwner.Name);
		message.setUseSignature(true);
		Messaging.SingleEmailMessage[] messages =  new List<Messaging.SingleEmailMessage> {message};
		Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
		if (results[0].success)
		{
    		System.debug('The email was sent successfully.');
		}
		else
		{
    		System.debug('The email failed to send: ' + results[0].errors[0].message);
		}
 	}
}
