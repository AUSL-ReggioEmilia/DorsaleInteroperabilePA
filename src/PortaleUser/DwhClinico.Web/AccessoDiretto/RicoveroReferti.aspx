<%@ Page Language="VB" MasterPageFile="~/AccessoDiretto/AccessoDiretto.master" AutoEventWireup="false"
    Inherits="DwhClinico.Web.AccessoDiretto_RicoveroReferti" Title=""
    CodeBehind="RicoveroReferti.aspx.vb" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" runat="Server">
    <div class="row">
        <div class="col-sm-12">
            <div id="divPageTitle" class="page-header" runat="server">
                <h3>Elenco referti del ricovero</h3>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <div class="alert alert-danger" id="alertErrorMessage" runat="server" enableviewstate="false" visible="false">
                <asp:Label ID="lblErrorMessage" runat="server" CssClass="text-danger" EnableViewState="False"></asp:Label>
            </div>
        </div>
    </div>

    <div class="row" id="divTestataPaziente" runat="server">
        <div class="col-sm-12">
            <div class="panel panel-default">
                <div class="panel-heading">
                    Paziente
                </div>
                <div class="panel-body">
                    <div class="form">
                        <div class="row">
                            <div class="col-sm-6">
                                <asp:Label Text="Cognome:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblCognome" />
                                <asp:Label ID="lblCognome" runat="server"></asp:Label>
                            </div>
                            <div class="col-sm-6">
                                <asp:Label Text="Nome:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblNome" />
                                <asp:Label ID="lblNome" runat="server"></asp:Label>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-sm-6">
                                <asp:Label Text="Data di nascita:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblDataNascita" />
                                <asp:Label ID="lblDataNascita" runat="server"></asp:Label>
                            </div>
                            <div class="col-sm-6">
                                <asp:Label Text="Luogo di nascita:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblLuogoNascita" />
                                <asp:Label ID="lblLuogoNascita" runat="server"></asp:Label>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-sm-6">
                                <asp:Label Text="Codice fiscale:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblCodiceFiscale" />
                                <asp:Label ID="lblCodiceFiscale" runat="server"></asp:Label>
                            </div>
                            <div class="col-sm-6">
                                <asp:Label Text="Codice Sanitario:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblCodiceSanitario" />
                                <asp:Label ID="lblCodiceSanitario" runat="server"></asp:Label>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-sm-6">
                                <asp:Label ID="lblDataDecessoDesc" runat="server" Text="Data decesso:" CssClass="col-sm-6" AssociatedControlID="lblDataDecesso" />
                                <asp:Label ID="lblDataDecesso" runat="server" CssClass="text-danger"></asp:Label>
                            </div>
                        </div>
                    </div>

                </div>

            </div>
        </div>
    </div>

    <asp:FormView ID="FormViewTestataEpisodio" runat="server" DataSourceID="DataSourceTestataEpisodio" RenderOuterTable="false">
        <ItemTemplate>
            <div class="row" id="divTestataPaziente" runat="server">
                <div class="col-sm-12">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <asp:Label ID="lblTitoloSezione" runat="server" Text='<%# GetTitoloSezioneEpisodio() %>'></asp:Label>
                        </div>
                        <div class="panel-body">
                            <div class="form">
                                <div class="row">
                                    <div class="col-sm-6">
                                        <asp:Label Text="Azienda/Ospedale:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblAzienda" />
                                        <asp:Label ID="lblAzienda" runat="server" Text='<%# Bind("AziendaErogante") %>'></asp:Label>
                                    </div>
                                    <div class="col-sm-6">
                                        <asp:Label ID="lblNumeroNosologicoEtichetta" runat="server" Text='<%# GetNumeroNosologicoEtichetta() %>' CssClass="col-sm-6" AssociatedControlID="lblNumeroNosologico"></asp:Label>
                                        <asp:Label ID="lblNumeroNosologico" runat="server" Text='<%# Bind("NumeroNosologico") %>'></asp:Label>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-sm-6">
                                        <asp:Label Text="Episodio:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblEpisodioDescr" />
                                        <asp:Label ID="lblEpisodioDescr" runat="server" Text='<%# Bind("TipoEpisodioDescr") %>'></asp:Label>
                                    </div>
                                    <div class="col-sm-6">
                                        <asp:Label Text="Data/ora inizio:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblDataInizioEpisodio" />
                                        <asp:Label ID="lblDataInizioEpisodio" runat="server" Text='<%# GetDataOraEvento( Eval("DataInizioEpisodio")) %>'></asp:Label>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-sm-6">
                                        <asp:Label Text="Data/ora fine:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblDataFineEpisodio" />
                                        <asp:Label ID="lblDataFineEpisodio" runat="server" Text='<%# GetDataOraEvento( Eval("DataFineEpisodio")) %>'></asp:Label>
                                    </div>
                                    <div class="col-sm-6">
                                        <asp:Label Text="Ultimo evento:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblUltimoEventoDescr" />
                                        <asp:Label ID="lblUltimoEventoDescr" runat="server" Text='<%# Bind("UltimoEventoDescr") %>' CssClass="text-danger"></asp:Label>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-sm-6">
                                        <asp:Label Text="Reparto accettazione:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblRepartoAccettazione" />
                                        <asp:Label ID="lblRepartoAccettazione" runat="server" Text='<%# Eval("RepartoRicoveroAccettazioneDescr") %>'></asp:Label>
                                    </div>
                                    <div class="col-sm-6">
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

    <div class="row">
        <div class="col-sm-12">
            <div class="well well-sm">
                <div class="btn-toolbar">
                    <div class="btn-group">
                        <asp:Button ID="cmdCerca" runat="server" Text="Cerca" CssClass="btn btn-primary btn-sm" />
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="row" id="divReportContainer" runat="server">
        <div class="col-sm-12">
            <div class="table-responsive">
                <asp:GridView runat="server" ID="WebGridMain" AutoGenerateColumns="False"
                    DataKeyField="ID" DataSourceID="DataSourceRicoveroReferti" CssClass="table table-striped table-bordered table-condensed" DefaultColumnWidth=""
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

                        <asp:BoundField DataField="Anteprima" HeaderText="" Visible="True" />

                        <asp:TemplateField HeaderText="Data evento">
                            <ItemTemplate>
                                <asp:HyperLink ID="hlRef_DataEvento" runat="server" NavigateUrl='<%# GetUrlLinkReferto(Eval("Id")) %>'
                                    Text='<%# String.Format("{0:g}", Eval("DataEvento")) %>'></asp:HyperLink>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Data referto">
                            <ItemTemplate>
                                <asp:HyperLink ID="hlRef_DataReferto" runat="server" NavigateUrl='<%# GetUrlLinkReferto(Eval("Id")) %>'
                                    Text='<%# String.Format("{0:d}", Eval("DataReferto")) %>'></asp:HyperLink>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="PrioritaDescr" HeaderText="Priorit&#224; richiesta"
                            ReadOnly="True" SortExpression="PrioritaDescr" />

                        <asp:TemplateField HeaderText="Erogante">
                            <ItemTemplate>
                                <asp:Label ID="lbErogante" runat="server" Text='<%# BuildEroganteDescrizione(Eval("RepartoErogante") , Eval("SpecialitaErogante"), Eval("AziendaErogante"))  %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="NumeroReferto" HeaderText="Numero referto" SortExpression="NumeroReferto" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>
        <!-- Contenitore principale -->
    </div>

    <div class="row">
        <div class="col-sm-12">
            <asp:Label ID="lblNoRecordFound" runat="server" EnableViewState="False"></asp:Label>
        </div>
    </div>

    <asp:ObjectDataSource ID="DataSourceRicoveroReferti" runat="server" SelectMethod="GetDataRicoveroRefertiLista"
        TypeName="DwhClinico.Data.AccessoDiretto" EnableCaching="True" OldValuesParameterFormatString="original_{0}"
        CacheKeyDependency="CKD_DataSourceRicoveroReferti" CacheDuration="180">
        <SelectParameters>
            <asp:Parameter Name="IdPaziente" Type="Object" />
            <asp:Parameter Name="AziendaErogante" Type="String" />
            <asp:Parameter Name="NumeroNosologico" Type="String" />
            <asp:Parameter Name="DataDal" Type="DateTime" />
            <asp:Parameter Name="AziendaEroganteNosologico" Type="String" />
        </SelectParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="DataSourceTestataEpisodio" runat="server" OldValuesParameterFormatString="original_{0}"
        SelectMethod="GetRicoveroTestata" TypeName="DwhClinico.Web.PazientiRicoveri"
        CacheKeyDependency="CKD_DataSourceRicoveroRefertiTestataEpisodio" CacheDuration="180">
        <SelectParameters>
            <asp:Parameter Type="Object" Name="IdRicovero" />
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>
