<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="AttributiInserisci.aspx.vb"
	Inherits=".AttributiInserisci" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
	<title></title>
	<link href="~/Styles/master.css" rel="stylesheet" type="text/css" />
	<link href="~/Styles/jquery-ui.css" rel="stylesheet" type="text/css" />
	<script type="text/javascript" src="../Scripts/jquery-1.6.1.min.js"></script>
	<script type="text/javascript" src="../Scripts/jquery-ui-1.8.14.custom.min.js"></script>
	<script type="text/javascript" src="../Scripts/master.js"></script>
	<script type="text/javascript" src="../Scripts/PopUp.js"></script>
	<style type="text/css">
		.ddlSistema
		{
			margin-bottom: 9px;
		}
		.ddlUnità
		{
			margin-bottom: 5px;
		}
	
	</style>
</head>
<body style="overflow-x: hidden;">
	<form id="form1" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False"></asp:Label>
	<asp:Label ID="lblTitolo" runat="server" class="Title" Text="Label"></asp:Label>
	<asp:FormView ID="FormViewDettaglio" runat="server" DataKeyNames="Id" DataSourceID="odsDettaglio"
		EmptyDataText="Dettaglio non disponibile." EnableModelValidation="True" DefaultMode="Insert" >
		<InsertItemTemplate>
			<table class="table_dettagli">
				<tr>
					<td class="Td-Text" style="width: 250px;">
						<b>Tipo di Accesso</b>
						<asp:RadioButtonList ID="rblTipiAttributo" runat="server" GroupName="gTipo" commandname="rbRuolo"
							OnSelectedIndexChanged="TipoRuolo_OptionChanged" AutoPostBack="true" SelectedValue='<%# Bind("TipoAttributo") %>'>
							<asp:ListItem Value="0" Selected="True">Accesso di Ruolo</asp:ListItem>
							<asp:ListItem Value="1">Accesso del sistema</asp:ListItem>
							<asp:ListItem Value="2">Accesso dell&#39;unità operativa</asp:ListItem>
						</asp:RadioButtonList>
					</td>
					<td class="Td-Value" style="vertical-align: bottom; width: 300px; min-width: 300px;">
						<asp:RequiredFieldValidator ID="Required_ddlSistemi" class="Error" runat="server"
							ErrorMessage="Campo Obbligatorio" Display="Dynamic" ControlToValidate="ddlSistemi"
							Enabled="false" />
						<asp:DropDownList ID="ddlSistemi" runat="server" AppendDataBoundItems="True" Width="100%"
							DataSourceID="odsSistemi" DataTextField="NomeConcatenato" DataValueField="Id" CssClass="ddlSistema"
							SelectedValue='<%# Bind("IdRuoloSistema") %>' Enabled="false">
							<asp:ListItem Value="" Text=""></asp:ListItem>
						</asp:DropDownList>
						<asp:RequiredFieldValidator ID="Required_ddlUnità" class="Error" runat="server" Enabled="false"
							ErrorMessage="Campo Obbligatorio" Display="Dynamic" ControlToValidate="ddlUnità" />
						<asp:DropDownList ID="ddlUnità" runat="server" AppendDataBoundItems="True" Width="100%"
							DataSourceID="odsUnitàOperative" DataTextField="NomeConcatenato" DataValueField="Id"
							CssClass="ddlUnità" SelectedValue='<%# Bind("IdRuoliUnitaOperative") %>' Enabled="false">
							<asp:ListItem Value="" Text=""></asp:ListItem>
						</asp:DropDownList>
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Codice
					</td>
					<td class="Td-Value">
						<asp:RequiredFieldValidator ID="RequiredFieldValidator1" class="Error" runat="server"
							ErrorMessage="Campo Obbligatorio" Display="Dynamic" ControlToValidate="ddlCodice" />
						<asp:DropDownList ID="ddlCodice" runat="server" AppendDataBoundItems="false" Width="100%"
							DataSourceID="odsAttributi" DataTextField="Descrizione" DataValueField="Codice"
							OnDataBound="ddlCodice_DataBound">
						</asp:DropDownList>
					</td>
				</tr>
				<tr>
					<td class="Td-Text2">
						Note
					</td>
					<td class="Td-Value2">
						<asp:TextBox ID="txtNote" runat="server" Width="100%" MaxLength="128" Rows="2" TextMode="MultiLine"
							Text='<%# Bind("Note") %>' />
					</td>
				</tr>
				<tr>
					<td class="LeftFooter">
						<asp:Button ID="butSalva" runat="server" Text="Conferma" CssClass="TabButton" CommandName="Insert" />
					</td>
					<td class="RightFooter">
						<button onclick="window.parent.commonModalDialogClose(0);" class="asp_button">Chiudi</button>
					</td>
				</tr>
			</table>
		</InsertItemTemplate>
	</asp:FormView>
	<asp:ObjectDataSource ID="odsDettaglio" runat="server" TypeName="OrganigrammaDataSetTableAdapters.RuoliAttributiTableAdapter"
		InsertMethod="Insert" OldValuesParameterFormatString="{0}">
		<InsertParameters>
			<asp:Parameter Name="UtenteInserimento" Type="String" />
			<asp:Parameter DbType="Guid" Name="IdRuolo" />
			<asp:Parameter DbType="Guid" Name="IdRuoloSistema" />
			<asp:Parameter DbType="Guid" Name="IdRuoliUnitaOperative" />
			<asp:Parameter Name="CodiceAttributo" Type="String" />
			<asp:Parameter Name="Note" Type="String" />
			<asp:Parameter Name="TipoAttributo" Type="Byte" />
		</InsertParameters>
	</asp:ObjectDataSource>
	<asp:ObjectDataSource ID="odsAttributi" runat="server" TypeName="OrganigrammaDataSetTableAdapters.AttributiListaTableAdapter"
		SelectMethod="GetData" OldValuesParameterFormatString="{0}">
		<SelectParameters>
			<asp:Parameter Name="UsoPerRuolo" Type="Boolean" DefaultValue="True" />
			<asp:Parameter Name="UsoPerUnitaOperativa" Type="Boolean" DefaultValue="False" />
			<asp:Parameter Name="UsoPerSistemaErogante" Type="Boolean" DefaultValue="False" />
		</SelectParameters>
	</asp:ObjectDataSource>
        <asp:ObjectDataSource ID="odsSistemi" runat="server" TypeName="OrganigrammaDataSetTableAdapters.RuoliSistemiTableAdapter"
            SelectMethod="GetData" OldValuesParameterFormatString="{0}" DeleteMethod="Delete">
            <SelectParameters>
                <asp:QueryStringParameter DbType="Guid" Name="IdRuolo" QueryStringField="Id" />
                <asp:Parameter Name="Codice" Type="String" />
                <asp:Parameter Name="Descrizione" Type="String" />
                <asp:Parameter Name="CodiceAzienda" Type="String" />
                <asp:Parameter Name="Top" Type="Int32" />
                <asp:Parameter Name="Attivo" Type="Boolean" DefaultValue=""></asp:Parameter>
            </SelectParameters>
	</asp:ObjectDataSource>
        <asp:ObjectDataSource ID="odsUnitàOperative" runat="server" TypeName="OrganigrammaDataSetTableAdapters.RuoliUnitaOperativeTableAdapter"
            SelectMethod="GetData" OldValuesParameterFormatString="original_{0}"  DeleteMethod="Delete">
            <SelectParameters>
                <asp:QueryStringParameter DbType="Guid" Name="IdRuolo" QueryStringField="Id" />
                <asp:Parameter Name="Codice" Type="String" />
                <asp:Parameter Name="Descrizione" Type="String" />
                <asp:Parameter Name="CodiceAzienda" Type="String" />
                <asp:Parameter Name="Top" Type="Int32" />
                <asp:Parameter Name="Attivo" Type="Boolean" DefaultValue=""></asp:Parameter>
                <asp:Parameter Name="CodiceRegime" Type="String"></asp:Parameter>
            </SelectParameters>
	</asp:ObjectDataSource>
	</form>
</body>
</html>
