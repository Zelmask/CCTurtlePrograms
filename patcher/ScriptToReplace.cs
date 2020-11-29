using System.Collections.Generic;

namespace patcher
{
    public class ScriptToReplace
    {
        public string Script { get; set; }
        public List<string> Dests { get; set; }
    }
}