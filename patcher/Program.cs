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
            var scriptsToReplace = JsonSerializer.Deserialize<ScriptsToReplace>(json);
            var allComputerIds = Directory.GetDirectories(scriptsToReplace.BasePath);
            var scriptsToRemove = new List<ScriptToReplace>();
            foreach (var scriptToReplace in scriptsToReplace.Scripts)
            {
                FileInfo fileInfoScript = new FileInfo(scriptToReplace.Script);
                if (fileInfoScript.Exists)
                {
                    string[] idsToWorkWith = allComputerIds;
                    if (scriptToReplace.Ids != null && scriptToReplace.Ids.Length > 0)
                    {
                        idsToWorkWith = scriptToReplace.Ids;
                    }
                    foreach (var id in idsToWorkWith)
                    {
                        switch (scriptToReplace.Action)
                        {
                            case "DELETE_IN_ALL":
                                DeleteInAll(fileInfoScript.Name, Path.Combine(scriptsToReplace.BasePath, id));
                                scriptsToRemove.Add(scriptToReplace);
                                break;
                            case "CREATE":
                                OverwriteIfNewest(fileInfoScript, Path.Combine(scriptsToReplace.BasePath, id,fileInfoScript.Name),true);
                                scriptsToRemove.Add(scriptToReplace);
                                break;
                            default:
                                OverwriteIfNewest(fileInfoScript, Path.Combine(scriptsToReplace.BasePath, id,fileInfoScript.Name),false);
                                break;
                        }
                    }
                }
            }
            // if (scriptsToRemove.Count > 0)
            // {
            //     foreach (var scriptToRemove in scriptsToRemove)
            //     {
            //         scriptsToReplace.Scripts.Remove(scriptToRemove);
            //     }
            //     File.WriteAllText("ScriptsToReplace.json",JsonSerializer.Serialize<ScriptsToReplace>(scriptsToReplace, new JsonSerializerOptions() { WriteIndented = true }));
            // }
        }

        private static void DeleteInAll(string scriptFileName, string dest)
        {
            var fileMatches = EnumerateFiles(dest, scriptFileName);
            foreach (var fileMatch in fileMatches)
            {
                File.Delete(fileMatch);
            }
        }

        private static void OverwriteIfNewest(FileInfo fileInfoScript, string dest,bool createIfNotExist)
        {
            var fileInfoDest = new FileInfo(dest);
            var directoryDestName = Path.GetDirectoryName(fileInfoDest.FullName);
            var files = EnumerateFileInfos(directoryDestName, "*.lua");
            if (!File.Exists(fileInfoDest.FullName))
            {
                foreach (var file in files)
                {
                    if (file.Name == System.IO.Path.GetFileNameWithoutExtension(fileInfoDest.Name))
                    {
                        File.Delete(Path.Combine(directoryDestName, file.Name));
                        File.Copy(fileInfoScript.FullName, fileInfoDest.FullName, true);
                        break;
                    }else if(createIfNotExist)
                    {
                        File.Copy(fileInfoScript.FullName, fileInfoDest.FullName, true);
                    }
                }
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
