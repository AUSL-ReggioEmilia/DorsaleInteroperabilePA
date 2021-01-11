<%@ Page Title="" Language="vb" AutoEventWireup="false"
    CodeBehind="ReportViewer.aspx.vb" Inherits="DI.PortalUser.Home.ReportViewer" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <div class="row">
        <div class="col-sm-12">
            <div class="embed-responsive embed-responsive-4by3">
                <iframe id="IframeMain" runat="server" class="embed-responsive-item"
                    scrolling="yes"></iframe>
            </div>
        </div>
    </div>
</asp:Content>
