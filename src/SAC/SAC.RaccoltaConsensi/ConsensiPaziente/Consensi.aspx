<%@ Page Title="Raccolta dei Consensi Privacy" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
    CodeBehind="Consensi.aspx.vb" Inherits=".Consensi" %>

<%@ MasterType VirtualPath="~/Site.Master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <div class="row">
        <div class="col-sm-12">
            <div id="toolbar" runat="server" class="form-group">
                <a href="Default.aspx" class="btn btn-sm btn-primary"><span class="glyphicon glyphicon-arrow-left" aria-hidden="true"></span> Torna alla ricerca anagrafica</a>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <div class="panel panel-default">
                <div class="panel-body">
                    <strong>
                        <asp:Label runat="server" ID="lblTitolo" CssClass="Title"></asp:Label></strong>
                </div>
            </div>
        </div>
    </div>


    <div id="divConsensi" runat="server" class="divConsensi">
        <div class="row">
            <div class="col-sm-12 form-group">
                <a class="btn btn-sm btn-default" onclick="window.open('/Documenti/Informativa.pdf');"><span class="glyphicon glyphicon-print" aria-hidden="true"></span> Stampa Informativa</a>
            </div>
        </div>

        <div class="row">
            <div class="col-sm-12" id="divMessageConsensoGenericoNegato" runat="server">
                <div class="alert alert-warning">
                    <asp:Label ID="lblMessageConsensoGenericoNegato" runat="server" CssClass="text-danger" Visible="true"></asp:Label>
                </div>
            </div>

            <div class="col-sm-12 form-group">
                <asp:Button ID="butBase" runat="server" CssClass="btn btn-lg btn-default custom-button" />
                <asp:Button ID="butBaseNegato" runat="server" CssClass="btn btn-lg btn-default custom-button" />
            </div>
            <div class="col-sm-12 form-group text-nowrap">
                <asp:Button ID="butDossier" runat="server" CssClass="btn btn-lg btn-default custom-button" />
                <asp:Button ID="butTutti" runat="server" CssClass="btn btn-lg btn-default btn-tuttiConsensi" />
            </div>
            <div class="col-sm-12 form-group">
                <asp:Button ID="butDossierStorico" runat="server" CssClass="btn btn-lg btn-default custom-button" />
            </div>
        </div>

    </div>

    <asp:ObjectDataSource ID="odsPazientePerId" runat="server" SelectMethod="PazienteDettaglio" TypeName="WcfSacPazientiHelper"
        OldValuesParameterFormatString="original_{0}">
        <SelectParameters>
            <asp:QueryStringParameter DbType="Guid" Name="IdPaziente" QueryStringField="Id" />
        </SelectParameters>
    </asp:ObjectDataSource>
    <asp:ObjectDataSource ID="odsPazientePerIdProvenienza" runat="server" SelectMethod="PazienteDettaglioPerIdProvenienza"
        TypeName="WcfSacPazientiHelper" OldValuesParameterFormatString="original_{0}">
        <SelectParameters>
            <asp:QueryStringParameter Name="Provenienza" QueryStringField="Provenienza" Type="String" />
            <asp:QueryStringParameter DefaultValue="" Name="IdProvenienza" QueryStringField="IdProvenienza"
                Type="String" />
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>
