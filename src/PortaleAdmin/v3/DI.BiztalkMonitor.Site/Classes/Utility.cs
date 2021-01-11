using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Principal;
using System.Threading.Tasks;
using System.Xml.Linq;
using Microsoft.JSInterop;


namespace DI.BiztalkMonitor.Site.Classes
{
    public static class Utility
    {
        public static string GetSidObjectDomain(string name)
        {
            try
            {
                NTAccount ntRole = new NTAccount(name);
                IdentityReference irGroup = ntRole.Translate(typeof(SecurityIdentifier));

                return irGroup.Value;
            }
            catch (Exception)
            {
                //Non esiste il gruppo!
                return "";
            }
        }

        public async static Task SaveAsZip(IJSRuntime js, string filename, byte[] data)
        {
            await js.InvokeAsync<object>(
                "FileSaveAsZip",
                filename,
                data);
        }

        public async static Task SaveAs(IJSRuntime js, string filename, string data)
        {
            await js.InvokeAsync<object>(
                "FileSaveAs",
                filename,
                data);
        }

        public async static Task OpenXMlNewTab(IJSRuntime js, string id)
        {
            await js.InvokeAsync<object>(
                "openXmlNewTab",
                id);
        }
    }
}
