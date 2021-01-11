<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="ucInfoPaziente.ascx.vb" Inherits="DwhClinico.Web.ucInfoPaziente" %>

<label class="label label-default">Dati anagrafici</label>
<div class="well well-sm small">
    <div class="form-horizontal">
        <div class="row">
            <div class="col-sm-4">
                <asp:Label Text="Cognome" AssociatedControlID="lblCognome" CssClass="col-sm-6" runat="server" />
                <asp:Label ID="lblCognome" runat="server" />
            </div>
            <div class="col-sm-4">
                <asp:Label Text="Nome" AssociatedControlID="lblNome" CssClass="col-sm-6" runat="server" />
                <asp:Label ID="lblNome" runat="server" />
            </div>
            <div class="col-sm-4">
                <asp:Label Text="Codice fiscale:" AssociatedControlID="lblCodiceFiscale" CssClass="col-sm-6" runat="server" />
                <asp:Label ID="lblCodiceFiscale" runat="server" />
            </div>
        </div>
        <div class="row">
            <div class="col-sm-4">
                <asp:Label Text="Data di nascita:" AssociatedControlID="lblDataNascita" CssClass="col-sm-6" runat="server" />
                <asp:Label ID="lblDataNascita" runat="server" />
            </div>
            <div class="col-sm-4">
                <asp:Label Text="Luogo di nascita:" AssociatedControlID="lblLuogoNascita" CssClass="col-sm-6" runat="server" />
                <asp:Label ID="lblLuogoNascita" runat="server" />
            </div>
        </div>
    </div>
</div>
