using System.Collections.Generic;

namespace patcher
{
    public class ScriptToReplace
    {
        public string Action { get; set; }
        public string Script { get; set; }
        public string[] Ids { get; set; }
    }
}