<%@ Control Language="VB" CodeBehind="ForeignKey.ascx.vb" Inherits="ForeignKeyField" %>

<p class="form-control-static">
	<asp:HyperLink ID="HyperLink1" runat="server"
		Text="<%# GetDisplayString() %>"
		NavigateUrl="<%# GetNavigateUrl() %>" />
</p>
