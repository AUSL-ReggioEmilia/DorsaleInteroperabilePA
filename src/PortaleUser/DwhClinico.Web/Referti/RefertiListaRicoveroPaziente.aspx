<%@ Page Language="VB" MasterPageFile="~/Portale/Default.master" AutoEventWireup="false"
    Inherits="DwhClinico.Web.Referti_RefertiListaRicoveroPaziente" Title=""
    CodeBehind="RefertiListaRicoveroPaziente.aspx.vb" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" runat="Server">
    <div class="row">
        <div class="col-sm-12">
            <div id="divPageTitle" class="page-header" runat="server">
                <h3>Elenco referti del paziente
                </h3>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <div class="alert alert-danger" id="alertErrorMessage" runat="server" visible="false" enableviewstate="false">
                <asp:Label ID="lblErrorMessage" runat="server" EnableViewState="False"></asp:Label>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <div class="panel panel-default" id="divTestataPaziente" runat="server">
                <div class="panel-heading">
                    Paziente
                </div>
                <div class="panel-body">
                    <div class="row">
                        <div class="col-sm-6">
                            <div class=" form-group">
                                <asp:Label Text="Nome e Cognome:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblNomeCognome" />
                                <asp:Label ID="lblNomeCognome" runat="server"></asp:Label>
                            </div>
                        </div>
                        <div class="col-sm-6">
                            <div class=" form-group">
                                <asp:Label Text="Codice Fiscale:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblCodiceFiscale" />
                                <asp:Label ID="lblCodiceFiscale" runat="server"></asp:Label>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-sm-6">
                            <div class=" form-group">
                                <asp:Label Text="Luogo e data di nascita:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblLuogoNascita" />
                                <asp:Label ID="lblLuogoNascita" runat="server"></asp:Label>
                                -
                        <asp:Label ID="lblDataNascita" runat="server"></asp:Label>
                            </div>
                        </div>
                        <div class="col-sm-6">
                            <div class=" form-group">
                                <asp:Label Text="Codice Sanitario:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblCodiceSanitario" />
                                <asp:Label ID="lblCodiceSanitario" runat="server"></asp:Label>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-sm-6">
                            <div class=" form-group">
                                <asp:Label ID="lblDataDecesso" runat="server" Text="Data di decesso:" CssClass="col-sm-6" AssociatedControlID="lblDataDecessoValue"></asp:Label>
                                <asp:Label ID="lblDataDecessoValue" runat="server" CssClass="text-danger"></asp:Label>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <asp:FormView ID="FormViewTestataEpisodio" runat="server" DataSourceID="DataSourceTestataEpisodio"
        RenderOuterTable="false">
        <ItemTemplate>
            <div class="row">
                <div class="col-sm-12">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <asp:Label ID="lblTitoloSezione" runat="server" Text='<%# GetTitoloSezioneEpisodio() %>'></asp:Label>
                        </div>
                        <div class="panel-body">
                            <div class="row">
                                <div class="col-sm-6">
                                    <div class=" form-group">
                                        <asp:Label Text="Azienda/Ospedale:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblAzienda" />
                                        <asp:Label ID="lblAzienda" runat="server" Text='<%# Bind("AziendaErogante") %>'></asp:Label>
                                    </div>
                                </div>
                                <div class="col-sm-6">
                                    <div class=" form-group">
                                        <asp:Label ID="lblNumeroNosologicoEtichetta" runat="server" Text='<%# GetNumeroNosologicoEtichetta() %>' CssClass="col-sm-6" AssociatedControlID="lblNumeroNosologico"></asp:Label>
                                        <asp:Label ID="lblNumeroNosologico" runat="server" Text='<%# Bind("NumeroNosologico") %>'></asp:Label>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-sm-6">
                                    <div class=" form-group">

                                        <asp:Label Text="Episodio:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblEpisodioDescr" />

                                        <asp:Label ID="lblEpisodioDescr" runat="server" Text='<%# Bind("TipoEpisodioDescr") %>'></asp:Label>

                                    </div>
                                </div>
                                <div class="col-sm-6">
                                    <div class=" form-group">

                                        <asp:Label Text="Data/ora inizio:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblDataInizioEpisodio" />

                                        <asp:Label ID="lblDataInizioEpisodio" runat="server" Text='<%# GetDataOraEvento(Eval("DataInizioEpisodio")) %>'></asp:Label>

                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-sm-6">
                                    <div class=" form-group">

                                        <asp:Label Text="Data/ora fine:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblDataFineEpisodio" />
                                        <asp:Label ID="lblDataFineEpisodio" runat="server" Text='<%# GetDataOraEvento(Eval("DataFineEpisodio")) %>'></asp:Label>
                                    </div>
                                </div>
                                <div class="col-sm-6">
                                    <div class=" form-group">
                                        <asp:Label Text="Ultimo evento:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblUltimoEventoDescr" />
                                        <asp:Label ID="lblUltimoEventoDescr" runat="server" Text='<%# Bind("UltimoEventoDescr") %>'
                                            CssClass="text-danger"></asp:Label>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-sm-6">
                                    <div class=" form-group">
                                        <asp:Label Text="Reparto Accettazione:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblRepartoAccettazione" />
                                        <asp:Label ID="lblRepartoAccettazione" runat="server" Text='<%# Eval("RepartoRicoveroAccettazioneDescr") %>'></asp:Label>
                                    </div>
                                </div>
                                <div class="col-sm-6">
                                    <div class=" form-group">
                                        <asp:Label ID="lblRepartoEtichetta" runat="server" Text="Reparto:" Visible='<%# GetRepartoEtichettaVisible()%>' CssClass="col-sm-6" AssociatedControlID="lblReparto"></asp:Label>
                                        <asp:Label ID="lblReparto" runat="server" Text='<%# Eval("RepartoRicoveroUltimoEventoDescr") %>'
                                            Visible='<%# GetRepartoEtichettaVisible()%>'></asp:Label>
                                    </div>
                                </div>
                            </div>

                        </div>
                    </div>
                </div>
            </div>

        </ItemTemplate>
    </asp:FormView>

    <!-- Inizio Referti singoli -->
    <div runat="server" id="divEventiSingoli" class="row">
        <div class="col-sm-12">
            <div class="table-responsive">
                <%--<C1WebGrid:C1WebGrid ID="C1WebGridRefSingoli" runat="server" AutoGenerateColumns="False"
                    DataKeyField="ID" DataSourceID="DataSourceEventiSingoli" DefaultColumnWidth=""
                    DefaultRowHeight="" AllowPaging="False" ShowHeader="false" CssClass="table table-bordered table-condensed table-striped"
                    ShowFooter="False">
                    <Columns>
                        <C1WebGrid:C1TemplateColumn>
                            <ItemTemplate>
                                <asp:HyperLink ID="hlReferto2" runat="server" NavigateUrl='<%# GetUrlLinkReferto(Eval("Id")) %>'
                                    Text='<%# Eval("DescrizioneRepartoErogante") %>'></asp:HyperLink>
                            </ItemTemplate>
                        </C1WebGrid:C1TemplateColumn>
                        <C1WebGrid:C1TemplateColumn HeaderText="Stato">
                            <ItemTemplate>
                                <asp:Image ID="Image2" runat="server" ImageUrl='<%# GetStatoImageUrl(Eval("StatoRichiestaCodice")) %>' />
                            </ItemTemplate>
                        </C1WebGrid:C1TemplateColumn>
                        <C1WebGrid:C1BoundColumn DataField="DataReferto" DataFormatString="{0:d}">
                        </C1WebGrid:C1BoundColumn>
                    </Columns>
                </C1WebGrid:C1WebGrid>--%>

                <asp:GridView runat="server" ID="WebGridRefSingoli" AutoGenerateColumns="False"
                    DataKeyField="ID" DataSourceID="DataSourceEventiSingoli" DefaultColumnWidth=""
                    DefaultRowHeight="" AllowPaging="False" ShowHeader="false" CssClass="table table-bordered table-condensed table-striped"
                    ShowFooter="False">
                    <Columns>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <asp:HyperLink ID="hlReferto" runat="server" NavigateUrl='<%# GetUrlLinkReferto(Eval("Id")) %>'
                                    Text='<%# Eval("DescrizioneRepartoErogante") %>'></asp:HyperLink>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Stato">
                            <ItemTemplate>
                                <asp:Image ID="Image1" runat="server" ImageUrl='<%# GetStatoImageUrl(Eval("StatoRichiestaCodice")) %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="DataReferto" DataFormatString="{0:d}" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>
    <!-- Fine Referti singoli -->
    <div class="row" id="divFiltersContainer" runat="server">
        <div class="col-sm-12">
            <div class="well well-sm">
                <div class="btn-toolbar">
                    <div class="col-sm-5">
                        <div class="input-group input-group-sm">
                            <asp:Label ID="lblDallaData" runat="server" Text="Dalla data:" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtDataDal" runat="server" CssClass="form-control input-sm"></asp:TextBox>
                            <asp:Label ID="lblFormatoData" runat="server" Text="(dd/mm/yyyy)" CssClass="input-group-addon"></asp:Label>
                        </div>
                    </div>
                    <div class="col-sm-5">
                        <div class="input-group input-group-sm">
                            <asp:Label ID="lblNumeroReferto" runat="server" Text="Numero referto:" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtNumeroReferto" runat="server" CssClass="form-control input-sm"></asp:TextBox>
                        </div>
                    </div>
                    <div class="col-sm-2">
                        <asp:Button ID="cmdCerca" runat="server" Text="Cerca" CssClass="btn btn-primary btn-sm" />
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row" id="divReportContainer" runat="server">
        <div class="col-sm-12">
            <ul class="nav nav-tabs">
                <li id="tabLnkReferti" runat="server">
                    <asp:LinkButton ID="lnkReferti" CssClass="ReportGroupUnSelectedTab" runat="server"
                        OnCommand="SelectView" CommandArgument="ViewReferti" CommandName="TabClick"
                        CausesValidation="False" Font-Underline="False">Referti</asp:LinkButton>
                </li>
                <%-- <li>
                    <asp:LinkButton ID="lnkRepartoRichiedente" CssClass="ReportGroupUnSelectedTab" runat="server"
                        OnCommand="SelectView" CommandArgument="ViewRepartoRichiedente" CommandName="TabClick"
                        Font-Underline="False">Reparto richiedente</asp:LinkButton>
                </li>
                <li>
                    <asp:LinkButton ID="lnkSistemaErogante" CssClass="ReportGroupUnSelectedTab" runat="server"
                        OnCommand="SelectView" CommandArgument="ViewSistemaErogante" CommandName="TabClick"
                        Font-Underline="False">Sistema erogante</asp:LinkButton>
                </li>--%>
                <li id="tabLnkRisultatoMatrice" runat="server">
                    <asp:LinkButton ID="lnkRisultatoMatrice" CssClass="ReportGroupUnSelectedTab" runat="server"
                        OnCommand="SelectView" CommandArgument="ViewRisultatoMatrice" CommandName="TabClick"
                        Font-Underline="False">Risultato matrice</asp:LinkButton>
                </li>
            </ul>
        </div>
    </div>
    <div>
        <div class="row">
            <div class="col-sm-12">
                <div class="table-responsive">
                    <asp:MultiView ID="MultiViewMain" runat="server">
                        <asp:View ID="ViewReferti" runat="server">
                            <%--<C1WebGrid:C1WebGrid ID="C1WebGridAnnoMese" runat="server" AutoGenerateColumns="False"
                                DataKeyField="ID" DataSourceID="DataSourceMain" CssClass="table table-bordered table-condensed table-striped" DefaultColumnWidth=""
                                DefaultRowHeight="" PageSize="2" AllowPaging="True">
                                <ItemStyle CssClass="GridItem" />
                                <Columns>
                                    <C1WebGrid:C1BoundColumn DataField="DataEventoMeseAnno" HeaderText="Mese evento"
                                        ReadOnly="True" SortExpression="DataEventoMeseAnno" Visible="False">
                                        <GroupInfo Position="Header">
                                            <HeaderStyle CssClass="GridGroupingHeader" />
                                        </GroupInfo>
                                    </C1WebGrid:C1BoundColumn>
                                    <C1WebGrid:C1TemplateColumn>
                                        <ItemTemplate>
                                            <asp:Image ID="ImgStatoRichiestaCodice" runat="server" ImageUrl='<%# GetStatoImageUrl(Eval("StatoRichiestaCodice")) %>' />
                                        </ItemTemplate>
                                        <GroupInfo GroupSingleRow="False">
                                        </GroupInfo>
                                        <ItemStyle HorizontalAlign="Center" Width="30px" />
                                    </C1WebGrid:C1TemplateColumn>
                                    <C1WebGrid:C1TemplateColumn>
                                        <ItemTemplate>
                                            <asp:HyperLink ID="hlRef_SistemaErogante" runat="server" NavigateUrl='<%# GetUrlLinkReferto(Eval("Id")) %>'
                                                Text='<%# Eval("SistemaErogante") %>'></asp:HyperLink>
                                        </ItemTemplate>
                                        <ItemStyle Width="50px" />
                                    </C1WebGrid:C1TemplateColumn>
                                    <C1WebGrid:C1BoundColumn DataField="Anteprima" HeaderText="" Visible="True">
                                        <ItemStyle Width="200px" />
                                    </C1WebGrid:C1BoundColumn>
                                    <C1WebGrid:C1TemplateColumn HeaderText="Data evento">
                                        <ItemTemplate>
                                            <asp:HyperLink ID="hlRef_DataEvento" runat="server" NavigateUrl='<%# GetUrlLinkReferto(Eval("Id")) %>'
                                                Text='<%# String.Format("{0:g}", Eval("DataEvento")) %>'></asp:HyperLink>
                                        </ItemTemplate>
                                    </C1WebGrid:C1TemplateColumn>
                                    <C1WebGrid:C1TemplateColumn HeaderText="Data referto">
                                        <ItemTemplate>
                                            <asp:HyperLink ID="hlRef_DataReferto" runat="server" NavigateUrl='<%# GetUrlLinkReferto(Eval("Id")) %>'
                                                Text='<%# String.Format("{0:d}", Eval("DataReferto")) %>'></asp:HyperLink>
                                        </ItemTemplate>
                                    </C1WebGrid:C1TemplateColumn>
                                    <C1WebGrid:C1BoundColumn DataField="PrioritaDescr" HeaderText="Priorit&#224; richiesta"
                                        ReadOnly="True" SortExpression="PrioritaDescr">
                                    </C1WebGrid:C1BoundColumn>
                                    <C1WebGrid:C1TemplateColumn HeaderText="Erogante">
                                        <ItemTemplate>
                                            <asp:Label ID="lbErogante" runat="server" Text='<%# BuildEroganteDescrizione(Eval("RepartoErogante"), Eval("SpecialitaErogante"), Eval("AziendaErogante"))  %>'></asp:Label>
                                        </ItemTemplate>
                                    </C1WebGrid:C1TemplateColumn>
                                    <C1WebGrid:C1BoundColumn DataField="NumeroReferto" HeaderText="Numero referto" SortExpression="NumeroReferto">
                                    </C1WebGrid:C1BoundColumn>
                                    <C1WebGrid:C1TemplateColumn HeaderText="Cancella">
                                        <ItemTemplate>
                                            <asp:HyperLink ID="hlEliminaReferto" runat="server" ImageUrl="~/Images/RefertiCancella.gif"
                                                NavigateUrl='<%# Eval("Id", "~/Referti/RefertiCancella.aspx?Idreferto={0}") %>'
                                                Visible='<%# CheckDeleteRefertiPermission( CStr(Eval("AziendaErogante")), CStr(Eval("SistemaErogante")), CStr(Eval("RepartoErogante"))) %>'></asp:HyperLink>
                                        </ItemTemplate>
                                        <ItemStyle HorizontalAlign="Center" Width="30px" />
                                    </C1WebGrid:C1TemplateColumn>
                                </Columns>
                                <PagerStyle CssClass="GridPager" Mode="NumericPages" Position="TopAndBottom" />
                                <HeaderStyle CssClass="GridHeader" />
                                <SelectedItemStyle CssClass="GridSelected" />
                                <AlternatingItemStyle CssClass="GridAlternatingItem" />
                            </C1WebGrid:C1WebGrid>--%>

                            <asp:GridView ID="WebGridReferti" runat="server" AutoGenerateColumns="False"
                                DataKeyField="ID" DataKeyNames="ID" DataSourceID="DataSourceMain" CssClass="table table-bordered table-condensed table-striped  gridView-custum-margin" DefaultColumnWidth=""
                                DefaultRowHeight="" PageSize="2" AllowPaging="True">
                                <Columns>
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <asp:Image ID="ImgStatoRichiestaCodice" runat="server" ImageUrl='<%# GetStatoImageUrl(Eval("StatoRichiestaCodice")) %>' />
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <asp:HyperLink ID="hlRef_SistemaErogante" runat="server" NavigateUrl='<%# GetUrlLinkReferto(Eval("Id")) %>'
                                                Text='<%# Eval("SistemaErogante") %>'></asp:HyperLink>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:BoundField DataField="Anteprima" HeaderText="Anteprima" Visible="True" />

                                    <asp:TemplateField HeaderText="Data Evento">
                                        <ItemTemplate>
                                            <asp:HyperLink ID="hlRef_DataEvento" runat="server" NavigateUrl='<%# GetUrlLinkReferto(Eval("Id")) %>'
                                                Text='<%# String.Format("{0:g}", Eval("DataEvento")) %>'></asp:HyperLink>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:TemplateField HeaderText="Data Referto">
                                        <ItemTemplate>
                                            <asp:HyperLink ID="hlRef_DataReferto" runat="server" NavigateUrl='<%# GetUrlLinkReferto(Eval("Id")) %>'
                                                Text='<%# String.Format("{0:d}", Eval("DataReferto")) %>'></asp:HyperLink>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:BoundField DataField="PrioritaDescr" HeaderText="Priorit&#224; richiesta"
                                        ReadOnly="True" SortExpression="PrioritaDescr" />

                                    <asp:TemplateField HeaderText="Erogante">
                                        <ItemTemplate>
                                            <asp:Label ID="lbErogante" runat="server" Text='<%# BuildEroganteDescrizione(Eval("RepartoErogante"), Eval("SpecialitaErogante"), Eval("AziendaErogante"))  %>'></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:BoundField DataField="NumeroReferto" HeaderText="Numero referto" SortExpression="NumeroReferto" />

                                    <asp:TemplateField HeaderText="Cancella">
                                        <ItemTemplate>
                                            <asp:HyperLink ID="hlEliminaReferto" runat="server" ImageUrl="~/Images/RefertiCancella.gif"
                                                NavigateUrl='<%# Eval("Id", "~/Referti/RefertiCancella.aspx?Idreferto={0}") %>'
                                                Visible='<%# CheckDeleteRefertiPermission( CStr(Eval("AziendaErogante")), CStr(Eval("SistemaErogante")), CStr(Eval("RepartoErogante"))) %>'></asp:HyperLink>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </asp:View>
                        <%--<asp:View ID="ViewRepartoRichiedente" runat="server">
                            <C1WebGrid:C1WebGrid ID="C1WebGridRepartoRichiedente" runat="server" AutoGenerateColumns="False"
                                DataKeyField="ID" DataSourceID="DataSourceMain" CssClass="table table-striped table-condensed table-bordered" DefaultColumnWidth=""
                                DefaultRowHeight="" PageSize="2" AllowPaging="True">
                                <ItemStyle CssClass="GridItem" />
                                <Columns>
                                    <C1WebGrid:C1BoundColumn DataField="RepartoRichiedente" HeaderText="Reparto richiedente"
                                        SortExpression="RepartoRichiedente" Visible="False">
                                        <GroupInfo Position="Header">
                                            <HeaderStyle CssClass="GridGroupingHeader" />
                                        </GroupInfo>
                                    </C1WebGrid:C1BoundColumn>
                                    <C1WebGrid:C1TemplateColumn>
                                        <ItemTemplate>
                                            <asp:Image ID="ImgStatoRichiestaCodice" runat="server" ImageUrl='<%# GetStatoImageUrl(Eval("StatoRichiestaCodice")) %>' />
                                        </ItemTemplate>
                                        <GroupInfo GroupSingleRow="False">
                                        </GroupInfo>
                                        <ItemStyle HorizontalAlign="Center" Width="30px" />
                                    </C1WebGrid:C1TemplateColumn>
                                    <C1WebGrid:C1TemplateColumn>
                                        <ItemTemplate>
                                            <asp:HyperLink ID="hlRef_SistemaErogante" runat="server" NavigateUrl='<%# GetUrlLinkReferto(Eval("Id")) %>'
                                                Text='<%# Eval("SistemaErogante") %>'></asp:HyperLink>
                                        </ItemTemplate>
                                        <ItemStyle Width="50px" />
                                    </C1WebGrid:C1TemplateColumn>
                                    <C1WebGrid:C1BoundColumn DataField="Anteprima" HeaderText="" Visible="True">
                                        <ItemStyle Width="200px" />
                                    </C1WebGrid:C1BoundColumn>
                                    <C1WebGrid:C1TemplateColumn HeaderText="Data evento">
                                        <ItemTemplate>
                                            <asp:HyperLink ID="hlRef_DataEvento" runat="server" NavigateUrl='<%# GetUrlLinkReferto(Eval("Id")) %>'
                                                Text='<%# String.Format("{0:g}", Eval("DataEvento")) %>'></asp:HyperLink>
                                        </ItemTemplate>
                                    </C1WebGrid:C1TemplateColumn>
                                    <C1WebGrid:C1TemplateColumn HeaderText="Data referto">
                                        <ItemTemplate>
                                            <asp:HyperLink ID="hlRef_DataReferto" runat="server" NavigateUrl='<%# GetUrlLinkReferto(Eval("Id")) %>'
                                                Text='<%# String.Format("{0:d}", Eval("DataReferto")) %>'></asp:HyperLink>
                                        </ItemTemplate>
                                    </C1WebGrid:C1TemplateColumn>
                                    <C1WebGrid:C1BoundColumn DataField="PrioritaDescr" HeaderText="Priorit&#224; richiesta"
                                        ReadOnly="True" SortExpression="PrioritaDescr">
                                    </C1WebGrid:C1BoundColumn>
                                    <C1WebGrid:C1TemplateColumn HeaderText="Erogante">
                                        <ItemTemplate>
                                            <asp:Label ID="lbErogante" runat="server" Text='<%# BuildEroganteDescrizione(Eval("RepartoErogante"), Eval("SpecialitaErogante"), Eval("AziendaErogante"))  %>'></asp:Label>
                                        </ItemTemplate>
                                    </C1WebGrid:C1TemplateColumn>
                                    <C1WebGrid:C1BoundColumn DataField="NumeroReferto" HeaderText="Numero referto" SortExpression="NumeroReferto">
                                    </C1WebGrid:C1BoundColumn>
                                </Columns>
                                <PagerStyle CssClass="GridPager" Mode="NumericPages" Position="TopAndBottom" />
                                <HeaderStyle CssClass="GridHeader" />
                                <SelectedItemStyle CssClass="GridSelected" />
                                <AlternatingItemStyle CssClass="GridAlternatingItem" />
                            </C1WebGrid:C1WebGrid>
                        </asp:View>
                        <asp:View ID="ViewSistemaErogante" runat="server">
                            <C1WebGrid:C1WebGrid ID="C1WebGridSistemaErogante" runat="server" AutoGenerateColumns="False"
                                DataKeyField="ID" DataSourceID="DataSourceMain" CssClass="table table-striped table-condensed table-bordered" DefaultColumnWidth=""
                                DefaultRowHeight="" PageSize="2" AllowPaging="True">
                                <ItemStyle CssClass="GridItem" />
                                <Columns>
                                    <C1WebGrid:C1BoundColumn DataField="SistemaErogante" HeaderText="SistemaErogante"
                                        SortExpression="SistemaErogante" Visible="False">
                                        <GroupInfo Position="Header">
                                            <HeaderStyle CssClass="GridGroupingHeader" />
                                        </GroupInfo>
                                    </C1WebGrid:C1BoundColumn>
                                    <C1WebGrid:C1TemplateColumn>
                                        <ItemTemplate>
                                            <asp:Image ID="ImgStatoRichiestaCodice" runat="server" ImageUrl='<%# GetStatoImageUrl(Eval("StatoRichiestaCodice")) %>' />
                                        </ItemTemplate>
                                        <GroupInfo GroupSingleRow="False">
                                        </GroupInfo>
                                        <ItemStyle HorizontalAlign="Center" Width="30px" />
                                    </C1WebGrid:C1TemplateColumn>
                                    <C1WebGrid:C1TemplateColumn>
                                        <ItemTemplate>
                                            <asp:HyperLink ID="hlRef_SistemaErogante" runat="server" NavigateUrl='<%# GetUrlLinkReferto(Eval("Id")) %>'
                                                Text='<%# Eval("SistemaErogante") %>'></asp:HyperLink>
                                        </ItemTemplate>
                                        <ItemStyle Width="50px" />
                                    </C1WebGrid:C1TemplateColumn>
                                    <C1WebGrid:C1BoundColumn DataField="Anteprima" HeaderText="" Visible="True">
                                        <ItemStyle Width="200px" />
                                    </C1WebGrid:C1BoundColumn>
                                    <C1WebGrid:C1TemplateColumn HeaderText="Data evento">
                                        <ItemTemplate>
                                            <asp:HyperLink ID="hlRef_DataEvento" runat="server" NavigateUrl='<%# GetUrlLinkReferto(Eval("Id")) %>'
                                                Text='<%# String.Format("{0:g}", Eval("DataEvento")) %>'></asp:HyperLink>
                                        </ItemTemplate>
                                    </C1WebGrid:C1TemplateColumn>
                                    <C1WebGrid:C1TemplateColumn HeaderText="Data referto">
                                        <ItemTemplate>
                                            <asp:HyperLink ID="hlRef_DataReferto" runat="server" NavigateUrl='<%# GetUrlLinkReferto(Eval("Id")) %>'
                                                Text='<%# String.Format("{0:d}", Eval("DataReferto")) %>'></asp:HyperLink>
                                        </ItemTemplate>
                                    </C1WebGrid:C1TemplateColumn>
                                    <C1WebGrid:C1BoundColumn DataField="PrioritaDescr" HeaderText="Priorit&#224; richiesta"
                                        ReadOnly="True" SortExpression="PrioritaDescr">
                                    </C1WebGrid:C1BoundColumn>
                                    <C1WebGrid:C1TemplateColumn HeaderText="Erogante">
                                        <ItemTemplate>
                                            <asp:Label ID="lbErogante" runat="server" Text='<%# BuildEroganteDescrizione(Eval("RepartoErogante"), Eval("SpecialitaErogante"), Eval("AziendaErogante"))  %>'></asp:Label>
                                        </ItemTemplate>
                                    </C1WebGrid:C1TemplateColumn>
                                    <C1WebGrid:C1BoundColumn DataField="NumeroReferto" HeaderText="Numero referto" SortExpression="NumeroReferto">
                                    </C1WebGrid:C1BoundColumn>
                                </Columns>
                                <PagerStyle CssClass="GridPager" Mode="NumericPages" Position="TopAndBottom" />
                                <HeaderStyle CssClass="GridHeader" />
                                <SelectedItemStyle CssClass="GridSelected" />
                                <AlternatingItemStyle CssClass="GridAlternatingItem" />
                            </C1WebGrid:C1WebGrid>
                        </asp:View>--%>
                        <asp:View ID="ViewRisultatoMatrice" runat="server">
                            <div class=" gridView-custum-margin">
                                <asp:Xml ID="XmlRisultatoMatrice" runat="server" TransformSource="~/Xslt/MatricePrestazioni.xsl"></asp:Xml>
                            </div>
                        </asp:View>
                    </asp:MultiView>
                </div>
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-sm-12">
            <asp:Label ID="lblNoRecordFound" runat="server" EnableViewState="False" CssClass="text-danger"></asp:Label>
            <asp:Label ID="lblPrestazioniMatrice" runat="server" EnableViewState="False" CssClass="text-danger"></asp:Label>
        </div>
    </div>

    <asp:ObjectDataSource ID="DataSourceMain" runat="server" SelectMethod="GetPazientiRefertiLista2"
        TypeName="DwhClinico.Web.PazientiRefertiLista" EnableCaching="True" OldValuesParameterFormatString="original_{0}"
        CacheKeyDependency="CKD_DataSourceMain_RefertiListaRicoveroPaziente" CacheDuration="180">
        <SelectParameters>
            <asp:Parameter Name="IdPaziente" Type="Object" />
            <asp:Parameter Name="AziendaErogante" Type="String" />
            <asp:Parameter Name="SistemaErogante" Type="String" />
            <asp:Parameter Name="RepartoErogante" Type="String" />
            <asp:Parameter Name="DataDal" Type="String" />
            <asp:Parameter Name="NumeroReferto" Type="String" />
            <asp:Parameter Name="NumeroNosologico" Type="String" />
            <asp:Parameter Name="AziendaEroganteNosologico" Type="String" />
            <asp:Parameter Name="Sort" Type="String" />
        </SelectParameters>
    </asp:ObjectDataSource>
    <asp:ObjectDataSource ID="DataSourceEventiSingoli" runat="server" SelectMethod="GetPazientiRefertiSingoliLista"
        TypeName="DwhClinico.Web.PazientiRefertiLista" EnableCaching="True" OldValuesParameterFormatString="original_{0}"
        CacheKeyDependency="CKD_DataSourceEventiSingoli_RefertiListaRicoveroPaziente" CacheDuration="180">
        <SelectParameters>
            <asp:Parameter Name="IdPaziente" Type="Object" />
            <asp:Parameter Name="NumeroNosologico" Type="String" />
            <asp:Parameter Name="DataDal" Type="String" />
        </SelectParameters>
    </asp:ObjectDataSource>
    <asp:ObjectDataSource ID="DataSourcePrestazioniMatrice" runat="server" OldValuesParameterFormatString="original_{0}"
        SelectMethod="GetPazientiRefertiPrestazioneMatrice2" TypeName="DwhClinico.Web.PazientiRefertiLista"
        CacheDuration="180" CacheKeyDependency="CKD_DataSourcePrestazioniMatrice">
        <SelectParameters>
            <asp:Parameter Name="IdPaziente" Type="Object" />
            <asp:Parameter Name="AziendaErogante" Type="String" />
            <asp:Parameter Name="SistemaErogante" Type="String" />
            <asp:Parameter Name="RepartoErogante" Type="String" />
            <asp:Parameter Name="DataDal" Type="String" />
            <asp:Parameter Name="NumeroReferto" Type="String" />
            <asp:Parameter Name="PrestazioneCodice" Type="String" />
            <asp:Parameter Name="SezioneCodice" Type="String" />
            <asp:Parameter Name="NumeroNosologico" Type="String" />
            <asp:Parameter Name="AziendaEroganteNosologico" Type="String" />
        </SelectParameters>
    </asp:ObjectDataSource>
    <asp:ObjectDataSource ID="DataSourceTestataEpisodio" runat="server" OldValuesParameterFormatString="original_{0}"
        SelectMethod="GetRicoveroTestata" TypeName="DwhClinico.Web.PazientiRicoveri"
        CacheKeyDependency="CKD_DataSourceTestataEpisodio" CacheDuration="180">
        <SelectParameters>
            <asp:Parameter Type="Object" Name="IdRicovero" />
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>
