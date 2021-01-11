<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
    CodeBehind="ReportViewer.aspx.vb" Inherits="DI.PortalAdmin.Home.ReportViewer" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <div class="embed-responsive embed-responsive-16by9">
        <iframe id="IframeMain" runat="server" class="embed-responsive-item" frameborder="0"
            scrolling="yes" height="100%" width="100%"></iframe>
    </div>
</asp:Content>
