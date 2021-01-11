<%@ Page Title="Sistemi" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="LogOperazioni.aspx.vb"
	Inherits=".LogOperazioni" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:ScriptManager ID="scrMgr" runat="server"></asp:ScriptManager>

	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False" />

	<fieldset class="filters">
		<legend>Ricerca</legend>
		<div>
			<span>Periodo</span><br />
			<asp:DropDownList ID="ddlFiltriPeriodo" runat="server" Width="120px" >
				<asp:ListItem Text="Ultima ora" Value="1" Selected="True" />
				<asp:ListItem Text="Oggi" Value="2" />
				<asp:ListItem Text="Ultimi 7 Giorni" Value="3" />
				<asp:ListItem Text="Ultimi 30 Giorni" Value="4" />
			</asp:DropDownList>
		</div>
		<div>
			<span>Visualizzazione</span><br />
			<asp:RadioButtonList runat="server" ID="rbtVisual" >
				<asp:ListItem Text="Compatta" Value="Compatta" Selected="True" />
				<asp:ListItem Text="Dettagliata" Value="Dettagliata" />
			</asp:RadioButtonList>
		</div>
		<div>
			<span>Id Referto</span><br />
			<asp:TextBox ID="txtIdReferto" runat="server" Width="120px" MaxLength="36"></asp:TextBox>
		</div>
		
		<asp:UpdatePanel ID="upAziendeSistemi" runat="server" UpdateMode="Conditional">
			<ContentTemplate>

				<asp:ObjectDataSource ID="odsAziende" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData"
					TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.AziendeErogantiListaTableAdapter"
					EnableCaching="true" CacheDuration="120"></asp:ObjectDataSource>

				<asp:ObjectDataSource ID="odsSistemiEroganti" runat="server" SelectMethod="GetDataByAziendaETipo"
					TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.SistemiErogantiListaTableAdapter"
					EnableCaching="true" CacheDuration="120" OldValuesParameterFormatString="{0}">
					<SelectParameters>
						<asp:ControlParameter ControlID="ddlAziendaErogante" PropertyName="SelectedValue" Name="AziendaErogante" Type="String"></asp:ControlParameter>
						<asp:Parameter DefaultValue="referti" Name="Tipo" Type="String" />
					</SelectParameters>
				</asp:ObjectDataSource>

				<div>
					<span>Azienda Erogante</span><br />
					<asp:DropDownList ID="ddlAziendaErogante" runat="server" Width="120px" DataSourceID="odsAziende"
						DataTextField="Descrizione" DataValueField="Codice" AutoPostBack="true">
					</asp:DropDownList>
				</div>
				<div>
					<span>Sistema Erogante</span><br />
					<asp:DropDownList ID="ddlSistemaErogante" runat="server" Width="170px" DataSourceID="odsSistemiEroganti"
						DataTextField="Descrizione" DataValueField="Codice" >
					</asp:DropDownList>
				</div>

			</ContentTemplate>
		</asp:UpdatePanel>

		<div>
			<span>Reparto Erogante</span><br />
			<asp:TextBox ID="txtRepartoErogante" runat="server" Width="120px" MaxLength="64"></asp:TextBox>
		</div>
		<div>
			<span>Codice Reparto Richiedente</span><br />
			<asp:TextBox ID="txtRepartoRichiedente" runat="server" Width="120px" MaxLength="16"></asp:TextBox>
		</div>
		<div>
			<br />
			<asp:Button ID="SearchButton" Text="Cerca" runat="server" CssClass="Button" CausesValidation="true" />
		</div>

	</fieldset>

	
		<asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional">
			<ContentTemplate>

	<asp:GridView ID="gvLista" runat="server" DataSourceID="odsLista" AutoGenerateColumns="False" CssClass="Grid"
		Width="100%" EmptyDataText="Nessun risultato!" AllowPaging="true" PageSize="100" PagerSettings-Position="TopAndBottom">
		<Columns>
			<asp:BoundField DataField="DataInserimento" HeaderText="Data" ItemStyle-Width="70" />
			<asp:BoundField DataField="IdGuidReferto" HeaderText="Id Referto" ItemStyle-CssClass="breakword" ItemStyle-Width="130"></asp:BoundField>
			<asp:BoundField DataField="AziendaEroganteCodice" HeaderText="Azienda Erogante" ItemStyle-Width="50" />
			<asp:BoundField DataField="SistemaEroganteCodice" HeaderText="Sistema Erogante" ItemStyle-Width="50" />
			<asp:BoundField DataField="RepartoErogante" HeaderText="Reparto Erogante" ItemStyle-Width="50" />
			<asp:BoundField DataField="RepartoRichiedenteCodice" HeaderText="Reparto Richiedente" ItemStyle-Width="50"></asp:BoundField>
			<asp:BoundField DataField="Messaggio" HeaderText="Messaggio" />
			<asp:BoundField DataField="DestinazioneCopia" HeaderText="Destinazione" ItemStyle-CssClass="breakword" />
			<asp:BoundField DataField="NrTentativi" HeaderText="Tentativo Nr." ItemStyle-Width="50"></asp:BoundField>
			<asp:BoundField DataField="TempoDiCopia" HeaderText="Durata (msec)" ItemStyle-Width="50" />
			<asp:BoundField DataField="Esito" HeaderText="Esito"></asp:BoundField>
		</Columns>
		<RowStyle CssClass="GridItem" />
		<PagerStyle CssClass="GridPager" />
		<HeaderStyle CssClass="GridHeader" />
		<FooterStyle CssClass="GridFooter" />
	</asp:GridView>
			

	<asp:ObjectDataSource ID="odsLista" runat="server" SelectMethod="GetData" TypeName="CrashSystemTableAdapters.LogOperazioniTableAdapter"
		OldValuesParameterFormatString="{0}" EnableCaching="false">		
		<SelectParameters>
			<asp:Parameter Name="Top" Type="Int32" DefaultValue="1000" />
			<asp:Parameter Name="DataDal" Type="DateTime" />
			<asp:Parameter Name="DataAl" Type="DateTime"></asp:Parameter>
			<asp:ControlParameter ControlID="txtIdReferto" PropertyName="Text" DbType="Guid" DefaultValue="" Name="IdGuidReferto"></asp:ControlParameter>
			<asp:ControlParameter ControlID="ddlAziendaErogante" PropertyName="SelectedValue" Name="AziendaEroganteCodice" Type="String"></asp:ControlParameter>
			<asp:ControlParameter ControlID="ddlSistemaErogante" PropertyName="SelectedValue" Name="SistemaEroganteCodice" Type="String"></asp:ControlParameter>
			<asp:ControlParameter ControlID="txtRepartoErogante" PropertyName="Text" Name="RepartoErogante" Type="String"></asp:ControlParameter>
			<asp:ControlParameter ControlID="txtRepartoRichiedente" PropertyName="Text" Name="RepartoRichiedenteCodice" Type="String"></asp:ControlParameter>
		</SelectParameters>
	</asp:ObjectDataSource>

	</ContentTemplate>
			</asp:UpdatePanel>


</asp:Content>
