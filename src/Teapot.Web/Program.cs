using System;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Hosting;

namespace Teapot.Web
{
    public class Program
    {
        public static void Main(string[] args)
        {
            System.Console.WriteLine("Starting httpstat.us");
            CreateHostBuilder(args).Build().Run();
        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.UseStartup<Startup>()
                        .UseUrls($"http://*:{Environment.GetEnvironmentVariable("PORT") ?? "5000"}");
                });
    }
}
