using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Security.Claims;
using System.Threading;
using System.Threading.Tasks;
using System.Web.Http;
using System.Web.Http.Controllers;
using eChartWCF;
using Microsoft.Ajax.Utilities;
using eChart.Security;
using EHRProxy;
using EHRProxy.Updates;
using System.ServiceModel;
using Hst.Core.Entity;
using Hst.Core.Helpers;
using System.Text;
using System.Diagnostics;
using System.Web;

namespace eChart.Controllers
{
    [Authorize]
    public class BaseApiController : ApiController
    {
        private ChartFacadeClient _proxy;

        public ChartFacadeClient Proxy
        {
            get { return _proxy ?? (_proxy = ProxyHelper.GetChartFacadeClient()); }
        }

        public string UserId { get; private set; }
        public int CenterId { get; private set; }
        public int TimeoutInterval { get; private set; } // Number of minutes of inactivity that are allowed
        public bool IsPhysician { get; private set; }
        public bool IsAnesthesiologist { get; private set; }
        public bool IsCRNA { get; private set; }
        public int PhysicianID { get; private set; }
        public bool IsOverridePhysician { get; private set; }

        public override Task<HttpResponseMessage> ExecuteAsync(HttpControllerContext controllerContext, CancellationToken cancellationToken)
        {
            if (User == null) return base.ExecuteAsync(controllerContext, cancellationToken);
            var currentUser = User.Identity as ClaimsIdentity;
            if (currentUser == null) return base.ExecuteAsync(controllerContext, cancellationToken);
            var singleOrDefault = currentUser.Claims.SingleOrDefault(c => c.Type == "HSTSTS/UserID");
            if (singleOrDefault != null)
            {
                UserId = singleOrDefault.Value;
            }
            var orDefault = currentUser.Claims.SingleOrDefault(c => c.Type == "HSTSTS/CenterID");
            if (orDefault == null) return base.ExecuteAsync(controllerContext, cancellationToken);
            int cid;
            if (int.TryParse(orDefault.Value, out cid))
            {
                CenterId = cid;
            }

            var timeoutDefault = currentUser.Claims.SingleOrDefault(c => c.Type == "HSTSTS/InactivityTimeOutMinutes");
            if (timeoutDefault == null) return base.ExecuteAsync(controllerContext, cancellationToken);
            int timeout;
            TimeoutInterval = int.TryParse(timeoutDefault.Value, out timeout) ? timeout : 5;

            // ToDo: move this up and convert other claim information to use HSTUser instead
            HSTUser user = ClaimsUserFactory.GetHSTUser(User);

            IsPhysician = user.isPhysician;
            IsAnesthesiologist = user.isAnesthesiologist;
            IsCRNA = user.isCRNA;

            var tempPhysicianID = user.getHSTInt("PhysicianID");
            IsOverridePhysician = UserHasPermission(FunctionKeys.OverridePhysicianChartVisibility, AccessKeys.Retreive);

            PhysicianID = IsOverridePhysician ? 0 : ((IsPhysician && !IsAnesthesiologist && !IsCRNA && tempPhysicianID > 0) ? tempPhysicianID : 0);

            return base.ExecuteAsync(controllerContext, cancellationToken);
        }

        protected Task<HttpResponseMessage> InvokeProxyAsync(Func<eChartWCF.ChartFacadeClient, LoggedInUser, RowUpdateResponse> f)
        {
            return Task.FromResult(InvokeProxy(f));
        }

        protected HttpResponseMessage InvokeProxy(Func<eChartWCF.ChartFacadeClient, LoggedInUser, RowUpdateResponse> f)
        {
            eChartWCF.ChartFacadeClient proxy = ProxyHelper.GetChartFacadeClient();

            LoggedInUser user = new LoggedInUser(User);

            RowUpdateResponse result = null;

            try
            {
                result = f(proxy, user);
            }
            catch (InvalidUserExeption ex)
            {
                HttpResponseMessage response = Request.CreateResponse(HttpStatusCode.Forbidden);
                response.Content = new StringContent(ex.Message);

                return response;
            }
            catch (Exception e)
            {
                HttpResponseMessage response = Request.CreateResponse(HttpStatusCode.InternalServerError);
                response.Content = new StringContent(e.Message);
                response.Content.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue("text/plain");

                return response;
            }

            if (result.success)
            {
                LiveUpdateResponse data = new LiveUpdateResponse();

                data.originatingUser = user.UserID;

                data.inserts = result.inserts.Select(i => InsertedRow.FromLiveEditInsert(i)).ToList();

                data.updates = result.updates.Select(u => UpdatedRow.FromLiveEditUpdate(u)).ToList();                

                foreach (var error in result.errors)
                {
                    data.errors.GetOrAdd(error.moduleKey, e => { return new ModuleError(); }).incomplete.Add(error);
                }

                foreach (var missing in result.missingFields)
                {
                    data.errors.GetOrAdd(missing.moduleKey, e => { return new ModuleError(); }).missing.Add(missing);
                }

                string body = LiveEditMessageQueue.EnqueueMessage(result.chartKey, user.CenterID, result.connectionID, data,result.groupUpdated);

                HttpResponseMessage response = Request.CreateResponse(HttpStatusCode.OK);
                response.Content = new StringContent(body);
                response.Content.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue("application/json");

                return response;
            }
            else
            {
                HttpResponseMessage response = Request.CreateResponse(HttpStatusCode.InternalServerError);
                response.Content = new StringContent(result.exceptionMessage);
                response.Content.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue("text/plain");

                return response;
            }
        }

