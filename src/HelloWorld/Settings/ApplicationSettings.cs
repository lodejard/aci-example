using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace HelloWorld.Settings
{
    public class ApplicationSettings
    {
        public AzureSettings Azure { get; set; } = new AzureSettings();
        public DataProtectionSettings DataProtection { get; set; } = new DataProtectionSettings();
    }
}
