<%@ Page Title="" Language="vb" AutoEventWireup="false" CodeBehind="Home.aspx.vb" Inherits="DI.PortalUser.Home.HomePage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<div class="row" id="divErrorMessage" runat="server" visible="false">
		<div class="col-sm-12">
			<div class="alert alert-danger">
				<asp:Label ID="LabelError" runat="server" CssClass="text-danger"></asp:Label>
			</div>
		</div>
	</div>

	<div class="row">
		<div class="col-sm-12">
			<div id="DivNews" runat="server" visible="true">
				<h2 class="text-center">
					<asp:Label ID="lblNewsTitle" runat="server"></asp:Label></h2>
				<hr />
				<asp:Xml ID="DwhNews" runat="server"></asp:Xml>
			</div>
		</div>
	</div>
</asp:Content>
