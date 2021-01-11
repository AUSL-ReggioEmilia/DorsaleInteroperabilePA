<%@ Page Language="VB" MasterPageFile="~/Portale/Default.master" AutoEventWireup="false" Inherits="Eventi_RicoveroEventoDettaglio" Title="" CodeBehind="RicoveroEventoDettaglio.aspx.vb" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" runat="Server">
    <div class="row">
        <div class="col-sm-12">
            <div class="page-header">
                <h3>Evento</h3>
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
                                <asp:Label ID="lblDataDecesso" runat="server" Text="Data di decesso:" AssociatedControlID="lblDataDecessoValue" />
                                <asp:Label ID="lblDataDecessoValue" runat="server" ForeColor="Red"></asp:Label>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <asp:Xml EnableViewState="true" ID="XmlInfoRicovero" runat="server" TransformSource="~/Xslt/TestataRicovero.xsl"></asp:Xml>
        </div>
    </div>

    <div class="row" id="divReportContainer" runat="server">
        <div class="col-sm-12">
            <div class="panel panel-default">
                <div class="panel-body">
                    <!-- Contenitore principale del dettaglio -->
                    <asp:FormView ID="FormViewEventoDettaglio" runat="server" DataSourceID="DataSourceMain" RenderOuterTable="false">
                        <ItemTemplate>
                            <div class="form-horizontal">

                                <div class="form-group">
                                    <div class="col-sm-12">
                                        <asp:Label Text="Data Evento:" runat="server" class="col-sm-2" AssociatedControlID="DataEventoLabel" />
                                        <div class="col-sm-10">
                                            <asp:Label ID="DataEventoLabel" runat="server" Text='<%# GetDataOraEvento(Eval("DataEvento")) %>'> 
                                            </asp:Label>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div class="col-sm-12">
                                        <asp:Label Text="Tipo Evento:" runat="server" class="col-sm-2" AssociatedControlID="TipoEventoLabel" />
                                        <div class="col-sm-10">
                                            <asp:Label ID="TipoEventoLabel" runat="server" Text='<%# GetCodiceDescrizione(Eval("TipoEventoCodice"), Eval("TipoEventoDescr")) %>'>
                                            </asp:Label>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div class="col-sm-12">
                                        <asp:Label Text="Azienda Rrogante:" runat="server" class="col-sm-2" AssociatedControlID="AziendaEroganteLabel" />
                                        <div class="col-sm-10">
                                            <asp:Label ID="AziendaEroganteLabel" CssClass="form-control-static" runat="server" Text='<%# Bind("AziendaErogante") %>'>
                                            </asp:Label>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div class="col-sm-12">
                                        <asp:Label Text="Reparto di Ricovero:" runat="server" class="col-sm-2" AssociatedControlID="RepartoRicoveroCodiceLabel" />
                                        <div class="col-sm-10">
                                            <asp:Label ID="RepartoRicoveroCodiceLabel" runat="server" CssClass="form-control-static" Text='<%# GetCodiceDescrizione(Eval("RepartoCodice"), Eval("RepartoDescr")) %>'>
                                            </asp:Label>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div class="col-sm-12">
                                        <asp:Label Text="Settore di Ricovero:" runat="server" class="col-sm-2" AssociatedControlID="SettoreRicoveroCodiceLabel" />
                                        <div class="col-sm-10">
                                            <asp:Label ID="SettoreRicoveroCodiceLabel" runat="server" Text='<%# GetCodiceDescrizione(Eval("SettoreCodice"), Eval("SettoreDescr")) %>'>
                                            </asp:Label>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div class="col-sm-12">
                                        <asp:Label Text="Letto di Ricovero:" runat="server" class="col-sm-2" AssociatedControlID="SettoreRicoveroCodiceLabel" />
                                        <div class="col-sm-10">
                                            <asp:Label ID="LettoRicoveroCodiceLabel" runat="server" Text='<%# Bind("LettoCodice") %>'>
                                            </asp:Label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:FormView>
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <asp:Label ID="lblNoRecordFound" runat="server" CssClass="text-danger" EnableViewState="False"></asp:Label>
        </div>
    </div>

    <asp:ObjectDataSource ID="DataSourceMain" runat="server" SelectMethod="GetRicoveroPazienteEventoDettaglio"
        TypeName="DwhClinico.Web.PazientiRicoveri" EnableCaching="True" OldValuesParameterFormatString="original_{0}"
        CacheKeyDependency="CKD_DataSourceMain" CacheDuration="180">
        <SelectParameters>
            <asp:Parameter Type="Object" Name="IdEventi" />
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>
