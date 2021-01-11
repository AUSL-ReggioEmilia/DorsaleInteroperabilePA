<%@ Page Title="Order Entry" Language="vb" AutoEventWireup="false" MasterPageFile="~/OrderEntry.Master"
    CodeBehind="HomeOrderEntry.aspx.vb" Inherits="DI.OrderEntry.Admin.HomeOrderEntry" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="OrderEntryContentPlaceHolder"
    runat="server">
    <div style="width: 100%; text-align: center; padding-top: 30px">
        <span style="font-size: 17px;">Benvenuto nel portale dell'Order Entry.<br />
            Clicca sul menu a sinistra per accedere alle sezioni</span>
    </div>
    <script type="text/javascript">

        window.location = "Ordini/OrdiniRichiesti.aspx";
    </script>
</asp:Content>
