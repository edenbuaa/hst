using System;
using System.Linq;
using System.Security.Claims;
using System.Web.Mvc;
using eChartWCF;
using EHRProxy;
using eChart.Security;
using System.ServiceModel;
using Hst.Core.Entity;
using Hst.Core.Helpers;
using eChart.ViewModels;

namespace eChart.Controllers
{
    [Authorize]
    public class BaseController : Controller
    {
        private readonly Lazy<string> _applicationVirtualPath = new Lazy<string>(() => System.Web.Hosting.HostingEnvironment.ApplicationVirtualPath);

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
        public bool ISCenterAdmin { get; private set; }

        public bool UserHasWorkflowPermission(int workflowKey, string actionKey = AccessKeys.Retreive)
        {
            if (workflowKey <= 0) return false;

            var functionId = Proxy.GetWorkflowFunctionKey(CenterId, workflowKey, UserId);

            return UserHasPermission(functionId, actionKey);
        }

        public bool UserHasModulePermission(int moduleKey, string actionKey = AccessKeys.Retreive)
        {
            if (moduleKey <= 0) return false;

            var functionId = Proxy.GetModuleFunctionKey(CenterId, moduleKey, UserId);

            return UserHasPermission(functionId, actionKey, true);
        }

        public bool UserHasPermission(string functionKey, string actionKey = AccessKeys.Update, bool returnDefaultValue = false)
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

        public string ApplicationVirtualPath
        {
            get
            {
                return _applicationVirtualPath.Value;
            }
        }

        public ActionResult ErrorPartialView(string msg)
        {
            var viewModel = new ErrorViewModel
            {
                Code = 1,
                Message = msg
            };

            return PartialView("_ErrorPartial", viewModel);
        }

        protected override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            if (User == null) return;

            var currentUser = User.Identity as ClaimsIdentity;
            if (currentUser == null) return;

            // ToDo: convert later when more testing
            var singleOrDefault = currentUser.Claims.SingleOrDefault(c => c.Type == "HSTSTS/UserID");
            if (singleOrDefault != null)
            {
                UserId = singleOrDefault.Value;
            }
            var orDefault = currentUser.Claims.SingleOrDefault(c => c.Type == "HSTSTS/CenterID");
            if (orDefault == null) return;
            int cid;
            if (int.TryParse(orDefault.Value, out cid))
            {
                CenterId = cid;
            }

            var timeoutDefault = currentUser.Claims.SingleOrDefault(c => c.Type == "HSTSTS/InactivityTimeOutMinutes");
            if (timeoutDefault == null) return;

            int timeout;
            TimeoutInterval = int.TryParse(timeoutDefault.Value, out timeout) ? timeout : 5;
            // end ToDo

            HSTUser user = ClaimsUserFactory.GetHSTUser(User);

            IsPhysician = user.isPhysician;
            IsAnesthesiologist = user.isAnesthesiologist;
            IsCRNA = user.isCRNA;
            ISCenterAdmin = user.isCenterAdministrator;

            var tempPhysicianID = user.getHSTInt("PhysicianID");
           
            IsOverridePhysician = UserHasPermission(FunctionKeys.OverridePhysicianChartVisibility, AccessKeys.Retreive);

            PhysicianID = IsOverridePhysician ? 0 : ((IsPhysician && !IsAnesthesiologist && !IsCRNA && tempPhysicianID > 0) ? tempPhysicianID : 0);

            base.OnActionExecuting(filterContext);
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