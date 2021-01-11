<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
    CodeBehind="ReportViewer.aspx.vb" Inherits="DI.OrderEntry.User.ReportViewer" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<div class="row" id="divErrorMessage" runat="server" visible="false" enableviewstate="false">
		<div class="col-sm-12">
			<div class="alert alert-danger">
				<asp:Label ID="lblError" runat="server" CssClass="Error text-danger" EnableViewState="false" />
			</div>
		</div>
	</div>
	<iframe id="IframeMain" runat="server" class="ExpandWidthHeight" frameborder="0"
        scrolling="yes" height="100%" width="100%"></iframe>
</asp:Content>
