using eChart.Helper;
using EHRProxy.Updates;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Web.Http;
using System.Web.Caching;
using MoreLinq;
using Newtonsoft.Json;

namespace eChart.Controllers
{
    public class SiteSideController : BaseApiController
    {
        [HttpGet]
        public HttpResponseMessage GetSideDataSet()
        {
            var user = new LoggedInUser(User);
            HttpResponseMessage response = null;

            DataSet ds = Proxy.GetSideDataSet(CenterId, UserId);

            if (ds == null || ds.Tables.Count < 1)
            {
                return Request.CreateResponse(HttpStatusCode.NotFound);
            }
            string json = JsonConvert.SerializeObject(ds.Tables[0].AsEnumerable());

            Dictionary<string, object> result = new Dictionary<string, object>();

            result.Add("sideItems", DataTableHelper.ConvertTable(ds.Tables[0]));
            result.Add("siteItems", DataTableHelper.ConvertTable(ds.Tables[1]));
            String body = JsonConvert.SerializeObject(result);

            response = Request.CreateResponse(HttpStatusCode.OK);
            response.Content = new StringContent(body);
            response.Content.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue("application/json");
            return response;
        }
    }
}
