using System;
using eChart.Models;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Mvc;
using eChart.Helper;
using eChart.ViewModels;
using EHRProxy;
using System.Collections.Generic;
using eChart.Filters;
using Hst.Core.Entity;
using Hst.Core.Helpers;

namespace eChart.Controllers
{
    [RoutePrefix("chart")]
    public class ChartController : BaseController
    {
        /*
         * Note to self: to log out of application, call this in the code behind: FederatedAuthentication.SessionAuthenticaionModule.SignOut()
         *   and then redirect to LoggedOut.cshtml page.  this page says "you are logged out"  and gives a button to log in.  log in button redirects to index.  
         *   LoggedOut.cshtml is exempt from WIF protection.
         */
        // GET: chart/{chartKey}/{workflowKey}        
        [Route("{chartKey}/{workflowKey}", Name = "ChartWorkflowPage")]
        public ActionResult Index(int chartKey, int workflowKey)
        {
            ViewBag.UseCamera = true;
            if (!UserHasWorkflowPermission(workflowKey))
                return RedirectToAction("AccessDenied", "Home", null);

            return View("~/Views/Shared/ChartSection.cshtml", new ChartSectionModel(chartKey, workflowKey));
        }

        /// <summary>
        /// Get all avaliable data for adding module or re-active existing module
        /// </summary>
        /// <param name="chartKey"></param>
        /// <param name="workflowKey"></param>
        /// <param name="moduleKey"></param>
        /// <returns></returns>
        [Route("modules/{chartKey}/{workflowKey}/{moduleKey}/add", Name = "AddModulePage")]
        public async Task<ActionResult> GetModules(int chartKey, int workflowKey, int moduleKey)
        {
            if (!UserHasWorkflowPermission(workflowKey, AccessKeys.Create))
                return RedirectToAction("AccessDenied", "Home", null);

            var response = Proxy.GetModuleTemplates(CenterId, moduleKey, UserId);

            var request = new GetConsentTypeRequest
            {
                centerID = CenterId,
                requestingUserID = UserId,
                workflowKey = workflowKey
            };

            #region 001/121/122 - question and 105 - consent module
            
            var module001 = await Module001(request);
            ViewBag.QuestionnaireTemplates = module001 != null ? new SelectList(module001, "Id", "Name") : null;

            var module105 = await Module105(request);
            ViewBag.ConsentTypes = module105 != null ? new SelectList(module105, "Id", "Name") : null;
            ViewBag.ShowConsent = module105.Count() > 0;

            #endregion

            var availableModelTemplates = await ScheduleHelper.ToModuleTemplatesAsync(response.DataSet.Tables["modules"]);
            var inActiveViewModels = await ScheduleHelper.ToChartModuleAsync(response.DataSet.Tables["inactives"]);

            var viewModel = new ModulesViewModel
            {
                ChartKey = chartKey,
                WorkflowKey = workflowKey,
                ModuleKey = moduleKey
            };

            ViewBag.Blocs = availableModelTemplates; 
            ViewBag.InActivedBlocs = inActiveViewModels; 

            return PartialView("_ModulesPartial", viewModel);
        }

