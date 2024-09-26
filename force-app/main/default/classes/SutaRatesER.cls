public with sharing class SutaRatesER {

	public String CLIENTID;
	public List<DATA> DATALIST;

	public class DATA {
		public String State{get; set;}
		public Decimal SUTA{get; set;}
		public Decimal ETT{get; set;}
		public Decimal EAF{get; set;}
		public Decimal Local{get; set;}
	}

	private Set<String> statesSet;

/*	public List<String> States {
		get{
			if (statesSet == null){
				statesSet = new Set<String>();
				For(DATA item : DATALIST){
					statesSet.add(item.State);
				}
			}
			return new List<String>(statesSet);
		}
	}
*/
	public static SutaRatesER parse(String json) {
		return (SutaRatesER) System.JSON.deserialize(json, SutaRatesER.class);
	}
}