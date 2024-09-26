public with sharing class Folder_Service {
	@Future(Callout=true)
	public static void create(String type, String name, Id idParent) {
		if (String.isNotBlank(name)) {
			if (0 == [SELECT Id FROM Folder WHERE Type = :type AND Name = :name].size()) {
				HttpRequest request = new HttpRequest();
				request.setMethod('POST');
				request.setEndpoint(Url.getSalesforceBaseUrl().toExternalForm() + '/services/data/v52.0/folders/');
				request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
				request.setHeader('Content-Type', 'application/json');
				request.setBody(
					JSON.serialize(
						new Map<String, String>{
							'label' => name,
							'name' => name.toLowerCase().replaceAll('[^a-zA-Z]', '_') + '_generated',
							'type' => type,
							'parentId' => idParent
						}
					)
				);

				HttpCallout.request(request);
			}
		}
	}
}