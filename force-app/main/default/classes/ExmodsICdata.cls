/**
 * ExmodsICdata class
 * Published Xmod data from IntelliComp
 * (California Xmods only)
 */
public with sharing class ExmodsICdata {
	public List<ExModItem> ExMods;
	public String BureauReportUrl;

	public Integer BureauNumber{
		get{
			if(BureauReportUrl != null && BureauReportUrl.length() > 0){
				String tempStr = BureauReportUrl.replaceAll('[^0-9]','');
				if(tempStr != null && tempStr.length() > 0){
					return Integer.valueOf(tempStr);
				}
			}
			return 0;
		}
	}
	
	public class ExModItem {
		public Integer year;
		public String calc_date;
		public Integer exmod;
        @TestVisible
		private String exmod_status;
        
        public decimal Xmod{
            get{
                if (exmod != null){

                    return (decimal)exmod / 100.0;
                }
                return null;
            }
        }
		public String XmodStatus{
			get{
				// replace multiple spaces with just one space
				if(exmod_status == null || exmod_status.length() < 1){
					return '';
				}
				return exmod_status.replaceAll('[ ]+',' ');
			}
		}
		// Intellicomp does not return a State Code, but only serves California accounts
		public String StateCode{ get{ return 'CA'; } }
	}
	
    public static String ApiUrl {get {return '/getExmodReport?fein='; }}
    
	public static ExmodsICdata parse(String json) {
		return (ExmodsICdata) System.JSON.deserialize(json, ExmodsICdata.class);
	}

}