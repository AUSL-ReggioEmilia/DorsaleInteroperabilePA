using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection.Metadata.Ecma335;
using System.Threading.Tasks;

namespace DI.BiztalkMonitor.Site.Pages
{
    public class HostModel: PageModel
    {
        // Il seguente codice deriva dal seguente esempio su stackOverflow: 
        // https://stackoverflow.com/questions/59538318/how-to-use-the-httpcontext-object-in-server-side-blazor-to-retrieve-information

        private readonly IHttpContextAccessor _httpContextAccssor;

        public HostModel(IHttpContextAccessor httpContextAccssor)
        {
            _httpContextAccssor = httpContextAccssor;
        }

        public string UserAgent =>  _httpContextAccssor.HttpContext.Request.Headers["User-Agent"];
    }
}
