public without sharing class BranchLeadsAndOpportunities {
  public string LeadData {get;set;}
  public string ProspectData {get;set;}
  public string ClientData {get;set;}
  public String daysToProcessString {get;set;}
  private Integer daysToProcess;
  private Datetime sDate;
  private Datetime eDate;

  public String hiddenStart{get;set;}
  public String hiddenEnd{get;set;}

  public string leadTotalData{get;private set;}
  public string prospectTotalData{get;private set;}
  public string clientTotalData{get;private set;}

  public list<List<Object>> leadtotalvalues;
  public list<list<Object>> prospecttotalvalues;
  public list<list<Object>> clienttotalvalues;

  public list<String> sortedRegionLeads {get;private set;}
  public list<String> sortedRegionProspects {get;private set;}
  public list<String> sortedRegionClients {get;private set;}

  public map<String,Integer> totalLeads {get;private set;}
  public map<String,Integer> totalprospects {get;private set;}
  public map<String,Integer> totalclients {get;private set;}
  
  public list<String> leadColumns{get;private set;}
  public list<String> prospectColumns{get;private set;}
  public list<String> clientColumns{get;private set;}
  public String sectionTitle{get;private set;}

public BranchLeadsAndOpportunities() {
  daysToProcessString = '7';
  loadData();
  setupColumns();
}

public void loadData(){

  System.Debug('daysToProcessString ' + daysToProcessString);
  if(daysToProcessString != 'CUSTOM'){
    try{
      daysToProcess = Integer.ValueOF(daysToProcessString);
      sectionTitle = ' for the Last ' + daysToProcessString + ' Days by Branch';
    }catch(exception e){
      daysToProcess = 7; //default to 7 if they enter bad data maybe i'll show a message
    }
  }else{
    sDate = getDateTime(hiddenStart);
    eDate = getDateTime(hiddenEnd);
    sectionTitle = ' From ' + sDate.Month() + '/'+ sDate.Day() + '/' + sDate.Year() + ' To ' + eDate.Month() + '/'+ eDate.Day() + '/' + eDate.Year() + ' by Branch';
  }
  serializeData();
}

private DateTime getDateTime(String sDate){

  list<String> dateValues;
  if(sDate.Contains('-')){ 
     dateValues = sDate.split('-');
  }
  else{
     dateValues = sDate.split('/');
  }

  return DateTime.newInstance(Integer.ValueOf(dateValues[2]), Integer.ValueOf(dateValues[0]), Integer.ValueOf(dateValues[1]));
}

private void serializeData(){
  map<String,chartWrapper> data = new map<String,chartWrapper>();
  list<String> branchNames = new list<String>();
  data = loadValues();
  list<chartWrapper> returnData = data.Values();
  map<String,List<List<Object>>> valuesMap = getChartData(returnData);
  LeadData = JSON.serialize(valuesMap.get('Leads'));
  ProspectData = JSON.serialize(valuesMap.get('Prospects'));
  ClientData = JSON.serialize(valuesMap.get('Clients'));
  leadTotalData = JSON.serialize(leadtotalvalues);
  prospectTotalData = JSON.serialize(prospecttotalvalues);
  clientTotalData = JSON.serialize(clienttotalvalues);
}

private void setupColumns(){
  leadColumns = new list<String>();
  leadColumns.add('string|Branches');
  leadColumns.add('number|New Leads');
  leadColumns.add('number|New RP Leads');
  prospectColumns = new list<String>();
  prospectColumns.add('string|Branches');
  prospectColumns.add('number|New Prospects');
  clientColumns = new list<String>();
  clientColumns.add('string|Branches');
  clientColumns.add('number|New Clients');
}


public map<String,chartWrapper> loadValues(){
  
  map<String,chartWrapper> returnVal = new map<String,chartWrapper>();
  returnVal = getBranches();
  returnVal = getLeads(returnVal);
  returnVal = getAccounts(returnVal);
  
  return returnVal;
}

public List<SelectOption> getDaysToProcess(){
  List<SelectOption> options = new List<SelectOption>();
  options.add(new SelectOption('7','7'));
  options.add(new SelectOption('14','14'));
  options.add(new SelectOption('30','30'));
  options.add(new SelectOption('60','60'));
  options.add(new SelectOption('90','90'));
  options.add(new SelectOption('120','120'));
  options.add(new SelectOption('365','365'));
  options.add(new SelectOption('CUSTOM','Date Range'));
  return options;
}

public map<String,List<List<object>>> getChartData(List<chartWrapper> inData){
  Map<String,list<list<Object>>> data = new Map<string,list<List<Object>>>();
  List<List<object>> Leads = new List<List<Object>>();
  List<List<object>> Prospects = new List<List<Object>>();
  List<List<object>> Clients = new List<List<Object>>();

  
  for(chartWrapper ch: inData){
    Leads.add(new List<Object>{ch.Branch,ch.NumLeads,ch.NumRPLeads});
    Prospects.add(new List<Object>{ch.Branch,ch.NumProspects});
    Clients.add(new List<Object>{ch.Branch,ch.NumClients});
  }
  data.put('Leads',Leads);
  data.put('Prospects',Prospects);
  data.put('Clients', Clients);
    
  return data;
}

public map<String,chartWrapper> getAccounts(map<String,chartWrapper> data){
  
  Datetime startDateTime;
  Datetime endDateTime;
  Date startDate;
  Date endDate;

  if(daysToProcessString != 'CUSTOM'){
    startDate = System.Today().addDays(-daysToProcess);
    startDateTime = System.Today().addDays(-daysToProcess);
  }else{
    startDate =date.newinstance(sDate.year(), sDate.month(), sDate.day());
    endDate = date.newinstance(eDate.year(), eDate.month(), eDate.day());
    startDateTime = sDate;
    endDateTime = eDate;
  }

  totalprospects = new map<string,integer>();
  totalClients = new map<string,integer>();
  totalprospects.put('total',0);
  totalClients.put('total',0);
  list<Account> Accounts = (list<Account>)Database.Query(getQuery('Client'));
  For(Account a: Accounts){
    System.Debug('data: ' + data);
    System.Debug('a:' + a.Prospect_Branch__r.Name + a.iD);
    data.get(a.Prospect_Branch__r.Name).NumClients ++;
    if(totalclients.ContainsKey(a.Prospect_Branch__r.Region__c)){
      integer i= totalclients.get(a.Prospect_Branch__r.Region__c);
      i++;
      totalclients.put(a.Prospect_Branch__r.Region__c,i);
    }else{
      totalclients.put(a.Prospect_Branch__r.Region__c,1);
    }
  } 
  
  Date dToday = System.Today().addDays(-daysToProcess);
  Datetime dateVal2 = datetime.newInstance(dToday.year(), dToday.month(),dToday.day());
  Accounts = (list<Account>)Database.Query(getQuery('Prospect'));
  
  For(Account a: Accounts){
    data.get(a.Prospect_Branch__r.Name).numProspects ++;
    if(totalprospects.ContainsKey(a.Prospect_Branch__r.Region__c)){
      integer i= totalprospects.get(a.Prospect_Branch__r.Region__c);
      i++;
      totalprospects.put(a.Prospect_Branch__r.Region__c,i);
    }else{
      totalprospects.put(a.Prospect_Branch__r.Region__c,1);
    }
  }
  sortedRegionClients = getSortedList(totalClients);
  clienttotalvalues = getArrayFromMap(totalClients);
  sortedRegionProspects = getSortedList(totalprospects);
  prospecttotalvalues = getArrayFromMap(totalprospects);
  return data;
} 

private String getQuery(String sRecordType){
  String query;
  if(sRecordType == 'Lead'){
    query = 'SELECT ID, Branch__r.Name, Branch__r.Region__c,recordTypeID,Company,CreatedDate from Lead where Branch__c != null';
    query += ' and Branch__r.Branch_No__c != null and Branch__r.Branch_No__c != \'910\'';
    if(daysToProcessString != 'CUSTOM'){
      query += ' AND CreatedDate >=: startDateTime';
    }else{
      query += ' AND (CreatedDate >=: startDateTime AND CreatedDate <=: endDateTime)';
    }
  }else{
    query = 'SELECT ID,Prospect_Branch__r.Name,Prospect_Branch__r.Region__c from Account where Prospect_Branch__c != null AND Prospect_Branch__r.Branch_No__c != \'910\' and RecordType.Name = ';
    if(sRecordType == 'Prospect'){
      query += '\'Prospect\'';
      if(daysToProcessString != 'CUSTOM'){
        query += ' AND CreatedDate >=: startDateTime';
      }else{
        query += ' AND (CreatedDate >=: startDateTime AND CreatedDate <=: endDateTime)';
      }
    }else{
       query += '\'Client\'';
       if(daysToProcessString != 'CUSTOM'){
        query += ' AND Start_Date__c >=: startDate';
      }else{
        query += ' AND (Start_Date__c >=: startDate AND Start_Date__c <=: endDate)';
      }
    }
    
  }
  System.Debug(query);
  return query;

}
public map<String,chartWrapper> getLeads(map<String,chartWrapper> data){
 
  Datetime startDateTime;
  Datetime endDateTime;
  
  if(daysToProcessString != 'CUSTOM'){
    startDateTime = System.Today().addDays(-daysToProcess);
  }else{
    startDateTime = sDate;
    endDateTime = eDate;
  }

  totalleads = new map<String,Integer>();
  totalleads.put('total',0);
  Date dToday = System.Today().addDays(-daysToProcess);
  Datetime dateVal = datetime.newInstance(dToday.year(), dToday.month(),dToday.day());
  Id ClientRecType = RecordTypeService.getId('Lead','Client_Lead');
  list<Lead> leads = (List<Lead>)Database.query(getQuery('Lead'));
  for(Lead l: leads){
    if(totalleads.ContainsKey(l.Branch__r.Region__c)){
      integer i= totalleads.get(l.Branch__r.Region__c);
      i++;
      totalleads.put(l.Branch__r.Region__c,i);
    }else{
      totalleads.put(l.Branch__r.Region__c,1);
    }
    if(l.recordTypeID == ClientRecType){
      data.get(l.Branch__r.Name).numLeads ++;
    }else{
      data.get(l.Branch__r.Name).numRPLeads ++;
    }
  }
  sortedRegionLeads = getSortedList(totalleads);
  leadtotalvalues = getArrayFromMap(totalleads);

  return data;
}

private list<List<object>> getArrayFromMap(map<String,integer> totalMap){
  list<List<object>> values = new list<list<object>>();
  list<object> temp = new list<object>();
  temp.add('Region');
  temp.add('Total Leads');
  values.add(temp);
  for(String s: totalMap.keyset()){
    if(s != 'total'){
      temp = new list<object>();
      temp.add(s);
      temp.add(totalMap.get(s));
      values.add(temp);
    }
  }

  return values;
}

private list<String> getSortedList(map<String,Integer> values){
  
  if(Values.isEmpty()) return new list<String>();
  list<Integer> listValues =values.values();
  list<String> sortedValues = new list<String>();
  listValues.sort();
  set<String> alreadySorted = new set<string>();
  Integer m = listValues.size() -1;
  Integer total = 0;
  System.debug('m: ' + m + ' size: ' + listValues.size());
  for(Integer x = listValues.size() -1; x >= 0;x--){
      Integer i = listValues[x];
      total = total + i;
      for(String s: values.keyset()){
        if(s != 'total'){
          if(!alreadySorted.contains(s)){
            if(i == values.get(s)){
              alreadySorted.add(s);
              sortedValues.add(s);
            }
          }
        }
      }
  }
  values.put('total',total);
  system.debug('values ' + values);
  return sortedValues;
}

public map<String,chartWrapper> getBranches(){
  map<String,chartWrapper> returnVal = new map<String,chartWrapper>();
  for(Account branch: [Select Name,Region__c from Account where recordType.Name = 'BBSI Branch'
                       AND Branch_No__c != NULL AND Branch_No__c != '910']){
    chartWrapper chart = new chartWrapper();
    chart.branch = branch.name;
    chart.region = branch.Region__c;
    returnVal.put(branch.Name,chart);
  }
  return returnVal;
}

public class chartWrapper{

  String branch;
  String region;
  Integer numLeads = 0;
  Integer numRPLeads = 0;
  Integer numProspects = 0;
  Integer numClients = 0;
}

}