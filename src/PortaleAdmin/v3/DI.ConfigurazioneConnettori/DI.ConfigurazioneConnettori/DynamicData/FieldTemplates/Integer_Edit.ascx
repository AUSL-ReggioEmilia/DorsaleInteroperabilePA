<%@ Control Language="VB" CodeBehind="Integer_Edit.ascx.vb" Inherits="Integer_EditField" %>

<asp:TextBox ID="TextBox1" runat="server" Text='<%# FieldValueEditString %>' CssClass="form-control" Columns="10" placeholder='<%# Column.DisplayName %>'></asp:TextBox>

<small>

	<asp:RequiredFieldValidator runat="server" ID="RequiredFieldValidator1" CssClass="validator text-danger" ControlToValidate="TextBox1" 
		Display="Dynamic"	Enabled="false" />

	<asp:CompareValidator runat="server" ID="CompareValidator1" CssClass="validator text-danger" ControlToValidate="TextBox1" Display="Dynamic"
		Operator="DataTypeCheck" Type="Integer"
		ErrorMessage='<%# String.Format("Il campo {0} contiene un valore non numerico.", Column.DisplayName)%>' Text="Valore non numerico" />

	<asp:RegularExpressionValidator runat="server" ID="RegularExpressionValidator1" CssClass="validator text-danger" ControlToValidate="TextBox1" 
		Display="Dynamic" Enabled="false"  />

	<asp:RangeValidator runat="server" ID="RangeValidator1" CssClass="validator text-danger" ControlToValidate="TextBox1" Type="Integer"
		Enabled="false" EnableClientScript="true" Display="Dynamic" MinimumValue="0" MaximumValue="99999"/>

	<asp:DynamicValidator runat="server" ID="DynamicValidator1" CssClass="validator text-danger" ControlToValidate="TextBox1" Display="Dynamic" />

</small>