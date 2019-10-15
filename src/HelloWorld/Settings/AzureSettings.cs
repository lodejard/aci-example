using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace HelloWorld.Settings
{
    public class AzureSettings
    {
        public string AzureEnvironment { get; set; } = "AzureGlobalCloud";

        public string TenantId { get; set; }

        public string SubscriptionId { get; set; }
    }
}
