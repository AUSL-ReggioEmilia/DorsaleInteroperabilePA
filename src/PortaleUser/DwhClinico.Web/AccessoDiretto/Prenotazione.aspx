<%@ Page Title="" Language="VB" MasterPageFile="~/AccessoDiretto/AccessoDiretto.master" AutoEventWireup="false" Inherits="DwhClinico.Web.AccessoDiretto_Prenotazione" CodeBehind="Prenotazione.aspx.vb" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" runat="Server">
    <div class="row">
        <div class="col-sm-12">
            <div id="divPageTitle" runat="server" class="page-header">
                <h3>Prenotazione</h3>
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

    <!--TESTATA PAZIENTE-->
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
                                <asp:Label ID="lblDataDecessoValue" runat="server" CssClass="text-danger"></asp:Label>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row" runat="server" id="divDettaglioPrenotazione">
        <div class="col-sm-12">
            <asp:Xml EnableViewState="true" ID="XmlDettaglioPrenotazione" runat="server" TransformSource="~/Xslt/DettaglioPrenotazione.xsl"></asp:Xml>
        </div>
    </div>
</asp:Content>

