public without sharing class FlowLogDebug {
	/**
	 * @description log writes to the debug log at the given level
	 * @param  messages  Messages to write
	 */ 
	@InvocableMethod(label='Log Debug Message' description='Outputs System log messages at LoggingLevel.DEBUG level.')
	public static void log(List<String> messages) {
		String text = 'FLOW DEBUG: ';

		if (1 == messages.size()) {
			text += messages[0];
		} else if (1 < messages.size()) {
			Integer count = 0;

			for (String message : messages) {
				++count;

				text += '\n ' + count + ': ' + message;
			}
		}

		System.debug(LoggingLevel.DEBUG, text);
	}
}