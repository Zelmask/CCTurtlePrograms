using System.Collections.Generic;

namespace patcher
{
    public class ScriptsToReplace
    {
        public string BasePath { get; set; }
        public List<ScriptToReplace> Scripts { get; set; }
    }
}