        /// <summary>
        /// Add the module to workflow or re-active
        /// </summary>
        /// <param name="module"></param>
        /// <returns></returns>
        [HttpPost]
        //[ValidateAntiForgeryToken]
        public async Task<ActionResult> AddModule(ModulesViewModel module)
        {
            if (!ModelState.IsValid) return null;

            if (!UserHasWorkflowPermission(module.WorkflowKey, AccessKeys.Create))
                return RedirectToAction("AccessDenied", "Home", null);

            int? templateKey = null;
            int? moduleKey = null;
            if (module.SelectedType == 1)
                templateKey = module.SelectedKey;
            else
                moduleKey = module.SelectedKey;

            module.Verify();

            var request = new AddModuleToWorkflowRequest
            {
                centerID = CenterId,
                workflowKey = module.WorkflowKey,
                moduleKey = module.ModuleKey,
                moduleTemplateKey = templateKey,
                inactiveModuleKey = moduleKey,
                questionnaireTemplateKey = module.QuestionnaireTemplateKey,
                requestingUserID = UserId,
                titleOverride = module.TitleOverride,
                consentID = module.ConsentID
            };

            var response = await Proxy.AddModuleToWorkflowAsync(request); 

            if (response.error)
                return null;

            var md = Url.Action("Index", "Chart", new { chartKey = module.ChartKey, workflowKey = module.WorkflowKey });

            //md #modulekey
            var newModule = response.DataSet.Tables["ModuleTable"];
            var newModuleKey = newModule != null && newModule.Rows.Count > 0 ? newModule.Rows[0][0].ToString() : string.Empty;
            if (!string.IsNullOrEmpty(newModuleKey))
            {
                md += "#" + newModuleKey;
            }

            return Redirect(md);

            //var jsons = Json(new { Status = "0", HtmlView = md }, JsonRequestBehavior.AllowGet);
            //return jsons;
        }

        [Route("modules/{chartKey}/{workflowKey}/{moduleKey}/remove")]
        public async Task<ActionResult> GetRemovedModule(int chartKey, int workflowKey, int moduleKey)
        {
            if (!UserHasWorkflowPermission(workflowKey, AccessKeys.Delete))
                return RedirectToAction("AccessDenied", "Home", null);

            var request = new RemoveModuleFromWorkflowRequest
            {
                centerID = CenterId,
                workflowKey = workflowKey,
                moduleKey = moduleKey,
                requestingUserID = UserId
            };

            var response = await Proxy.IsRemovableModuleAsync(request); //CenterId, workflowKey, moduleKey, UserId);

            if (response.error)
                return null;

            var errors = ScheduleHelper.ToErrorViewModel(response.DataSet.Tables["errors"]);

            string modulesPartialView;
            if (errors.Code != 0)
            {
                ViewBag.UserMessage = errors.Message;
                return PartialView("_InActiveModule");
            }
            else
            {
                var viewModel = new ChartModule
                {
                    Id = moduleKey,
                    ChartKey = chartKey,
                    WorkflowKey = workflowKey
                };

                return PartialView("_RemoveModulePartial", viewModel);
            }
        }

        [HttpPost]
        //[ValidateAntiForgeryToken]
        [Route("modules/{chartKey}/{workflowKey}/{moduleKey}/remove")]
        public async Task<ActionResult> RemovedModule(int chartKey, int workflowKey, int moduleKey)
        {
            if (!UserHasWorkflowPermission(workflowKey, AccessKeys.Delete))
                return RedirectToAction("AccessDenied", "Home", null);

            var request = new RemoveModuleFromWorkflowRequest
            {
                centerID = CenterId,
                workflowKey = workflowKey,
                moduleKey = moduleKey,
                requestingUserID = UserId
            };

            var response = await Proxy.RemoveModuleFromWorkflowAsync(request); //CenterId, workflowKey, moduleKey, UserId);

            if (response.error) return null;

            var md = Url.Action("Index", "Chart", new { chartKey = chartKey, workflowKey = workflowKey });

            //md #modulekey
            var newModule = response.DataSet.Tables["ModuleTable"];
            var newModuleKey = newModule != null && newModule.Rows.Count > 0 ? newModule.Rows[0][0].ToString() : string.Empty;
            if (!string.IsNullOrEmpty(newModuleKey))
            {
                md += "#" + newModuleKey;
            }

            return Redirect(md);
        }