        protected HttpResponseMessage InvokeNotLoggedInProxy(int centerID, string userID, Func<eChartWCF.ChartFacadeClient, RowUpdateResponse[]> f)
        {
            HttpResponseMessage response;
            eChartWCF.ChartFacadeClient proxy = ProxyHelper.GetChartFacadeClient();

            RowUpdateResponse[] results = null;

            try
            {
                results = f(proxy);
            }
            catch (InvalidUserExeption ex)
            {
                Elmah.ErrorLog.GetDefault(HttpContext.Current).Log(new Elmah.Error(ex));
                response = Request.CreateResponse(HttpStatusCode.Forbidden);
                response.Content = new StringContent(ex.Message);

                return response;
            }
            catch (Exception e)
            {
                Elmah.ErrorLog.GetDefault(HttpContext.Current).Log(new Elmah.Error(e));
                response = Request.CreateResponse(HttpStatusCode.InternalServerError);
                response.Content = new StringContent(e.Message);
                response.Content.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue("text/plain");

                return response;
            }

            // It is allowed not to return any results to LiveEdit (i.e. vital data which must be pended rather than saved to Live Edited table)
            if (results.Length == 0)
            {
                response = Request.CreateResponse(HttpStatusCode.OK);
                response.Content = new StringContent("{}");
                response.Content.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue("application/json");
            }
            else if (results[0].success)
            {
                LiveUpdateResponse data = new LiveUpdateResponse();

                data.originatingUser = userID;

                data.inserts = results[0].inserts.Select(i => InsertedRow.FromLiveEditInsert(i)).ToList();

                data.updates = results[0].updates.Select(u => UpdatedRow.FromLiveEditUpdate(u)).ToList(); ;

                string body = LiveEditMessageQueue.EnqueueMessage(results[0].chartKey, centerID, results[0].connectionID, data);

                response = Request.CreateResponse(HttpStatusCode.OK);
                response.Content = new StringContent(body);
                response.Content.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue("application/json");
            }
            else
            {
                string errorMsg = results[0].exceptionMessage;

                response = Request.CreateResponse(HttpStatusCode.InternalServerError);
                response.Content = new StringContent(errorMsg);
                response.Content.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue("text/plain");
            }

            // results[0] is primary and already processed
            // now LiveUpdate the remaining secondary results
            for (int resultsIdx = 1; resultsIdx < results.Length; resultsIdx++)
            {
                LiveUpdateResponse data = new LiveUpdateResponse();

                data.originatingUser = userID;

                data.inserts = results[resultsIdx].inserts.Select(i => InsertedRow.FromLiveEditInsert(i)).ToList();

                data.updates = results[resultsIdx].updates.Select(u => UpdatedRow.FromLiveEditUpdate(u)).ToList(); ;

                // queue the live edits for broadcasting.  Just ignore the generated body -- no place to send it to anyway
                string body = LiveEditMessageQueue.EnqueueMessage(results[resultsIdx].chartKey, centerID, results[resultsIdx].connectionID, data);
            }

            return response;
        }

        protected bool UserHasPermission(string functionKey, string actionKey = AccessKeys.Update, bool returnDefaultValue = false)
        {
            if (string.IsNullOrWhiteSpace(functionKey)) return false;

            var functionId = string.Empty;

            switch (actionKey)
            {
                case AccessKeys.Update:
                    functionId = FunctionKeyHelper.ActionUpdate(functionKey);
                    break;
                case AccessKeys.Create:
                    functionId = FunctionKeyHelper.ActionCreate(functionKey);
                    break;
                case AccessKeys.Retreive:
                    functionId = FunctionKeyHelper.ActionRetreive(functionKey);
                    break;
                case AccessKeys.Delete:
                    functionId = FunctionKeyHelper.ActionDelete(functionKey);
                    break;
                default:
                    functionId = FunctionKeyHelper.ActionUpdate(functionKey);
                    break;
            }

            return ClaimsUserFactory.hasSystemFunction(User, functionId, returnDefaultValue);
        }

        protected override void Dispose(bool disposing)
        {

            try
            {
                base.Dispose(disposing);

                if (_proxy == null) return;

                if (_proxy.State != CommunicationState.Faulted)
                    _proxy.Close();
                else
                    _proxy.Abort();
            }
            catch (Exception ex)
            {
                _proxy.Abort();
            }
        }
    }
}