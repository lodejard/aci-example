using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace HelloWorld.Settings
{
    public class DataProtectionSettings
    {
        public bool Enabled { get; set; } = false;

        public string KeyIdentifier { get; set; }

        public string StorageAccountIdentifier { get; set; }

        public string StorageAccountRelativePath { get; set; } = "webapp/dataprotection/keys.xml";
    }
}
