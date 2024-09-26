/*
    Deserialize payroll data
*/
public with sharing class PayrollHistoryData {

	public Integer Client;
	public String StartDate;
	public List<PayrollItem> Payroll;

	public String MaxYear{
		get{
			Integer maxYr = 0;
			For(PayrollItem item :Payroll){
				if(Integer.valueOf(item.Year) > maxYr){
					maxYr = Integer.valueOf(item.Year);
				}
			}
			return maxYr.format();
		}
	}

	public class PayrollItem {
		public String Year;
		public String MinDate;
		public String MaxDate;
		public String LastName;
		public String FirstName;
		public String SSN;
		public String Active;
		public Integer IsOwner;
		public List<WcDetail> WcDetails;
		public Double TotalBillAmt{
			get{
				Double result = 0;
				for(WcDetail item :WcDetails){
					result += item.BillAmt;
				}
				return result;
			}
		}
		public Double TotalPayAmt{
			get{
				Double result = 0;
				for(WcDetail item :WcDetails){
					result += item.PayAmt;
				}
				return result;
			}
		}
		public Double TotalPremPayAmt{
			get{
				Double result = 0;
				for(WcDetail item :WcDetails){
					result += item.PremPayAmt;
				}
				return result;
			}
		}
		public Double TotalTaxablePayAmt{
			get{
				Double result = 0;
				for(WcDetail item :WcDetails){
					result += item.TaxablePayAmt;
				}
				return result;
			}
		}
		public Double TotalErTaxes{
			get{
				Double result = 0;
				for(WcDetail item :WcDetails){
					result += item.ErTaxes;
				}
				return result;
			}
		}
		public Double TotalWcPremiums{
			get{
				Double result = 0;
				for(WcDetail item :WcDetails){
					result += item.WcPremiums;
				}
				return result;
			}
		}
		public Double TotalHoursWorked{
			get{
				Double result = 0;
				for(WcDetail item :WcDetails){
					result += item.HoursWorked;
				}
				return result;
			}
		}
		public String StateCode{
			get{
				Double temp = 0;
				String tempSt = '';
				for(WcDetail item :WcDetails){
					if(item.PayAmt > temp){
						temp = item.PayAmt;
						tempSt = item.State;
					}
				}
				return tempSt;
			}
		}
    }

	public class WcDetail {
		public String State;
		public String WcCode;
		public String JobCode;
		public Double BillAmt;
		public Double PayAmt;
		public Double PremPayAmt;
		public Double TaxablePayAmt;
		public Double ErTaxes;
		public Double WcPremiums;
		public Double HoursWorked;
	}
    
	public static String GetRequestBody(Integer clientId, String contractStartDate){
        String template = '\"CLIENT\":{0},\"STARTDATE\":\"{1}\"';
        List<String> args = new String[]{String.valueOf(clientId), contractStartDate};
        return '{' + String.format(template, args) + '}';
    }
    
	public static PayrollHistoryData parse(String json) {
		return (PayrollHistoryData) System.JSON.deserialize(json, PayrollHistoryData.class);
	}

}