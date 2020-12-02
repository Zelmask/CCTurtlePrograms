using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text.Json;

namespace patcher
{
    class Program
    {
        static void Main(string[] args)
        {
            var json = File.ReadAllText("ScriptsToReplace.json");
            var scriptsToReplace = JsonSerializer.Deserialize<List<ScriptToReplace>>(json, new JsonSerializerOptions()
            {
                WriteIndented = true
            });
            foreach (var scriptToReplace in scriptsToReplace)
            {
                FileInfo fileInfoScript = new FileInfo(scriptToReplace.Script);
                foreach (var dest in scriptToReplace.Dests)
                {
                    switch (scriptToReplace.Action)
                    {
                        case "DELETE_IN_ALL":
                            DeleteInAll(fileInfoScript.Name, dest);
                            break;

                        default:
                            CopyAndOverwriteIfNewest(fileInfoScript, dest);
                            break;
                    }
                }
            }
        }

        private static void DeleteInAll(string scriptFileName, string dest)
        {
            var fileMatches = EnumerateFiles(dest, scriptFileName);
            foreach (var fileMatch in fileMatches)
            {
                File.Delete(fileMatch);
            }
        }

        private static void CopyAndOverwriteIfNewest(FileInfo fileInfoScript, string dest)
        {
            var fileInfoDest = new FileInfo(dest);
            var directoryDestName = Path.GetDirectoryName(fileInfoDest.FullName);
            var fileMatches = EnumerateFileInfos(directoryDestName, fileInfoScript.Name);
            if (!File.Exists(fileInfoDest.FullName))
            {
                foreach (var fileMatch in fileMatches)
                {
                    if (fileMatch.Name == System.IO.Path.GetFileNameWithoutExtension(fileInfoDest.Name))
                    {
                        File.Delete(Path.Combine(directoryDestName, fileMatch.Name));
                        break;
                    }
                }
                File.Copy(fileInfoScript.FullName, fileInfoDest.FullName, true);
            }
            else if (File.ReadAllBytes(fileInfoScript.FullName) != File.ReadAllBytes(fileInfoDest.FullName))
            {
                File.Copy(fileInfoScript.FullName, fileInfoDest.FullName, true);
            }
        }

        private static IEnumerable<string> EnumerateFiles(string directory, string pattern)
        {
            return Directory.EnumerateFiles(directory, pattern, new EnumerationOptions() { RecurseSubdirectories = true });
        }

        private static IEnumerable<FileInfo> EnumerateFileInfos(string directory, string pattern)
        {
            return EnumerateFiles(directory, pattern).Select(x => new FileInfo(x));
        }
    }
}
