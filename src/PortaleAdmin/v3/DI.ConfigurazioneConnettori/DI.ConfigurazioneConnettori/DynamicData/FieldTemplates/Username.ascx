<%@ Control Language="VB" CodeBehind="Username.ascx.vb" Inherits="UsernameField" %>
<p class="form-control-static">
	<asp:HyperLink ID="HyperLink1" runat="server"
		Text="<%# GetDisplayString() %>"
		NavigateUrl="<%# GetNavigateUrl() %>" />
</p>

