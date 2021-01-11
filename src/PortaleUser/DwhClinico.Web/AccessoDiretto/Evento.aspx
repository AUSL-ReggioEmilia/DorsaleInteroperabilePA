<%@ Page Language="VB" MasterPageFile="~/AccessoDiretto/AccessoDiretto.master" AutoEventWireup="false" Inherits="DwhClinico.Web.AccessoDiretto_Evento" Title="" CodeBehind="Evento.aspx.vb" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" runat="Server">
    <div class="row">
        <div class="col-sm-12">
            <div id="divPageTitle" class="page-header" runat="server">
                <h3>Evento</h3>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <div class="alert alert-danger" runat="server" enableviewstate="false" id="alertErrorMessage" visible="false">
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
                                <asp:Label Text="Nome e Cognome:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblNomeCognome" />
                                <asp:Label ID="lblNomeCognome" runat="server"></asp:Label>
                            </div>
                            <div class="col-sm-6">
                                <asp:Label Text="Codice Fiscale:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblCodiceFiscale" />
                                <asp:Label ID="lblCodiceFiscale" runat="server"></asp:Label>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-sm-6">
                                <asp:Label Text="Luogo e data di nascita:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblLuogoNascita" />
                                <asp:Label ID="lblLuogoNascita" runat="server"></asp:Label>
                                -
                        <asp:Label ID="lblDataNascita" runat="server"></asp:Label>
                            </div>
                            <div class="col-sm-6">
                                <asp:Label Text="Codice Sanitario:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblCodiceSanitario" />
                                <asp:Label ID="lblCodiceSanitario" runat="server"></asp:Label>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-sm-6">
                                <asp:Label ID="lblDataDecesso" runat="server" Text="Data di decesso:" CssClass="col-sm-6" AssociatedControlID="lblDataDecessoValue" />
                                <asp:Label ID="lblDataDecessoValue" runat="server" ForeColor="Red"></asp:Label>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row" id="divInfoRicovero" runat="server">
        <div class="col-sm-12">
            <asp:Xml EnableViewState="true" ID="XmlInfoRicovero" runat="server" TransformSource="~/Xslt/TestataRicovero.xsl"></asp:Xml>
        </div>
    </div>

    <div id="divReportContainer" runat="server">
        <asp:FormView ID="FormViewEventoDettaglio" runat="server" DataSourceID="DataSourceMain" RenderOuterTable="false">
            <ItemTemplate>
                <div class="row">
                    <div class="col-sm-12">
                        <div class="panel panel-default">
                            <div class="panel-body">
                                <div class="form">
                                    <div class="row">
                                        <div class="col-sm-6">
                                            <asp:Label Text="Data Evento:" runat="server" CssClass="col-sm-6" AssociatedControlID="DataEventoLabel" />
                                            <asp:Label ID="DataEventoLabel" runat="server" Text='<%# GetDataOraEvento( Eval("DataEvento")) %>'> 
                                            </asp:Label>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-sm-6">
                                            <asp:Label Text=" Tipo Evento:" runat="server" CssClass="col-sm-6" AssociatedControlID="TipoEventoLabel" />
                                            <asp:Label ID="TipoEventoLabel" runat="server" Text='<%# GetCodiceDescrizione(Eval("TipoEventoCodice"), Eval("TipoEventoDescr")) %>'>
                                            </asp:Label>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-sm-6">
                                            <asp:Label Text="Tipo Episodio:" runat="server" CssClass="col-sm-6" AssociatedControlID="TipoEpisodioLabel" />
                                            <asp:Label ID="TipoEpisodioLabel" runat="server" Text='<%# GetCodiceDescrizione(Eval("TipoEpisodio"), Eval("TipoEpisodioDescr")) %>'>
                                            </asp:Label>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-sm-6">
                                            <asp:Label Text=" Azienda Erogante:" runat="server" CssClass="col-sm-6" AssociatedControlID="AziendaEroganteLabel" />
                                            <asp:Label ID="AziendaEroganteLabel" runat="server" Text='<%# Bind("AziendaErogante") %>'>
                                            </asp:Label>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-sm-6">
                                            <asp:Label Text="Sistema Erogante:" runat="server" CssClass="col-sm-6" AssociatedControlID="SistemaEroganteLabel" />
                                            <asp:Label ID="SistemaEroganteLabel" runat="server" Text='<%# Bind("SistemaErogante") %>'>
                                            </asp:Label>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-sm-6">
                                            <asp:Label Text="Reparto Erogante:" runat="server" CssClass="col-sm-6" AssociatedControlID="RepartoEroganteLabel" />
                                            <asp:Label ID="RepartoEroganteLabel" runat="server" Text='<%# Bind("RepartoErogante") %>'>
                                            </asp:Label>
                                            </td>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-sm-6">
                                            <asp:Label Text="Reparto Ricovero:" runat="server" CssClass="col-sm-6" AssociatedControlID="RepartoRicoveroCodiceLabel" />
                                            <asp:Label ID="RepartoRicoveroCodiceLabel" runat="server" Text='<%# GetCodiceDescrizione(Eval("RepartoCodice"), Eval("RepartoDescr")) %>'>
                                            </asp:Label>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-sm-6">
                                            <asp:Label Text="Settore Ricovero:" runat="server" CssClass="col-sm-6" AssociatedControlID="SettoreRicoveroCodiceLabel" />
                                            <asp:Label ID="SettoreRicoveroCodiceLabel" runat="server" Text='<%# GetCodiceDescrizione(Eval("SettoreCodice"), Eval("SettoreDescr")) %>'>
                                            </asp:Label>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-sm-6">
                                            <asp:Label Text="Letto Ricovero:" runat="server" CssClass="col-sm-6" AssociatedControlID="LettoRicoveroCodiceLabel" />
                                            <asp:Label ID="LettoRicoveroCodiceLabel" runat="server" Text='<%# Bind("LettoCodice") %>'>
                                            </asp:Label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:FormView>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <asp:Label ID="lblNoRecordFound" runat="server" EnableViewState="False"></asp:Label>
        </div>
    </div>

    <asp:ObjectDataSource ID="DataSourceMain" runat="server" SelectMethod="GetDataRicoveroEventoDettaglio"
        TypeName="DwhClinico.Data.AccessoDiretto" EnableCaching="True" OldValuesParameterFormatString="original_{0}"
        CacheKeyDependency="CKD_RicoveroEventoDettaglio" CacheDuration="180">
        <SelectParameters>
            <asp:Parameter Type="Object" Name="IdEventi" />
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>

