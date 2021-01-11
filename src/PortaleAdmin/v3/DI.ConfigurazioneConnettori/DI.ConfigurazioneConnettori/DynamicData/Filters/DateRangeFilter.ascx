<%@ Control Language="VB" CodeBehind="DateRangeFilter.ascx.vb" Inherits="DateRangeFilter" %>
<div class="input-group input-group-sm ">
	<div class="input-group-addon">
		<p>Dal</p>
		Al
	</div>
	<asp:TextBox
		ID="txbFrom"
		runat="server"
		CssClass="form-control"
		MaxLength="10"
		onkeydown="TextBox_onkeydown(this,event);">
	</asp:TextBox>
	<br />
	<asp:TextBox
		ID="txbTo"
		runat="server"
		CssClass="form-control"
		MaxLength="10"
		onkeydown="TextBox_onkeydown(this,event);">
	</asp:TextBox>
	<span class="input-group-addon">
		<asp:LinkButton ID="Button1" runat="server" 
			CssClass="btn btn-sm btn-default disabled" 
			ToolTip="Applica Filtro [invio]">
				<span class="glyphicon glyphicon-filter"></span></asp:LinkButton>
	</span>

	<asp:CompareValidator
		ID="txbFromDateValidator" runat="server"
		Type="Date"
		Operator="DataTypeCheck"
		ControlToValidate="txbFrom"
		ErrorMessage="Data non valida [Dal]"
		Display="None" ValidationGroup="">
	</asp:CompareValidator>

	<asp:CompareValidator
		ID="txbToDateValidator" runat="server"
		Type="Date"
		Operator="DataTypeCheck"
		ControlToValidate="txbTo"
		ErrorMessage="Data non valida [Al]"
		Display="None" ValidationGroup="">
	</asp:CompareValidator>

</div>

<script type="text/javascript">

	function TextBox_onkeydown(txtBox, e) {
		if (e.keyCode == 13) {
			Page_ClientValidate("");
			__doPostBack();
			return;
		}

		var inputgrp = txtBox.parentElement;
		addClass(inputgrp, "has-warning");
		var btn = inputgrp.getElementsByTagName("a")[0];
		remClass(btn, "disabled")
		addClass(btn, "btn");
		addClass(btn, "btn-warning");
	}

</script>


