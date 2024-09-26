public with sharing class dupeCatcherLightningWrapper {
	@AuraEnabled
  public List<possibleMatches> allMatches {get; set;}
  
  @AuraEnabled 
  public boolean foundmatches{get;set;}

  public dupeCatcherLightningWrapper() {
		
	}
}