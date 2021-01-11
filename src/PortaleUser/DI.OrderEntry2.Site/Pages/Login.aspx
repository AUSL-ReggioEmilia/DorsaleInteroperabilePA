<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
    CodeBehind="Login.aspx.vb" Inherits="DI.OrderEntry.User.Login" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <div style="width: 100%; text-align: center;">
        <div id="login" style="width: 450px; border: silver 1px solid; padding: 10px; margin: 50px auto">
            Benvenuto
            <asp:Label ID="NomeLabel" runat="server" Text="Pizzarrone" Font-Bold="true"></asp:Label>,
            seleziona l'azienda e l'unità operativa
            <table style="width: 100%; border-collapse: collapse; margin-top: 15px;">
                <tr>
                    <td style="width: 100px;">
                        Azienda
                    </td>
                    <td>
                        <select id="aziendaSelect" style="width: 310px; float: left;" onchange="LoadUnitaOperativa();" />
                    </td>
                </tr>
                <tr>
                    <td style="width: 100px;">
                        Unità operativa
                    </td>
                    <td>
                        <select id="uoSelect" style="width: 310px; float: left;" />
                    </td>
                </tr>
            </table>
            <input type="button" id="okButton" class="Button" onclick="Login();" value="OK" style="float: right;
                margin-top: 3px;" />
        </div>
    </div>
    <script src="../Scripts/login.js?<%# Reflection.Assembly.GetExecutingAssembly.GetName.Version.ToString %>" type="text/javascript"></script>
</asp:Content>
