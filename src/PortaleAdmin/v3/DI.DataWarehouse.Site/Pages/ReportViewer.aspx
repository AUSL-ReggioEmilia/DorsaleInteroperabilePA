<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
    CodeBehind="ReportViewer.aspx.vb" Inherits="DI.DataWarehouse.Admin.ReportViewer" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
     <asp:Label ID="LabelError" runat="server" CssClass="Error" 
      EnableViewState="False"></asp:Label>
    <iframe id="IframeMain" runat="server" class="ExpandWidthHeight" frameborder="0"
        scrolling="yes" height="100%" width="100%"></iframe>
</asp:Content>
