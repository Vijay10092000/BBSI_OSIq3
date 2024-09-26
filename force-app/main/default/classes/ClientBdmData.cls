public with sharing class ClientBdmData {
	public String CLIENT;
	public String HASBDM;
	public String BDMNAME;

	public static ClientBdmData parse(String json) {
		return (ClientBdmData) System.JSON.deserialize(json,ClientBdmData.class);
	}
}