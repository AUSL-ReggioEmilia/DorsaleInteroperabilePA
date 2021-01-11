<%@ Page Language="VB" MasterPageFile="~/Portale/Default.master" AutoEventWireup="false" Inherits="Eventi_RicoveriLista" Title="" CodeBehind="RicoveriLista.aspx.vb" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" runat="Server">
    <div class="row">
        <div class="col-sm-12">
            <div id="divPageTitle" runat="server" class="page-header">
                <h3>Episodi</h3>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <div class="alert alert-danger" id="alertErrorMessage" runat="server" enableviewstate="false" visible="false">
                <asp:Label ID="lblErrorMessage" runat="server" EnableViewState="False"></asp:Label>
            </div>
        </div>
    </div>

    <%-- TESTATA PAZIENTE --%>
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
                            <div class="form-group">
                                <asp:Label Text="Codice Fiscale:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblCodiceFiscale" />
                                <asp:Label ID="lblCodiceFiscale" runat="server"></asp:Label>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-sm-6">
                            <div class="form-group">
                                <asp:Label Text="Luogo e data di nascita:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblLuogoNascita" />

                                <asp:Label ID="lblLuogoNascita" runat="server"></asp:Label>
                                -
                        <asp:Label ID="lblDataNascita" runat="server"></asp:Label>
                            </div>
                        </div>
                        <div class="col-sm-6">
                            <div class="form-group">
                                <asp:Label Text="Codice sanitario:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblCodiceSanitario" />
                                <asp:Label ID="lblCodiceSanitario" runat="server"></asp:Label>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-sm-6">
                            <div class="form-group">
                                <asp:Label ID="lblDataDecesso" runat="server" Text="Data di decesso:" AssociatedControlID="lblDataDecessoValue" CssClass="col-sm-6"></asp:Label>
                                <asp:Label ID="lblDataDecessoValue" runat="server" CssClass="text-danger" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- TOOLBAR BOOTSTRAP --%>
    <div class="row" id="divFiltersContainer" runat="server">
        <div class="col-sm-12">
            <div class="well well-sm">
                <div class="btn-toolbar">
                    <div class="col-sm-3">
                        <div class="input-group input-group-sm">
                            <asp:Label ID="lblDallaData" runat="server" Text="Dalla data:" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtDataDal" runat="server" CssClass="form-control input-sm" placeholder="Dalla data"></asp:TextBox>
                            <asp:Label ID="lblFormatoData" runat="server" Text="(dd/mm/yyyy)" CssClass="input-group-addon"></asp:Label>
                        </div>
                    </div>
                    <div class="col-sm-6">
                        <asp:Button ID="cmdCerca" runat="server" Text="Cerca" CssClass="btn btn-primary btn-sm" />
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- TABELLA EPISODI --%>
    <div class="row" id="divReportContainer" runat="server">
        <div class="col-sm-12">
            <div class="table-responsive">
                <asp:GridView runat="server" ID="WebGridEpisodi" AutoGenerateColumns="False" DataSourceID="DataSourceMain" CssClass="table table-striped table-condensed table-bordered" DefaultColumnWidth=""
                    DefaultRowHeight="" PageSize="2" AllowPaging="True">
                    <Columns>
                        <asp:TemplateField HeaderText="Nosologico">
                            <ItemTemplate>
                                <asp:HyperLink ID="hlEventiLista" NavigateUrl='<%# GetUrlDettaglio(Eval("IdRicovero"), Eval("NumeroNosologico")) %>'
                                    Text='<%# Eval("NumeroNosologico") %>' runat="server" />
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="AziendaErogante" HeaderText="Azienda/Ospedale"
                            ReadOnly="True" />

                        <asp:TemplateField HeaderText="Episodio">
                            <ItemTemplate>
                                <asp:Label ID="lblEpisodio" runat="server" Text='<%# GetEpisodioDesc(Eval("NumeroNosologico"), Eval("TipoEpisodioDescr")) %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="DataInizioEpisodio" HeaderText="Data/Ora inizio"
                            ReadOnly="True" DataFormatString="{0:g}" />

                        <asp:TemplateField HeaderText="Diagnosi di Accettazione">
                            <ItemTemplate>
                                <asp:Label ID="lblDiagnosi" runat="server" Text='<%# Eval("Diagnosi") %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="RepartoRicoveroAccettazioneDescr" HeaderText="Reparto di accettazione"
                            ReadOnly="True" />

                        <asp:BoundField DataField="UltimoEventoDescr" HeaderText="Ultimo evento"
                            ReadOnly="True" />

                        <asp:BoundField DataField="DataFineEpisodio" HeaderText="Data/Ora fine"
                            ReadOnly="True" DataFormatString="{0:g}" />

                        <asp:BoundField DataField="RepartoRicoveroUltimoEventoDescr" HeaderText="Reparto"
                            ReadOnly="True" />

                        <asp:TemplateField>
                            <ItemTemplate>
                                <asp:HyperLink ID="hlReferti" runat="server" NavigateUrl='<%# GetUrlLinkReferti(Eval("IdRicovero"), Eval("AziendaErogante"), Eval("NumeroNosologico")) %>'
                                    Text="Referti"></asp:HyperLink>&nbsp;
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <asp:Label ID="lblNoRecordFound" runat="server" EnableViewState="False"></asp:Label>
        </div>
    </div>

    <asp:ObjectDataSource ID="DataSourceMain" runat="server" SelectMethod="GetRicoveriLista"
        TypeName="DwhClinico.Web.PazientiRicoveri" EnableCaching="True" OldValuesParameterFormatString="original_{0}"
        CacheKeyDependency="CKD_DataSourceMain" CacheDuration="180">
        <SelectParameters>
            <asp:Parameter Name="IdPaziente" Type="Object" />
            <asp:Parameter Name="DataEpisodio" Type="String" />
            <asp:Parameter Name="AziendaErogante" Type="String" />
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>
