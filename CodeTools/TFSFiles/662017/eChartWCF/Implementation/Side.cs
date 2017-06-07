using EHRProxy.Updates;
using Hst.DataAccess;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Web;

namespace eChartWCF
{
    public partial class ChartFacade : IChartFacade
    {


        public DataSet GetSideDataSet(int centerID, string requestingUserID)
        {
           
                DataSet ds = new DataSet();

                Dalc.ExecuteDataSetQuery("select SideCode,SideName from t_EHR_Side　order by ordinal;select BodySiteKey,BodySide from t_EHR_BodySite where CenterID="+centerID.ToString()+" and Status='A'", ds, new SqlParameter[] { }, new string[] { "t_EHR_Side","t_EHR_BodySite" }, centerID, requestingUserID);
            return ds;
        }

        
    }
}