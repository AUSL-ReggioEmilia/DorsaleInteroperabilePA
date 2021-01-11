<%@ Page Language="VB" MasterPageFile="~/Portale/Default.master" AutoEventWireup="false" Inherits="DwhClinico.Web.Eventi_RicoveroEventiLista"
    Title="" CodeBehind="RicoveroEventiLista.aspx.vb" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" runat="Server">
    <div class="row">
        <div class="col-sm-12">
            <div id="divPageTitle" class="page-header" runat="server">
                <h3>Eventi</h3>
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
                                <asp:Label ID="lblDataDecesso" runat="server" Text="Data decesso:" AssociatedControlID="lblDataDecessoValue"></asp:Label>
                                <asp:Label ID="lblDataDecessoValue" runat="server" CssClass="text-danger"></asp:Label>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- XML EPISODIO --%>
    <asp:Xml EnableViewState="true" ID="XmlInfoRicovero" runat="server" TransformSource="~/Xslt/TestataRicovero.xsl"></asp:Xml>

    <!-- TOOLBAR  BOOTSTRAP -->
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

    <%-- LISTA DEGLI EVENTI --%>
    <div class="row" id="divReportContainer" runat="server">
        <div class="col-sm-12">
            <div class="table-responsive">                
                <asp:GridView runat="server"  ID="WebGridEventi" AutoGenerateColumns="False"
                    DataKeyField="ID" DataSourceID="DataSourceMain" CssClass="table table-bordered table-striped table-condensed" DefaultColumnWidth=""
                    DefaultRowHeight="" PageSize="2" AllowPaging="True">
                    <Columns>
                        <asp:TemplateField HeaderText="Evento">
                            <ItemTemplate>
                                <asp:HyperLink ID="hlDettaglioEvento" runat="server" NavigateUrl='<%# GetUrlDettaglio(Eval("NumeroNosologico"), Eval("IdPaziente"), Eval("IdRicovero"), Eval("Id")) %>'
                                    Text='<%# GetCodiceDescrizione(Eval("TipoEventoCodice"), Eval("TipoEventoDescr")) %>'></asp:HyperLink>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="DataEvento" HeaderText="Data" ReadOnly="True"
                            DataFormatString="{0:g}"/>

                        <asp:TemplateField HeaderText="Reparto di Ricovero">
                            <ItemTemplate>
                                <asp:Label ID="lblRepartoRicovero" runat="server" Text='<%# GetCodiceDescrizione(Eval("RepartoCodice"), Eval("RepartoDescr")) %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Settore di Ricovero">
                            <ItemTemplate>
                                <asp:Label ID="lblSettoreRicovero" runat="server" Text='<%# GetCodiceDescrizione(Eval("SettoreCodice"), Eval("SettoreDescr")) %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <asp:Label ID="lblNoRecordFound" runat="server" EnableViewState="False" CssClass="text-danger"></asp:Label>
        </div>
    </div>

    <asp:ObjectDataSource ID="DataSourceMain" runat="server" SelectMethod="GetRicoveroEventiLista"
        TypeName="DwhClinico.Web.PazientiRicoveri" EnableCaching="True" OldValuesParameterFormatString="original_{0}"
        CacheKeyDependency="CKD_DataSourceMain" CacheDuration="180">
        <SelectParameters>
            <asp:Parameter Name="IdRicovero" Type="Object" />
            <asp:Parameter Name="DataEventoDal" Type="String" />
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>
