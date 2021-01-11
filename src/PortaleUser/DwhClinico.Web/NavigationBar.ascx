<%@ Control Language="VB" AutoEventWireup="false" Inherits="DwhClinico.Web.NavigationBar" Codebehind="NavigationBar.ascx.vb" %>
<table class="LinkNavContainer" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td>
			<asp:DataList CssClass="PageNavBarContent" id="dlLinkNav" runat="server" ShowHeader="False" ShowFooter="False"
				RepeatDirection="Horizontal">
				<SeparatorStyle CssClass="LinkNavSeparatorStyle"></SeparatorStyle>
				<ItemStyle CssClass="LinkNavItemStyle"></ItemStyle>
				<ItemTemplate>
					<%# GetHtmlLink(DataBinder.Eval(Container, "DataItem"))%>
				</ItemTemplate>
				<SeparatorTemplate>
					&gt;
				</SeparatorTemplate>
			</asp:DataList>
		</td>
	</tr>
</table>
