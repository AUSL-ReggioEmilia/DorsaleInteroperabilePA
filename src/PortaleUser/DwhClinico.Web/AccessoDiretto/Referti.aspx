<%@ Page Language="VB" MasterPageFile="~/AccessoDiretto/AccessoDiretto.master" AutoEventWireup="false" Inherits="DwhClinico.Web.AccessoDiretto_Referti"
    Title="" CodeBehind="Referti.aspx.vb" %>

<%@ Register Src="~/UserControl/ucTestataPaziente.ascx" TagPrefix="uc1" TagName="ucTestataPaziente" %>
<%@ Register Src="~/UserControl/ucLegenda.ascx" TagPrefix="uc1" TagName="ucLegenda" %>
<%@ Register Src="~/UserControl/ucInfoPaziente.ascx" TagPrefix="uc1" TagName="ucInfoPaziente" %>
<%@ Register Src="~/UserControl/ucModaleInvioLinkPerAccessoDiretto.ascx" TagPrefix="uc1" TagName="ucModaleInvioLinkPerAccessoDiretto" %>


<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" runat="Server">
    <%-- Style Sheet per il calendario --%>
    <link href="../Content/StyleCalendar.css" rel="stylesheet" />

    <div class="row" id="divErrorMessage" visible="false" runat="server" enableviewstate="false">
        <div class="col-sm-12">
            <div class="alert alert-danger">
                <asp:Label ID="lblErrorMessage" runat="server" CssClass="text-danger"></asp:Label>
            </div>
        </div>
    </div>


    <div class="row divPage" id="divPage" runat="server">
        <div class="col-sm-9 col-md-9 col-lg-10">
            <%-- TESTATA PAZIENTE --%>
            <uc1:ucTestataPaziente runat="server" ID="ucTestataPaziente" />

            <!-- CONTENITORE TAB E TABELLE-->
            <div id="TableReportContainer" runat="server">

                <!-- NAVBAR TAB -->
                <ul class="nav nav-tabs">

                    <%-- TAB REFERTI --%>
                    <li id="tabLnkReferti" runat="server">
                        <asp:LinkButton ID="lnkReferti" CssClass="ReportGroupUnSelectedTab" runat="server"
                            OnCommand="SelectView" CommandArgument="ViewReferti" CommandName="TabClick"
                            CausesValidation="False" Font-Underline="False">Referti</asp:LinkButton>
                    </li>

                    <%-- TAB CALENDARIO --%>
                    <li id="tabLnkCalendario" runat="server">
                        <asp:LinkButton ID="lnkCalendario" CssClass="ReportGroupUnSelectedTab" runat="server"
                            OnCommand="SelectView" CommandArgument="ViewCalendario" CommandName="TabClick"
                            CausesValidation="False" Font-Underline="False">Calendario</asp:LinkButton>
                    </li>

                    <%-- TAB EPISODI E REFERTI --%>
                    <li id="tabLnkRefertiEpisodi" runat="server">
                        <asp:LinkButton ID="lnkRefertiEpisodi" CssClass="ReportGroupUnSelectedTab" runat="server"
                            OnCommand="SelectView" CommandArgument="ViewRefertiEpisodi" CommandName="TabClick"
                            CausesValidation="False" Font-Underline="False">Episodi e Referti</asp:LinkButton>
                    </li>

                    <%-- TAB RISULTATO MATRICE --%>
                    <li id="tabLnkRisultatoMatrice" runat="server">
                        <asp:LinkButton ID="lnkRisultatoMatrice" CssClass="ReportGroupUnSelectedTab" runat="server"
                            OnCommand="SelectView" CommandArgument="ViewRisultatoMatrice" CommandName="TabClick"
                            Font-Underline="False">Risultato matrice</asp:LinkButton>
                    </li>

                    <%-- TAB IMPEGNATIVE --%>
                    <li id="tabLnkPrescrizioni" runat="server">
                        <asp:LinkButton ID="lnkPrescrizioni" CssClass="ReportGroupUnSelectedTab" runat="server"
                            OnCommand="SelectView" CommandArgument="ViewPrescrizioni" CommandName="TabClick"
                            Font-Underline="False">Impegnative</asp:LinkButton>
                    </li>

                    <%-- TAB SCHEDE PAZIENTE --%>
                    <li id="tabLnkSchedePaziente" runat="server">
                        <asp:LinkButton ID="lnkSchedePaziente" CssClass="ReportGroupUnSelectedTab" runat="server"
                            OnCommand="SelectView" CommandArgument="ViewSchedePaziente" CommandName="TabClick"
                            Font-Underline="False">Schede Paziente</asp:LinkButton>
                    </li>

                    <%-- TAB NOTE ANAMNESTICHE --%>
                    <li id="tabLnkNoteAnamnestiche" runat="server">
                        <asp:LinkButton ID="lnkNoteAnamnestiche" CssClass="ReportGroupUnSelectedTab"
                            OnCommand="SelectView" CommandArgument="ViewNoteAnamnestiche"
                            Font-Underline="False" CommandName="TabClick" Text="Note Anamnestiche" runat="server" />
                    </li>

                    <%-- LABEL "Documentazione dal" --%>
                    <li class="navbar-right" style="margin-top: 20px; margin-right: 0px;">Documentazione dal
                        <asp:Label ID="lblDataFiltri" runat="server" />
                    </li>
                </ul>

                <asp:MultiView ID="MultiViewMain" runat="server">

                    <%-- VIEW REFERTI --%>
                    <asp:View ID="ViewReferti" runat="server">
                        <div id="divMessageReferti" class="jumbotron message-custom-padding" runat="server" visible="false" enableviewstate="false">
                        </div>
                        <div id="divWebGridReferti" runat="server">
                            <div class="table-responsive">

                                <%-- LISTA REFERTI --%>
                                <asp:GridView ID="WebGridReferti" EnableViewState="false"
                                    DataKeyNames="Id" ShowHeader="false" ClientIDMode="Static" GridLines="None" CssClass="table table-bordered table-condensed small" runat="server"
                                    AutoGenerateColumns="False" DataSourceID="DataSourceMain">
                                    <Columns>

                                         <asp:TemplateField ItemStyle-Width="2%" HeaderStyle-Width="2%" ItemStyle-CssClass="icon-align">
                                            <ItemTemplate>
                                                <%# GetImgPresenzaWarning(Container.DataItem) %>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField ItemStyle-Width="2%" HeaderStyle-Width="2%" ItemStyle-CssClass="icon-align">
                                            <ItemTemplate>
                                                <%# DwhClinico.Web.UserInterface.GetImgPresenzaReferti(CType(Container.DataItem, DwhClinico.Web.WcfDwhClinico.RefertoListaType), Me)  %>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField ItemStyle-Width="2%" HeaderStyle-Width="2%" ItemStyle-CssClass="icon-align">
                                            <ItemTemplate>
                                                <asp:Image ID="ImgStatoRichisistestaCodice" runat="server" ImageUrl='<%# GetStatoImageUrl2(Container.DataItem) %>' />
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField ItemStyle-Width="2%" HeaderStyle-Width="2%" ItemStyle-CssClass="icon-align">
                                            <ItemTemplate>
                                                <asp:HyperLink ID="hlRefertoImg" runat="server" NavigateUrl='<%# GetUrlLinkReferto(Container.DataItem) %>'>
                                                                             <asp:Image runat="server" ImageUrl="<%#GetUrlIconaTipoReferto(Container.DataItem)%>"></asp:Image>
                                                </asp:HyperLink>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField ItemStyle-Width="2%" HeaderStyle-Width="2%" ItemStyle-CssClass="icon-align">
                                            <ItemTemplate>
                                                <%# GetIconaStatoInvioSole(Container.DataItem) %>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Descrizione">
                                            <ItemTemplate>
                                                <asp:HyperLink ID="hlReferto" runat="server" NavigateUrl='<%# GetUrlLinkReferto(Container.DataItem) %>'
                                                    Text='<%# GetStringaDescrittiva(Container.DataItem) %>'></asp:HyperLink>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Anteprima" ItemStyle-Width="20%" HeaderStyle-Width="20%">
                                            <ItemTemplate>
                                                <%# GetLabelAnteprima(Container.DataItem) %>
                                                <%# GetLabelAvvertenze(Container.DataItem) %>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Episodio">
                                            <ItemTemplate>
                                                <%# GetDataEvento(Container.DataItem) %>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Priorità">
                                            <ItemTemplate>
                                                <%# GetPriorita(Container.DataItem) %>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Numero Referto">
                                            <ItemTemplate>
                                                <%# GetNumeroReferto(Container.DataItem) %>
                                                <p style="margin-top: 8px;">
                                                    <%# GetNumeroVersione(Container.DataItem) %>
                                                </p>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>

                                <%-- ATTENZIONE: Viene impostato  SelectMethod="X" TypeName="X" per fare eseguire l'evento Selecting in caso di qualche errore che fa si che non vengano impostati i parametri corretti --%>
                                <asp:ObjectDataSource ID="DataSourceMain" runat="server" SelectMethod="X" TypeName="X" OldValuesParameterFormatString="original_{0}">
                                    <SelectParameters>
                                    </SelectParameters>
                                </asp:ObjectDataSource>
                            </div>
                        </div>
                    </asp:View>

                    <%-- VIEW CALENDARIO --%>
                    <asp:View ID="ViewCalendario" runat="server">

                        <asp:UpdatePanel ID="UpdatePanelCalendario" runat="server" ChildrenAsTriggers="false" UpdateMode="Conditional">
                            <ContentTemplate>

                                <%-- BOTTONI NAVIGAZIONE CALENDARIO --%>
                                <div class="row text-center" style="margin-top: 10px; margin-bottom: 5px; font-weight: 700">
                                    <% If CalendarAdapter IsNot Nothing AndAlso CalendarAdapter.IsPreviousYearAvaible Then %>
                                    <asp:LinkButton ID="lnk_annoFuturo" runat="server" OnClick="PreviousCalendarBtn_Click" ToolTip="Anno futuro"><span class="glyphicon glyphicon-chevron-left"></span></asp:LinkButton>
                                    <% End If %>

                                    <asp:Label ID="lblCurrentYear" runat="server"></asp:Label>

                                    <% If CalendarAdapter IsNot Nothing AndAlso CalendarAdapter.IsNextYearAvaible Then %>
                                    <asp:LinkButton ID="lnk_annoPassato" runat="server" OnClick="NextCalendarBtn_Click" ToolTip="Anno passato"><span class="glyphicon glyphicon-chevron-right"></span></asp:LinkButton>
                                    <%End if %>
                                </div>

                                <%-- CALENDARIO ANNUALE --%>
                                <div class="row">
                                    <asp:Repeater ID="RepeaterMesi" runat="server" OnItemDataBound="RepeaterMesi_ItemDataBound">
                                        <ItemTemplate>

                                            <div class="col-xs-3 col-sm-2 col-md-2 col-lg-1" style="margin-bottom: 10px">
                                                <div class="text-center small" style="margin: 10px 0; font-weight: 600;">
                                                    <asp:Literal runat="server" Text='<%# DataBinder.Eval(Container.DataItem, "Nome") %>' />
                                                </div>

                                                <%-- GRIGLIA PER OGNI MESE --%>
                                                <asp:GridView ID="GrigliaMese" runat="server" ShowHeader="false" ShowFooter="false" OnRowCommand="GrigliaMese_RowCommand" align="center"
                                                    AllowPaging="false" AllowSorting="false" AutoGenerateColumns="false" BorderStyle="None" GridLines="None">

                                                    <%-- SPIEGAZIONE FUNZIONAMENTO CALENDARIO ANNUALE:
                                                         Ogni mese ha 6 colonne (settimane) e 7 righe (giorni della settimana). --> Fare riferimento alle classi in Components>Calendario
                                                         Il colore e il bordo dei panel viene determinato tramite l'uso di classi CSS (definite in StyleCalendar), 
                                                         assegnate dinamicamente tramite la property classeCss del CalendarDa, che restituisce una stringa con le classi da applicare.
                                                         L'IIf serve per rendere cliccabili solo i giorni in cui ci sono referti (Rank > 0) oppure se all'interno di un ricovero (episodio). 
                                                         Per lo scopo si usa " ‎" che è una carattere invisibile (non uno spazio). Viene usato per rendere cliccabile il LinkButton senza far vedere alcun testo --%>

                                                    <Columns>
                                                        <asp:TemplateField>
                                                            <ItemTemplate>

                                                                <asp:Panel ID="PanelWeek1" runat="server" CssClass='<%# DataBinder.Eval(Container.DataItem, "ColWeek1.ClasseCss")%>'>


                                                                    <asp:LinkButton Text='<%# DataBinder.Eval(Container.DataItem, "ColWeek1.Text")%>'
                                                                        runat="server" CommandName="SetDayDetail"
                                                                        CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ColWeek1.Giorno")%>'
                                                                        title='<%# DataBinder.Eval(Container.DataItem, "ColWeek1.ToolTip")%>'>
                                                                    </asp:LinkButton>

                                                                </asp:Panel>

                                                            </ItemTemplate>
                                                        </asp:TemplateField>

                                                        <asp:TemplateField>
                                                            <ItemTemplate>

                                                                <asp:Panel ID="PanelWeek2" runat="server" CssClass='<%# DataBinder.Eval(Container.DataItem, "ColWeek2.ClasseCss")%>'>

                                                                    <asp:LinkButton Text='<%# DataBinder.Eval(Container.DataItem, "ColWeek2.Text")%>'
                                                                        runat="server" CommandName="SetDayDetail"
                                                                        CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ColWeek2.Giorno")%>'
                                                                        title='<%# DataBinder.Eval(Container.DataItem, "ColWeek2.ToolTip")%>'>
                                                                    </asp:LinkButton>

                                                                </asp:Panel>

                                                            </ItemTemplate>
                                                        </asp:TemplateField>

                                                        <asp:TemplateField>
                                                            <ItemTemplate>

                                                                <asp:Panel ID="PanelWeek3" runat="server" CssClass='<%# DataBinder.Eval(Container.DataItem, "ColWeek3.ClasseCss")%>'>

                                                                    <asp:LinkButton Text='<%# DataBinder.Eval(Container.DataItem, "ColWeek3.Text")%>'
                                                                        runat="server" CommandName="SetDayDetail"
                                                                        CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ColWeek3.Giorno")%>'
                                                                        title='<%# DataBinder.Eval(Container.DataItem, "ColWeek3.ToolTip")%>'>
                                                                    </asp:LinkButton>

                                                                </asp:Panel>

                                                            </ItemTemplate>
                                                        </asp:TemplateField>

                                                        <asp:TemplateField>
                                                            <ItemTemplate>

                                                                <asp:Panel ID="PanelWeek4" runat="server" CssClass='<%# DataBinder.Eval(Container.DataItem, "ColWeek4.ClasseCss")%>'>

                                                                    <asp:LinkButton Text='<%# DataBinder.Eval(Container.DataItem, "ColWeek4.Text")%>'
                                                                        runat="server" CommandName="SetDayDetail"
                                                                        CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ColWeek4.Giorno")%>'
                                                                        title='<%# DataBinder.Eval(Container.DataItem, "ColWeek4.ToolTip")%>'>
                                                                    </asp:LinkButton>

                                                                </asp:Panel>

                                                            </ItemTemplate>
                                                        </asp:TemplateField>

                                                        <asp:TemplateField>
                                                            <ItemTemplate>

                                                                <asp:Panel ID="PanelWeek5" runat="server" CssClass='<%# DataBinder.Eval(Container.DataItem, "ColWeek5.ClasseCss")%>'>

                                                                    <asp:LinkButton Text='<%# DataBinder.Eval(Container.DataItem, "ColWeek5.Text")%>'
                                                                        runat="server" CommandName="SetDayDetail"
                                                                        CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ColWeek5.Giorno")%>'
                                                                        title='<%# DataBinder.Eval(Container.DataItem, "ColWeek5.ToolTip")%>'>
                                                                    </asp:LinkButton>

                                                                </asp:Panel>

                                                            </ItemTemplate>
                                                        </asp:TemplateField>

                                                        <asp:TemplateField>
                                                            <ItemTemplate>

                                                                <asp:Panel ID="PanelWeek6" runat="server" CssClass='<%# DataBinder.Eval(Container.DataItem, "ColWeek6.ClasseCss")%>'>

                                                                    <asp:LinkButton Text='<%# DataBinder.Eval(Container.DataItem, "ColWeek6.Text")%>'
                                                                        runat="server" CommandName="SetDayDetail"
                                                                        CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ColWeek6.Giorno")%>'
                                                                        data-html="true" title='<%# DataBinder.Eval(Container.DataItem, "ColWeek6.ToolTip")%>'>
                                                                    </asp:LinkButton>

                                                                </asp:Panel>

                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                    </Columns>

                                                </asp:GridView>

                                            </div>

                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>

                            </ContentTemplate>
                            <Triggers>
                                <asp:AsyncPostBackTrigger ControlID="lnk_annoFuturo" EventName="Click" />
                                <asp:AsyncPostBackTrigger ControlID="lnk_annoPassato" EventName="Click" />
                            </Triggers>
                        </asp:UpdatePanel>


                        <%--GRIDVIEW DETAGLIO REFERTI--%>
                        <asp:UpdatePanel ID="UpdatePanelDettaglio" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="false">
                            <ContentTemplate>
                                <div class="row">
                                    <div class="col-sm-12">
                                        <asp:GridView ID="WebGridDettaglioCalendario" EnableViewState="false" DataKeyNames="Id,AziendaErogante,SistemaErogante,Cognome,Nome,NumeroNosologico,NumeroReferto"
                                            AllowSorting="false" ShowHeader="false" ClientIDMode="Static" GridLines="None" CssClass="table table-bordered table-condensed small" runat="server"
                                            AutoGenerateColumns="False">
                                            <Columns>
                                                <asp:TemplateField ItemStyle-Width="2%" HeaderStyle-Width="2%" ItemStyle-CssClass="icon-align">
                                                    <ItemTemplate>
                                                        <asp:CheckBox ID="chkSelect" AutoPostBack="false" CssClass="chkSelect" runat="server" EnableViewState="true" Visible="true" />
                                                    </ItemTemplate>
                                                </asp:TemplateField>

                                                <asp:TemplateField ItemStyle-Width="2%" HeaderStyle-Width="2%" ItemStyle-CssClass="icon-align">
                                                    <ItemTemplate>
                                                        <%# GetImgPresenzaReferti(Container.DataItem) %>
                                                    </ItemTemplate>
                                                </asp:TemplateField>

                                                <asp:TemplateField ItemStyle-Width="2%" HeaderStyle-Width="2%" ItemStyle-CssClass="icon-align">
                                                    <ItemTemplate>
                                                        <asp:Image ID="ImgStatoRichisistestaCodice" runat="server" ImageUrl='<%# GetStatoImageUrl2(Container.DataItem) %>' />
                                                    </ItemTemplate>
                                                </asp:TemplateField>

                                                <asp:TemplateField ItemStyle-Width="2%" HeaderStyle-Width="2%" ItemStyle-CssClass="icon-align">
                                                    <ItemTemplate>
                                                        <asp:HyperLink ID="hlRefertoImg" runat="server" NavigateUrl='<%# GetUrlLinkReferto(Container.DataItem) %>'>
                                                                            <asp:Image runat="server" ImageUrl="<%#GetUrlIconaTipoReferto(Container.DataItem)%>" />
                                                        </asp:HyperLink>
                                                    </ItemTemplate>
                                                </asp:TemplateField>

                                                <asp:TemplateField ItemStyle-Width="2%" HeaderStyle-Width="2%" ItemStyle-CssClass="icon-align">
                                                    <ItemTemplate>
                                                        <%# GetIconaStatoInvioSole(Container.DataItem) %>
                                                    </ItemTemplate>
                                                </asp:TemplateField>

                                                <asp:TemplateField HeaderText="Descrizione">
                                                    <ItemTemplate>
                                                        <asp:HyperLink ID="hlReferto" runat="server" NavigateUrl='<%# GetUrlLinkReferto(Container.DataItem) %>'
                                                            Text='<%# GetStringaDescrittiva(Container.DataItem) %>'></asp:HyperLink>
                                                    </ItemTemplate>
                                                </asp:TemplateField>

                                                <asp:TemplateField HeaderText="Anteprima" ItemStyle-Width="20%" HeaderStyle-Width="20%">
                                                    <ItemTemplate>
                                                        <%# GetLabelAnteprima(Container.DataItem) %>
                                                        <%# GetLabelAvvertenze(Container.DataItem) %>
                                                    </ItemTemplate>
                                                </asp:TemplateField>

                                                <asp:TemplateField HeaderText="Episodio">
                                                    <ItemTemplate>
                                                        <%# GetDataEvento(Container.DataItem) %>
                                                    </ItemTemplate>
                                                </asp:TemplateField>

                                                <asp:TemplateField HeaderText="Priorità">
                                                    <ItemTemplate>
                                                        <%# GetPriorita(Container.DataItem) %>
                                                    </ItemTemplate>
                                                </asp:TemplateField>

                                                <asp:TemplateField HeaderText="Numero Referto">
                                                    <ItemTemplate>
                                                        <%# GetNumeroReferto(Container.DataItem) %>
                                                        <p style="margin-top: 8px;">
                                                            <%# GetNumeroVersione(Container.DataItem) %>
                                                        </p>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                            </Columns>
                                        </asp:GridView>
                                    </div>
                                </div>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </asp:View>

                    <%-- VIEW EPISODI E REFERTI --%>
                    <asp:View ID="ViewRefertiEpisodi" runat="server">
                        <div id="divMessageEpisodi" class="jumbotron message-custom-padding" runat="server" visible="false" enableviewstate="false">
                        </div>
                        <div id="divWebGridRefertiEpisodi" runat="server">
                            <div class="table-responsive">
                                <asp:GridView ShowHeader="false" ClientIDMode="Static" EnableViewState="false" ID="WebGridRefertiEpisodi" AllowPaging="true" AllowSorting="true" runat="server"
                                    DataSourceID="DataSourceEpisodi" AutoGenerateColumns="False" DataKeyNames="NumeroNosologico"
                                    CssClass=" table table-bordered table-condensed small">
                                    <Columns>
                                        <asp:TemplateField ItemStyle-Width="2%" HeaderStyle-Width="2%" ItemStyle-CssClass="icon-align">
                                            <ItemTemplate>
                                                <%-- Contiene btn generato lato server per il collassamento delle righe--%>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField ItemStyle-Width="2%" HeaderStyle-Width="2%" ItemStyle-CssClass="icon-align">
                                            <ItemTemplate>
                                                <%# GetSimboloTipoEpisodioRicovero(Container.DataItem)%>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField ItemStyle-Width="5%" HeaderStyle-Width="5%" ItemStyle-CssClass="icon-align">
                                            <ItemTemplate>
                                                <%# GetTipoEpisodioDescrizione(Container.DataItem)%>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Stato Episodio">
                                            <ItemTemplate>
                                                <%# GetStatoEpisodio(Container.DataItem)%>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Accettazione">
                                            <ItemTemplate>
                                                <%# GetInfoAccettazione(Container.DataItem)%>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Nosologico">
                                            <ItemTemplate>
                                                <%# GetNosologico(Container.DataItem)%>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField ItemStyle-Width="10%" HeaderStyle-Width="10%">
                                            <ItemTemplate>
                                                <button onclick="doPostBack('<%# Eval("Id") %>');" type="button" data-episodioid='<%# Eval("Id") %>' class="btn btn-link btn-xs">
                                                    Dettaglio episodio
                                                </button>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField>
                                            <ItemTemplate>
                                                <asp:GridView ID="WebGridrefertiPerNosologico" ShowHeader="false" OnRowDataBound="WebGridrefertiPerNosologico_RowDataBound"
                                                    DataKeyNames="Id" ClientIDMode="Static" GridLines="None" CssClass="table table-bordered table-condensed" runat="server" AutoGenerateColumns="False" DataSourceID="DataSourceRefertiPerNosologico">
                                                    <Columns>
                                                        <asp:TemplateField ItemStyle-Width="2%" HeaderStyle-Width="2%" ItemStyle-CssClass="icon-align">
                                                            <ItemTemplate>
                                                                <%# GetImgPresenzaReferti(Container.DataItem) %>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>

                                                        <asp:TemplateField ItemStyle-Width="2%" HeaderStyle-Width="2%" ItemStyle-CssClass="icon-align">
                                                            <ItemTemplate>
                                                                <asp:Image ID="ImgStatoRichisistestaCodice" runat="server" ImageUrl='<%# GetStatoImageUrl2(Container.DataItem) %>' />
                                                            </ItemTemplate>
                                                        </asp:TemplateField>

                                                        <asp:TemplateField ItemStyle-Width="2%" HeaderStyle-Width="2%" ItemStyle-CssClass="icon-align">
                                                            <ItemTemplate>
                                                                <asp:HyperLink ID="hlRefertoImg" runat="server" NavigateUrl='<%# GetUrlLinkReferto(Container.DataItem) %>'>
                                                                                        <asp:Image runat="server" ImageUrl="<%#GetUrlIconaTipoReferto(Container.DataItem)%>"></asp:Image>
                                                                </asp:HyperLink>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>

                                                        <asp:TemplateField ItemStyle-Width="2%" HeaderStyle-Width="2%" ItemStyle-CssClass="icon-align">
                                                            <ItemTemplate>
                                                                <%# GetIconaStatoInvioSole(Container.DataItem) %>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>

                                                        <asp:TemplateField HeaderText="Descrizione">
                                                            <ItemTemplate>
                                                                <asp:HyperLink ID="hlReferto" runat="server" NavigateUrl='<%# GetUrlLinkReferto(Container.DataItem) %>'
                                                                    Text='<%# GetStringaDescrittiva(Container.DataItem) %>'></asp:HyperLink>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>

                                                        <asp:TemplateField HeaderText="Anteprima">
                                                            <ItemTemplate>
                                                                <%# GetLabelAnteprima(Container.DataItem) %>
                                                                <%# GetLabelAvvertenze(Container.DataItem) %>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>

                                                        <asp:TemplateField HeaderText="Episodio">
                                                            <ItemTemplate>
                                                                <%# GetDataEvento(Container.DataItem) %>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>

                                                        <asp:TemplateField HeaderText="Priorità">
                                                            <ItemTemplate>
                                                                <%# GetPriorita(Container.DataItem) %>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>

                                                        <asp:TemplateField HeaderText="Numero Referto">
                                                            <ItemTemplate>
                                                                <%# GetNumeroReferto(Container.DataItem) %>
                                                                <p style="margin-top: 8px;">
                                                                    <%# GetNumeroVersione(Container.DataItem) %>
                                                                </p>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                    </Columns>
                                                </asp:GridView>
                                                <asp:ObjectDataSource ID="DataSourceRefertiPerNosologico" runat="server" SelectMethod="GetData"
                                                    TypeName="DwhClinico.Web.CustomDataSource.AccessoDirettoRefertiCercaPerNosologico" OldValuesParameterFormatString="original_{0}"
                                                    OnSelecting="DataSourceRefertiPerNosologico_Selecting" OnSelected="DataSourceRefertiPerNosologico_Selected">
                                                    <SelectParameters>
                                                        <asp:Parameter Name="Token" Type="Object"></asp:Parameter>
                                                        <asp:Parameter Name="Ordinamento" Type="String"></asp:Parameter>
                                                        <asp:Parameter Name="ByPassaConsenso" Type="Boolean"></asp:Parameter>
                                                        <asp:Parameter Name="Nosologico" Type="String"></asp:Parameter>
                                                        <asp:Parameter Name="Azienda" Type="String"></asp:Parameter>
                                                        <asp:Parameter Name="lstFiltriTipiReferto" Type="Object"></asp:Parameter>
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>

                                <%-- ATTENZIONE: Viene impostato  SelectMethod="X" TypeName="X" per fare eseguire l'evento Selecting in caso di qualche errore che fa si che non vengano impostati i parametri corretti --%>
                                <asp:ObjectDataSource ID="DataSourceEpisodi" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="X" TypeName="X">
                                    <SelectParameters>
                                    </SelectParameters>
                                </asp:ObjectDataSource>
                            </div>
                        </div>
                    </asp:View>

                    <%-- VIEW MATRICE --%>
                    <asp:View ID="ViewRisultatoMatrice" runat="server">
                        <div id="divMessageMatrice" class="jumbotron message-custom-padding" runat="server" visible="false" enableviewstate="false">
                        </div>

                        <div class="table-responsive">
                            <asp:Button ID="btnCollapseMatrice" ClientIDMode="Static" class="btn btn-default btn-xs" Style="margin-top: 5px; margin-bottom: 5px;" ng-opened="0" Text="Chiudi tutte le sezioni" runat="server" OnClientClick="changeCollapseBtnText();return false;" />
                            <asp:Xml ID="XmlRisultatoMatrice" runat="server" TransformSource="~/Xslt/MatricePrestazioni.xsl"></asp:Xml>

                            <%-- ATTENZIONE: Viene impostato  SelectMethod="X" TypeName="X" per fare eseguire l'evento Selecting in caso di qualche errore che fa si che non vengano impostati i parametri corretti --%>
                            <asp:ObjectDataSource ID="DataSourcePrestazioniMatrice" runat="server"
                                OldValuesParameterFormatString="original_{0}" SelectMethod="X" TypeName="X">
                                <SelectParameters>
                                </SelectParameters>
                            </asp:ObjectDataSource>
                        </div>
                    </asp:View>

                    <%-- VIEW PRESCRIZIONI --%>
                    <asp:View ID="ViewPrescrizioni" runat="server">
                        <div id="divMessagePrescrizioni" class="jumbotron message-custom-padding" runat="server" visible="false" enableviewstate="false">
                        </div>
                        <div id="divWebGridPrescrizione" runat="server">
                            <div class="table-responsive">
                                <asp:GridView runat="server" EnableViewState="false" ShowHeader="true" ID="WebGridPrescrizioni" AutoGenerateColumns="False"
                                    DataSourceID="DataSourcePrescrizioni" CssClass="table table-striped table-condensed table-bordered small" DefaultColumnWidth=""
                                    DefaultRowHeight="" AllowPaging="True">
                                    <Columns>
                                        <asp:BoundField DataField="TipoPrescrizione" HeaderText="Tipo"
                                            ReadOnly="True" SortExpression="TipoPrescrizione" />

                                        <asp:TemplateField HeaderText="Data">
                                            <ItemTemplate>
                                                <%# GetPrescrizioneDataPrescrizione(Container.DataItem) %>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="NRE">
                                            <ItemTemplate>
                                                <%# GetPrescrizioneNumero(Container.DataItem) %>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Prescrittore">
                                            <ItemTemplate>
                                                <%# GetPrescrizioneMedicoPrescrittoreDesc(Container.DataItem) %>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="">
                                            <ItemTemplate>
                                                <%# GetPrescrizioneEsenzioneCodici(Container.DataItem) %>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="">
                                            <ItemTemplate>
                                                <%# GetPrescrizioniPrioritaCodice(Container.DataItem) %>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Quesito-Indicazioni" ItemStyle-Width="30%" HeaderStyle-Width="30%">
                                            <ItemTemplate>
                                                <%# GetPrescrizioniQuesitoDiagnosticoPropostaTerapeutica(Container.DataItem) %>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderStyle-Width="40%" HeaderText="Prestazioni/Farmaci">
                                            <ItemTemplate>
                                                <%# GetPrescrizioniFarmaciPrestazioni(Container.DataItem) %>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                    </Columns>
                                </asp:GridView>

                                <%-- ATTENZIONE: Viene impostato  SelectMethod="X" TypeName="X" per fare eseguire l'evento Selecting in caso di qualche errore che fa si che non vengano impostati i parametri corretti --%>
                                <asp:ObjectDataSource ID="DataSourcePrescrizioni" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="X" TypeName="X">
                                    <SelectParameters>
                                    </SelectParameters>
                                </asp:ObjectDataSource>
                            </div>
                        </div>
                    </asp:View>

                    <%-- VIEW SCHEDE PAZIENTE --%>
                    <asp:View ID="ViewSchedePaziente" runat="server">
                        <div id="divMessageEventiSingoli" class="jumbotron message-custom-padding" runat="server" visible="false" enableviewstate="false">
                        </div>
                        <div id="divWebGridRefertiSingoli" runat="server">
                            <div class="table-responsive">
                                <asp:GridView ID="WebGridRefertiSingoli"
                                    DataKeyNames="Id" ShowHeader="false" ClientIDMode="Static" GridLines="None" CssClass="table table-bordered table-condensed small" runat="server"
                                    AutoGenerateColumns="False" ViewStateMode="Disabled" DataSourceID="DataSourceRefertiSingoli" EnableViewState="false" AllowPaging="True" AllowSorting="true">
                                    <Columns>
                                        
                                         <asp:TemplateField ItemStyle-Width="2%" HeaderStyle-Width="2%" ItemStyle-CssClass="icon-align">
                                            <ItemTemplate>
                                                <%# GetImgPresenzaWarning(Container.DataItem) %>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField ItemStyle-Width="2%" HeaderStyle-Width="2%" ItemStyle-CssClass="icon-align">
                                            <ItemTemplate>
                                                <%# DwhClinico.Web.UserInterface.GetImgPresenzaReferti(CType(Container.DataItem, DwhClinico.Web.WcfDwhClinico.RefertoListaType), Me)  %>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField ItemStyle-Width="2%" HeaderStyle-Width="2%" ItemStyle-CssClass="icon-align">
                                            <ItemTemplate>
                                                <asp:Image ID="ImgStatoRichisistestaCodice" runat="server" ImageUrl='<%# GetStatoImageUrl2(Container.DataItem) %>' />
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField ItemStyle-Width="2%" HeaderStyle-Width="2%" ItemStyle-CssClass="icon-align">
                                            <ItemTemplate>
                                                <asp:HyperLink ID="hlRefertoImg" runat="server" NavigateUrl='<%# GetUrlLinkReferto(Container.DataItem) %>'>
                                                                             <asp:Image runat="server" ImageUrl="<%#GetUrlIconaTipoReferto(Container.DataItem)%>"></asp:Image>
                                                </asp:HyperLink>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField ItemStyle-Width="2%" HeaderStyle-Width="2%" ItemStyle-CssClass="icon-align">
                                            <ItemTemplate>
                                                <%# GetIconaStatoInvioSole(Container.DataItem) %>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Descrizione">
                                            <ItemTemplate>
                                                <asp:HyperLink ID="hlReferto" runat="server" NavigateUrl='<%# GetUrlLinkReferto(Container.DataItem) %>'
                                                    Text='<%# GetStringaDescrittiva(Container.DataItem) %>'></asp:HyperLink>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Anteprima" ItemStyle-Width="20%" HeaderStyle-Width="20%">
                                            <ItemTemplate>
                                                <%# GetLabelAnteprima(Container.DataItem) %>
                                                <%# GetLabelAvvertenze(Container.DataItem) %>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Episodio">
                                            <ItemTemplate>
                                                <%# GetDataEvento(Container.DataItem) %>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Priorità">
                                            <ItemTemplate>
                                                <%# GetPriorita(Container.DataItem) %>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Numero Nosologico">
                                            <ItemTemplate>
                                                <%# GetNumeroReferto(Container.DataItem) %>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>

                                <%-- ATTENZIONE: Viene impostato  SelectMethod="X" TypeName="X" per fare eseguire l'evento Selecting in caso di qualche errore che fa si che non vengano impostati i parametri corretti --%>
                                <asp:ObjectDataSource ID="DataSourceRefertiSingoli" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="X" TypeName="X">
                                    <SelectParameters>
                                    </SelectParameters>
                                </asp:ObjectDataSource>
                            </div>
                        </div>
                    </asp:View>

                    <%-- VIEW NOTE ANAMNESTICHE --%>
                    <asp:View ID="ViewNoteAnamnestiche" runat="server">
                        <div id="divMessageNoteAnamnestiche" class="jumbotron message-custom-padding" runat="server" visible="false" enableviewstate="false">
                        </div>
                        <div id="divWebGridNoteAnamnestiche" runat="server">
                            <asp:GridView ID="gvNoteAnamnestiche" runat="server" DataSourceID="DataSourceNoteAnamnestiche" GridLines="None" CssClass="table table-bordered table-condensed small"
                                ShowHeader="false" AutoGenerateColumns="False" EnableViewState="false" AllowPaging="True" AllowSorting="true">
                                <Columns>
                                    <asp:BoundField DataField="SistemaErogante" HeaderText="SistemaErogante" SortExpression="SistemaErogante"></asp:BoundField>

                                    <asp:BoundField DataField="AziendaErogante" HeaderText="AziendaErogante" SortExpression="AziendaErogante"></asp:BoundField>

                                    <%-- ICONA STATO CODICE--%>
                                    <asp:TemplateField ItemStyle-HorizontalAlign="Center">
                                        <ItemTemplate>
                                            <%# GetIconaStatoNotaAnamnestica(Container.DataItem) %>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="TipoDescrizione" HeaderText="TipoDescrizione" SortExpression="TipoDescrizione"></asp:BoundField>

                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <%# String.Format("{0:g}", Eval("DataNota")) %>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:BoundField DataField="ContenutoText" HeaderText="ContenutoText" SortExpression="ContenutoText" ItemStyle-Width="50%"></asp:BoundField>

                                    <asp:TemplateField ItemStyle-Width="5%" HeaderStyle-Width="5%">
                                        <ItemTemplate>
                                            <button type="button" class="btn btn-link btn-xs" onclick="updateNoteAnamnestichePanel('<%# Eval("Id") %>');">
                                                Dettaglio
                                            </button>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>

                            <%-- ATTENZIONE: Viene impostato  SelectMethod="X" TypeName="X" per fare eseguire l'evento Selecting in caso di qualche errore che fa si che non vengano impostati i parametri corretti --%>
                            <asp:ObjectDataSource ID="DataSourceNoteAnamnestiche" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="X" TypeName="X">
                                <SelectParameters>
                                </SelectParameters>
                            </asp:ObjectDataSource>
                        </div>
                    </asp:View>

                </asp:MultiView>
            </div>
        </div>

        <%-- HIDDEN FIELD --%>
        <asp:HiddenField ID="hiddenRichiedenteCodiceFiscale" runat="server" />
        <asp:HiddenField ID="hiddenRichiedenteCognome" runat="server" />
        <asp:HiddenField ID="hiddenRichiedenteNome" runat="server" />
        <asp:HiddenField ID="hiddenPazienteCodiceFiscale" runat="server" />
        <asp:HiddenField ID="hiddenIdPaziente" runat="server" />
        <asp:HiddenField ID="hiddenCallEnableButtonPatientSummary" runat="server" />

        <div class="col-sm-3 col-md-3 col-lg-2">

            <%-- PANNELLO FILTRI --%>
            <div id="rightSidebar" data-offset-top="64" data-spy="affix">
                <div class="row">
                    <div class="col-sm-12">
                        <uc1:ucModaleInvioLinkPerAccessoDiretto runat="server" ID="ucModaleInvioLinkPerAccessoDiretto" />
                    </div>
                    <div class="col-sm-12">
                        <div id="divFiltersContainer" class="panel panel-default" runat="server">
                            <div class="panel-body">
                                <div class="form-horizontal">
                                    <div class="col-sm-12">
                                        <div class="form-group form-group-sm">
                                            <asp:DropDownList ID="cmbFiltroTemporale" ClientIDMode="Static" AutoPostBack="true" runat="server" CssClass="form-control">
                                                <asp:ListItem Value="-1" Text="" />
                                                <asp:ListItem Value="0" Text="Ultima Settimana" />
                                                <asp:ListItem Value="1" Text="Ultimo Mese" />
                                                <asp:ListItem Value="2" Text="Ultimo Anno" Selected="True" />
                                                <asp:ListItem Value="3" Text="Ultimi 5 anni" />
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                    <div class="form-group form-group-sm">
                                        <asp:Label ID="lblDallaData" runat="server" Text="Da:" CssClass="col-sm-2 control-label" AssociatedControlID="txtDataDal"></asp:Label>
                                        <div class="col-sm-10">
                                            <asp:TextBox ID="txtDataDal" ClientIDMode="Static" runat="server" CssClass="form-control form-control-dataPicker" MaxLength="10" placeholder="es 22/11/1996"></asp:TextBox>
                                            <asp:RequiredFieldValidator CssClass="label label-danger" Display="Dynamic" ErrorMessage="Campo Obbligatorio" ControlToValidate="txtDataDal" runat="server" />
                                            <asp:CompareValidator ID="CompareValidator1" Type="Date" Operator="DataTypeCheck" CssClass="label label-danger" Display="Dynamic" runat="server" ErrorMessage="Formato data non valido" ControlToValidate="txtDataDal"></asp:CompareValidator>
                                            <asp:RangeValidator ID="RangeValAutorizzatoreDataNascita" Type="Date" MinimumValue="1900-01-01"
                                                MaximumValue="3000-01-01" ControlToValidate="txtDataDal" CssClass="label label-danger"
                                                runat="server" ErrorMessage="Inserire una data nell'intervallo </br> 01/01/1900 e 01/01/3000" Display="Dynamic"></asp:RangeValidator>
                                        </div>
                                    </div>
                                    <div class="form-group form-group-sm">
                                        <asp:Label ID="lblAllaData" runat="server" Text="a:" CssClass="col-sm-2 control-label" AssociatedControlID="txtAllaData"></asp:Label>
                                        <div class="col-sm-10">
                                            <asp:TextBox ID="txtAllaData" MaxLength="10" runat="server" CssClass="form-control form-control-dataPicker" placeholder="es 22/11/1996"></asp:TextBox>
                                            <asp:CompareValidator ID="CompareValidator2" Type="Date" Operator="DataTypeCheck" CssClass="label label-danger" Display="Dynamic" runat="server" ErrorMessage="Formato data non valido" ControlToValidate="txtAllaData"></asp:CompareValidator>
                                            <asp:RangeValidator ID="RangeValidator1" Type="Date" MinimumValue="1900-01-01"
                                                MaximumValue="3000-01-01" ControlToValidate="txtAllaData" CssClass="label label-danger"
                                                runat="server" ErrorMessage="Inserire una data nell'intervallo </br> 01/01/1900 e 01/01/3000" Display="Dynamic"></asp:RangeValidator>
                                        </div>
                                    </div>
                                    <div class="form-group form-group-sm">
                                        <div class="col-sm-12">
                                            <asp:Button ID="cmdCerca" runat="server" Text="Applica Filtro" CssClass="btn btn-primary btn-block btn-sm" />
                                        </div>
                                    </div>
                                    <div id="FiltriCheckBoxList" visible="true" runat="server" class="checkbox checkboxlist">
                                        <div class="form-group form-group-sm">
                                            <asp:CheckBoxList CssClass="checkboxlist-custom-left-margin" ID="TipoRefertoCheckboxList" DataTextField="Descrizione" DataValueField="Id" AutoPostBack="true" runat="server" RepeatLayout="flow" RepeatDirection="Horizontal" RepeatColumns="1" DataSourceID="DataSourceLstTipiReferti">
                                            </asp:CheckBoxList>
                                            <asp:CheckBoxList CssClass="checkboxlist-custom-left-margin" ID="TipoRefertoPerEpisodioCheckboxList" DataTextField="Descrizione" DataValueField="Id" AutoPostBack="true" RepeatLayout="flow" RepeatDirection="Horizontal" RepeatColumns="1" runat="server" DataSourceID="DataSourceLstTipiRefertiPerEpisodio">
                                            </asp:CheckBoxList>
                                            <asp:CheckBoxList CssClass="checkboxlist-custom-left-margin" ID="TipoPrescrizioneCheckboxList" AutoPostBack="true" runat="server" RepeatLayout="flow" RepeatDirection="Horizontal" RepeatColumns="1" DataSourceID="DataSourceLstTipiPrescrizioni">
                                            </asp:CheckBoxList>
                                        </div>
                                        <asp:Button ID="cmdApplicaFiltri" runat="server" Text="Visualizza Tutti" CssClass="btn btn-default btn-block btn-sm" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-12">
                        <div class=" form-group form-group-sm">
                            <img src="../Images/sole-logo.png" class="img-responsive center-block" alt="Responsive image" />
                        </div>
                        <div class="form-group-sm">
                            <asp:Button ID="btnApriPdfPatientSummary" runat="server"
                                Text="Apri Patient Summary" CssClass="PatientSummary btn btn-default btn-sm btn-block" />
                            <asp:Button ID="BtnFSE" Text="Fascicolo Sanitario Elettronico Regionale" runat="server" CssClass="btn btn-default btn-block btn-sm" />
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <asp:ObjectDataSource ID="DataSourceLstTipiRefertiPerEpisodio" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetSelectedTipiReferto" TypeName="DwhClinico.Web.CustomDataSource.AccessoDirettoRefertiCercaPerNosologico">
            <SelectParameters>
                <asp:Parameter Name="listaReferti" Type="Object"></asp:Parameter>
            </SelectParameters>
        </asp:ObjectDataSource>
        <asp:ObjectDataSource ID="DataSourceLstTipiReferti" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetSelectedTipiReferto" TypeName="DwhClinico.Web.CustomDataSource.AccessoDirettoRefertiCercaPerIdPaziente">
            <SelectParameters>
                <asp:Parameter Name="IdPaziente" DbType="Guid" />
            </SelectParameters>
        </asp:ObjectDataSource>
        <asp:ObjectDataSource ID="DataSourceLstTipiPrescrizioni" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetSelectedTipiPrescrizione" TypeName="DwhClinico.Web.CustomDataSource.AccessoDirettoPrescrizioniCercaPerIdPaziente" />
    </div>
    
    <%-- MODALE CONSENSO FSE --%>
    <div class="modal fade" id="ModaleConsensoFSE" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    <h4 class="modal-title">Consenso alla consultazione del Fascicolo Sanitario Elettronico</h4>
                </div>
                <div class="modal-body">
                    <h4>Vuoi acquisire il consenso?</h4>
                    <asp:Button ID="BtnAcquisisciConsensoFSE" runat="server" Text="Acquisisci il consenso per accesso a FSE" CssClass="btn btn-success btn-sm" />
                    <asp:Button ID="BtnNegaConsensoFSE" runat="server" Text="Nega il consenso per accesso a FSE" CssClass="btn btn-danger btn-sm" />
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Annulla</button>
                </div>
            </div>
        </div>
    </div>

    <%-- MODALE DETTAGLIO EPISODIO --%>
    <div class="modal fade bs-example-modal-lg" tabindex="-1" role="dialog" aria-labelledby="myLargeModalLabel" id="ModalDettaglioEpisodio">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true"></span></button>
                    <h4 class="modal-title">Episodio</h4>
                </div>
                <div class="modal-body">
                    <div id="alertErrorEventiModal" runat="server" visible="false" enableviewstate="false">
                        <div class="alert alert-danger">
                            <asp:Label ID="eventiModalLblError" EnableViewState="false" runat="server" />
                        </div>
                    </div>

                    <asp:UpdatePanel ID="UpdatePanelDettaglioEpisodio" UpdateMode="Conditional" runat="server">
                        <ContentTemplate>
                            <asp:HiddenField ID="hfIdEpisodio" runat="server" />
                            <uc1:ucInfoPaziente runat="server" ID="ucInfoPaziente" />
                            <div class="row" id="divInfoRicovero" runat="server">
                                <div class="col-sm-12">
                                    <label class="label label-default">Episodio</label>
                                    <div class="well well-sm small">
                                        <asp:Xml EnableViewState="false" ViewStateMode="Enabled" ID="XmlInfoRicovero" runat="server"></asp:Xml>
                                    </div>
                                </div>
                            </div>
                            <div class="table-responsive small">
                                <asp:GridView CssClass="table table-bordered table-striped gridView-custom-margin" ID="WebGridEventiEpisodio" runat="server" AutoGenerateColumns="False" DataSourceID="DataSourceEventiEpisodio">
                                    <Columns>
                                        <asp:TemplateField HeaderText="Evento">
                                            <ItemTemplate>
                                                <%# GetEventoEpisodioDescr(Container.DataItem) %>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Data">
                                            <ItemTemplate>
                                                <%# GetDataEventoEpisodio(Container.DataItem) %>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Reparto di Ricovero">
                                            <ItemTemplate>
                                                <%# GetEventoRepartoRicovero(Container.DataItem) %>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Settore di Ricovero">
                                            <ItemTemplate>
                                                <%# GetEventoSettoreRicovero(Container.DataItem) %>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Letto di Ricovero">
                                            <ItemTemplate>
                                                <%# GetEventoLettoRicovero(Container.DataItem) %>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                                <asp:ObjectDataSource ID="DataSourceEventiEpisodio" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="DwhClinico.Web.CustomDataSource.AccessoDirettoEventiEpisodioCercaPerId">
                                    <SelectParameters>
                                        <asp:Parameter Name="Token" Type="Object"></asp:Parameter>
                                        <asp:Parameter DbType="Guid" Name="IdRicovero"></asp:Parameter>
                                    </SelectParameters>
                                </asp:ObjectDataSource>
                            </div>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Chiudi</button>
                </div>
            </div>
        </div>
    </div>

    <%-- MODALE DETTAGLIO NOTA ANAMNESTICA --%>
    <div class="modal fade bs-example-modal-lg" tabindex="-1" role="dialog" aria-labelledby="myLargeModalLabel" id="ModaleDettaglioNotaAnamnestica">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    <h4 class="modal-title">Nota Anamnestica</h4>
                </div>
                <div class="modal-body">
                    <div id="alertErrorNotaAnamnesticaModal" runat="server" visible="false" enableviewstate="false">
                        <div class="alert alert-danger">
                            <asp:Label ID="lblErrorNotaAnamnesticaModal" EnableViewState="false" runat="server" />
                        </div>
                    </div>
                    <asp:UpdatePanel ID="udpNotaAnamnesticaDettaglio" UpdateMode="Conditional" runat="server">
                        <ContentTemplate>
                            <asp:HiddenField ID="hflNotaAnamnestica" runat="server" />

                            <uc1:ucInfoPaziente runat="server" ID="ucInfoPazienteNotaAnamnestica" />

                            <asp:FormView ID="fvNotaAnamestica" runat="server" DataSourceID="OdsNotaAnamnestica" RenderOuterTable="false">
                                <ItemTemplate>
                                    <label class="label label-default">Testata Nota Anamnestica</label>
                                    <div class="well well-sm small">
                                        <div class="form-horizontal">
                                            <div class="row">
                                                <div class="col-sm-4">
                                                    <asp:Label Text="Azienda:" AssociatedControlID="lblAzienda" CssClass="col-sm-6" runat="server" />
                                                    <asp:Label ID="lblAzienda" runat="server" Text='<%# Bind("AziendaErogante") %>' />
                                                </div>
                                                <div class="col-sm-4">
                                                    <asp:Label Text="Sistema:" AssociatedControlID="lblSistema" CssClass="col-sm-6" runat="server" />
                                                    <asp:Label ID="lblSistema" runat="server" Text='<%# Eval("SistemaErogante") %>' />
                                                </div>
                                                <div class="col-sm-4">
                                                    <asp:Label Text="Data Nota:" AssociatedControlID="lblDataNota" CssClass="col-sm-6" runat="server" />
                                                    <asp:Label ID="lblDataNota" Text='<%# String.Format("{0:g}", Eval("DataNota")) %>' runat="server" />
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="col-sm-4">
                                                    <asp:Label Text="Stato:" AssociatedControlID="lblStatoCodice" CssClass="col-sm-6" runat="server" />
                                                    <label id="lblStatoCodice" runat="server"><%# GetIconaStatoDettaglioNotaAnamnestica(Container.DataItem) %></label>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <label class="label label-default">Contenuto</label>
                                    <div class="well">
                                        <%# Eval("ContenutoHtml") %>
                                    </div>
                                </ItemTemplate>
                            </asp:FormView>

                            <asp:ObjectDataSource runat="server" ID="OdsNotaAnamnestica" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="DwhClinico.Web.CustomDataSource.NotaAnamnesticaOttieniPerId">
                                <SelectParameters>
                                    <asp:Parameter Name="Token" Type="Object"></asp:Parameter>
                                    <asp:Parameter DbType="Guid" Name="IdNotaAnamnestica"></asp:Parameter>
                                </SelectParameters>
                            </asp:ObjectDataSource>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Chiudi</button>
                </div>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        $(document).ready(function () {
            if ($("#<%=hiddenCallEnableButtonPatientSummary.ClientID%>")[0].value == "TRUE") {
                EnableButtonPatientSummary();
            }
            //         // CREO I TOOLTIP BOOTSTRAP PER LE ANTEPRIME DEI REFERTI CONTENUTE NELLE TABELLE
            $(function () {
                $('[data-toggle="tooltip"]').tooltip()
            })
        });

        function EnableButtonPatientSummary() {

            var datajson = '{RichiedenteCodiceFiscale: "' + $("#<%=hiddenRichiedenteCodiceFiscale.ClientID%>")[0].value + '",'
                + 'RichiedenteCognome: "' + $("#<%=hiddenRichiedenteCognome.ClientID%>")[0].value + '",'
                + 'RichiedenteNome: "' + $("#<%=hiddenRichiedenteNome.ClientID%>")[0].value + '",'
                + 'PazienteCodiceFiscale: "' + $("#<%=hiddenPazienteCodiceFiscale.ClientID%>")[0].value + '",'
                + 'IdPaziente: "' + $("#<%=hiddenIdPaziente.ClientID%>")[0].value + '" }';

            var buttonPatientSummary = $(".PatientSummary");
            buttonPatientSummary.css("background", "url(../Images/Progress.gif) no-repeat");

            $.ajax({
                type: "POST",
                url: "Referti.aspx/ShowPatientSummary",
                data: datajson,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: OnSuccess,
                failure: function (response) {
                    try {
                        //Failure del codice in ShowPatientSummary
                        //alert(response.d);
                        var buttonPatientSummary = $(".PatientSummary");
                        buttonPatientSummary.css("background", "");     //resetto background
                        buttonPatientSummary.attr("disabled", true);    //disabilito
                        //alert("Si è verificato un errore durante la lettura del Patient Summary");
                    } catch (err) { };
                },
                error: function (error) {
                    try {
                        //Failure in fase di chiamata AJAX
                        //alert(error.responseText);
                        var buttonPatientSummary = $(".PatientSummary");
                        buttonPatientSummary.css("background", "");     //resetto background
                        buttonPatientSummary.attr("disabled", true);    //disabilito
                        //alert("Si è verificato un errore durante la lettura del Patient Summary");
                    } catch (err) { };
                }
            });
        }
        function OnSuccess(response) {
            try {
                //In response.d c'è il valore di ritorno
                var buttonPatientSummary = $(".PatientSummary");
                buttonPatientSummary.css("background", "");     //resetto background
                if (response.d) {
                    buttonPatientSummary.attr("disabled", false);   //abilito
                }
                else {
                    buttonPatientSummary.attr("disabled", true);    //disabilito
                }
            } catch (err) { };
        }


        // Eseguo l'update dell'updatePanel contenente il dettaglio dell'episodio.
        // Questo per non eseguire un bind dell'intera pagina che ripristinerebbe i collapse delle righe della tabella "referti e episodi"
        function doPostBack(idEpisodio) {
            var myHidden = document.getElementById('<%= hfIdEpisodio.ClientID %>');
            myHidden.value = idEpisodio
            __doPostBack('<%=UpdatePanelDettaglioEpisodio.ClientID %>', null);

        };

        //Esegue il postback dell'objectDataSource della Nota Anamnestica.
        function updateNoteAnamnestichePanel(idNotaAnamnestica) {
            var myHidden = document.getElementById('<%= hflNotaAnamnestica.ClientID %>');
            myHidden.value = idNotaAnamnestica
            __doPostBack('<%=udpNotaAnamnesticaDettaglio.ClientID %>', null);
        };

        /*
     * SERVE PER COLLASSARE TUTTE LE SEZIONI DELLA MATRICE
     * NON E' STATO POSSIBILE USARE UN BOTTONE COLLAPSE DI BOOTSTRAP PERCHE' I PANNELLI DELLA MATRICE SONO GIA' COLLASSABILI
     * QUINDI ANDREBBERO IN CONFLITTO TRA LORO
     *
     */
        function changeCollapseBtnText() {
            //OTTENGO IL BOTTONE PER COLLASSARE LE MATRICI
            var btn = $("#btnCollapseMatrice");

            //OTTENGO IL PANEL BOOSTTRAP CHE CONTIENE LE MATRICI
            var pannelloMatrice = $(".demo");

            //IL BOTTONE HA UN CUSTOM ATTRIBUTE PER INDICARE SE BISOGNA COLLASSARE O APRIRE I PANNELLI
            //SE ng-opened = 0 ALLORA BISOGNA APRIRE I PANEL
            //SE ng-opened = 1 ALLORA BISOGNA COLLASSARE I PANEL
            if (btn.attr("ng-opened") == "0") {
                //APRO I PANNELLI
                pannelloMatrice.collapse("hide");

                //CAMBIO LO STATO DEL CUSTOM ATTRIBUTE
                btn.attr("ng-opened", "1");

                //CAMBIO IL TESTO DEL BOTTONE
                btn.val("Apri tutte le sezioni");
            } else {
                //COLLASSO I PANNELLI
                pannelloMatrice.collapse("show");

                //CAMBIO LO STATO DEL CUSTOM ATTRIBUTE
                btn.attr("ng-opened", "0");

                //CAMBIO IL TESTO DEL BOTTONE
                btn.val("Chiudi tutte le sezioni");
            }
        }


        //CREO I BOOTSTRAP DATETIME PICKER.
        $('.form-control-dataPicker').datepicker({
            format: "dd/mm/yyyy",
            weekStart: 1,
            language: "it-it",
            todayHighlight: true,
            todayBtn: "linked",
            orientation: "bottom left"
        });

        //SBIANCO LA DROPDOWNLIST DEL FITRO TEMPORALE QUANDO MODIFICO IL FILTRO "DATA DAL".
        $('#txtDataDal').datepicker().on("changeDate", function (e) {
            $('#cmbFiltroTemporale>option:eq(0)').prop('selected', true);
        });
    </script>
</asp:Content>
