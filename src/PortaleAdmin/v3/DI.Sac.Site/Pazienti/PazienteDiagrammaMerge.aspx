<%@ Page Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="PazienteDiagrammaMerge.aspx.vb"
    Inherits="DI.Sac.Admin.PazienteDiagrammaMerge" Title="Untitled Page" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
        Visible="False"></asp:Label>
    <div id="divDiagram" runat="server">
    </div>
</asp:Content>
