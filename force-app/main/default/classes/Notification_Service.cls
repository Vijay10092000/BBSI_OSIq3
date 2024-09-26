/**
 * @description Notification_Service is a wrapper class for the CustomNotification object.  It builds a list
 * of notifications before sending them.  Also allows sending of a single notification.
 *
 * See:
 * https://developer.salesforce.com/docs/atlas.en-us.230.0.apexcode.meta/apexcode/apex_class_Messaging_CustomNotification.htm
 */
public without sharing class Notification_Service {
	@TestVisible
	private static Boolean testException = false;

	// Holds all the types so only one SOQL call is made to retrieve them
	@TestVisible
	private static List<CustomNotificationType> types = null;

	// Holds notifications waiting to be sent
	@TestVisible
	private List<CustomNotificationItem> items = new List<CustomNotificationItem>();

	// Holds group user ids so does not call multiple times for same group.
	@TestVisible
	private static Map<Id, List<Id>> groupUsers = new Map<Id, List<Id>>();

	/**
	 * @description CustomNotificationAction holds information about a notification
	 * and sends them.
	 */
	@TestVisible
    @SuppressWarnings('PMD.ApexDoc')
    private class CustomNotificationItem {
		public Id typeId { get; set; }
		public List<Id> recipientIds { get; set; }
		public String title { get; set; }
		public String body { get; set; }
		public Id targetId { get; set; }
		public String pageReference { get; set; }

		/**
		 * @description CustomNotificationItem constructor.
		 * @param  idType        Identifier of the Custom Notification to send
		 * @param  recipientIds  Who receives the Notification
		 * @param  title         Title of notification
		 * @param  body          Message of notification
		 * @param  targetId      Related Record Id
    	 * @param  pageRef       Navigation target of the notification
		 */
		@SuppressWarnings('PMD.ExcessiveParameterList')
		public CustomNotificationItem(
			Id idType,
			List<Id> recipientIds,
			String title,
			String body,
			Id idTarget,
			String pageRef
		) {
			this.typeId = idType;
			this.recipientIds = recipientIds;
			this.title = title;
			this.body = body;
			this.targetId = idTarget;
			this.pageReference = pageRef;
		}

		/**
		 * @description removeInactive remove from the recipients the inactive users.
		 * @param  users  All users receiving notifictions
		 */
		public void removeInactive(Map<Id, User> users) {
			Log logInactive = new Log();
			User user;

			for (Integer index = recipientIds.size() - 1; 0 <= index; --index) {
				user = users.get(recipientIds.get(index));

				if (user == null) {
					recipientIds.remove(index);
					logInactive.addLine('NULL user was given');
				} else if (!user.IsActive) {
					logInactive.addLine('Inactive User: ' + user.Id + ' ' + user.Name);
					recipientIds.remove(index);
				}
			}

			if (logInactive.hasDescription()) {
				logInactive.description = 'NOTIFICATION: ' + this + '\n\n' + logInactive.description;
				logInactive.write(Log.Severity.WARN, 'Notification Service', 'Notification Service does not send to inactive users');
			}
		}

		/**
		 * @description send builds and sends the notification.
		 */
		public void send() {
			if (!recipientIds.isEmpty()) {
				Messaging.CustomNotification notification = new Messaging.CustomNotification();

				try {
					notification.setNotificationTypeId(typeId);
					notification.setTitle(title);
					notification.setBody(body);
					notification.setTargetId(targetId);
					notification.setTargetPageRef(pageReference);

					Set<String> toIds = new Set<String>();
					for (Id id : recipientIds) {
						toIds.add(String.valueOf(id));
					}

					if (Test.isRunningTest()) {
						if (Notification_Service.testException) {
							throw new IllegalArgumentException('TEST EXCEPTION');
						}
					} else {
						if (toIds == null || toIds.isEmpty())
						{
							Log.info('Notification Service', 'No users to send to', 'NOTIFICATION: ' + notification);
						}
						else
						{
							notification.send(toIds);
						}
					}
				} catch (Exception e) {
					Log.error('Notification Service', 'Failed to send Notification', 'NOTIFICATION: ' + notification, e);
				}
			}
		}
	}

	/**
	 * @description getCustomNotificationId returns the CustomNotificationType for the given
	 * Custom Notification name.  It retrieves all Custom Notifications
	 * and stores them for a later call.
	 * @param  name  Name of the Custom Notification
	 * @return The CustomNotificationType's Id or null if not found
	 */
	public static Id getCustomNotificationId(String name) {
		if (types == null) {
			types = new List<CustomNotificationType>(
				[SELECT Id, MasterLabel, CustomNotifTypeName, Description, DeveloperName FROM CustomNotificationType]
			);
		}

		for (CustomNotificationType cnt : types) {
			if (cnt.MasterLabel == name || cnt.CustomNotifTypeName == name || cnt.DeveloperName == name) {
				return cnt.Id;
			}
		}

		return null;
	}

    /**
     * @description notify sends a notification with target record.
     * @param  idType        Identifier of the Custom Notification to send
     * @param  recipientIds  Who receives the Notification
     * @param  title         Title of notification
     * @param  body          Message of notification
     * @param  targetId      Related Record Id
     */
	public static void notify(
		Id idType,
		List<Id> recipientIds,
		String title,
		String body,
		Id targetId
	) {
		Notification_Service service = new Notification_Service();

		service.addItem(idType, recipientIds, title, body, targetId, null);

		service.sendNotifications();
	}

    /**
     * @description notify sends a Notification with target page reference.
     * @param  idType        Identifier of the Custom Notification to send
     * @param  recipientIds  Who receives the Notification
     * @param  title         Title
     * @param  body          Body
     * @param  pageRef       Navigation target of the notification
     */
	public static void notify(
		Id idType,
		List<Id> recipientIds,
		String title,
		String body,
		String pageRef
	) {
		Notification_Service service = new Notification_Service();

		service.addItem(idType, recipientIds, title, body, null, pageRef);

		service.sendNotifications();
	}

	/**
	 * @description addNotify adds a notification to the current list.
	 * @param  name      Name of the Custom Notification
	 * @param  idUsers   Users to receive the notification
	 * @param  title     Title of the Notification
	 * @param  body      Breif description
	 * @param  idTarget  related object to notification
	 */
	public void addNotify(String name, List<Id> idUsers, String title, String body, Id idTarget) {
		addItem(getCustomNotificationId(name), idUsers, title, body, idTarget, null);
	}

	/**
	 * @description addNotify adds a notification to the current list.
	 * @param  name     Name of the Custom Notification
	 * @param  idUsers  Users to receive the notification
	 * @param  title    Title of the Notification
	 * @param  body     Breif description
	 * @param  pageRef
	 */
	public void addNotify(String name, List<Id> idUsers, String title, String body, String pageRef) {
		addItem(getCustomNotificationId(name), idUsers, title, body, null, pageRef);
	}

    /**
     * @description sendNotifications sends the current list of notifications.
     */
    public void sendNotifications() {
		Map<Id, User> users = getUsers();

		for (customNotificationItem item : items) {
			try {
				item.removeInactive(users);
				item.send();
			} catch (Exception e) {
				Log.error(
					'Notification Service',
					'Notification Failure',
					'Notification_Service.sendNotifications()\nUsers:\n' + users.toString() + '\n\nitems:\n' + items.toString(),
					e
				);
			}
		}
	}

	/**
	 * @description addItem adds a notification to the current list.
	 * @param  idType    Identifier of the Custom Notification
	 * @param  idUsers   Users to receive the notification
	 * @param  title     Title of the Notification
	 * @param  body      Breif description
	 * @param  idTarget  related object to notification
	 * @param  pageRef   related object to notification
	 */
	@TestVisible
	@SuppressWarnings('PMD.ExcessiveParameterList')
	private void addItem(Id idType, List<Id> idUsers, String title, String body, Id idTarget, String pageRef) {
		if (idType == null || idUsers == null || (idTarget == null && pageRef == null)) {
			Log.error(
				'Notification_Service',
				'addItem: Invalid null value in parameters',
				'Parameters:' +
				'\nidType: ' + idType +
				'\nidUsers = ' + idUsers +
				'\nidTarget = ' + idTarget +
				'\npageRef = ' + pageRef +
				'\ntitle = ' + title +
				'\body = ' + body
			);
			throw new IllegalArgumentException('Invalid null value in parameters');
		}

		items.add(
			new CustomNotificationItem(idType, fixUserIds(idUsers), title, body, idTarget, pageRef)
		);
	}

	/**
	 * @description getUsers retrieves users receiving notifications and their active state.
	 * @return Map<Id, Users>
	 */
	@TestVisible
	private Map<Id, User> getUsers() {
		Set<Id> idUsers = new Set<Id>();

		for (CustomNotificationItem item : items) {
			idUsers.addAll(item.recipientIds);
		}

		return new Map<Id, User>([SELECT Id, Name, IsActive FROM User WHERE Id IN :idUsers]);
	}
	
	/**
	 * @description fixUserIds finds any groups and changes them to the user members.
	 * @param  idUsers  List of Users and Groups
	 * @return List<Id>
	 */
	@TestVisible
	private List<Id> fixUserIds(List<Id> idUsers) {
		Set<Id> result = new Set<Id>();

		String prefixGroup = Sobject_Services.getIdPrefix('Group');

		for (Id id : idUsers) {
			if (String.valueOf(id).startsWith(prefixGroup)) {
				if (!groupUsers.containsKey(id)) {
					groupUsers.put(id, new List<Id>(Group_Service.getUserIdsInGroups(new Set<Id>{ id }, true)));
				}

				result.addAll(groupUsers.get(id));
			} else {
				result.add(id);
			}
		}

		return new List<Id>(result);
	}
}