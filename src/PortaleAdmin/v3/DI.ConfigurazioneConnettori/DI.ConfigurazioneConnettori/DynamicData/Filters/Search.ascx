<%@ Control Language="VB" CodeBehind="Search.ascx.vb" Inherits="Search" %>

<div class="input-group input-group-sm ">
    <!-- le funzioni collegate agli eventi onblur e onfocus sono definiti dentro il file main.js -->
	<asp:TextBox ID="TextBox1" runat="server" CssClass="form-control" onblur="TextBox_onBlur(this,event);" onfocus="TextBox_onFocus(this,event);" OnTextChanged="Button1_Click"></asp:TextBox>
	<span class="input-group-btn">
		<asp:LinkButton ID="Button1" ClientIDMode="Static" runat="server" CssClass="btn btn-default disabled" ToolTip="Applica Filtro [invio]">
				<span class="glyphicon glyphicon-filter"></span></asp:LinkButton>
	</span>
</div>



