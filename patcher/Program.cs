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
            var scriptsToReplace = JsonSerializer.Deserialize<List<ScriptToReplace>>(json,new JsonSerializerOptions(){
                WriteIndented = true
            });
            foreach (var scriptToReplace in scriptsToReplace)
            {
                FileInfo fileInfoScript = new FileInfo(scriptToReplace.Script);
                foreach(var dest in scriptToReplace.Dests)
                {
                    var fileInfoDest = new FileInfo(dest);
                    var directoryDestName = Path.GetDirectoryName(fileInfoDest.FullName);
                    var similarFiles = new DirectoryInfo(directoryDestName).EnumerateFiles();
                    if(!File.Exists(fileInfoDest.FullName))
                    {
                        
                        foreach(var similarFile in similarFiles)
                        {
                            if(similarFile.Name==System.IO.Path.GetFileNameWithoutExtension(fileInfoDest.Name))
                            {
                                File.Delete(Path.Combine(directoryDestName,similarFile.Name));
                                break;
                            }
                        }
                        File.Copy(fileInfoScript.FullName,fileInfoDest.FullName,true);
                    }
                    else if(File.ReadAllBytes(fileInfoScript.FullName)!=File.ReadAllBytes(fileInfoDest.FullName))
                    {
                        File.Copy(fileInfoScript.FullName,fileInfoDest.FullName,true);
                    }
                }
            }
        }
    }
}
