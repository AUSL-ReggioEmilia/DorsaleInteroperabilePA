<%@ Page Title="Ordini" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="RefertiRiassociazioneLista.aspx.vb"
	Inherits="DI.DataWarehouse.Admin.RefertiRiassociazioneLista" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<style type="text/css">
		.breakword
		{
			word-wrap: break-word;
			word-break: break-all;
		}
		.hiddencol
		{
			display: none;
		}
		div.legenda
		{
			display: inline-block;
			overflow: hidden;
			margin: 0px 30px 0px 10px;
		}
		div.legenda ul
		{
			margin-top: 6px;
			margin-left: 15px;
			margin-bottom: 0px;
		}
	</style>
	<script src="../Scripts/referti-lista.js" type="text/javascript"></script>
	<script type="text/javascript">

		function chkRefertiOrfani_Click() {

			var IdSACTextBox = $("#<%= IdSACTextBox.ClientID %>");
			var checked = $("#<%= chkRefertiOrfani.ClientID %>").attr('checked') == 'checked';
			IdSACTextBox.attr('disabled', checked);
			if (checked) {
				IdSACTextBox.val('');
			}
		}
	</script>
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False"></asp:Label>
	<div id="filterPanel" runat="server">
		<fieldset class="filters">
			<legend>Ricerca</legend>
			<table>
				<tr>
					<td>
						Id Referto
					</td>
					<td>
						Id Esterno Referto
					</td>
					<td>
						Id SAC
					</td>
					<td>
						&nbsp;
					</td>
					<td>
						Max Records
					</td>
				</tr>
				<tr>
					<td>
						<asp:TextBox ID="IdRefertoTextBox" runat="server" MaxLength="36" Width="210px"></asp:TextBox>
					</td>
					<td>
						<asp:TextBox ID="IdEsternoTextBox" runat="server" Width="210px" MaxLength="64"></asp:TextBox>
					</td>
					<td>
						<asp:TextBox ID="IdSACTextBox" runat="server" Width="210px" MaxLength="36" Enabled="false"></asp:TextBox>
					</td>
					<td>
						<asp:CheckBox runat="server" ID="chkRefertiOrfani" Text="Solo Referti Orfani" Checked="true" onclick="javascript:return chkRefertiOrfani_Click();" />
					</td>
					<td>
						<asp:DropDownList ID="LimitaRisDropDownList" runat="server" Width="80px">
							<asp:ListItem Selected="True">50</asp:ListItem>
							<asp:ListItem>100</asp:ListItem>
							<asp:ListItem>500</asp:ListItem>
							<asp:ListItem>1000</asp:ListItem>
						</asp:DropDownList>
					</td>
				</tr>
				<tr>
					<td>
						Azienda Erogante
					</td>
					<td>
						Sistema Erogante
					</td>
					<td>
						Data Modifica (dal / al)
					</td>
					<td>
						Data Referto
					</td>
					<td>
						&nbsp;
					</td>
				</tr>
				<tr>
					<td>
						<asp:DropDownList ID="AziendaDropDownList" runat="server" DataSourceID="AziendeObjectDataSource" DataTextField="Descrizione"
							DataValueField="Codice" Width="210px">
						</asp:DropDownList>
					</td>
					<td>
						<asp:DropDownList ID="SistemaEroganteDropDownList" runat="server" DataSourceID="odsSistemiEroganti" DataTextField="Descrizione"
							DataValueField="Codice" Width="210px">
						</asp:DropDownList>
					</td>
					<td>
						<asp:TextBox ID="DataModificaDALTextBox" runat="server" MaxLength="10" Width="95px"></asp:TextBox>
						&nbsp;<asp:TextBox ID="DataModificaALTextBox" runat="server" MaxLength="10" Width="95px"></asp:TextBox>
					</td>
					<td>
						<asp:TextBox ID="DataRefertoTextBox" runat="server" MaxLength="10" Width="95px"></asp:TextBox>
					</td>
					<td>
						<asp:Button ID="SearchButton" Text="Cerca" runat="server" CssClass="Button" CausesValidation="true" />
					</td>
				</tr>
				<tr>
					<td>
						Reparto
					</td>
					<td>
						Numero Nosologico
					</td>
					<td>
						Numero Prenotazione
					</td>
					<td>
						Numero Referto
					</td>
					<td>
					</td>
				</tr>
				<tr>
					<td>
						<asp:TextBox ID="RepartoEroganteTextBox" runat="server" Width="210px"></asp:TextBox>
					</td>
					<td>
						<asp:TextBox ID="NosologicoTextBox" runat="server" Width="210px"></asp:TextBox>
					</td>
					<td>
						<asp:TextBox ID="NumeroPrenotazioneTextBox" runat="server" Width="210px"></asp:TextBox>
					</td>
					<td>
						<asp:TextBox ID="NumeroRefertoTextBox" runat="server" Width="210px"></asp:TextBox>
					</td>
					<td>
						<asp:Button ID="ClearFiltersButton" Text="Annulla" runat="server" CssClass="Button" ValidationGroup="null" />
					</td>
				</tr>
				<tr>
					<td colspan="9">
						<div>
							<b>Compilare almeno una delle seguenti combinazioni di filtri:</b>
						</div>
					</td>
				</tr>
				<tr>
					<td colspan="9">
						<div class="legenda">
							<ul>
								<li>Id Referto</li>
								<li>Id Esterno Referto</li>
								<li>Id SAC</li>
							</ul>
						</div>
						<div class="legenda">
							<ul>
								<li>Numero Nosologico</li>
								<li>Numero Prenotazione</li>
								<li>Numero Referto</li>
							</ul>
						</div>
						<div class="legenda">
							<ul>
								<li>Azienda Erogante, Sistema Erogante, Data Modifica</li>
								<li>Azienda Erogante, Sistema Erogante, Data Referto</li>
							</ul>
						</div>
					</td>
				</tr>
			</table>
		</fieldset>
	</div>
	<div id="gridPanel">
		<asp:GridView ID="RefertiGridView" runat="server" AllowPaging="True" AllowSorting="True" CssClass="Grid" AutoGenerateColumns="False"
			DataSourceID="RefertiListaObjectDataSource" EnableModelValidation="True" PageSize="100" PagerSettings-Position="TopAndBottom">
			<HeaderStyle CssClass="GridHeader" />
			<PagerStyle CssClass="GridPager" />
			<SelectedRowStyle CssClass="GridSelected" />
			<RowStyle CssClass="GridItem" Wrap="true" />
			<AlternatingRowStyle CssClass="GridAlternatingItem" Wrap="true" />
			<Columns>
				<asp:TemplateField HeaderText="">
					<ControlStyle Width="30px" />
					<ItemStyle Width="30px" />
					<ItemTemplate>
						<asp:HyperLink ImageUrl="../Images/edititem.gif" ID="IdHyperLink" runat="server" NavigateUrl='<%# String.Format("RefertiRiassociazioneDettaglio.aspx?IdReferto={0}", Eval("Id")) %>'
							ToolTip="Riassociazione referto...">
						</asp:HyperLink>
					</ItemTemplate>
				</asp:TemplateField>
				<asp:TemplateField HeaderText="Id Referto">
					<ItemTemplate>
						<asp:HyperLink ID="IdHyperLink" runat="server" Target="_blank" NavigateUrl='<%# GetDettaglioRefertoTestataUrl(Eval("Id")) %>'
							ToolTip="Vai al dettaglio...">
							<%# Eval("Id")%>
						</asp:HyperLink>
					</ItemTemplate>
				</asp:TemplateField>
				<asp:BoundField DataField="IdEsterno" HeaderText="Id Esterno" ItemStyle-CssClass="breakword" />
				<asp:BoundField DataField="DataInserimento" HeaderText="Data Inserimento" SortExpression="DataInserimento" />
				<asp:BoundField DataField="DataModifica" HeaderText="Data Modifica" SortExpression="DataModifica" />
				<asp:BoundField DataField="AziendaErogante" HeaderText="Azienda Erogante" SortExpression="AziendaErogante" />
				<asp:BoundField DataField="SistemaErogante" HeaderText="Sistema Erogante" SortExpression="SistemaErogante" />
				<asp:BoundField DataField="RepartoErogante" HeaderText="Reparto Erogante" SortExpression="RepartoErogante" />
				<asp:BoundField DataField="DataReferto" HeaderText="Data Referto" SortExpression="DataReferto" DataFormatString="{0:d}" />
				<asp:BoundField DataField="NumeroReferto" HeaderText="Numero Referto" SortExpression="NumeroReferto" />
				<asp:BoundField DataField="NumeroNosologico" HeaderText="Numero Nosologico" SortExpression="NumeroNosologico" />
				<asp:BoundField DataField="NumeroPrenotazione" HeaderText="Numero Prenotazione" SortExpression="NumeroPrenotazione" />
				<asp:TemplateField HeaderText="Dati anagrafici SAC" SortExpression="SACCognome">
					<ItemStyle HorizontalAlign="Left" />
					<ItemTemplate>
						<%#GetHTML_Paziente(Eval("SACNome"), Eval("SACCognome"), Eval("SACComuneNascita"), Eval("SACProvinciaNascita"), Eval("SACDataNascita"), Eval("SACCodiceFiscale"), Eval("SACProvenienza"), Eval("SACIdProvenienza"))%>
					</ItemTemplate>
				</asp:TemplateField>
				<asp:TemplateField HeaderText="Dati anagrafici Referto" SortExpression="Cognome">
					<ItemStyle HorizontalAlign="Left" />
					<ItemTemplate>
						<%#GetHTML_Paziente(Eval("Nome"), Eval("Cognome"), Eval("ComuneNascita"), Eval("ProvinciaNascita"), Eval("DataNascita"), Eval("CodiceFiscale"), Eval("NomeAnagraficaCentrale"), Eval("CodiceAnagraficaCentrale"))%>
					</ItemTemplate>
				</asp:TemplateField>
			</Columns>
		</asp:GridView>
		<br />
	</div>
	<div>
		<asp:ObjectDataSource ID="AziendeObjectDataSource" runat="server" SelectMethod="GetData" TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.AziendeErogantiListaTableAdapter"
			OldValuesParameterFormatString="original_{0}" EnableCaching="False"></asp:ObjectDataSource>
		<asp:ObjectDataSource ID="RefertiListaObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
			SelectMethod="GetData" TypeName="RefertiDataSetTableAdapters.RiassociazioneRefertiListaTableAdapter" CacheKeyDependency="CKD_RiassociazioneListaTableAdapter"
			CacheDuration="120" EnableCaching="True">
			<SelectParameters>
				<asp:Parameter DbType="Guid" Name="idReferto" />
				<asp:ControlParameter ControlID="IdEsternoTextBox" Name="idEsterno" PropertyName="Text" Type="String" />
				<asp:Parameter DbType="Guid" Name="idPaziente" />
				<asp:ControlParameter ControlID="DataModificaDALTextBox" Name="dataModificaDAL" PropertyName="Text" />
				<asp:ControlParameter ControlID="DataModificaALTextBox" Name="dataModificaAL" PropertyName="Text" />
				<asp:ControlParameter ControlID="AziendaDropDownList" Name="aziendaErogante" PropertyName="SelectedValue" Type="String" />
				<asp:ControlParameter ControlID="SistemaEroganteDropDownList" Name="sistemaErogante" PropertyName="SelectedValue"
					Type="String" />
				<asp:ControlParameter ControlID="RepartoEroganteTextBox" Name="repartoErogante" PropertyName="Text" Type="String" />
				<asp:ControlParameter ControlID="DataRefertoTextBox" Name="dataReferto" PropertyName="Text" />
				<asp:ControlParameter ControlID="NumeroRefertoTextBox" Name="numeroReferto" PropertyName="Text" Type="String" />
				<asp:ControlParameter ControlID="NosologicoTextBox" Name="numeroNosologico" PropertyName="Text" Type="String" />
				<asp:ControlParameter ControlID="NumeroPrenotazioneTextBox" Name="numeroPrenotazione" PropertyName="Text" Type="String" />
				<asp:ControlParameter ControlID="chkRefertiOrfani" Name="RefertiOrfani" PropertyName="Checked" Type="Boolean" DefaultValue="" />
				<asp:ControlParameter ControlID="LimitaRisDropDownList" DefaultValue="200" Name="MaxRow" PropertyName="SelectedValue"
					Type="Int32" />
			</SelectParameters>
		</asp:ObjectDataSource>
		<asp:ObjectDataSource ID="odsSistemiEroganti" runat="server" SelectMethod="GetDataByAziendaETipo" TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.SistemiErogantiListaTableAdapter"
			EnableCaching="False" OldValuesParameterFormatString="original_{0}">
			<SelectParameters>
				<asp:Parameter Name="AziendaErogante" Type="String" />
				<asp:Parameter DefaultValue="referti" Name="Tipo" Type="String" />
			</SelectParameters>
		</asp:ObjectDataSource>
	</div>
</asp:Content>
