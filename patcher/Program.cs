using System;
using System.IO;
using System.Linq;
using System.Reflection;

namespace patcher
{
    class Program
    {
        private static string path;

        static void Main(string[] args)
        {
            Console.WriteLine("Welcome to the patcher");
            string rootDir = Path.GetDirectoryName(Assembly.GetEntryAssembly().Location);
            var potato = Directory.EnumerateFiles(rootDir, "*", SearchOption.AllDirectories).ToList();
            var codeFiles = Directory.EnumerateDirectories(rootDir).SelectMany(x=> Directory.EnumerateFiles(x, "*", SearchOption.AllDirectories)).ToList();
            Console.WriteLine(codeFiles);
            path = Console.ReadLine();

        }
    }
}