        /// <summary>
        /// Get Workflows
        /// </summary>
        /// <param name="chartKey"></param>
        /// <returns></returns>
        [Route("{chartKey}/workflows", Name = "GetWorkflowsPage")]
        public async Task<ActionResult> GetWorkflows(int chartKey)
        {
            //throw new NotImplementedException();

            var response = await Proxy.GetWorkflowsAsync(CenterId, chartKey, UserId);

            if (response.error)
            {
                var result = new ErrorViewModel(response);
                return PartialView("_SystemError", result);
            }

            var workflows = ScheduleHelper.ToWorkflowMenuViewModels(response.DataSet.Tables["workflows"]);
            var areas = ScheduleHelper.ToAreaViewModels(response.DataSet.Tables["areas"]);

            var viewModel = new WorkflowManagerViewModel
            {
                ChartKey = chartKey,
                Areas = areas,
                WorkflowMenus = workflows
            };            

            return PartialView("_WorkflowConfig", viewModel);
        }

        /// <summary>
        /// Get Workflow Templates 
        /// </summary>
        /// <param name="workflowKey"></param>
        /// <returns></returns>
        [Route("WorkflowTemplates/{chartKey}/{workflowAreaKey}", Name = "GetWorkflowTemplatesPage")]
        public async Task<ActionResult> GetWorkflowTemplates(int chartKey, int workflowAreaKey)
        {
            var response = await Proxy.GetWorkflowTemplatesAsync(CenterId, workflowAreaKey, UserId);

            if (response.error)
                return null;

            var availableTemplates = ScheduleHelper.ToTemplateViewModels(response.DataSet.Tables["WorkflowTemplates"]);
            ViewBag.WorkflowTemplates = new SelectList(availableTemplates, "ID", "Name");

            var viewModel = new WorkflowBundleViewModel
            {
                ChartKey = chartKey,
                AreaKey = workflowAreaKey                
            };

            return PartialView("_WorkflowTemplates", viewModel);
        }

