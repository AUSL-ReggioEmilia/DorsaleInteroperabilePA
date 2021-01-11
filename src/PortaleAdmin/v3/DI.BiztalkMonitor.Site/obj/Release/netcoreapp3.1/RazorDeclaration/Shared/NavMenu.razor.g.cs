// <auto-generated/>
#pragma warning disable 1591
#pragma warning disable 0414
#pragma warning disable 0649
#pragma warning disable 0169

namespace DI.BiztalkMonitor.Site.Shared
{
    #line hidden
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Threading.Tasks;
    using Microsoft.AspNetCore.Components;
#nullable restore
#line 1 "C:\Users\sandro\Source\Repos\DorsaleInteroperabilePA\Git\src\PortaleAdmin\v3\DI.BiztalkMonitor.Site\_Imports.razor"
using System.Net.Http;

#line default
#line hidden
#nullable disable
#nullable restore
#line 2 "C:\Users\sandro\Source\Repos\DorsaleInteroperabilePA\Git\src\PortaleAdmin\v3\DI.BiztalkMonitor.Site\_Imports.razor"
using Microsoft.AspNetCore.Authorization;

#line default
#line hidden
#nullable disable
#nullable restore
#line 3 "C:\Users\sandro\Source\Repos\DorsaleInteroperabilePA\Git\src\PortaleAdmin\v3\DI.BiztalkMonitor.Site\_Imports.razor"
using Microsoft.AspNetCore.Components.Authorization;

#line default
#line hidden
#nullable disable
#nullable restore
#line 4 "C:\Users\sandro\Source\Repos\DorsaleInteroperabilePA\Git\src\PortaleAdmin\v3\DI.BiztalkMonitor.Site\_Imports.razor"
using Microsoft.AspNetCore.Components.Forms;

#line default
#line hidden
#nullable disable
#nullable restore
#line 5 "C:\Users\sandro\Source\Repos\DorsaleInteroperabilePA\Git\src\PortaleAdmin\v3\DI.BiztalkMonitor.Site\_Imports.razor"
using Microsoft.AspNetCore.Components.Routing;

#line default
#line hidden
#nullable disable
#nullable restore
#line 6 "C:\Users\sandro\Source\Repos\DorsaleInteroperabilePA\Git\src\PortaleAdmin\v3\DI.BiztalkMonitor.Site\_Imports.razor"
using Microsoft.AspNetCore.Components.Web;

#line default
#line hidden
#nullable disable
#nullable restore
#line 7 "C:\Users\sandro\Source\Repos\DorsaleInteroperabilePA\Git\src\PortaleAdmin\v3\DI.BiztalkMonitor.Site\_Imports.razor"
using Microsoft.JSInterop;

#line default
#line hidden
#nullable disable
#nullable restore
#line 8 "C:\Users\sandro\Source\Repos\DorsaleInteroperabilePA\Git\src\PortaleAdmin\v3\DI.BiztalkMonitor.Site\_Imports.razor"
using DI.BiztalkMonitor.Site;

#line default
#line hidden
#nullable disable
#nullable restore
#line 9 "C:\Users\sandro\Source\Repos\DorsaleInteroperabilePA\Git\src\PortaleAdmin\v3\DI.BiztalkMonitor.Site\_Imports.razor"
using DI.BiztalkMonitor.Site.Shared;

#line default
#line hidden
#nullable disable
#nullable restore
#line 10 "C:\Users\sandro\Source\Repos\DorsaleInteroperabilePA\Git\src\PortaleAdmin\v3\DI.BiztalkMonitor.Site\_Imports.razor"
using DI.BiztalkMonitor.Site.Classes;

#line default
#line hidden
#nullable disable
#nullable restore
#line 11 "C:\Users\sandro\Source\Repos\DorsaleInteroperabilePA\Git\src\PortaleAdmin\v3\DI.BiztalkMonitor.Site\_Imports.razor"
using DI.BiztalkMonitor.Site.Components;

#line default
#line hidden
#nullable disable
#nullable restore
#line 12 "C:\Users\sandro\Source\Repos\DorsaleInteroperabilePA\Git\src\PortaleAdmin\v3\DI.BiztalkMonitor.Site\_Imports.razor"
using DI.BiztalkMonitor.DataAccess;

#line default
#line hidden
#nullable disable
#nullable restore
#line 13 "C:\Users\sandro\Source\Repos\DorsaleInteroperabilePA\Git\src\PortaleAdmin\v3\DI.BiztalkMonitor.Site\_Imports.razor"
using DI.BiztalkMonitor.DataAccess.Adapters;

#line default
#line hidden
#nullable disable
#nullable restore
#line 14 "C:\Users\sandro\Source\Repos\DorsaleInteroperabilePA\Git\src\PortaleAdmin\v3\DI.BiztalkMonitor.Site\_Imports.razor"
using DI.BiztalkMonitor.DataAccess.Data;

#line default
#line hidden
#nullable disable
#nullable restore
#line 15 "C:\Users\sandro\Source\Repos\DorsaleInteroperabilePA\Git\src\PortaleAdmin\v3\DI.BiztalkMonitor.Site\_Imports.razor"
using DI.BiztalkMonitor.DataAccess.Models;

#line default
#line hidden
#nullable disable
#nullable restore
#line 16 "C:\Users\sandro\Source\Repos\DorsaleInteroperabilePA\Git\src\PortaleAdmin\v3\DI.BiztalkMonitor.Site\_Imports.razor"
using Microsoft.Extensions.Logging;

#line default
#line hidden
#nullable disable
    public partial class NavMenu : LayoutComponentBase
    {
        #pragma warning disable 1998
        protected override void BuildRenderTree(Microsoft.AspNetCore.Components.Rendering.RenderTreeBuilder __builder)
        {
        }
        #pragma warning restore 1998
#nullable restore
#line 31 "C:\Users\sandro\Source\Repos\DorsaleInteroperabilePA\Git\src\PortaleAdmin\v3\DI.BiztalkMonitor.Site\Shared\NavMenu.razor"
       

