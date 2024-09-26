public with sharing class PayWcEstimate {

	public String CLIENT;
	public List<DATA> DATALIST;

	public class DATA {
		public String State{get; private set;}
		public String LastName{get; private set;}
		public String FirstName{get; private set;}
		public String Active{get; private set;}
		public Integer IsOwner{get; private set;}
		public List<WcPay> WCcodes{get; private set;}
		public Decimal TotalPay {
			get{
				Decimal temp = 0.0;
				for (WcPay item : WCcodes){
					temp += item.PayAmt;
				}
				return temp;
			}
		}
		public Decimal TotalPremBasedPay {
			get{
				Decimal temp = 0.0;
				for (WcPay item : WCcodes){
					temp += item.PremPayAmt;
				}
				return temp;
			}
		}
		public Decimal TotalHours {
			get{
				Decimal temp = 0.0;
				for (WcPay item : WCcodes){
					temp += item.HoursWorked;
				}
				return temp;
			}
		}
	}
    
    private Set<String> statesSet;
    public List<String> States {
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
    


	public class WcPay {
		public String WCcode{get; private set;}
		public Decimal PayAmt{get; private set;}
		public Decimal PremPayAmt{get; private set;}
		public Decimal HoursWorked{get; private set;}
        public Integer IsEligibleSI {get; private set;}
        public Decimal EligibleRateSI {get; private set;}
	}

	public static PayWcEstimate parse(String json) {
		return (PayWcEstimate) System.JSON.deserialize(json, PayWcEstimate.class);
	}
}