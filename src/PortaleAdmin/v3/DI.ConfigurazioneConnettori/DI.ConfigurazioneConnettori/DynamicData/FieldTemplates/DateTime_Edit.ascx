<%@ Control Language="VB" CodeBehind="DateTime_Edit.ascx.vb" Inherits="DateTime_EditField" %>

<asp:TextBox
	ID="TextBox1"
	runat="server"
	CssClass="form-control"
	Text='<%# FieldValueEditString %>'
	placeholder="es: 22/11/1996 22:10">
</asp:TextBox>


<asp:RequiredFieldValidator
	runat="server"
	ID="RequiredFieldValidator1"
	CssClass="validator text-danger"
	ControlToValidate="TextBox1"
	Display="Dynamic"
	Enabled="false"
	ErrorMessage='<%# String.Format("Il campo {0} è obbligatorio.", Column.DisplayName)%>'
	Text="Campo Obbligatorio"
	ToolTip='<%# String.Format("Il campo {0} è obbligatorio.", Column.DisplayName)%>' />

<%--<asp:RegularExpressionValidator
    runat="server"
    ID="RegularExpressionValidator1"
    CssClass="validator text-danger"
    ControlToValidate="TextBox1"
    Display="Dynamic"
    Enabled="false" />

<asp:CompareValidator runat="server" ID="CompareValidator1" CssClass="validator text-danger" ControlToValidate="TextBox1" Display="Dynamic"
    Type="Date"
    ErrorMessage='<%# String.Format("Il campo {0} contiene un valore non numerico.", column.DisplayName)%>' Text="Valore non numerico" />--%>

<asp:RegularExpressionValidator ID="RegularExpressionValidator1" runat="server" 	
	class="Error text-danger" Display="Dynamic" ControlToValidate="TextBox1" 
	ValidationExpression="^(0?[1-9]|[12][0-9]|3[01])[/-](0?[1-9]|1[0-2])[/-](1[89][0-9]{2}|[2-9][0-9]{3})([ ]([0-9]|[01][0-9]|2[0-3])[.:][0-5][0-9]([.:][0-5][0-9])?)?$"
	SetFocusOnError="True"></asp:RegularExpressionValidator>


<asp:DynamicValidator runat="server" ID="DynamicValidator1" CssClass="validator text-danger" 
	ControlToValidate="TextBox1" Display="Dynamic" />

<asp:CustomValidator runat="server" ID="DateValidator" CssClass="validator text-danger" 
	ControlToValidate="TextBox1" Display="Dynamic" EnableClientScript="false" Enabled="false" OnServerValidate="DateValidator_ServerValidate" />

