<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="StampaOrdine.aspx.vb" Inherits=".StampaOrdine2" %>

<!DOCTYPE html>
<html lang="it-it" style="height: 100%">
<head runat="server">
    <title></title>
    <%-- IMPORT FILE BOOTSTRAP --%>
    <link href="~/Content/bootstrap.min.css" rel="stylesheet" />
</head>
<body style="height: 100%">
    <form id="form1" runat="server" style="height: 100%">
        <asp:ScriptManager ID="ScriptManagerMaster" runat="server" EnablePageMethods="false">
            <Scripts>
                <%-- DEFINITI NEL GLOBAL.ASAX --%>
                <asp:ScriptReference Name="jquery" />
                <asp:ScriptReference Name="bootstrap" />
                <asp:ScriptReference Name="respond" />
                <asp:ScriptReference Path="modernizr" />
            </Scripts>
        </asp:ScriptManager>
        <%--    <div class="container-fluid">
            <div class="row">--%>
        <%--<div class="col-sm-12">
                    
              <%--  </div>
            </div>
        </div>--%>
        <div class="alert alert-danger" id="alertErrore" runat="server">
            <asp:Label ID="lblErrore" CssClass="text-danger" runat="server" Style="width: 100%" /><br />
        </div>
        <asp:Button ID="btnIndietro" Text="Indietro" CssClass="btn btn-default btn-primary" runat="server" Style="margin-bottom:5px; margin-top: 5px" />
        <iframe class="embed-responsive-item" id="iframeStampaOrdine" runat="server" style="height: 90%; width: 100%" scrolling="no"></iframe>
    </form>
</body>
</html>