    [CascadingParameter]
    private Task<AuthenticationState> _authenticationStateTask { get; set; }
    private System.Security.Claims.ClaimsPrincipal _user;

    private List<PortalAdminConfigurazioneMenuData> _menu = new List<PortalAdminConfigurazioneMenuData>();

    //MENU
    bool collapseNavMenu = true;
    string baseMenuClass = "navbar-collapse d-sm-inline-flex flex-sm-row-reverse";
    string NavMenuCssClass => baseMenuClass + (collapseNavMenu ? " collapse" : "");

    protected override async Task OnInitializedAsync()
    {
        //Utente corrente
        _user = (await _authenticationStateTask).User;

        await PopolateMenu();
    }

    protected async Task PopolateMenu()
    {
        try
        {
            List<PortalAdminConfigurazioneMenuData> menuTemp;

            using (PortalAdminConfigurazioneMenuAdapter configurazioneMenuRepository = _dbRepository.ConfigurazioneMenu)
            {
                menuTemp = await configurazioneMenuRepository.GetAll();
            }
            if (menuTemp != null)
            {
                foreach (PortalAdminConfigurazioneMenuData item in menuTemp)
                {
                    //Se l'utente corrente ha il Gruppo ad per poter vedere la n voce del menu l'aggiungo alla lista "menu"
                    string sIdRuoloLetture = Utility.GetSidObjectDomain(item.RuoloLettura);
                    if (_user.IsInRole(sIdRuoloLetture))
                    {
                        _menu.Add(item);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Errore durante il caricamento del menu");
        }
    }

    void ToggleNavMenu()
    {
        collapseNavMenu = !collapseNavMenu;
    }

#line default
#line hidden
#nullable disable
        [global::Microsoft.AspNetCore.Components.InjectAttribute] private ILogger<NavMenu> _logger { get; set; }
        [global::Microsoft.AspNetCore.Components.InjectAttribute] private IDBRepository _dbRepository { get; set; }
        [global::Microsoft.AspNetCore.Components.InjectAttribute] private NavigationManager NavigationManager { get; set; }
    }
}
#pragma warning restore 1591
