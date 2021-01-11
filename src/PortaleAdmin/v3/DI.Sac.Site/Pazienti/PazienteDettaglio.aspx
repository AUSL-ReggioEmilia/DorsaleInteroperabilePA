<%@ Page Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="PazienteDettaglio.aspx.vb"
	Inherits="DI.Sac.Admin.PazienteDettaglio" Title="Untitled Page" EnableEventValidation="false" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False"></asp:Label>
	<table id="ToolbarTable" runat="server" class="toolbar">
		<tr>
			<td>
				<asp:HyperLink ID="ModificaLink" runat="server" NavigateUrl="~/Pazienti/PazienteDettaglio.aspx?id={0}&mode=edit"><img src="../Images/edititem.gif" alt="Modifica" class="toolbar-img"/> Modifica</asp:HyperLink>
				<asp:HyperLink ID="MergeLink" runat="server" NavigateUrl="~/Pazienti/PazientiListaMerge.aspx?idPazienteFuso={0}"><img src="../Images/merge.gif" alt="Fusione" class="toolbar-img"/> Fusione</asp:HyperLink>
				<asp:HyperLink ID="MergeDettaglioLink" runat="server" NavigateUrl="~/Pazienti/PazienteDiagrammaMerge.aspx?id={0}"><img src="../Images/detailsmerge.gif" alt="Diagramma Fusione" class="toolbar-img"/> Diagramma Fusione</asp:HyperLink>
                <asp:LinkButton ID="RinotificaPazienteAttivoButton" runat="server" OnClientClick="return confirm('Si conferma la rinotifica del paziente?');"><img src="../Images/rinotificaPaz.gif" alt="Rinotifica Paziente" class="toolbar-img" />Rinotifica Paziente</asp:LinkButton>
				<asp:LinkButton ID="RinotificaFusioneButton" runat="server" OnClientClick="return confirm('Si conferma la rinotifica della fusione anagrafica?');"><img src="../Images/rinotifica.gif" alt="Rinotifica Fusione" class="toolbar-img" />Rinotifica Fusione</asp:LinkButton>
				<asp:LinkButton ID="EliminaLink" runat="server" OnClientClick="return confirm('Procedere con l\'eliminazione?');"><img src="../Images/delete.gif" alt="Elimina" class="toolbar-img"/> Elimina</asp:LinkButton>
				<asp:LinkButton ID="RipristinaLink" runat="server" OnClientClick="return confirm('Procedere con il ripristino?');"><img src="../Images/restore.gif" alt="Ripristina" class="toolbar-img"/> Ripristina</asp:LinkButton>
				<asp:HyperLink ID="VisualizzaLogLink" runat="server" NavigateUrl="~/Pazienti/PazienteLog.aspx?idPaziente={0}"><img src="../Images/log.gif" alt="Log" class="toolbar-img"/> Visualizza Log</asp:HyperLink>
				<asp:HyperLink ID="CopiaSuAppuntiLink" runat="server" Target="_blank" NavigateUrl="~/Pazienti/PazienteDettaglioRiassunto.aspx?id={0}"><img src="../Images/copy.png" alt="Copia su appunti" class="toolbar-img"/> Copia su Appunti</asp:HyperLink>
				<asp:LinkButton ID="SincronizzaLink" runat="server"><img src="../Images/refresh.png" alt="Sincronizza" class="toolbar-img"/> Sincronizza da S.R.</asp:LinkButton>
				<asp:HyperLink ID="AnonimizzazioneLink" runat="server" NavigateUrl="~/Pazienti/PazienteCreaAnonimizzazione.aspx?id={0}"><img src="../Images/CreaAnonimo.png" alt="Anonimizzazione" class="toolbar-img"/> Anonimizzazione</asp:HyperLink>
                <asp:HyperLink ID="PosizioneCollegataLink" runat="server" NavigateUrl="~/Pazienti/PazienteCreaPosCollegata.aspx?id={0}"><img src="../Images/CreaPosCollegata.png" alt="Posizione collegata" class="toolbar-img"/> Posizione collegata</asp:HyperLink>
			</td>
		</tr>
	</table>
	<br />
	<asp:FormView ID="NomePazienteFormView" runat="server" DataKeyNames="Id" DataSourceID="PazienteDettaglioObjectDataSource" 
		EnableModelValidation="True">
		<ItemTemplate>
			<span style="font-weight: bold; font-size: 14px;">
				<%# Eval("Nome") %>
				<%# Eval("Cognome") %>, nato il
				<%# Eval("DataNascita", "{0:d}") %>
				Codice Fiscale:
				<%# Eval("CodiceFiscale") %></span>
			<br />
			<span style="font-weight: bold; font-size: 14px;margin-bottom:10px;display:block;">
				<%# Eval("Provenienza") %>
				(<%# Eval("IdProvenienza") %>)</span>
		</ItemTemplate>
	</asp:FormView>
	<table cellpadding="1" cellspacing="0" border="0" style="width: 800;">
		<tr id="TabContainer" runat="server">
			<td style="height: 25px;">
				<asp:Button ID="btnActiveViewAnagrafeStati" runat="server" Text="Anagrafe/Stati"
					OnCommand="Button_Command" CommandArgument="AnagrafeStati" CommandName="ButtonAnagrafeStati"
					CssClass="ActiveView" Enabled="true" />
				<asp:Button ID="btnActiveViewResidenzaDomicilio" runat="server" Text="Residenza/Domicilio"
					OnCommand="Button_Command" CommandArgument="ResidenzaDomicilio" CommandName="ButtonResidenzaDomicilio"
					CssClass="DefaultView" Enabled="true" />
				<asp:Button ID="btnActiveViewAssistitoMedicoBase" runat="server" Text="Assistito/Medico Base"
					OnCommand="Button_Command" CommandArgument="AssistitoMedicoBase" CommandName="ButtonAssistitoMedicoBase"
					CssClass="DefaultView" Enabled="true" />
				<asp:Button ID="btnActiveViewSTP" runat="server" Text="STP" OnCommand="Button_Command"
					CommandArgument="STP" CommandName="ButtonSTP" CssClass="DefaultView" Enabled="true" />
				<asp:Button ID="btnActiveViewEsenzioni" runat="server" Text="Esenzioni" OnCommand="Button_Command"
					CommandArgument="Esenzioni" CommandName="ButtonEsenzioni" CssClass="DefaultView"
					Enabled="true" />
				<asp:Button ID="btnActiveViewConsensi" runat="server" Text="Consensi" OnCommand="Button_Command"
					CommandArgument="Consensi" CommandName="ButtonConsensi" CssClass="DefaultView"
					Enabled="true" />
				<asp:Button ID="btnActiveViewAnonimizzazioni" runat="server" Text="Anonimizzazioni"
					OnCommand="Button_Command" CommandArgument="Anonimizzazioni" CommandName="ButtonAnonimizzazioni"
					CssClass="DefaultView" Enabled="true" />
				<asp:Button ID="btnActiveViewPosizioniCollegate" runat="server" Text="Posizioni collegate"
					OnCommand="Button_Command" CommandArgument="PosizioniCollegate" CommandName="ButtonPosizioniCollegate"
					CssClass="DefaultView" Enabled="true" />
			</td>
		</tr>
		<tr id="TabSeparator" runat="server" class="TabSeparator">
			<td style="height: 3px;">
			</td>
		</tr>
		<tr>
			<asp:FormView ID="PazienteDettaglioFormView" runat="server" DataKeyNames="Id" DataSourceID="PazienteDettaglioObjectDataSource"
				EmptyDataText="Dettaglio non disponibile!" EnableModelValidation="True">
				<EditItemTemplate>
					<fieldset>
						<table cellpadding="1" cellspacing="0" border="0" style="width: 800;">
							<tr>
								<td style="height: 500px; vertical-align: top;">
									<asp:MultiView ID="PazienteDettaglioMultiView" runat="server" ActiveViewIndex="0">
										<%--Anagrafe e Stati--%>
										<asp:View ID="AnagrafeStati" runat="Server">
											<fieldset>
												<legend>Anagrafe</legend>
												<table cellpadding="5" cellspacing="1" border="0">
													<tr>
														<td>
															Cognome
														</td>
														<td>
															<asp:TextBox ID="txtCognome" runat="server" Text='<%# Bind("Cognome") %>' CssClass="Input64"
																MaxLength="64" />
														</td>
														<td>
															Nome
														</td>
														<td>
															<asp:TextBox ID="txtNome" runat="server" Text='<%# Bind("Nome") %>' CssClass="Input64"
																MaxLength="64" />
														</td>
													</tr>
													<tr>
														<td>
															Codice fiscale
														</td>
														<td>
															<asp:TextBox ID="txtCodiceFiscale" runat="server" Text='<%# Bind("CodiceFiscale") %>'
																CssClass="Input16" MaxLength="16" />
															<asp:RequiredFieldValidator ID="CodiceFiscaleRequiredFieldValidator" runat="server"
																ControlToValidate="txtCodiceFiscale" ErrorMessage='Richiesto!'></asp:RequiredFieldValidator>
														</td>
														<td>
															Sesso
														</td>
														<td>
															<asp:DropDownList ID="ddlSesso" runat="server" SelectedValue='<%# Bind("Sesso") %>'
																OnDataBinding="ddlSesso_DataBinding">
																<asp:ListItem Selected="True"></asp:ListItem>
																<asp:ListItem>M</asp:ListItem>
																<asp:ListItem>F</asp:ListItem>
															</asp:DropDownList>
														</td>
													</tr>
													<tr>
														<td>
															Data di nascita
														</td>
														<td>
															<asp:TextBox ID="txtDataNascita" runat="server" Text='<%# Bind("DataNascita", "{0:d}") %>'
																CssClass="InputDate" MaxLength="10" />
															<asp:CompareValidator ID="cvalDataNascita" runat="server" ControlToValidate="txtDataNascita"
																ErrorMessage='<img src="../Images/icon_small_caution.gif" alt="Valore non valido!" />'
																Operator="DataTypeCheck" Type="Date"></asp:CompareValidator>
														</td>
														<td>
															Data decesso
														</td>
														<td>
															<asp:TextBox ID="txtDataDecesso" runat="server" Text='<%# GetDataDecesso(Eval("CodiceTerminazione"), Eval("DataTerminazioneAss")) %>'
																CssClass="InputDate" MaxLength="10" Enabled="False" />
															<%-- <asp:CompareValidator ID="cvalDataDecesso" runat="server" ControlToValidate="txtDataDecesso"
                                                                ErrorMessage='<img src="../Images/icon_small_caution.gif" alt="Valore non valido!" />'
                                                                Operator="DataTypeCheck" Type="Date"></asp:CompareValidator> --%>
														</td>
													</tr>
													<tr>
														<td style="vertical-align: top;">
															Comune di nascita
														</td>
														<td>
															<progel:CustomDropDownList ID="pddlComuneNascita" runat="server" ServicePath="~/WebServices/Istat.asmx"
																ParentCategory="Province" ParentServiceMethod="GetProvinceIstat" ParentPromptText="- seleziona la provincia -"
																ParentLoadingText="caricamento province..." ParentBindValue='<%# Eval("ProvinciaNascitaCodice") %>'
																ChildCategory="Comuni" ChildServiceMethod="GetComuniIstat" ChildPromptText="- seleziona il comune -"
																ChildLoadingText="caricamento comuni..." ChildBindValue='<%# Bind("ComuneNascitaCodice") %>' />
														</td>
														<td style="vertical-align: top;">
															Nazionalità
														</td>
														<td style="vertical-align: top;">
															<asp:DropDownList ID="ddlNazionalita" runat="server" DataSourceID="ComboNazioniObjectDataSource"
																DataTextField="Nome" DataValueField="Codice" SelectedValue='<%# Bind("NazionalitaCodice") %>'>
															</asp:DropDownList>
														</td>
													</tr>
												</table>
											</fieldset>
											<br />
											<fieldset>
												<legend>Stati</legend>
												<table cellpadding="5" cellspacing="1" border="0">
													<tr>
														<td style="vertical-align: top;">
															Dati Anamnestici
														</td>
														<td colspan="3">
															<asp:TextBox ID="txtDatiAnamnestici" runat="server" Text='<%# Bind("DatiAnamnestici") %>'
																CssClass="Input128" TextMode="MultiLine" Rows="5" />
														</td>
													</tr>
													<tr>
														<td>
															Mantenimento Pediatra
														</td>
														<td>
															<asp:CheckBox ID="chkMantenimentoPediatra" runat="server" Checked='<%# Bind("MantenimentoPediatra") %>' />
														</td>
														<td>
															Capo famiglia
														</td>
														<td>
															<asp:CheckBox ID="chkCapoFamiglia" runat="server" Checked='<%# Bind("CapoFamiglia") %>' />
														</td>
													</tr>
													<tr>
														<td>
															Indigenza
														</td>
														<td>
															<asp:CheckBox ID="chkIndigenza" runat="server" Checked='<%# Bind("Indigenza") %>' />
														</td>
														<td>
														</td>
														<td>
														</td>
													</tr>
												</table>
											</fieldset>
										</asp:View>
										<%--Residenza, Domicilio e Recapiti--%>
										<asp:View ID="ResidenzaDomicilio" runat="Server">
											<fieldset>
												<legend>Residenza</legend>
												<table cellpadding="5" cellspacing="1" border="0">
													<tr>
														<td style="vertical-align: top;">
															Comune
														</td>
														<td>
															<progel:CustomDropDownList ID="pddlComuneRes" runat="server" ServicePath="~/WebServices/Istat.asmx"
																ParentCategory="Province" ParentServiceMethod="GetProvinceIstat" ParentPromptText="- seleziona la provincia -"
																ParentLoadingText="caricamento province..." ParentBindValue='<%# Eval("ProvinciaResCodice") %>'
																ChildCategory="Comuni" ChildServiceMethod="GetComuniIstat" ChildPromptText="- seleziona il comune -"
																ChildLoadingText="caricamento comuni..." ChildBindValue='<%# Bind("ComuneResCodice") %>' />
														</td>
														<td style="vertical-align: top;">
															Sub Comune
														</td>
														<td style="vertical-align: top;">
															<asp:TextBox ID="txtSubComuneRes" runat="server" Text='<%# Bind("SubComuneRes") %>'
																CssClass="Input64" MaxLength="64" />
														</td>
													</tr>
													<tr>
														<td style="vertical-align: top;">
															Indirizzo
														</td>
														<td>
															<asp:TextBox ID="txtIndirizzoRes" runat="server" Text='<%# Bind("IndirizzoRes") %>'
																CssClass="Input64" MaxLength="256" TextMode="MultiLine" Rows="2" />
														</td>
														<td style="vertical-align: top;">
															Località
														</td>
														<td style="vertical-align: top;">
															<asp:TextBox ID="txtLocalitaRes" runat="server" Text='<%# Bind("LocalitaRes") %>'
																CssClass="Input64" MaxLength="128" />
														</td>
													</tr>
													<tr>
														<td>
															Cap
														</td>
														<td>
															<asp:TextBox ID="txtCapRes" runat="server" Text='<%# Bind("CapRes") %>' CssClass="InputDate"
																MaxLength="8" />
														</td>
														<td>
															Data decorrenza
														</td>
														<td>
															<asp:TextBox ID="txtDataDecorrenzaRes" runat="server" Text='<%# Bind("DataDecorrenzaRes", "{0:d}") %>'
																CssClass="InputDate" MaxLength="10" />
															<asp:CompareValidator ID="cvalDataDecorrenzaRes" runat="server" ControlToValidate="txtDataDecorrenzaRes"
																ErrorMessage='<img src="../Images/icon_small_caution.gif" alt="Valore non valido!" />'
																Operator="DataTypeCheck" Type="Date"></asp:CompareValidator>
														</td>
													</tr>
													<tr>
														<td style="vertical-align: top;">
															Asl
														</td>
														<td>
															<progel:CascadingDropDownList ID="pddlComuneAslRes" runat="server" ServicePath="~/WebServices/Istat.asmx"
																ParentCategory="Province" ParentServiceMethod="GetProvinceIstat" ParentPromptText="- seleziona la provincia -"
																ParentLoadingText="caricamento province..." ParentBindValue='<%# Eval("ProvinciaAslResCodice") %>'
																ChildTopCategory="Comuni" ChildTopServiceMethod="GetComuniIstat" ChildTopPromptText="- seleziona il comune -"
																ChildTopLoadingText="caricamento comuni..." ChildTopBindValue='<%# Bind("ComuneAslResCodice") %>'
																ChildDownCategory="AslComuni" ChildDownServiceMethod="GetAslIstat" ChildDownBindValue='<%# Bind("CodiceAslRes") %>' />
														</td>
														<td style="vertical-align: top;">
														</td>
														<td style="vertical-align: top;">
														</td>
													</tr>
												</table>
											</fieldset>
											<br />
											<fieldset>
												<legend>Domicilio</legend>
												<table cellpadding="5" cellspacing="1" border="0">
													<tr>
														<td style="vertical-align: top;">
															Comune
														</td>
														<td>
															<progel:CustomDropDownList ID="pddlComuneDom" runat="server" ServicePath="~/WebServices/Istat.asmx"
																ParentCategory="Province" ParentServiceMethod="GetProvinceIstat" ParentPromptText="- seleziona la provincia -"
																ParentLoadingText="caricamento province..." ParentBindValue='<%# Eval("ProvinciaDomCodice") %>'
																ChildCategory="Comuni" ChildServiceMethod="GetComuniIstat" ChildPromptText="- seleziona il comune -"
																ChildLoadingText="caricamento comuni..." ChildBindValue='<%# Bind("ComuneDomCodice") %>' />
														</td>
														<td style="vertical-align: top;">
															Sub Comune
														</td>
														<td style="vertical-align: top;">
															<asp:TextBox ID="txtSubComuneDom" runat="server" Text='<%# Bind("SubComuneDom") %>'
																CssClass="Input64" MaxLength="64" />
														</td>
													</tr>
													<tr>
														<td style="vertical-align: top;">
															Indirizzo
														</td>
														<td>
															<asp:TextBox ID="txtIndirizzoDom" runat="server" Text='<%# Bind("IndirizzoDom") %>'
																CssClass="Input64" MaxLength="256" TextMode="MultiLine" Rows="2" />
														</td>
														<td style="vertical-align: top;">
															Località
														</td>
														<td style="vertical-align: top;">
															<asp:TextBox ID="txtLocalitaDom" runat="server" Text='<%# Bind("LocalitaDom") %>'
																CssClass="Input64" MaxLength="128" />
														</td>
													</tr>
													<tr>
														<td>
															Cap
														</td>
														<td>
															<asp:TextBox ID="txtCapDom" runat="server" Text='<%# Bind("CapDom") %>' CssClass="InputDate"
																MaxLength="8" />
														</td>
														<td>
														</td>
														<td>
														</td>
													</tr>
												</table>
											</fieldset>
											<br />
											<fieldset>
												<legend>Recapiti</legend>
												<table cellpadding="5" cellspacing="1" border="0">
													<tr>
														<td style="vertical-align: top;">
															Comune
														</td>
														<td>
															<progel:CustomDropDownList ID="pddlComuneRecapito" runat="server" ServicePath="~/WebServices/Istat.asmx"
																ParentCategory="Province" ParentServiceMethod="GetProvinceIstat" ParentPromptText="- seleziona la provincia -"
																ParentLoadingText="caricamento province..." ParentBindValue='<%# Eval("ProvinciaRecapitoCodice") %>'
																ChildCategory="Comuni" ChildServiceMethod="GetComuniIstat" ChildPromptText="- seleziona il comune -"
																ChildLoadingText="caricamento comuni..." ChildBindValue='<%# Bind("ComuneRecapitoCodice") %>' />
														</td>
														<td style="vertical-align: top;">
															Indirizzo
														</td>
														<td style="vertical-align: top;">
															<asp:TextBox ID="txtIndirizzoRecapito" runat="server" Text='<%# Bind("IndirizzoRecapito") %>'
																CssClass="Input64" MaxLength="256" TextMode="MultiLine" Rows="2" />
														</td>
													</tr>
													<tr>
														<td>
															Località
														</td>
														<td>
															<asp:TextBox ID="txtLocalitaRecapito" runat="server" Text='<%# Bind("LocalitaRecapito") %>'
																CssClass="Input64" MaxLength="128" />
														</td>
														<td>
															Telefono 1
														</td>
														<td>
															<asp:TextBox ID="txtTelefono1" runat="server" Text='<%# Bind("Telefono1") %>' CssClass="Input16"
																MaxLength="20" />
														</td>
													</tr>
													<tr>
														<td>
															Telefono 2
														</td>
														<td>
															<asp:TextBox ID="txtTelefono2" runat="server" Text='<%# Bind("Telefono2") %>' CssClass="Input16"
																MaxLength="20" />
														</td>
														<td>
															Telefono 3
														</td>
														<td>
															<asp:TextBox ID="txtTelefono3" runat="server" Text='<%# Bind("Telefono3") %>' CssClass="Input16"
																MaxLength="20" />
														</td>
													</tr>
												</table>
											</fieldset>
										</asp:View>
										<%--Assistito e Medico di base--%>
										<asp:View ID="AssistitoMedicoBase" runat="Server">
											<fieldset>
												<legend>Assistito</legend>
												<table cellpadding="5" cellspacing="1" border="0">
													<tr>
														<td>
															Posizione
														</td>
														<td>
															<asp:DropDownList ID="ddlPosizioneAss" runat="server" Enabled="false" DataSourceID="ComboPosizioniAssObjectDataSource"
																DataTextField="Descrizione" DataValueField="Codice" SelectedValue='<%# Bind("PosizioneAss") %>'>
															</asp:DropDownList>
														</td>
														<td>
															Ambito
														</td>
														<td>
															<asp:TextBox ID="txtAmbito" runat="server" Text='<%# Bind("Ambito") %>' CssClass="Input16"
																MaxLength="16" />
														</td>
													</tr>
													<tr>
														<td>
															Data inizio
														</td>
														<td>
															<asp:TextBox ID="txtDataInizioAss" runat="server" Text='<%# Bind("DataInizioAss", "{0:d}") %>'
																CssClass="InputDate" MaxLength="10" />
															<asp:CompareValidator ID="cvalDataInizioAss" runat="server" ControlToValidate="txtDataInizioAss"
																ErrorMessage='<img src="../Images/icon_small_caution.gif" alt="Valore non valido!" />'
																Operator="DataTypeCheck" Type="Date"></asp:CompareValidator>
														</td>
														<td>
															Data scadenza
														</td>
														<td>
															<asp:TextBox ID="txtDataScadenzaAss" runat="server" Text='<%# Bind("DataScadenzaAss", "{0:d}") %>'
																CssClass="InputDate" MaxLength="10" />
															<asp:CompareValidator ID="cvalDataScadenzaAss" runat="server" ControlToValidate="txtDataScadenzaAss"
																ErrorMessage='<img src="../Images/icon_small_caution.gif" alt="Valore non valido!" />'
																Operator="DataTypeCheck" Type="Date"></asp:CompareValidator>
														</td>
													</tr>
													<tr>
														<td>
															Descrizione terminazione
														</td>
														<td>
															<asp:DropDownList ID="ddlTerminazioni" runat="server" DataTextField="Descrizione"
																DataValueField="Codice">
															</asp:DropDownList>
														</td>
														<td>
															Data terminazione
														</td>
														<td>
															<asp:TextBox ID="txtDataTerminazioneAss" runat="server" Text='<%# Bind("DataTerminazioneAss", "{0:d}") %>'
																CssClass="InputDate" MaxLength="10" />
															<asp:CompareValidator ID="cvalDataTerminazioneAss" runat="server" ControlToValidate="txtDataTerminazioneAss"
																ErrorMessage='<img src="../Images/icon_small_caution.gif" alt="Valore non valido!" />'
																Operator="DataTypeCheck" Type="Date"></asp:CompareValidator>
														</td>
													</tr>
													<tr>
														<td>
															Distretto amm.
														</td>
														<td>
															<asp:TextBox ID="txtDistrettoAmm" runat="server" Text='<%# Bind("DistrettoAmm") %>'
																CssClass="InputDate" MaxLength="8" />
														</td>
														<td>
															Distretto ter.
														</td>
														<td>
															<asp:TextBox ID="txtDistrettoTer" runat="server" Text='<%# Bind("DistrettoTer") %>'
																CssClass="Input16" MaxLength="16" />
														</td>
													</tr>
													<tr>
														<td style="vertical-align: top;">
															Asl
														</td>
														<td>
															<progel:CascadingDropDownList ID="pddlComuneAslAss" runat="server" ServicePath="~/WebServices/Istat.asmx"
																ParentCategory="Province" ParentServiceMethod="GetProvinceIstat" ParentPromptText="- seleziona la provincia -"
																ParentLoadingText="caricamento province..." ParentBindValue='<%# Eval("ProvinciaAslAssCodice") %>'
																ChildTopCategory="Comuni" ChildTopServiceMethod="GetComuniIstat" ChildTopPromptText="- seleziona il comune -"
																ChildTopLoadingText="caricamento comuni..." ChildTopBindValue='<%# Bind("ComuneAslAssCodice") %>'
																ChildDownCategory="AslComuni" ChildDownServiceMethod="GetAslIstat" ChildDownBindValue='<%# Bind("CodiceAslAss") %>' />
														</td>
														<td style="vertical-align: top;">
														</td>
														<td style="vertical-align: top;">
														</td>
													</tr>
												</table>
											</fieldset>
											<br />
											<fieldset>
												<legend>Medico di base</legend>
												<table cellpadding="5" cellspacing="1" border="0">
													<tr>
														<td>
															Codice
														</td>
														<td>
															<asp:TextBox ID="txtCodiceMedicoDiBase" runat="server" Text='<%# Bind("CodiceMedicoDiBase") %>'
																CssClass="InputDate" />
															<asp:CompareValidator ID="cvalCodiceMedicoDiBase" runat="server" ControlToValidate="txtCodiceMedicoDiBase"
																ErrorMessage='<img src="../Images/icon_small_caution.gif" alt="Valore non valido!" />'
																Operator="DataTypeCheck" Type="Integer"></asp:CompareValidator>
														</td>
														<td>
															Codice Fiscale
														</td>
														<td>
															<asp:TextBox ID="txtCodiceFiscaleMedicoDiBase" runat="server" Text='<%# Bind("CodiceFiscaleMedicoDiBase") %>'
																CssClass="Input16" MaxLength="16" />
														</td>
													</tr>
													<tr>
														<td>
															Nome e Cognome
														</td>
														<td colspan="3">
															<asp:TextBox ID="txtCognomeNomeMedicoDiBase" runat="server" Text='<%# Bind("CognomeNomeMedicoDiBase") %>'
																CssClass="Input128" MaxLength="128" />
														</td>
													</tr>
													<tr>
														<td>
															Distretto
														</td>
														<td>
															<asp:TextBox ID="txtDistrettoMedicoDiBase" runat="server" Text='<%# Bind("DistrettoMedicoDiBase") %>'
																CssClass="InputDate" MaxLength="8" />
														</td>
														<td>
															Data scelta
														</td>
														<td>
															<asp:TextBox ID="txtDataSceltaMedicoDiBase" runat="server" Text='<%# Bind("DataSceltaMedicoDiBase", "{0:d}") %>'
																CssClass="InputDate" MaxLength="10" />
															<asp:CompareValidator ID="cvalDataSceltaMedicoDiBase" runat="server" ControlToValidate="txtDataSceltaMedicoDiBase"
																ErrorMessage='<img src="../Images/icon_small_caution.gif" alt="Valore non valido!" />'
																Operator="DataTypeCheck" Type="Date"></asp:CompareValidator>
														</td>
													</tr>
												</table>
											</fieldset>
										</asp:View>
										<%--STP--%>
										<asp:View ID="STP" runat="Server">
											<fieldset>
												<legend>Straniero Temporaneamente Presente</legend>
												<table cellpadding="5" cellspacing="1" border="0">
													<tr>
														<td>
															Codice
														</td>
														<td>
															<asp:TextBox ID="txtCodiceSTP" runat="server" Text='<%# Bind("CodiceSTP") %>' CssClass="Input16"
																MaxLength="32" />
														</td>
														<td>
															Motivo annullo
														</td>
														<td>
															<asp:TextBox ID="txtMotivoAnnulloSTP" runat="server" Text='<%# Bind("MotivoAnnulloSTP") %>'
																CssClass="InputDate" MaxLength="8" />
														</td>
													</tr>
													<tr>
														<td>
															Data inizio
														</td>
														<td>
															<asp:TextBox ID="txtDataInizioSTP" runat="server" Text='<%# Bind("DataInizioSTP", "{0:d}") %>'
																CssClass="InputDate" MaxLength="10" />
															<asp:CompareValidator ID="cvalDataInizioSTP" runat="server" ControlToValidate="txtDataInizioSTP"
																ErrorMessage='<img src="../Images/icon_small_caution.gif" alt="Valore non valido!" />'
																Operator="DataTypeCheck" Type="Date"></asp:CompareValidator>
														</td>
														<td>
															Data fine
														</td>
														<td>
															<asp:TextBox ID="txtDataFineSTP" runat="server" Text='<%# Bind("DataFineSTP", "{0:d}") %>'
																CssClass="InputDate" MaxLength="10" />
															<asp:CompareValidator ID="cvalDataFineSTP" runat="server" ControlToValidate="txtDataFineSTP"
																ErrorMessage='<img src="../Images/icon_small_caution.gif" alt="Valore non valido!" />'
																Operator="DataTypeCheck" Type="Date"></asp:CompareValidator>
														</td>
													</tr>
												</table>
											</fieldset>
										</asp:View>
									</asp:MultiView>
								</td>
							</tr>
							<tr>
								<td style="text-align: right">
									<asp:Button ID="UpdateButton" runat="server" CssClass="TabButton" CausesValidation="True"
										CommandName="Update" Text="Conferma" />
									<asp:Button ID="UpdateCancelButton" runat="server" CssClass="TabButton" CausesValidation="False"
										CommandName="Cancel" Text="Annulla" />
								</td>
							</tr>
						</table>
					</fieldset>
				</EditItemTemplate>
				<InsertItemTemplate>
					<fieldset>
						<table cellpadding="1" cellspacing="0" border="0" style="width: 800;">
							<tr>
								<td style="height: 500px; vertical-align: top;">
									<asp:MultiView ID="PazienteDettaglioMultiView" runat="server" ActiveViewIndex="0">
										<%--Anagrafe e Stati--%>
										<asp:View ID="AnagrafeStati" runat="Server">
											<fieldset>
												<legend>Anagrafe</legend>
												<table cellpadding="5" cellspacing="1" border="0">
													<tr>
														<td>
															Cognome
														</td>
														<td>
															<asp:TextBox ID="txtCognome" runat="server" Text='<%# Bind("Cognome") %>' CssClass="Input64"
																MaxLength="64" />
														</td>
														<td>
															Nome
														</td>
														<td>
															<asp:TextBox ID="txtNome" runat="server" Text='<%# Bind("Nome") %>' CssClass="Input64"
																MaxLength="64" />
														</td>
													</tr>
													<tr>
														<td>
															Codice fiscale
														</td>
														<td>
															<asp:TextBox ID="txtCodiceFiscale" runat="server" Text='<%# Bind("CodiceFiscale") %>'
																CssClass="Input16" MaxLength="16" />
															<asp:RequiredFieldValidator ID="CodiceFiscaleRequiredFieldValidator" runat="server"
																ControlToValidate="txtCodiceFiscale" ErrorMessage='Richiesto!'></asp:RequiredFieldValidator>
														</td>
														<td>
															Sesso
														</td>
														<td>
															<asp:DropDownList ID="ddlSesso" runat="server" SelectedValue='<%# Bind("Sesso") %>'>
																<asp:ListItem Selected="True"></asp:ListItem>
																<asp:ListItem>M</asp:ListItem>
																<asp:ListItem>F</asp:ListItem>
															</asp:DropDownList>
														</td>
													</tr>
													<tr>
														<td>
															Data nascita
														</td>
														<td>
															<asp:TextBox ID="txtDataNascita" runat="server" Text='<%# Bind("DataNascita", "{0:d}") %>'
																CssClass="InputDate" MaxLength="10" />
															<asp:CompareValidator ID="cvalDataNascita" runat="server" ControlToValidate="txtDataNascita"
																ErrorMessage='<img src="../Images/icon_small_caution.gif" alt="Valore non valido!" />'
																Operator="DataTypeCheck" Type="Date"></asp:CompareValidator>
														</td>
														<td>
															Data decesso
														</td>
														<td>
															<asp:TextBox ID="txtDataDecesso" runat="server" Text='<%# GetDataDecesso(Eval("CodiceTerminazione"), Eval("DataTerminazioneAss")) %>'
																CssClass="InputDate" MaxLength="10" Enabled="false" />
															<%-- <asp:CompareValidator ID="cvalDataDecesso" runat="server" ControlToValidate="txtDataDecesso" 
                                                                ErrorMessage='<img src="../Images/icon_small_caution.gif" alt="Valore non valido!" />'
                                                                Operator="DataTypeCheck" Type="Date"></asp:CompareValidator> --%>
														</td>
													</tr>
													<tr>
														<td style="vertical-align: top;">
															Comune nascita
														</td>
														<td>
															<progel:CustomDropDownList ID="pddlComuneNascita" runat="server" ServicePath="~/WebServices/Istat.asmx"
																ParentCategory="Province" ParentServiceMethod="GetProvinceIstat" ParentPromptText="- seleziona la provincia -"
																ParentLoadingText="caricamento province..." ParentBindValue='<%# Eval("ProvinciaNascitaCodice") %>'
																ChildCategory="Comuni" ChildServiceMethod="GetComuniIstat" ChildPromptText="- seleziona il comune -"
																ChildLoadingText="caricamento comuni..." ChildBindValue='<%# Bind("ComuneNascitaCodice") %>' />
														</td>
														<td style="vertical-align: top;">
															Nazionalità
														</td>
														<td style="vertical-align: top;">
															<asp:DropDownList ID="ddlNazionalita" runat="server" DataSourceID="ComboNazioniObjectDataSource"
																DataTextField="Nome" DataValueField="Codice" SelectedValue='<%# Bind("NazionalitaCodice") %>'>
															</asp:DropDownList>
														</td>
													</tr>
												</table>
											</fieldset>
											<br />
											<fieldset>
												<legend>Stati</legend>
												<table cellpadding="5" cellspacing="1" border="0">
													<tr>
														<td style="vertical-align: top;">
															Dati Anamnestici
														</td>
														<td colspan="3">
															<asp:TextBox ID="txtDatiAnamnestici" runat="server" Text='<%# Bind("DatiAnamnestici") %>'
																CssClass="Input128" TextMode="MultiLine" Rows="5" />
														</td>
													</tr>
													<tr>
														<td>
															Mantenimento Pediatra
														</td>
														<td>
															<asp:CheckBox ID="chkMantenimentoPediatra" runat="server" Checked='<%# Bind("MantenimentoPediatra") %>' />
														</td>
														<td>
															Capo famiglia
														</td>
														<td>
															<asp:CheckBox ID="chkCapoFamiglia" runat="server" Checked='<%# Bind("CapoFamiglia") %>' />
														</td>
													</tr>
													<tr>
														<td>
															Indigenza
														</td>
														<td>
															<asp:CheckBox ID="chkIndigenza" runat="server" Checked='<%# Bind("Indigenza") %>' />
														</td>
														<td>
														</td>
														<td>
														</td>
													</tr>
												</table>
											</fieldset>
										</asp:View>
										<%--Residenza, Domicilio e Recapiti--%>
										<asp:View ID="ResidenzaDomicilio" runat="Server">
											<fieldset>
												<legend>Residenza</legend>
												<table cellpadding="5" cellspacing="1" border="0">
													<tr>
														<td style="vertical-align: top;">
															Comune
														</td>
														<td>
															<progel:CustomDropDownList ID="pddlComuneRes" runat="server" ServicePath="~/WebServices/Istat.asmx"
																ParentCategory="Province" ParentServiceMethod="GetProvinceIstat" ParentPromptText="- seleziona la provincia -"
																ParentLoadingText="caricamento province..." ParentBindValue='<%# Eval("ProvinciaResCodice") %>'
																ChildCategory="Comuni" ChildServiceMethod="GetComuniIstat" ChildPromptText="- seleziona il comune -"
																ChildLoadingText="caricamento comuni..." ChildBindValue='<%# Bind("ComuneResCodice") %>' />
														</td>
														<td style="vertical-align: top;">
															Sub Comune
														</td>
														<td style="vertical-align: top;">
															<asp:TextBox ID="txtSubComuneRes" runat="server" Text='<%# Bind("SubComuneRes") %>'
																CssClass="Input64" MaxLength="64" />
														</td>
													</tr>
													<tr>
														<td style="vertical-align: top;">
															Indirizzo
														</td>
														<td>
															<asp:TextBox ID="txtIndirizzoRes" runat="server" Text='<%# Bind("IndirizzoRes") %>'
																CssClass="Input64" MaxLength="256" TextMode="MultiLine" Rows="2" />
														</td>
														<td style="vertical-align: top;">
															Località
														</td>
														<td style="vertical-align: top;">
															<asp:TextBox ID="txtLocalitaRes" runat="server" Text='<%# Bind("LocalitaRes") %>'
																CssClass="Input64" MaxLength="128" />
														</td>
													</tr>
													<tr>
														<td>
															Cap
														</td>
														<td>
															<asp:TextBox ID="txtCapRes" runat="server" Text='<%# Bind("CapRes") %>' CssClass="InputDate"
																MaxLength="8" />
														</td>
														<td>
															Data decorrenza
														</td>
														<td>
															<asp:TextBox ID="txtDataDecorrenzaRes" runat="server" Text='<%# Bind("DataDecorrenzaRes", "{0:d}") %>'
																CssClass="InputDate" MaxLength="10" />
															<asp:CompareValidator ID="cvalDataDecorrenzaRes" runat="server" ControlToValidate="txtDataDecorrenzaRes"
																ErrorMessage='<img src="../Images/icon_small_caution.gif" alt="Valore non valido!" />'
																Operator="DataTypeCheck" Type="Date"></asp:CompareValidator>
														</td>
													</tr>
													<tr>
														<td style="vertical-align: top;">
															Asl
														</td>
														<td>
															<progel:CascadingDropDownList ID="pddlComuneAslRes" runat="server" ServicePath="~/WebServices/Istat.asmx"
																ParentCategory="Province" ParentServiceMethod="GetProvinceIstat" ParentPromptText="- seleziona la provincia -"
																ParentLoadingText="caricamento province..." ParentBindValue='<%# Eval("ProvinciaAslResCodice") %>'
																ChildTopCategory="Comuni" ChildTopServiceMethod="GetComuniIstat" ChildTopPromptText="- seleziona il comune -"
																ChildTopLoadingText="caricamento comuni..." ChildTopBindValue='<%# Bind("ComuneAslResCodice") %>'
																ChildDownCategory="AslComuni" ChildDownServiceMethod="GetAslIstat" ChildDownBindValue='<%# Bind("CodiceAslRes") %>' />
														</td>
														<td style="vertical-align: top;">
															Regione
														</td>
														<td style="vertical-align: top;">
															<asp:DropDownList ID="ddlRegioneRes" runat="server" DataSourceID="ComboRegioniObjectDataSource"
																DataTextField="Nome" DataValueField="Codice" SelectedValue='<%# Bind("RegioneResCodice") %>'>
															</asp:DropDownList>
														</td>
													</tr>
												</table>
											</fieldset>
											<br />
											<fieldset>
												<legend>Domicilio</legend>
												<table cellpadding="5" cellspacing="1" border="0">
													<tr>
														<td style="vertical-align: top;">
															Comune
														</td>
														<td>
															<progel:CustomDropDownList ID="pddlComuneDom" runat="server" ServicePath="~/WebServices/Istat.asmx"
																ParentCategory="Province" ParentServiceMethod="GetProvinceIstat" ParentPromptText="- seleziona la provincia -"
																ParentLoadingText="caricamento province..." ParentBindValue='<%# Eval("ProvinciaDomCodice") %>'
																ChildCategory="Comuni" ChildServiceMethod="GetComuniIstat" ChildPromptText="- seleziona il comune -"
																ChildLoadingText="caricamento comuni..." ChildBindValue='<%# Bind("ComuneDomCodice") %>' />
														</td>
														<td style="vertical-align: top;">
															Sub Comune
														</td>
														<td style="vertical-align: top;">
															<asp:TextBox ID="txtSubComuneDom" runat="server" Text='<%# Bind("SubComuneDom") %>'
																CssClass="Input64" MaxLength="64" />
														</td>
													</tr>
													<tr>
														<td style="vertical-align: top;">
															Indirizzo
														</td>
														<td>
															<asp:TextBox ID="txtIndirizzoDom" runat="server" Text='<%# Bind("IndirizzoDom") %>'
																CssClass="Input64" MaxLength="256" TextMode="MultiLine" Rows="2" />
														</td>
														<td style="vertical-align: top;">
															Località
														</td>
														<td style="vertical-align: top;">
															<asp:TextBox ID="txtLocalitaDom" runat="server" Text='<%# Bind("LocalitaDom") %>'
																CssClass="Input64" MaxLength="128" />
														</td>
													</tr>
													<tr>
														<td>
															Cap
														</td>
														<td>
															<asp:TextBox ID="txtCapDom" runat="server" Text='<%# Bind("CapDom") %>' CssClass="InputDate"
																MaxLength="8" />
														</td>
														<td>
														</td>
														<td>
														</td>
													</tr>
												</table>
											</fieldset>
											<br />
											<fieldset>
												<legend>Recapiti</legend>
												<table cellpadding="5" cellspacing="1" border="0">
													<tr>
														<td style="vertical-align: top;">
															Comune
														</td>
														<td>
															<progel:CustomDropDownList ID="pddlComuneRecapito" runat="server" ServicePath="~/WebServices/Istat.asmx"
																ParentCategory="Province" ParentServiceMethod="GetProvinceIstat" ParentPromptText="- seleziona la provincia -"
																ParentLoadingText="caricamento province..." ParentBindValue='<%# Eval("ProvinciaRecapitoCodice") %>'
																ChildCategory="Comuni" ChildServiceMethod="GetComuniIstat" ChildPromptText="- seleziona il comune -"
																ChildLoadingText="caricamento comuni..." ChildBindValue='<%# Bind("ComuneRecapitoCodice") %>' />
														</td>
														<td style="vertical-align: top;">
															Indirizzo
														</td>
														<td style="vertical-align: top;">
															<asp:TextBox ID="txtIndirizzoRecapito" runat="server" Text='<%# Bind("IndirizzoRecapito") %>'
																CssClass="Input64" MaxLength="256" TextMode="MultiLine" Rows="2" />
														</td>
													</tr>
													<tr>
														<td>
															Località
														</td>
														<td>
															<asp:TextBox ID="txtLocalitaRecapito" runat="server" Text='<%# Bind("LocalitaRecapito") %>'
																CssClass="Input64" MaxLength="128" />
														</td>
														<td>
															Telefono 1
														</td>
														<td>
															<asp:TextBox ID="txtTelefono1" runat="server" Text='<%# Bind("Telefono1") %>' CssClass="Input16"
																MaxLength="20" />
														</td>
													</tr>
													<tr>
														<td>
															Telefono 2
														</td>
														<td>
															<asp:TextBox ID="txtTelefono2" runat="server" Text='<%# Bind("Telefono2") %>' CssClass="Input16"
																MaxLength="20" />
														</td>
														<td>
															Telefono 3
														</td>
														<td>
															<asp:TextBox ID="txtTelefono3" runat="server" Text='<%# Bind("Telefono3") %>' CssClass="Input16"
																MaxLength="20" />
														</td>
													</tr>
												</table>
											</fieldset>
										</asp:View>
										<%--Assistito e Medico di base--%>
										<asp:View ID="AssistitoMedicoBase" runat="Server">
											<fieldset>
												<legend>Assistito</legend>
												<table cellpadding="5" cellspacing="1" border="0">
													<tr>
														<td style="vertical-align: top;">
															Regione
														</td>
														<td style="vertical-align: top;">
															<asp:DropDownList ID="ddlRegioneAss" runat="server" DataSourceID="ComboRegioniObjectDataSource"
																DataTextField="Nome" DataValueField="Codice" SelectedValue='<%# Bind("RegioneAssCodice") %>'>
															</asp:DropDownList>
														</td>
														<td style="vertical-align: top;">
															Asl
														</td>
														<td>
															<progel:CascadingDropDownList ID="pddlComuneAslAss" runat="server" ServicePath="~/WebServices/Istat.asmx"
																ParentCategory="Province" ParentServiceMethod="GetProvinceIstat" ParentPromptText="- seleziona la provincia -"
																ParentLoadingText="caricamento province..." ParentBindValue='<%# Eval("ProvinciaAslAssCodice") %>'
																ChildTopCategory="Comuni" ChildTopServiceMethod="GetComuniIstat" ChildTopPromptText="- seleziona il comune -"
																ChildTopLoadingText="caricamento comuni..." ChildTopBindValue='<%# Bind("ComuneAslAssCodice") %>'
																ChildDownCategory="AslComuni" ChildDownServiceMethod="GetAslIstat" ChildDownBindValue='<%# Bind("CodiceAslAss") %>' />
														</td>
													</tr>
													<tr>
														<td>
															Posizione
														</td>
														<td>
															<asp:DropDownList ID="ddlPosizioneAss" runat="server" DataSourceID="ComboPosizioniAssObjectDataSource"
																DataTextField="Descrizione" DataValueField="Codice" SelectedValue='<%# Bind("PosizioneAss") %>'>
															</asp:DropDownList>
														</td>
														<td>
															Ambito
														</td>
														<td>
															<asp:TextBox ID="txtAmbito" runat="server" Text='<%# Bind("Ambito") %>' CssClass="Input16"
																MaxLength="16" />
														</td>
													</tr>
													<tr>
														<td>
															Data inizio
														</td>
														<td>
															<asp:TextBox ID="txtDataInizioAss" runat="server" Text='<%# Bind("DataInizioAss", "{0:d}") %>'
																CssClass="InputDate" MaxLength="10" />
															<asp:CompareValidator ID="cvalDataInizioAss" runat="server" ControlToValidate="txtDataInizioAss"
																ErrorMessage='<img src="../Images/icon_small_caution.gif" alt="Valore non valido!" />'
																Operator="DataTypeCheck" Type="Date"></asp:CompareValidator>
														</td>
														<td>
															Data scadenza
														</td>
														<td>
															<asp:TextBox ID="txtDataScadenzaAss" runat="server" Text='<%# Bind("DataScadenzaAss", "{0:d}") %>'
																CssClass="InputDate" MaxLength="10" />
															<asp:CompareValidator ID="cvalDataScadenzaAss" runat="server" ControlToValidate="txtDataScadenzaAss"
																ErrorMessage='<img src="../Images/icon_small_caution.gif" alt="Valore non valido!" />'
																Operator="DataTypeCheck" Type="Date"></asp:CompareValidator>
														</td>
													</tr>
													<tr>
														<td>
															Descrizione terminazione
														</td>
														<td>
															<asp:DropDownList ID="ddlTerminazioni" runat="server" DataTextField="Descrizione"
																DataValueField="Codice">
															</asp:DropDownList>
														</td>
														<td>
															Data terminazione
														</td>
														<td>
															<asp:TextBox ID="txtDataTerminazioneAss" runat="server" Text='<%# Bind("DataTerminazioneAss", "{0:d}") %>'
																CssClass="InputDate" MaxLength="10" />
															<asp:CompareValidator ID="cvalDataTerminazioneAss" runat="server" ControlToValidate="txtDataTerminazioneAss"
																ErrorMessage='<img src="../Images/icon_small_caution.gif" alt="Valore non valido!" />'
																Operator="DataTypeCheck" Type="Date"></asp:CompareValidator>
														</td>
													</tr>
													<tr>
														<td>
															Distretto amm.
														</td>
														<td>
															<asp:TextBox ID="txtDistrettoAmm" runat="server" Text='<%# Bind("DistrettoAmm") %>'
																CssClass="InputDate" MaxLength="8" />
														</td>
														<td>
															Distretto ter.
														</td>
														<td>
															<asp:TextBox ID="txtDistrettoTer" runat="server" Text='<%# Bind("DistrettoTer") %>'
																CssClass="Input16" MaxLength="16" />
														</td>
													</tr>
												</table>
											</fieldset>
											<br />
											<fieldset>
												<legend>Medico di base</legend>
												<table cellpadding="5" cellspacing="1" border="0">
													<tr>
														<td>
															Codice
														</td>
														<td>
															<asp:TextBox ID="txtCodiceMedicoDiBase" runat="server" Text='<%# Bind("CodiceMedicoDiBase") %>'
																CssClass="InputDate" />
															<asp:CompareValidator ID="cvalCodiceMedicoDiBase" runat="server" ControlToValidate="txtCodiceMedicoDiBase"
																ErrorMessage='<img src="../Images/icon_small_caution.gif" alt="Valore non valido!" />'
																Operator="DataTypeCheck" Type="Integer"></asp:CompareValidator>
														</td>
														<td>
															Codice Fiscale
														</td>
														<td>
															<asp:TextBox ID="txtCodiceFiscaleMedicoDiBase" runat="server" Text='<%# Bind("CodiceFiscaleMedicoDiBase") %>'
																CssClass="Input16" MaxLength="16" />
														</td>
													</tr>
													<tr>
														<td>
															Nome e Cognome
														</td>
														<td colspan="3">
															<asp:TextBox ID="txtCognomeNomeMedicoDiBase" runat="server" Text='<%# Bind("CognomeNomeMedicoDiBase") %>'
																CssClass="Input128" MaxLength="128" />
														</td>
													</tr>
													<tr>
														<td>
															Distretto
														</td>
														<td>
															<asp:TextBox ID="txtDistrettoMedicoDiBase" runat="server" Text='<%# Bind("DistrettoMedicoDiBase") %>'
																CssClass="InputDate" MaxLength="8" />
														</td>
														<td>
															Data scelta
														</td>
														<td>
															<asp:TextBox ID="txtDataSceltaMedicoDiBase" runat="server" Text='<%# Bind("DataSceltaMedicoDiBase", "{0:d}") %>'
																CssClass="InputDate" MaxLength="10" />
															<asp:CompareValidator ID="cvalDataSceltaMedicoDiBase" runat="server" ControlToValidate="txtDataSceltaMedicoDiBase"
																ErrorMessage='<img src="../Images/icon_small_caution.gif" alt="Valore non valido!" />'
																Operator="DataTypeCheck" Type="Date"></asp:CompareValidator>
														</td>
													</tr>
												</table>
											</fieldset>
										</asp:View>
										<%--STP--%>
										<asp:View ID="STP" runat="Server">
											<fieldset>
												<legend>Straniero Temporaneamente Presente</legend>
												<table cellpadding="5" cellspacing="1" border="0">
													<tr>
														<td>
															Codice
														</td>
														<td>
															<asp:TextBox ID="txtCodiceSTP" runat="server" Text='<%# Bind("CodiceSTP") %>' CssClass="Input16"
																MaxLength="32" />
														</td>
														<td>
															Motivo annullo
														</td>
														<td>
															<asp:TextBox ID="txtMotivoAnnulloSTP" runat="server" Text='<%# Bind("MotivoAnnulloSTP") %>'
																CssClass="InputDate" MaxLength="8" />
														</td>
													</tr>
													<tr>
														<td>
															Data inizio
														</td>
														<td>
															<asp:TextBox ID="txtDataInizioSTP" runat="server" Text='<%# Bind("DataInizioSTP", "{0:d}") %>'
																CssClass="InputDate" MaxLength="10" />
															<asp:CompareValidator ID="cvalDataInizioSTP" runat="server" ControlToValidate="txtDataInizioSTP"
																ErrorMessage='<img src="../Images/icon_small_caution.gif" alt="Valore non valido!" />'
																Operator="DataTypeCheck" Type="Date"></asp:CompareValidator>
														</td>
														<td>
															Data fine
														</td>
														<td>
															<asp:TextBox ID="txtDataFineSTP" runat="server" Text='<%# Bind("DataFineSTP", "{0:d}") %>'
																CssClass="InputDate" MaxLength="10" />
															<asp:CompareValidator ID="cvalDataFineSTP" runat="server" ControlToValidate="txtDataFineSTP"
																ErrorMessage='<img src="../Images/icon_small_caution.gif" alt="Valore non valido!" />'
																Operator="DataTypeCheck" Type="Date"></asp:CompareValidator>
														</td>
													</tr>
												</table>
											</fieldset>
										</asp:View>
									</asp:MultiView>
								</td>
							</tr>
							<tr>
								<td style="text-align: right">
									<asp:Button ID="InsertButton" runat="server" CssClass="TabButton" CausesValidation="True"
										CommandName="Insert" Text="Conferma" />
									<asp:Button ID="InsertCancelButton" runat="server" CssClass="TabButton" CausesValidation="False"
										CommandName="Cancel" Text="Annulla" />
								</td>
							</tr>
						</table>
					</fieldset>
				</InsertItemTemplate>
				<ItemTemplate>
					<fieldset>
						<table cellpadding="1" cellspacing="0" border="0" style="width: 800;">
							<tr>
								<td style="height: 500px; vertical-align: top;">
									<asp:MultiView ID="PazienteDettaglioMultiView" runat="server" ActiveViewIndex="0">
										<%--Anagrafe e Stati--%>
										<asp:View ID="AnagrafeStati" runat="Server">
											<fieldset>
												<legend>Anagrafe</legend>
												<table cellpadding="5" cellspacing="1" border="0">
													<tr>
														<td>
															Cognome
														</td>
														<td>
															<asp:Label ID="lblCognome" runat="server" Text='<%# Bind("Cognome") %>' CssClass="LabelReadOnly" />
														</td>
														<td>
															Nome
														</td>
														<td>
															<asp:Label ID="lblNome" runat="server" Text='<%# Bind("Nome") %>' CssClass="LabelReadOnly" />
														</td>
													</tr>
													<tr>
														<td>
															Codice fiscale
														</td>
														<td>
															<asp:Label ID="lblCodiceFiscale" runat="server" Text='<%# Bind("CodiceFiscale") %>'
																CssClass="LabelReadOnly" />
														</td>
														<td>
															Sesso
														</td>
														<td>
															<asp:Label ID="lblSesso" runat="server" Text='<%# Bind("Sesso") %>' CssClass="LabelReadOnly" />
														</td>
													</tr>
													<tr>
														<td>
															Data nascita
														</td>
														<td>
															<asp:Label ID="lblDataNascita" runat="server" Text='<%# Bind("DataNascita", "{0:d}") %>'
																CssClass="LabelReadOnly" />
														</td>
														<td>
															Data decesso
														</td>
														<td>
															<asp:Label ID="lblDataDecesso" runat="server" Text='<%# GetDataDecesso(Eval("CodiceTerminazione"), Eval("DataTerminazioneAss")) %>'
																CssClass="LabelReadOnly" />
														</td>
													</tr>
													<tr>
														<td style="vertical-align: top;">
															Comune nascita
														</td>
														<td>
															<progel:CustomDropDownList ID="pddlComuneNascita" runat="server" Enabled="false"
																ServicePath="~/WebServices/Istat.asmx" ParentCategory="Province" ParentServiceMethod="GetProvinceIstat"
																ParentPromptText="- seleziona la provincia -" ParentLoadingText="caricamento province..."
																ParentBindValue='<%# Eval("ProvinciaNascitaCodice") %>' ChildCategory="Comuni"
																ChildServiceMethod="GetComuniIstat" ChildPromptText="- seleziona il comune -" ChildLoadingText="caricamento comuni..."
																ChildBindValue='<%# Bind("ComuneNascitaCodice") %>' />
														</td>
														<td style="vertical-align: top;">
															Nazionalità
														</td>
														<td style="vertical-align: top;">
															<asp:DropDownList ID="ddlNazionalita" runat="server" Enabled="false" DataSourceID="ComboNazioniObjectDataSource"
																DataTextField="Nome" DataValueField="Codice" SelectedValue='<%# Bind("NazionalitaCodice") %>'>
															</asp:DropDownList>
														</td>
													</tr>
												</table>
											</fieldset>
											<br />
											<fieldset>
												<legend>Stati</legend>
												<table cellpadding="5" cellspacing="1" border="0">
													<tr>
														<td style="vertical-align: top;">
															Dati Anamnestici
														</td>
														<td colspan="3">
															<asp:TextBox ID="txtDatiAnamnestici" runat="server" Enabled="false" Text='<%# Bind("DatiAnamnestici") %>'
																CssClass="Input128" TextMode="MultiLine" Rows="5" />
														</td>
													</tr>
													<tr>
														<td>
															Mantenimento Pediatra
														</td>
														<td>
															<asp:CheckBox ID="chkMantenimentoPediatra" runat="server" Enabled="false" Checked='<%# Bind("MantenimentoPediatra") %>' />
														</td>
														<td>
															Capo famiglia
														</td>
														<td>
															<asp:CheckBox ID="chkCapoFamiglia" runat="server" Enabled="false" Checked='<%# Bind("CapoFamiglia") %>' />
														</td>
													</tr>
													<tr>
														<td>
															Indigenza
														</td>
														<td>
															<asp:CheckBox ID="chkIndigenza" runat="server" Enabled="false" Checked='<%# Bind("Indigenza") %>' />
														</td>
														<td>
														</td>
														<td>
														</td>
													</tr>
												</table>
											</fieldset>
										</asp:View>
										<%--Residenza, Domicilio e Recapiti--%>
										<asp:View ID="ResidenzaDomicilio" runat="Server">
											<fieldset>
												<legend>Residenza</legend>
												<table cellpadding="5" cellspacing="1" border="0">
													<tr>
														<td style="vertical-align: top;">
															Comune
														</td>
														<td>
															<progel:CustomDropDownList ID="pddlComuneRes" runat="server" Enabled="false" ServicePath="~/WebServices/Istat.asmx"
																ParentCategory="Province" ParentServiceMethod="GetProvinceIstat" ParentPromptText="- seleziona la provincia -"
																ParentLoadingText="caricamento province..." ParentBindValue='<%# Eval("ProvinciaResCodice") %>'
																ChildCategory="Comuni" ChildServiceMethod="GetComuniIstat" ChildPromptText="- seleziona il comune -"
																ChildLoadingText="caricamento comuni..." ChildBindValue='<%# Bind("ComuneResCodice") %>' />
														</td>
														<td style="vertical-align: top;">
															Sub Comune
														</td>
														<td style="vertical-align: top;">
															<asp:Label ID="lblSubComuneRes" runat="server" Text='<%# Bind("SubComuneRes") %>'
																CssClass="LabelReadOnly" />
														</td>
													</tr>
													<tr>
														<td style="vertical-align: top;">
															Indirizzo
														</td>
														<td>
															<asp:Label ID="lblIndirizzoRes" runat="server" Text='<%# Bind("IndirizzoRes") %>'
																CssClass="LabelReadOnly" />
														</td>
														<td style="vertical-align: top;">
															Località
														</td>
														<td style="vertical-align: top;">
															<asp:Label ID="lblLocalitaRes" runat="server" Text='<%# Bind("LocalitaRes") %>' CssClass="LabelReadOnly" />
														</td>
													</tr>
													<tr>
														<td>
															Cap
														</td>
														<td>
															<asp:Label ID="lblCapRes" runat="server" Text='<%# Bind("CapRes") %>' CssClass="LabelReadOnly" />
														</td>
														<td>
															Data decorrenza
														</td>
														<td>
															<asp:Label ID="lblDataDecorrenzaRes" runat="server" Text='<%# Bind("DataDecorrenzaRes", "{0:d}") %>'
																CssClass="LabelReadOnly" />
														</td>
													</tr>
													<tr>
														<td style="vertical-align: top;">
															Asl
														</td>
														<td>
															<progel:CascadingDropDownList ID="pddlComuneAslRes" runat="server" Enabled="false"
																ServicePath="~/WebServices/Istat.asmx" ParentCategory="Province" ParentServiceMethod="GetProvinceIstat"
																ParentPromptText="- seleziona la provincia -" ParentLoadingText="caricamento province..."
																ParentBindValue='<%# Eval("ProvinciaAslResCodice") %>' ChildTopCategory="Comuni"
																ChildTopServiceMethod="GetComuniIstat" ChildTopPromptText="- seleziona il comune -"
																ChildTopLoadingText="caricamento comuni..." ChildTopBindValue='<%# Bind("ComuneAslResCodice") %>'
																ChildDownCategory="AslComuni" ChildDownServiceMethod="GetAslIstat" ChildDownBindValue='<%# Bind("CodiceAslRes") %>' />
														</td>
														<td style="vertical-align: top;">
															Regione Asl
														</td>
														<td style="vertical-align: top;">
															<asp:Label ID="lblRegioneAslResNome" runat="server" Text='<%# Eval("RegioneAslResNome") %>'
																CssClass="LabelReadOnly"></asp:Label>
														</td>
													</tr>
												</table>
											</fieldset>
											<br />
											<fieldset>
												<legend>Domicilio</legend>
												<table cellpadding="5" cellspacing="1" border="0">
													<tr>
														<td style="vertical-align: top;">
															Comune
														</td>
														<td>
															<progel:CustomDropDownList ID="pddlComuneDom" runat="server" Enabled="false" ServicePath="~/WebServices/Istat.asmx"
																ParentCategory="Province" ParentServiceMethod="GetProvinceIstat" ParentPromptText="- seleziona la provincia -"
																ParentLoadingText="caricamento province..." ParentBindValue='<%# Eval("ProvinciaDomCodice") %>'
																ChildCategory="Comuni" ChildServiceMethod="GetComuniIstat" ChildPromptText="- seleziona il comune -"
																ChildLoadingText="caricamento comuni..." ChildBindValue='<%# Bind("ComuneDomCodice") %>' />
														</td>
														<td style="vertical-align: top;">
															Sub Comune
														</td>
														<td style="vertical-align: top;">
															<asp:Label ID="lblSubComuneDom" runat="server" Text='<%# Bind("SubComuneDom") %>'
																CssClass="LabelReadOnly" />
														</td>
													</tr>
													<tr>
														<td style="vertical-align: top;">
															Indirizzo
														</td>
														<td>
															<asp:Label ID="lblIndirizzoDom" runat="server" Text='<%# Bind("IndirizzoDom") %>'
																CssClass="LabelReadOnly" />
														</td>
														<td style="vertical-align: top;">
															Località
														</td>
														<td style="vertical-align: top;">
															<asp:Label ID="lblLocalitaDom" runat="server" Text='<%# Bind("LocalitaDom") %>' CssClass="LabelReadOnly" />
														</td>
													</tr>
													<tr>
														<td>
															Cap
														</td>
														<td>
															<asp:Label ID="lblCapDom" runat="server" Text='<%# Bind("CapDom") %>' CssClass="LabelReadOnly" />
														</td>
														<td>
														</td>
														<td>
														</td>
													</tr>
												</table>
											</fieldset>
											<br />
											<fieldset>
												<legend>Recapiti</legend>
												<table cellpadding="5" cellspacing="1" border="0">
													<tr>
														<td style="vertical-align: top;">
															Comune
														</td>
														<td>
															<progel:CustomDropDownList ID="pddlComuneRecapito" runat="server" Enabled="false"
																ServicePath="~/WebServices/Istat.asmx" ParentCategory="Province" ParentServiceMethod="GetProvinceIstat"
																ParentPromptText="- seleziona la provincia -" ParentLoadingText="caricamento province..."
																ParentBindValue='<%# Eval("ProvinciaRecapitoCodice") %>' ChildCategory="Comuni"
																ChildServiceMethod="GetComuniIstat" ChildPromptText="- seleziona il comune -" ChildLoadingText="caricamento comuni..."
																ChildBindValue='<%# Bind("ComuneRecapitoCodice") %>' />
														</td>
														<td style="vertical-align: top;">
															Indirizzo
														</td>
														<td style="vertical-align: top;">
															<asp:Label ID="lblIndirizzoRecapito" runat="server" Text='<%# Bind("IndirizzoRecapito") %>'
																CssClass="LabelReadOnly" />
														</td>
													</tr>
													<tr>
														<td>
															Località
														</td>
														<td>
															<asp:Label ID="lblLocalitaRecapito" runat="server" Text='<%# Bind("LocalitaRecapito") %>'
																CssClass="LabelReadOnly" />
														</td>
														<td>
															Telefono 1
														</td>
														<td>
															<asp:Label ID="lblTelefono1" runat="server" Text='<%# Bind("Telefono1") %>' CssClass="LabelReadOnly" />
														</td>
													</tr>
													<tr>
														<td>
															Telefono 2
														</td>
														<td>
															<asp:Label ID="lblTelefono2" runat="server" Text='<%# Bind("Telefono2") %>' CssClass="LabelReadOnly" />
														</td>
														<td>
															Telefono 3
														</td>
														<td>
															<asp:Label ID="lblTelefono3" runat="server" Text='<%# Bind("Telefono3") %>' CssClass="LabelReadOnly" />
														</td>
													</tr>
												</table>
											</fieldset>
										</asp:View>
										<%--Assistito e Medico di base--%>
										<asp:View ID="AssistitoMedicoBase" runat="Server">
											<fieldset>
												<legend>Assistito</legend>
												<table cellpadding="5" cellspacing="1" border="0">
													<tr>
														<td>
															Posizione
														</td>
														<td>
															<asp:DropDownList ID="ddlPosizioneAss" runat="server" Enabled="false" DataSourceID="ComboPosizioniAssObjectDataSource"
																DataTextField="Descrizione" DataValueField="Codice" SelectedValue='<%# Bind("PosizioneAss") %>'>
															</asp:DropDownList>
														</td>
														<td>
															Ambito
														</td>
														<td>
															<asp:Label ID="lblAmbito" runat="server" Text='<%# Bind("Ambito") %>' CssClass="LabelReadOnly" />
														</td>
													</tr>
													<tr>
														<td>
															Data inizio
														</td>
														<td>
															<asp:Label ID="lblDataInizioAss" runat="server" Text='<%# Bind("DataInizioAss", "{0:d}") %>'
																CssClass="LabelReadOnly" />
														</td>
														<td>
															Data scadenza
														</td>
														<td>
															<asp:Label ID="lblDataScadenzaAss" runat="server" Text='<%# Bind("DataScadenzaAss", "{0:d}") %>'
																CssClass="LabelReadOnly" />
														</td>
													</tr>
													<tr>
														<td>
															Descrizione terminazione
														</td>
														<td>
															<asp:DropDownList ID="ddlTerminazioni" runat="server" Enabled="false" DataTextField="Descrizione"
																DataValueField="Codice">
															</asp:DropDownList>
														</td>
														<td>
															Data terminazione
														</td>
														<td>
															<asp:Label ID="lblDataTerminazioneAss" runat="server" Text='<%# Bind("DataTerminazioneAss", "{0:d}") %>'
																CssClass="LabelReadOnly" />
														</td>
													</tr>
													<tr>
														<td>
															Distretto amm.
														</td>
														<td>
															<asp:Label ID="lblDistrettoAmm" runat="server" Text='<%# Bind("DistrettoAmm") %>'
																CssClass="LabelReadOnly" />
														</td>
														<td>
															Distretto ter.
														</td>
														<td>
															<asp:Label ID="lblDistrettoTer" runat="server" Text='<%# Bind("DistrettoTer") %>'
																CssClass="LabelReadOnly" />
														</td>
													</tr>
													<tr>
														<td style="vertical-align: top;">
															Asl
														</td>
														<td>
															<progel:CascadingDropDownList ID="pddlComuneAslAss" runat="server" Enabled="false"
																ServicePath="~/WebServices/Istat.asmx" ParentCategory="Province" ParentServiceMethod="GetProvinceIstat"
																ParentPromptText="- seleziona la provincia -" ParentLoadingText="caricamento province..."
																ParentBindValue='<%# Eval("ProvinciaAslAssCodice") %>' ChildTopCategory="Comuni"
																ChildTopServiceMethod="GetComuniIstat" ChildTopPromptText="- seleziona il comune -"
																ChildTopLoadingText="caricamento comuni..." ChildTopBindValue='<%# Bind("ComuneAslAssCodice") %>'
																ChildDownCategory="AslComuni" ChildDownServiceMethod="GetAslIstat" ChildDownBindValue='<%# Bind("CodiceAslAss") %>' />
														</td>
														<td style="vertical-align: top;">
															Regione Asl
														</td>
														<td style="vertical-align: top;">
															<asp:Label ID="lblRegioneAslAssNome" runat="server" Text='<%# Eval("RegioneAslAssNome") %>'
																CssClass="LabelReadOnly"></asp:Label>
														</td>
													</tr>
												</table>
											</fieldset>
											<br />
											<fieldset>
												<legend>Medico di base</legend>
												<table cellpadding="5" cellspacing="1" border="0">
													<tr>
														<td>
															Codice
														</td>
														<td>
															<asp:Label ID="lblCodiceMedicoDiBase" runat="server" Text='<%# Bind("CodiceMedicoDiBase") %>'
																CssClass="LabelReadOnly" />
														</td>
														<td>
															Codice Fiscale
														</td>
														<td>
															<asp:Label ID="lblCodiceFiscaleMedicoDiBase" runat="server" Text='<%# Bind("CodiceFiscaleMedicoDiBase") %>'
																CssClass="LabelReadOnly" />
														</td>
													</tr>
													<tr>
														<td>
															Nome e Cognome
														</td>
														<td colspan="3">
															<asp:Label ID="lblCognomeNomeMedicoDiBase" runat="server" Text='<%# Bind("CognomeNomeMedicoDiBase") %>'
																CssClass="LabelReadOnly" />
														</td>
													</tr>
													<tr>
														<td>
															Distretto
														</td>
														<td>
															<asp:Label ID="lblDistrettoMedicoDiBase" runat="server" Text='<%# Bind("DistrettoMedicoDiBase") %>'
																CssClass="LabelReadOnly" />
														</td>
														<td>
															Data scelta
														</td>
														<td>
															<asp:Label ID="lblDataSceltaMedicoDiBase" runat="server" Text='<%# Bind("DataSceltaMedicoDiBase", "{0:d}") %>'
																CssClass="LabelReadOnly" />
														</td>
													</tr>
												</table>
											</fieldset>
										</asp:View>
										<%--STP--%>
										<asp:View ID="STP" runat="Server">
											<fieldset>
												<legend>Straniero Temporaneamente Presente</legend>
												<table cellpadding="5" cellspacing="1" border="0">
													<tr>
														<td>
															Codice
														</td>
														<td>
															<asp:Label ID="txtCodiceSTP" runat="server" Text='<%# Bind("CodiceSTP") %>' CssClass="LabelReadOnly" />
														</td>
														<td>
															Motivo annullo
														</td>
														<td>
															<asp:Label ID="txtMotivoAnnulloSTP" runat="server" Text='<%# Bind("MotivoAnnulloSTP") %>'
																CssClass="LabelReadOnly" />
														</td>
													</tr>
													<tr>
														<td>
															Data inizio
														</td>
														<td>
															<asp:Label ID="txtDataInizioSTP" runat="server" Text='<%# Bind("DataInizioSTP", "{0:d}") %>'
																CssClass="LabelReadOnly" />
														</td>
														<td>
															Data fine
														</td>
														<td>
															<asp:Label ID="txtDataFineSTP" runat="server" Text='<%# Bind("DataFineSTP", "{0:d}") %>'
																CssClass="LabelReadOnly" />
														</td>
													</tr>
												</table>
											</fieldset>
										</asp:View>
										<%--Esenzioni--%>
										<asp:View ID="Esenzioni" runat="Server">
											<fieldset>
												<legend>Esenzioni</legend>
												<table cellpadding="5" cellspacing="1" border="0" width="100%">
													<tr>
														<td style="text-align: right;">
															<asp:RadioButtonList ID="rblVisualizzaEsenzioni" RepeatDirection="Horizontal" AutoPostBack="true"
																OnSelectedIndexChanged="LoadEsenzioni" runat="server">
																<asp:ListItem Value="Default" Text="Default" Selected="True"></asp:ListItem>
																<asp:ListItem Value="All" Text="Tutti"></asp:ListItem>
															</asp:RadioButtonList>
														</td>
													</tr>
													<tr>
														<td>
															<asp:GridView ID="gvEsenzioni" runat="server" AllowPaging="False" AllowSorting="False"
																AutoGenerateColumns="False" BackColor="White" BorderColor="White" BorderStyle="Solid"
																EmptyDataText="Nessun risultato!" GridLines="Horizontal" DataKeyNames="Id" Width="100%"
																PagerSettings-Position="TopAndBottom" CssClass="GridYellow" HeaderStyle-CssClass="Header"
																PagerStyle-CssClass="Pager">
																<Columns>
																	<asp:HyperLinkField DataTextField="CodiceEsenzione" DataNavigateUrlFormatString="../Esenzioni/EsenzioneDettaglio.aspx?idPaziente={0}&idEsenzione={1}"
																		DataNavigateUrlFields="IdPaziente,Id" HeaderText="Cod Esenzione" />
																	<asp:BoundField DataField="TestoEsenzione" HeaderText="Esenzione" />
																	<asp:BoundField DataField="DataInizioValidita" HeaderText="Inizio Validità" DataFormatString="{0:d}"
																		HtmlEncode="False" />
																	<asp:BoundField DataField="DataFineValidita" HeaderText="Fine Validità" DataFormatString="{0:d}"
																		HtmlEncode="False" />
																	<asp:BoundField DataField="CodiceDiagnosi" HeaderText="Cod Diagnosi" />
																	<asp:BoundField DataField="DecodificaEsenzioneDiagnosi" HeaderText="Diagnosi" />
																</Columns>
															</asp:GridView>
														</td>
													</tr>
												</table>
											</fieldset>
										</asp:View>
										<%--Consensi--%>
										<asp:View ID="Consensi" runat="Server">
											<fieldset>
												<legend>Consensi</legend>
												<table cellpadding="5" cellspacing="1" border="0" style="width: 100%;">
													<tr>
														<td style="text-align: right;">
															<asp:RadioButtonList ID="rblVisualizzaConsensi" RepeatDirection="Horizontal" AutoPostBack="true"
																OnSelectedIndexChanged="LoadConsensi" runat="server">
																<asp:ListItem Value="Default" Text="Default" Selected="True"></asp:ListItem>
																<asp:ListItem Value="All" Text="Tutti"></asp:ListItem>
															</asp:RadioButtonList>
														</td>
													</tr>
													<tr>
														<td>
															<asp:GridView ID="gvConsensi" runat="server" AllowPaging="False" AllowSorting="False"
																AutoGenerateColumns="False" EmptyDataText="Nessun risultato!" GridLines="Horizontal"
																DataKeyNames="Id" Width="100%" OnRowDataBound="gvConsensi_RowDataBound" PagerSettings-Position="TopAndBottom"
																CssClass="GridYellow" HeaderStyle-CssClass="Header" PagerStyle-CssClass="Pager">
																<Columns>
																	<asp:HyperLinkField DataTextField="Tipo" DataNavigateUrlFormatString="../Consensi/ConsensoDettaglio.aspx?idPaziente={0}&idConsenso={1}"
																		DataNavigateUrlFields="IdPaziente,Id" HeaderText="Tipo" ItemStyle-VerticalAlign="Top" />
																	<asp:TemplateField ItemStyle-VerticalAlign="Top">
																		<ItemTemplate>
																			<asp:GridView ID="gvConsensiNested" runat="server" AllowPaging="False" AllowSorting="False"
																				AutoGenerateColumns="False" BackColor="White" BorderColor="White" BorderStyle="Solid"
																				BorderWidth="1px" CellPadding="1" GridLines="Horizontal" DataKeyNames="Id" Width="100%"
																				PageSize="5" OnPageIndexChanging="gvConsensiNested_PageIndexChanging">
																				<Columns>
																					<asp:HyperLinkField DataTextField="DataStato" DataTextFormatString="{0:d}" DataNavigateUrlFormatString="../Consensi/ConsensoDettaglio.aspx?idPaziente={0}&idConsenso={1}"
																						DataNavigateUrlFields="IdPaziente,Id" HeaderText="Data" ItemStyle-VerticalAlign="Top"/>
																					<asp:BoundField DataField="Provenienza" HeaderText="Provenienza" ItemStyle-VerticalAlign="Top"/>
																					<asp:BoundField DataField="OperatoreCognome" HeaderText="Operatore Cognome" ItemStyle-VerticalAlign="Top"/>
																					<asp:BoundField DataField="OperatoreNome" HeaderText="Operatore Nome" ItemStyle-VerticalAlign="Top"/>
																					<asp:CheckBoxField DataField="Stato" HeaderText="Stato" ItemStyle-VerticalAlign="Top"/>
                                                                                    <asp:TemplateField HeaderText="Autorizzatore Minore" ItemStyle-VerticalAlign="Top">
																		                <ItemTemplate>
	    																	                <asp:Label ID="IdAutorizzatore" runat="server" Text='<%# ShowAttributiAutorizzatoreMinore(Eval("Attributi")) %>'></asp:Label>
    																		                </ItemTemplate>
    																                </asp:TemplateField>
																				</Columns>
																				<HeaderStyle Font-Bold="True" ForeColor="Black" HorizontalAlign="Left" Height="30"
																					VerticalAlign="Bottom" />
																				<PagerStyle CssClass="GridPager" />
																			</asp:GridView>
																		</ItemTemplate>
																	</asp:TemplateField>
																	<asp:BoundField DataField="DataStato" HeaderText="Data" DataFormatString="{0:d}"
																		HtmlEncode="False" ItemStyle-VerticalAlign="Top"/>
																	<asp:BoundField DataField="Provenienza" HeaderText="Provenienza" ItemStyle-VerticalAlign="Top"/>
																	<asp:BoundField DataField="OperatoreCognome" HeaderText="Operatore Cognome" ItemStyle-VerticalAlign="Top"/>
																	<asp:BoundField DataField="OperatoreNome" HeaderText="Operatore Nome" ItemStyle-VerticalAlign="Top"/>
																	<asp:CheckBoxField DataField="Stato" HeaderText="Stato" ItemStyle-VerticalAlign="Top"/>
																	<asp:TemplateField ItemStyle-VerticalAlign="Top">
																		<ItemTemplate>
																			<asp:Label ID="IdTipoLabel" runat="server" Text='<%#Eval("IdTipo") %>' Visible="false"></asp:Label>
																		</ItemTemplate>
																	</asp:TemplateField>
                                                                    <asp:TemplateField HeaderText="Autorizzatore Minore" ItemStyle-VerticalAlign="Top">
																		<ItemTemplate>
	    																	<asp:Label ID="IdAttributi" runat="server" Text='<%# ShowAttributiAutorizzatoreMinore(Eval("Attributi")) %>'></asp:Label>
    																		</ItemTemplate>
    																</asp:TemplateField>

																</Columns>
															</asp:GridView>
														</td>
													</tr>
												</table>
											</fieldset>
										</asp:View>
										<%--Lista anonimizzazioni--%>
										<asp:View ID="Anonimizzazioni" runat="Server">
											<fieldset>
												<legend>Anonimizzazioni</legend>
												<table cellpadding="5" cellspacing="1" border="0" style="width: 100%;">
													<tr>
														<td>
															<%-- Se dettaglio è una posizione originale mostra lista delle anonimizzazioni --%>
															<asp:GridView ID="gvAnonimizzazioni" runat="server" AllowPaging="True" PageSize="20"
																AllowSorting="False" AutoGenerateColumns="False" EmptyDataText="Nessun risultato!"
																GridLines="Horizontal" DataKeyNames="IdSacAnonimo" Width="70%" OnPageIndexChanging="gvAnonimizzazioni_PageIndexChanging"
																PagerSettings-Position="TopAndBottom" CssClass="GridYellow" HeaderStyle-CssClass="Header"
																PagerStyle-CssClass="Pager">
																<Columns>
																	<asp:TemplateField>
																		<ItemTemplate>
																			<asp:HyperLink ID="hlDettaglioAnonimizzazione" runat="server" ImageUrl="~/Images/view.png"
																				NavigateUrl='<%# String.Format("~/Pazienti/PazienteDettaglioAnonimizzazione.aspx?Id={0}&IdPazienteAnonimo={1}", Eval("IdSacOriginale"), Eval("IdSacAnonimo")) %>' />
																		</ItemTemplate>
																	</asp:TemplateField>
																	<asp:HyperLinkField DataTextField="IdAnonimo" DataNavigateUrlFormatString="../Pazienti/PazienteDettaglio.aspx?id={0}"
																		DataNavigateUrlFields="IdSacAnonimo" HeaderText="Codice<br/>anonimizzazione" />
																	<asp:BoundField DataField="Utente" HeaderText="Utente" />
																	<asp:BoundField DataField="DataInserimento" HeaderText="Data creazione" DataFormatString="{0:g}"
																		HtmlEncode="False" />
																</Columns>
															</asp:GridView>
															<%-- Se dettaglio NON è una posizione mostro link alla posizione originale --%>
															<asp:HyperLink ID="PosizioneOriginaleLink" runat="server">Vai alla posizione originale</asp:HyperLink>
														</td>
													</tr>
												</table>
											</fieldset>
										</asp:View>
										<%--Lista posizioni collegate--%>
										<asp:View ID="PosizioniCollegate" runat="Server">
											<fieldset>
												<legend>Posizioni collegate</legend>
												<table cellpadding="5" cellspacing="1" border="0" style="width: 100%;">
													<tr>
														<td>
                                                            <%-- Se dettaglio è una posizione originale mostra lista delle posizioni collegate --%>
															<asp:GridView ID="gvPosizioniCollegate" runat="server" AllowPaging="True" PageSize="20"
																AllowSorting="False" AutoGenerateColumns="False" EmptyDataText="Nessun risultato!"
																GridLines="Horizontal" DataKeyNames="IdSacPosizioneCollegata" Width="70%" OnPageIndexChanging="gvPosizioniCollegate_PageIndexChanging"
																PagerSettings-Position="TopAndBottom" CssClass="GridYellow" HeaderStyle-CssClass="Header"
																PagerStyle-CssClass="Pager">
																<Columns>
																	<asp:TemplateField>
																		<ItemTemplate>
																			<asp:HyperLink ID="hlDettaglioPosizioneCollegata" runat="server" ImageUrl="~/Images/view.png"
																				NavigateUrl='<%# String.Format("~/Pazienti/PazienteDettaglioPosCollegata.aspx?Id={0}&IdSacPosizioneCollegata={1}", Eval("IdSacOriginale"), Eval("IdSacPosizioneCollegata")) %>' />
																		</ItemTemplate>
																	</asp:TemplateField>
																	<asp:HyperLinkField DataTextField="IdPosizioneCollegata" DataNavigateUrlFormatString="../Pazienti/PazienteDettaglio.aspx?id={0}"
																		DataNavigateUrlFields="IdSacPosizioneCollegata" HeaderText="Codice<br/>paziente collegato" />
																	<asp:BoundField DataField="Utente" HeaderText="Utente" />
																	<asp:BoundField DataField="DataInserimento" HeaderText="Data creazione" DataFormatString="{0:g}"
																		HtmlEncode="False" />
																</Columns>
															</asp:GridView>
															<%-- Se dettaglio NON è una "posizione collegata" mostro link alla posizione originale --%>
															<asp:HyperLink ID="PosizioneOriginalePosizioneCollegataLink" runat="server">Vai alla posizione originale</asp:HyperLink>
														</td>
													</tr>
												</table>
											</fieldset>
										</asp:View>

									</asp:MultiView>
								</td>
							</tr>
						</table>
					</fieldset>
				</ItemTemplate>
			</asp:FormView>
		</tr>
	</table>
	<asp:ObjectDataSource ID="PazienteDettaglioObjectDataSource" runat="server" DeleteMethod="Delete"
		InsertMethod="Insert" SelectMethod="GetData" TypeName="DI.Sac.Admin.Data.PazientiDataSetTableAdapters.PazientiDettaglioTableAdapter"
		UpdateMethod="Update">
		<DeleteParameters>
			<asp:Parameter Name="Id" DbType="Guid" />
			<asp:Parameter Name="Ts" Type="Object" />
			<asp:Parameter Name="Utente" Type="String" />
		</DeleteParameters>
		<UpdateParameters>
			<asp:Parameter Name="Id" DbType="Guid" />
			<asp:Parameter Name="Ts" Type="Object" />
			<asp:Parameter Name="Tessera" Type="String" />
			<asp:Parameter Name="Cognome" Type="String" />
			<asp:Parameter Name="Nome" Type="String" />
			<asp:Parameter Name="DataNascita" Type="DateTime" />
			<asp:Parameter Name="Sesso" Type="String" />
			<asp:Parameter Name="ComuneNascitaCodice" Type="String" />
			<asp:Parameter Name="NazionalitaCodice" Type="String" />
			<asp:Parameter Name="CodiceFiscale" Type="String" />
			<asp:Parameter Name="DatiAnamnestici" Type="String" />
			<asp:Parameter Name="MantenimentoPediatra" Type="Boolean" />
			<asp:Parameter Name="CapoFamiglia" Type="Boolean" />
			<asp:Parameter Name="Indigenza" Type="Boolean" />
			<asp:Parameter Name="CodiceTerminazione" Type="String" />
			<asp:Parameter Name="DescrizioneTerminazione" Type="String" />
			<asp:Parameter Name="ComuneResCodice" Type="String" />
			<asp:Parameter Name="SubComuneRes" Type="String" />
			<asp:Parameter Name="IndirizzoRes" Type="String" />
			<asp:Parameter Name="LocalitaRes" Type="String" />
			<asp:Parameter Name="CapRes" Type="String" />
			<asp:Parameter Name="DataDecorrenzaRes" Type="DateTime" />
			<asp:Parameter Name="ComuneAslResCodice" Type="String" />
			<asp:Parameter Name="CodiceAslRes" Type="String" />
			<asp:Parameter Name="RegioneResCodice" Type="String" />
			<asp:Parameter Name="ComuneDomCodice" Type="String" />
			<asp:Parameter Name="SubComuneDom" Type="String" />
			<asp:Parameter Name="IndirizzoDom" Type="String" />
			<asp:Parameter Name="LocalitaDom" Type="String" />
			<asp:Parameter Name="CapDom" Type="String" />
			<asp:Parameter Name="PosizioneAss" Type="Byte" />
			<asp:Parameter Name="RegioneAssCodice" Type="String" />
			<asp:Parameter Name="ComuneAslAssCodice" Type="String" />
			<asp:Parameter Name="CodiceAslAss" Type="String" />
			<asp:Parameter Name="DataInizioAss" Type="DateTime" />
			<asp:Parameter Name="DataScadenzaAss" Type="DateTime" />
			<asp:Parameter Name="DataTerminazioneAss" Type="DateTime" />
			<asp:Parameter Name="DistrettoAmm" Type="String" />
			<asp:Parameter Name="DistrettoTer" Type="String" />
			<asp:Parameter Name="Ambito" Type="String" />
			<asp:Parameter Name="CodiceMedicoDiBase" Type="Int32" />
			<asp:Parameter Name="CodiceFiscaleMedicoDiBase" Type="String" />
			<asp:Parameter Name="CognomeNomeMedicoDiBase" Type="String" />
			<asp:Parameter Name="DistrettoMedicoDiBase" Type="String" />
			<asp:Parameter Name="DataSceltaMedicoDiBase" Type="DateTime" />
			<asp:Parameter Name="ComuneRecapitoCodice" Type="String" />
			<asp:Parameter Name="IndirizzoRecapito" Type="String" />
			<asp:Parameter Name="LocalitaRecapito" Type="String" />
			<asp:Parameter Name="Telefono1" Type="String" />
			<asp:Parameter Name="Telefono2" Type="String" />
			<asp:Parameter Name="Telefono3" Type="String" />
			<asp:Parameter Name="CodiceSTP" Type="String" />
			<asp:Parameter Name="DataInizioSTP" Type="DateTime" />
			<asp:Parameter Name="DataFineSTP" Type="DateTime" />
			<asp:Parameter Name="MotivoAnnulloSTP" Type="String" />
			<asp:Parameter Name="Utente" Type="String" />
		</UpdateParameters>
		<SelectParameters>
			<asp:QueryStringParameter Name="Id" QueryStringField="id" DbType="Guid" />
		</SelectParameters>
		<InsertParameters>
			<asp:Parameter Name="Tessera" Type="String" />
			<asp:Parameter Name="Cognome" Type="String" />
			<asp:Parameter Name="Nome" Type="String" />
			<asp:Parameter Name="DataNascita" Type="DateTime" />
			<asp:Parameter Name="Sesso" Type="String" />
			<asp:Parameter Name="ComuneNascitaCodice" Type="String" />
			<asp:Parameter Name="NazionalitaCodice" Type="String" />
			<asp:Parameter Name="CodiceFiscale" Type="String" />
			<asp:Parameter Name="DatiAnamnestici" Type="String" />
			<asp:Parameter Name="MantenimentoPediatra" Type="Boolean" />
			<asp:Parameter Name="CapoFamiglia" Type="Boolean" />
			<asp:Parameter Name="Indigenza" Type="Boolean" />
			<asp:Parameter Name="CodiceTerminazione" Type="String" />
			<asp:Parameter Name="DescrizioneTerminazione" Type="String" />
			<asp:Parameter Name="ComuneResCodice" Type="String" />
			<asp:Parameter Name="SubComuneRes" Type="String" />
			<asp:Parameter Name="IndirizzoRes" Type="String" />
			<asp:Parameter Name="LocalitaRes" Type="String" />
			<asp:Parameter Name="CapRes" Type="String" />
			<asp:Parameter Name="DataDecorrenzaRes" Type="DateTime" />
			<asp:Parameter Name="ComuneAslResCodice" Type="String" />
			<asp:Parameter Name="CodiceAslRes" Type="String" />
			<asp:Parameter Name="RegioneResCodice" Type="String" />
			<asp:Parameter Name="ComuneDomCodice" Type="String" />
			<asp:Parameter Name="SubComuneDom" Type="String" />
			<asp:Parameter Name="IndirizzoDom" Type="String" />
			<asp:Parameter Name="LocalitaDom" Type="String" />
			<asp:Parameter Name="CapDom" Type="String" />
			<asp:Parameter Name="PosizioneAss" Type="Byte" />
			<asp:Parameter Name="RegioneAssCodice" Type="String" />
			<asp:Parameter Name="ComuneAslAssCodice" Type="String" />
			<asp:Parameter Name="CodiceAslAss" Type="String" />
			<asp:Parameter Name="DataInizioAss" Type="DateTime" />
			<asp:Parameter Name="DataScadenzaAss" Type="DateTime" />
			<asp:Parameter Name="DataTerminazioneAss" Type="DateTime" />
			<asp:Parameter Name="DistrettoAmm" Type="String" />
			<asp:Parameter Name="DistrettoTer" Type="String" />
			<asp:Parameter Name="Ambito" Type="String" />
			<asp:Parameter Name="CodiceMedicoDiBase" Type="Int32" />
			<asp:Parameter Name="CodiceFiscaleMedicoDiBase" Type="String" />
			<asp:Parameter Name="CognomeNomeMedicoDiBase" Type="String" />
			<asp:Parameter Name="DistrettoMedicoDiBase" Type="String" />
			<asp:Parameter Name="DataSceltaMedicoDiBase" Type="DateTime" />
			<asp:Parameter Name="ComuneRecapitoCodice" Type="String" />
			<asp:Parameter Name="IndirizzoRecapito" Type="String" />
			<asp:Parameter Name="LocalitaRecapito" Type="String" />
			<asp:Parameter Name="Telefono1" Type="String" />
			<asp:Parameter Name="Telefono2" Type="String" />
			<asp:Parameter Name="Telefono3" Type="String" />
			<asp:Parameter Name="CodiceSTP" Type="String" />
			<asp:Parameter Name="DataInizioSTP" Type="DateTime" />
			<asp:Parameter Name="DataFineSTP" Type="DateTime" />
			<asp:Parameter Name="MotivoAnnulloSTP" Type="String" />
			<asp:Parameter Name="Utente" Type="String" />
		</InsertParameters>
	</asp:ObjectDataSource>
	<asp:ObjectDataSource ID="ComboNazioniObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
		SelectMethod="GetData" TypeName="DI.Sac.Admin.Data.PazientiDataSetTableAdapters.ComboNazioniTableAdapter">
	</asp:ObjectDataSource>
	<asp:ObjectDataSource ID="ComboRegioniObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
		SelectMethod="GetData" TypeName="DI.Sac.Admin.Data.PazientiDataSetTableAdapters.ComboRegioniTableAdapter">
	</asp:ObjectDataSource>
	<asp:ObjectDataSource ID="ComboPosizioniAssObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
		SelectMethod="GetData" TypeName="DI.Sac.Admin.Data.PazientiDataSetTableAdapters.ComboPosizioniAssTableAdapter">
	</asp:ObjectDataSource>
	<ajax:ToolkitScriptManager ID="MainScriptManager" runat="server">
	</ajax:ToolkitScriptManager>
</asp:Content>
