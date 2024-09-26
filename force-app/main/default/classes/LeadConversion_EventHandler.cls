/**
 * @description LeadConversion_EventHandler performs actions for the Platform Event: Lead_Conversion__e.
 */
public without sharing class LeadConversion_EventHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {
	/**
	 * @description afterInsert performs actions on related objects to the mapNew sObjects after
	 * the insert.
	 * @param  mapNew is the map of sObjects after being saved
	 */
	override public void afterInsert(Map<Id, SObject> mapNew) {
		List<Lead_Conversion__e> events = (List<Lead_Conversion__e>) mapNew.values();

		(new HandleEvents(events)).perform();
	}

	/**
	 * @description HandleEvents handles the Lead Conversion Platform Events.
	 */
	private class HandleEvents {
		private Map<Id, Lead> leads;
		private Map<Id, Id> accountToLead = new Map<Id, Id>();
		private Map<Id, Id> contactToLead = new Map<Id, Id>();
		private Map<Id, Id> opportunityToLead = new Map<Id, Id>();

		public HandleEvents(List<Lead_Conversion__e> events) {
			List<Id> idLeads = new List<Id>();

			for (Lead_Conversion__e event : events) {
				idLeads.add(event.LeadId__c);
			}

			leads = getLeads(idLeads);

			for (Lead lead : leads.values()) {
				accountToLead.put(lead.ConvertedAccountId, lead.Id);
				contactToLead.put(lead.ConvertedContactId, lead.Id);
				opportunityToLead.put(lead.ConvertedOpportunityId, lead.Id);
			}
		}

		public void perform() {
			moveAttachments();
			moveNotes();
			moveEventsToAccount();
			moveTasksToAccount();
			updateOpportunity();
		}

		/**
		 * @description getLeads retrieves the converted Leads from the given.
		 * @param  mapOld  Map of Leads before the changes
		 * @param  mapNew  Map of Leads with changes
		 * @return Map<Id, Lead>
		 */
		private Map<Id, Lead> getLeads(List<Id> idLeads) {
			return new Map<Id, Lead>(
				[
					SELECT Id, Name, IsConverted, ConvertedAccountId, ConvertedContactId, ConvertedOpportunityId
					FROM Lead
					WHERE Id IN :idLeads
				]
			);
		}

		/**
		 * @description moveEventsToAccount
		 */
		private void moveEventsToAccount() {
			List<Event> updateEvents = new List<Event>();

			List<Event> events = Contact_Services.getContactEvents(contactToLead.keySet());

			for (Event e : events) {
				if (contactToLead.keySet().contains(e.WhoId)) {
					Lead l = leads.get(contactToLead.get(e.WhoId));

					e.WhatId = l.ConvertedAccountId;

					updateEvents.add(e);
				}
			}

			update updateEvents;
		}

		/**
		 * @description moveTasksToAccount
		 */
		private void moveTasksToAccount() {
			List<Task> updateTasks = new List<Task>();

			List<Task> tasks = Contact_Services.getContactTasks(contactToLead.keySet());

			for (Task t : tasks) {
				if (contactToLead.containsKey(t.WhoId)) {
					Lead l = leads.get(contactToLead.get(t.WhoId));

					t.WhatId = l.ConvertedAccountId;

					updateTasks.add(t);
				}
			}

			update updateTasks;
		}

		/**
		 * @description moveAttachments moves Attachments from converted Contact to converted Opportunity.
		 */
		private void moveAttachments() {
			List<Attachment> movedAttachments = new List<Attachment>();
			List<Attachment> deleteAttachments = new List<Attachment>();

			List<Attachment> attachments = Contact_Services.getContactAttachments(contactToLead.keySet());

			for (Attachment attachment : attachments) {
				Id idContact = attachment.ParentId;

				Id idLead = contactToLead.get(idContact);

				Id idOpportunity = leads.get(idLead).ConvertedOpportunityId;

				Attachment newAttach = attachment.Clone();
				newAttach.ParentId = idOpportunity;
				movedAttachments.add(newAttach);
				deleteAttachments.add(attachment);
			}

			if (!movedAttachments.isEmpty()) {
				insert movedAttachments;
				delete deleteAttachments;
			}
		}

		/**
		 * @description moveNotes moves Notes from converted Contact to converted Account.
		 */
		private void moveNotes() {
			List<Note> movedNotes = new List<Note>();
			List<Note> deleteNotes = new List<Note>();

			List<Note> notes = Contact_Services.getContactNotes(contactToLead.keySet());

			for (Note note : notes) {
				Id idContact = note.ParentId;

				Id idLead = contactToLead.get(IdContact);

				Id idOpportunity = leads.get(idLead).ConvertedOpportunityId;

				Note newNote = note.Clone();
				newNote.ParentId = idOpportunity;
				movedNotes.add(newNote);
				deleteNotes.add(note);
			}

			if (!movedNotes.isEmpty()) {
				insert movedNotes;
				delete deleteNotes;
			}
		}

		private void updateOpportunity() {
			List<Opportunity> opps = [SELECT Id, CloseDate FROM Opportunity WHERE Id IN :opportunityToLead.keySet()];

			Date closeDate = OpportunityClient.getCloseDate();

			for (Opportunity opp : opps) {
				opp.CloseDate = closeDate;
			}
		}
	}
}