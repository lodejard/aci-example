using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.HttpsPolicy;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.Azure.KeyVault;
using Microsoft.Rest;
using HelloWorld.Settings;
using Microsoft.Azure.Storage;
using Microsoft.Azure.Storage.Auth;
using Microsoft.Azure.Management.ResourceManager.Fluent;
using Microsoft.Azure.Management.ResourceManager.Fluent.Authentication;
using Microsoft.Azure.Management.Fluent;

namespace HelloWorld
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddControllersWithViews();

            var settings = new ApplicationSettings();
            Configuration.Bind("HelloWorld", settings);

            if (settings.DataProtection.Enabled)
            {
                AzureEnvironment azureEnvironment = AzureEnvironment.FromName(settings.Azure.AzureEnvironment);

                var managedIdentityCredentials = SdkContext.AzureCredentialsFactory.FromMSI(
                    new MSILoginInformation(MSIResourceType.VirtualMachine),
                    azureEnvironment,
                    settings.Azure.TenantId);

                var azure = Azure
                    .Configure()
                    .Authenticate(managedIdentityCredentials)
                    .WithSubscription(settings.Azure.SubscriptionId);

                var storageAccount = azure.StorageAccounts.GetById(settings.DataProtection.StorageAccountIdentifier);

                var storageAccountKeys = storageAccount.GetKeys();

                var storageAccountConnectionString =
                    $"DefaultEndpointsProtocol=https;" +
                    $"AccountName={storageAccount.Name};" +
                    $"AccountKey={storageAccountKeys[0].Value};" +
                    $"EndpointSuffix={azureEnvironment.StorageEndpointSuffix}";

                var cloudStorageAccount = CloudStorageAccount.Parse(storageAccountConnectionString);

                var keyVaultClient = new KeyVaultClient(managedIdentityCredentials);

                services.AddDataProtection()
                    .PersistKeysToAzureBlobStorage(cloudStorageAccount, settings.DataProtection.StorageAccountRelativePath)
                    .ProtectKeysWithAzureKeyVault(keyVaultClient, settings.DataProtection.KeyIdentifier);
            }
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                app.UseExceptionHandler("/Home/Error");
                // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
                app.UseHsts();
            }
            // app.UseHttpsRedirection();
            app.UseStaticFiles();

            app.UseRouting();

            app.UseAuthorization();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllerRoute(
                    name: "default",
                    pattern: "{controller=Home}/{action=Index}/{id?}");
            });
        }
    }
}
