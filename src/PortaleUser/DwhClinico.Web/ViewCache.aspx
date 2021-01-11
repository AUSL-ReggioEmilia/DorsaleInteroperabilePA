<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="ViewCache.aspx.vb" Inherits="DwhClinico.Web.ViewCache" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Dwh Cache Role Manager</title>
</head>
<body>
    <form id="form1" runat="server">
    <asp:Label ID="lblErrore" runat="server" Text=""></asp:Label>
    <div id="divPageTitle" class="PageTitle" runat="server">
        DWH: ELENCO CACHE ROLE MANAGER
    </div>
    <br />
    <div>
        <div id="MainDiv" runat="server">
        </div>
    </div>
    <br />
    <asp:Button ID="cmdCancellaCache" runat="server" Text="Cancella cache" />
    </form>
</body>
</html>
