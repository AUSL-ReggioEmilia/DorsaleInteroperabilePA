<%@ Control Language="VB" CodeBehind="ValuesList_Edit.ascx.vb" Inherits="ValuesList_EditField" %>

<asp:DropDownList
	ID="DropDownList1"
	runat="server"
	CssClass="form-control">
</asp:DropDownList>

<asp:RequiredFieldValidator
	runat="server"
	ID="RequiredFieldValidator1"
	CssClass="validator text-danger"
	ControlToValidate="DropDownList1"
	Display="Dynamic"
	Enabled="false"
	ToolTip='<%# String.Format("Il campo {0} è obbligatorio.", Column.DisplayName)%>'
	ErrorMessage='<%# String.Format("Il campo {0} è obbligatorio.", Column.DisplayName)%>' />

