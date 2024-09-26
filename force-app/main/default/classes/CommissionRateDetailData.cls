public with sharing class CommissionRateDetailData {

	public String CLIENTID;
	public List<DATA> Datalist;

	public class DATA {
		public String Acronym;
		public String Company;
		public String TypeBegin;
		public String TypeEnd;
		public String CommissionType;
		public Decimal CommissionRate;
		public Decimal CommissionAmt;
		public Decimal Blended;
		public Decimal CommBasis;
		public Integer ChksInPeriod;
		public Integer WksInPeriod;
	}

	public Boolean HasRefPartner { 
        Get { 
            return !(Datalist == null || Datalist.size() == 0 || String.isEmpty(Datalist[0].Acronym)); 
            }
        }

    public Boolean HasValidRefPartner {
        Get {
            String temp = '';
            For(DATA item : Datalist) {
                if (String.isEmpty(item.Acronym) ) {
                    continue;
                }
                If(String.isEmpty(temp) ) {
                    temp = item.Acronym;
                } else if (temp != item.Acronym) {
                    return false;
                }
            }
            return !String.isEmpty(temp);
            }
        }

    public Boolean HasValidCommRate {
    	get {
    		Boolean rowCountOk = (this.Datalist.size() == 1);
    		Boolean hasRate = false;
    		Boolean hasType = false;

    		If(rowCountOk) {
    			hasRate = this.Datalist[0].CommissionRate != 0;
    			hasType = !String.isEmpty(this.Datalist[0].CommissionType);
    		}

    		return rowCountOk && hasRate && hasType;
    	}
    }

	public static CommissionRateDetailData parse(String json) {
		return (CommissionRateDetailData) System.JSON.deserialize(json, CommissionRateDetailData.class);
	}



}