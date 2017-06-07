using eChartWCF.Metadata;
using eChartWCF.SQL;
using eChartWCF.Utilities;
using EHRProxy.DBDictionary;
using EHRProxy.Updates;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using MoreLinq;

namespace eChartWCF
{
    public class Trigger : IEquatable<Trigger>
    {
        public Trigger(LiveEditTriggerDefinition def, string operation)
        {
            this.TriggerDefinition = def;

            this.Operation = operation;
        }

        public Trigger(LiveEditTriggerDefinition def, string operation, SwapKey keys)
            : this(def, operation)
        {
            this.Keys = keys;
        }

        public LiveEditTriggerDefinition TriggerDefinition { get; set; }

        public string Operation { get; set; }

        public SwapKey Keys { get; set; }

        public bool Equals(Trigger other)
        {
            return this.TriggerDefinition.Equals(other.TriggerDefinition) && this.Operation == other.Operation;
        }

        public override int GetHashCode()
        {
            unchecked
            {
                int hash = 27;
                hash = (13 * hash) + this.TriggerDefinition.GetHashCode();
                hash = (13 * hash) + this.Operation.GetHashCode();
                return hash;
            }
        }
    }

    public class DependencyTracker
    {
        // NOTE: Some universally used tables like t_EHR_ChartConfiguration are referenced, but never LiveEdited.  We remove them
        //        from consideration when deciding which back-end completion procs to run. Do NOT add anything to this list without 
        //        explicit permission from Mike or Dan. Bad Things™ will result if you do.
        private HashSet<string> blacklistedTables = new HashSet<string>();

        private HashSet<string> insertedTables = new HashSet<string>();

        private HashSet<string> allTables = new HashSet<string>();

        private HashSet<ProcDefinition> procDefs = new HashSet<ProcDefinition>();

        private HashSet<Trigger> triggerDefs = new HashSet<Trigger>();        

        private DBDictionary dbd;

        private int centerID;

        private int chartKey;

        private int moduleTemplateKey;

        private bool setDirtyFlag;

        private NamedParameterList parameters;

        public DependencyTracker(int centerID, DBDictionary dbd, NamedParameterList parameters, int chartKey) : this(centerID, dbd, parameters, chartKey, -1) { }

        public DependencyTracker(int centerID, DBDictionary dbd, NamedParameterList parameters, int chartKey, bool setDirty) : this(centerID, dbd, parameters, chartKey, -1, setDirty) { }

        public DependencyTracker(int centerID, DBDictionary dbd, NamedParameterList parameters, int chartKey, int moduleTemplateKey)
        {
            this.dbd = dbd;

            this.centerID = centerID;

            this.parameters = parameters;

            this.chartKey = chartKey;

            this.moduleTemplateKey = moduleTemplateKey;

            this.setDirtyFlag = true;

            blacklistedTables.Add("t_EHR_CenterConfiguration");            
        }

        public DependencyTracker(int centerID, DBDictionary dbd, NamedParameterList parameters, int chartKey, int moduleTemplateKey, bool setDirty)
            : this(centerID, dbd, parameters, chartKey, moduleTemplateKey)
        {
            this.setDirtyFlag = setDirty;
        }

        public void AddDependentTable(string tableName, bool isInsert)
        {
            allTables.Add(tableName);

            if (isInsert)
                insertedTables.Add(tableName);

            // Add a dependency for all views that reference the underlying table
            foreach (string referencingView in dbd.GetViewsByTableName(centerID, tableName))
            {
                allTables.Add(referencingView);

                if (isInsert)
                    insertedTables.Add(referencingView);
            }

            // Add a dependency for the underlying table, and all views that reference the underlying table.
            string underlyingTable;

            if (dbd.GetUnderlyingTableName(centerID, tableName, out underlyingTable))
            {
                allTables.Add(underlyingTable);

                if (isInsert)
                    insertedTables.Add(underlyingTable);

                foreach (string referencingView in dbd.GetViewsByTableName(centerID, underlyingTable))
                {
                    allTables.Add(referencingView);

                    if (isInsert)
                        insertedTables.Add(referencingView);
                }
            }            
        }
        
        public void RegisterProcDefinition(ProcDefinition def)
        {
            foreach (var dep in def.Dependencies) 
            {
                AddDependentTable(dep.TableName, true);
            }
        }

        public void RegisterTrigger(LiveEditTriggerDefinition def, string operation)
        {
            triggerDefs.Add(new Trigger(def, operation));

            foreach (AffectedTriggerTable triggerTable in def.AffectedTables)
                AddDependentTable(triggerTable.TableName, triggerTable.Operation == "I");
        }

        public void RegisterTrigger(LiveEditTriggerDefinition def, string operation, SwapKey keys)
        {
            triggerDefs.Add(new Trigger(def, operation, keys));

            foreach (AffectedTriggerTable triggerTable in def.AffectedTables)
                AddDependentTable(triggerTable.TableName, triggerTable.Operation == "I");
        }

        public void RegisterTrigger(IEnumerable<LiveEditTriggerDefinition> defs, string operation)
        {
            foreach (var def in defs)
                RegisterTrigger(def, operation);
        }

        public void RegisterTriggers(IEnumerable<LiveEditTriggerDefinition> defs, string operation, SwapKey keys)
        {
            foreach (var def in defs)
                RegisterTrigger(def, operation, keys);
        }

        public void RegisterField(Field field, string crudOp)
        {
            var primaryTableName = dbd.GetTableName(centerID, field);

            AddDependentTable(primaryTableName, crudOp=="I");

            LiveEditTriggerDefinition triggerDef = null;

            if(dbd.GetTrigger(field.dbDictionaryKey, crudOp, out triggerDef))
            {
                RegisterTrigger(triggerDef, crudOp);
            }
        }

        public IEnumerable<string> GetTableNames()
        {
            foreach (var tableName in allTables)
                yield return tableName;

            yield break;
        }

        public IEnumerable<Trigger> GetTriggers()
        {
            foreach (var trigger in triggerDefs)
                yield return trigger;

            yield break;
        }

        public IEnumerable<CRUDProcOperation> GetCRUDProcs()
        {
            HashSet<ProcDefinition> insertProcs = new HashSet<ProcDefinition>();

            HashSet<ProcDefinition> updateProcs = new HashSet<ProcDefinition>();

            // Bin the proc invocations into insert/update and update only sets. This prevents spurious invocations of the retrieve CRUD operation
            //  for BLOCs that we only want to recalculate completion for. Also filters out blacklisted tables from consideration.
            foreach (var tableName in allTables.Where(t => !blacklistedTables.Contains(t)))
            {
                foreach (ProcDefinition def in dbd.GetProcDefinitions(centerID, tableName).DistinctBy(pd => pd.CRUDProcName))
                {
                    if (insertedTables.Contains(tableName))
                        insertProcs.Add(def);
                    else
                        updateProcs.Add(def);
                }
            }

            // Also grab the CRUD proc of the triggering module if present, as NA and Notes edits won't (usually) show up in a module's dependency list
            if (moduleTemplateKey > 0)
                updateProcs.Add(dbd.GetProcDefByModuleTemplateKey(centerID, moduleTemplateKey));

            // Yield the inserts
            foreach (var def in insertProcs)
            {
                yield return new CRUDProcOperation(true, null, def, parameters, setDirtyFlag);
            }

            // Yield the updates
            foreach (var def in updateProcs)
            {
                yield return new CRUDProcOperation(false, null, def, parameters, setDirtyFlag);
            }

            yield break;
        }
    }
}