        /// <summary>
        /// Add the new workflow from workflow template following by the existing workflow
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [HttpPost]
        //[ValidateAntiForgeryToken]
        public async Task<ActionResult> AddWorkflow(WorkflowBundleViewModel model)
        {
            if (Proxy == null || model == null) return null;

            #region validation
            //only TemplateKey problem
            if (!ModelState.IsValid)
            {
                var resp = await Proxy.GetWorkflowTemplatesAsync(CenterId, model.AreaKey, UserId);
                var availableTemplates = ScheduleHelper.ToTemplateViewModels(resp.DataSet.Tables["WorkflowTemplates"]);
                ViewBag.WorkflowTemplates = new SelectList(availableTemplates, "ID", "Name");

                var addModulePartialView = ScheduleHelper.RenderRazorViewToString(this.ControllerContext, "_WorkflowTemplates", model);
                return Json(new GenericResponse { Code = 1, errorMessage = addModulePartialView }, JsonRequestBehavior.AllowGet);
            }
            #endregion

            #region Checking Bundles
            int? bundleKey = null;
            var bundleResponse = await Proxy.IsWorkflowTemplateWithBundleAsync(CenterId, model.ChartKey, model.TemplateKey, UserId);

            var errorMsg = ChartHelper.ErrorResponse("system error - detecting chart bundle category.");
            // popup a error dialog
            if (bundleResponse.error) return Json(errorMsg, JsonRequestBehavior.AllowGet);

            if ((bundleResponse.Code == 2 || Areakeys.IsBundleArea(model.AreaKey)) && bundleResponse.DataSet != null)
            {
                var bundles = ScheduleHelper.ToBundleViewModels(bundleResponse.DataSet.Tables["WorkflowGroup"]);
                var recordCount = bundles.Count();

                // mutiple bundles
                if (recordCount > 1)
                {
                    //todo user selection list UI/UX - no implementation
                    ViewBag.ExistingBundles = new SelectList(bundles, "ID", "Name");

                    var newModel = new WorkflowBundle2ViewModel(model);

                    var getBundlePartialView = ScheduleHelper.RenderRazorViewToString(this.ControllerContext, "_ExistingBundles", newModel);
                    return Json(new GenericResponse { Code = 2, errorMessage = getBundlePartialView }, JsonRequestBehavior.AllowGet);
                }
                else 
                    if (recordCount == 1)
                    {
                        bundleKey = bundles.First().ID;
                    }
            }
            else if (bundleResponse.Code == 2)
            {
                var bundleError = ChartHelper.ErrorResponse("application error - bundle is required, but there is no bundle in the chart - occupied or vacant");
                // bundle is required, but there is no bundle in the chart - occupied or vacant
                return Json(bundleError, JsonRequestBehavior.AllowGet);
            }

            model.BundleKey = bundleKey;

            #endregion

            var response = await AddWorkflowProcess(model);

            return Json(response, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        [Route("workflow/remove/{chartKey}/{workflowKey}", Name = "RemoveWorkflowsPage")]
        public async Task<ActionResult> PreRemoveWorkflow(int workflowKey, int chartKey)
        {
            if (Proxy == null) return null;

            ViewBag.WorkflowKey = workflowKey;
            ViewBag.ChartKey = chartKey;

            return PartialView("_RemoveWorkflowConfirm");
        }

        [HttpPost]
        //[ValidateAntiForgeryToken]
        public async Task<ActionResult> RemoveWorkflow(int workflowKey, int chartKey)
        {
            if (Proxy == null) return null;

            var response = await Proxy.RemoveWorkflowAsync(CenterId, workflowKey, UserId);

            if (!response.error)
            {
                var viewhtml = await GetWorkflowsMenuAsync(CenterId, chartKey, UserId);

                //Wahtever error or not
                response.errorMessage = viewhtml.errorMessage;
            }

            return Json(response, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        //[ValidateAntiForgeryToken]
        public async Task<ActionResult> AddWorkflowWithBundleKey(WorkflowBundle2ViewModel model)
        {
            if (Proxy == null || model == null) return null;

            if (ModelState.IsValid)
            {
                var response = await AddWorkflowProcess(new WorkflowBundleViewModel(model));

                return Json(response, JsonRequestBehavior.AllowGet);
            }
            
            var bundleResponse = await Proxy.IsWorkflowTemplateWithBundleAsync(CenterId, model.ChartKey, model.TemplateKey, UserId);

            if ((bundleResponse.Code == 2 || Areakeys.IsBundleArea(model.AreaKey)) && bundleResponse.DataSet != null)
            {
                var bundles = ScheduleHelper.ToBundleViewModels(bundleResponse.DataSet.Tables["WorkflowGroup"]);
                var recordCount = bundles.Count();

                // mutiple bundles
                if (recordCount > 1)
                {
                    //todo user selection list UI/UX - no implementation
                    ViewBag.ExistingBundles = new SelectList(bundles, "ID", "Name");

                    var getBundlePartialView = ScheduleHelper.RenderRazorViewToString(this.ControllerContext, "_ExistingBundles", model);
                    return Json(new GenericResponse { Code = 2, errorMessage = getBundlePartialView }, JsonRequestBehavior.AllowGet);
                }
            }
            else if (bundleResponse.Code == 2)
            {
                // bundle is required, but there is no bundle in the chart - occupied or vacant
                return null;
            }

            return Json(new GenericResponse { Code = 1, errorMessage = "Test Error!" }, JsonRequestBehavior.AllowGet);
        }

        //we'll add the global error handler or filter soon
        private async Task<GenericResponse> AddWorkflowProcess(WorkflowBundleViewModel model)
        {
            var response = await Proxy.AddWorkflowFromTemplatesAsync(CenterId, model.ChartKey, model.BundleKey, model.TemplateKey, model.AreaKey, UserId);

            if (!response.error)
            {
                var viewhtml = await GetWorkflowsMenuAsync(CenterId, model.ChartKey, UserId);

                //Wahtever error or not
                response.errorMessage = viewhtml.errorMessage;
            }

            return response;
        }

        /// <summary>
        /// Get Bundle Templates
        /// </summary>
        /// <returns></returns>
        [Route("{chartKey}/BundleTemplates", Name = "GetBundleTemplatesPage")]
        public async Task<ActionResult> GetBundleTemplates(int chartKey)
        {
            var response = await Proxy.GetBundleTemplatesAsync(CenterId, UserId);

            if (response.error)
                return null;

            var availableTemplates = ScheduleHelper.ToBundleViewModels(response.DataSet.Tables["BundleTemplates"]);
            ViewBag.BundleTemplates = new SelectList(availableTemplates, "ID", "Name");

            var viewModel = new AddBundleViewModel
            {
                ChartKey = chartKey
            };

            return PartialView("_BundleTemplates", viewModel);
        }

        /// <summary>
        /// Add the bundle to chart
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [HttpPost]
        //[ValidateAntiForgeryToken]
        public async Task<ActionResult> AddBundleToChart(AddBundleViewModel model)
        {
            if (Proxy == null || model == null) return null;

            #region validation
            //only TemplateKey problem
            if (!ModelState.IsValid)
            {
                var resp = await Proxy.GetBundleTemplatesAsync(CenterId, UserId);
                var availableTemplates = ScheduleHelper.ToBundleViewModels(resp.DataSet.Tables["BundleTemplates"]);
                ViewBag.BundleTemplates = new SelectList(availableTemplates, "ID", "Name");

                var addBundlePartialView = ScheduleHelper.RenderRazorViewToString(this.ControllerContext, "_BundleTemplates", model);
                return Json(new GenericResponse { Code = 1, errorMessage = addBundlePartialView }, JsonRequestBehavior.AllowGet);
            }
            #endregion

            var response = await AddBundleProcessAsync(model);

            return Json(response, JsonRequestBehavior.AllowGet);
        }

        private async Task<GenericResponse> AddBundleProcessAsync(AddBundleViewModel model)
        {
            var response = await Proxy.AddBundleToChartAsync(CenterId, model.ChartKey, model.BundleTemplateKey, UserId);

            if (!response.error)
            {
                var viewhtml = await GetWorkflowsMenuAsync(CenterId, model.ChartKey, UserId);
                
                //Wahtever error or not
                response.errorMessage = viewhtml.errorMessage;
            }

            return response;
        }

        private async Task<GenericResponse> GetWorkflowsMenuAsync(int centerId, int chartKey, string userId)
        {
            var response = await Proxy.GetWorkflowsAsync(centerId, chartKey, userId);

            if (!response.error)
            {
                var workflows = ScheduleHelper.ToWorkflowMenuViewModels(response.DataSet.Tables["workflows"]);
                var areas = ScheduleHelper.ToAreaViewModels(response.DataSet.Tables["areas"]);

                var viewModel = new WorkflowManagerViewModel
                {
                    ChartKey = chartKey,
                    Areas = areas,
                    WorkflowMenus = workflows
                };       

                response.errorMessage = ScheduleHelper.RenderRazorViewToString(this.ControllerContext, "_WorkflowConfig", viewModel);           
            }

            return response;
        }

        private async Task<IEnumerable<QuestionViewModel>> Module001(GetConsentTypeRequest request)
        {
            var baseRequest = new BaseRequest
            {
                centerID = request.centerID,
                requestingUserID = request.requestingUserID
            };

            var resp = await Proxy.GetQuestionnaireTemplatesAsync(baseRequest);
            if (resp.error) return null;

            return ScheduleHelper.ToQuestionViewModels(resp.DataSet.Tables["QuestionnaireTemplates"]);
        }

        private async Task<IEnumerable<ConsentOptionsViewModel>> Module105(GetConsentTypeRequest request)
        {
            var resp = await Proxy.GetConsentOptionsAsync(request); //.GetConsentTypesAsync(request);
            if (resp.error) return null;

            return ScheduleHelper.ToConsentOptionsViewModels(resp.DataSet.Tables["ConsentOptions"]);
        }
    }
}
