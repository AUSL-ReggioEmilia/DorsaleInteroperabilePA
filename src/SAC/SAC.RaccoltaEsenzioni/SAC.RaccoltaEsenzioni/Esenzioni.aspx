<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="Esenzioni.aspx.vb" Inherits="SAC.RaccoltaEsenzioni.Esenzioni" %>

<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

	<!-- Toolbar-->
	<div class="row">
		<div class="col-sm-12">
			<a href="Default.aspx"><span class="glyphicon glyphicon-chevron-left" aria-hidden="true"></span>&nbsp;Torna alla ricerca anagrafica</a>
		</div>
	</div>

	<!--Titolo-->
	<div class="row">
		<div class="col-sm-12">
			<label class="h3">Esenzioni</label>
		</div>
	</div>

	<!-- Info Paziente -->
	<div class="row">
		<div class="col-sm-12">
			<div class="panel panel-default">
				<div class="panel-body">
					<strong>
						<asp:Label runat="server" ID="lblPaziente"></asp:Label>
					</strong>
				</div>
			</div>
		</div>
	</div>

	<!--Tabella-->
	<div class="row">
		<div class="col-sm-12">
			<!-- (aggiungo un form-group per dargli un margin-bottom)-->
			<div class="form-group">
				<asp:LinkButton ID="btnNuovaEsenzione" CssClass="btn btn-sm btn-primary" runat="server" CausesValidation="false" OnClientClick="$('#formInserimentoEsenzione .form-control').val('')">
                    <span class="glyphicon glyphicon-plus"></span> Nuova esenzione
				</asp:LinkButton>
			</div>
		</div>

		<asp:UpdatePanel runat="server" ID="updGvEsenzioni" ChildrenAsTriggers="true" UpdateMode="Conditional">
			<ContentTemplate>
				<div class="col-sm-12" id="divEmptyRow" runat="server" visible="false" enableviewstate="false">
					<div class="well well-sm">
						Il paziente non ha esenzioni associate.
					</div>
				</div>

				<div class="col-sm-12">
					<asp:GridView ID="gvEsenzioni" runat="server" DataSourceID="odsEsenzioni" EnableViewState="false" AllowPaging="True"
						CssClass="table table-bordered table-striped table-condensed small" AutoGenerateColumns="False" PageSize="100">
						<Columns>
							<asp:BoundField DataField="CodiceEsenzione" HeaderText="Codice Esenzione" SortExpression="CodiceEsenzione"></asp:BoundField>
							<%--<asp:BoundField DataField="CodiceDiagnosi" HeaderText="Codice Diagnosi" SortExpression="CodiceDiagnosi"></asp:BoundField>--%>
							<asp:CheckBoxField DataField="Patologica" HeaderText="Per Patologia" SortExpression="Patologica"></asp:CheckBoxField>
							<asp:BoundField DataField="DataInizioValidita" HeaderText="Data Inizio Validità" SortExpression="DataInizioValidita" DataFormatString="{0:d}"></asp:BoundField>
							<asp:BoundField DataField="DataFineValidita" HeaderText="Data Fine Validità" SortExpression="DataFineValidita" DataFormatString="{0:d}"></asp:BoundField>
							<asp:TemplateField HeaderText="Descrizione">
								<ItemTemplate>
									<asp:Label Text='<%# GetDescrizione(Container.DataItem)  %>' runat="server" />
								</ItemTemplate>
							</asp:TemplateField>
							<asp:BoundField DataField="NoteAggiuntive" HeaderText="Note Aggiuntive" SortExpression="Note Aggiuntive"></asp:BoundField>
							<%--<asp:BoundField DataField="DecodificaEsenzioneDiagnosi" HeaderText="Decodifica Esenzione Diagnosi" SortExpression="DecodificaEsenzioneDiagnosi"></asp:BoundField>--%>
							<%--<asp:BoundField DataField="AttributoEsenzioneDiagnosi" HeaderText="Attributo Esenzione Diagnosi" SortExpression="AttributoEsenzioneDiagnosi"></asp:BoundField>--%>
							<%--<asp:BoundField DataField="Provenienza" HeaderText="Provenienza" SortExpression="Provenienza"></asp:BoundField>--%>
							<asp:TemplateField HeaderText="Informazioni">
								<ItemTemplate>
									<asp:Label Text='<%# If(String.IsNullOrEmpty(GetNomeCognomeOperatore(Container.DataItem)), "", "Ultima modifica effettuata da " + GetNomeCognomeOperatore(Container.DataItem))  %>' runat="server" />
								</ItemTemplate>
							</asp:TemplateField>
							<asp:TemplateField>
								<ItemTemplate>
									<!--Bottone per la cancellazione di una esenzione -->
									<asp:LinkButton CausesValidation="false" CommandName="Elimina"
										CommandArgument='<%# Eval("Id") %>' Text="" runat="server" ToolTip="Elimina esenzione" CssClass="btn btn-danger btn-xs"
										OnClientClick="javascript: return confirm('Confermi la cancellazione dell\'esenzione?');" Visible='<%# CancellaEsenzioniVisibility(Eval("Provenienza"), Eval("DataFineValidita")) %>'>
                                    <span class="glyphicon glyphicon-remove"></span>
									</asp:LinkButton>
								</ItemTemplate>
							</asp:TemplateField>
						</Columns>
					</asp:GridView>
				</div>
			</ContentTemplate>
		</asp:UpdatePanel>
	</div>

	<!--Modale di inserimento e editing delle esenzioni-->
	<div class="modal fade" id="modaleEsenzioni" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" data-backdrop="static">
		<div class="modal-dialog" role="document">
			<asp:UpdatePanel ID="updModaleEsenzione" runat="server" ViewStateMode="Disabled" EnableViewState="false" UpdateMode="Always">
				<ContentTemplate>
					<div class="modal-content">
						<div class="modal-header">
							<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
							<asp:Label runat="server" ID="modalTitle" class="modal-title h4" Text="Inserimento esenzione" />
						</div>
						<div class="modal-body">
							<div runat="server" id="divModalError" class="col-sm-12 alert alert-danger" visible="false" enableviewstate="false">
								<asp:Label ID="lblModalError" runat="server" CssClass="text-danger" />
							</div>

							<div id="modaleProgressbar" class="progress" style="display: none">
								<div class="progress-bar progress-bar-striped active" role="progressbar" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100" style="width: 100%">
									<span class="sr-only"></span>
								</div>
							</div>

							<div class="form-horizontal" id="formInserimentoEsenzione">
								<div class="form-group form-group-sm">
									<label for="txtCodiceEsenzione" class="col-sm-5 control-label">Codice Esenzione</label>
									<div class="col-sm-7">
										<asp:TextBox EnableViewState="False" ID="txtCodiceEsenzione" ClientIDMode="Static" runat="server" CssClass="form-control" placeholder="Codice" />
										<asp:RequiredFieldValidator ErrorMessage="campo obbligatorio" CssClass="text-danger small" ControlToValidate="txtCodiceEsenzione" runat="server" Display="Dynamic" />
									</div>
								</div>
								<div class="form-group form-group-sm">
									<label for="txtCodiceDiagnosi" class="col-sm-5 control-label">Codice diagnosi</label>
									<div class="col-sm-7">
										<asp:TextBox EnableViewState="false" ID="txtCodiceDiagnosi" ClientIDMode="Static" runat="server" CssClass="form-control" placeholder="Codice diagnosi" />
									</div>
								</div>
								<div class="form-group form-group-sm">
									<label for="txtPatologica" class="col-sm-5 control-label">Per patologia</label>
									<div class="col-sm-7">
										<asp:CheckBox Text="" ID="chkPatologica" runat="server" />
									</div>
								</div>
								<div class="form-group form-group-sm">
									<label for="txtDataInizioValidita" class="col-sm-5 control-label">Data inizio validità</label>
									<div class="col-sm-7">
										<asp:TextBox EnableViewState="false" MaxLength="16" ID="txtDataInizioValidita" ClientIDMode="Static" runat="server" CssClass="form-control form-control-dataPicker" placeholder="Data inizio validità" />
										<asp:RequiredFieldValidator ErrorMessage="campo obbligatorio" CssClass="text-danger small" ControlToValidate="txtDataInizioValidita" runat="server" Display="Dynamic" />
										<asp:RegularExpressionValidator ErrorMessage="Data non valida" Display="Dynamic" CssClass="text-danger small" ControlToValidate="txtDataInizioValidita" runat="server" ValidationExpression="(0?[1-9]|[12][0-9]|3[01])[/-](0?[1-9]|1[0-2])[/-](1[89][0-9]{2}|[23][0-9]{3})?" />
									</div>
									<%--\s([0-9]|[01][0-9]|2[0-3]):[0-5][0-9](:[0-5][0-9])--%>
								</div>
								<div class="form-group form-group-sm">
									<label for="txtDataFineValidita" class="col-sm-5 control-label">Data fine validità</label>
									<div class="col-sm-7">
										<asp:TextBox EnableViewState="false" MaxLength="16" ID="txtDataFineValidita" ClientIDMode="Static" runat="server" CssClass="form-control form-control-dataPicker" placeholder="Data fine validità" />
										<asp:RegularExpressionValidator ErrorMessage="Data non valida" Display="Dynamic" CssClass="text-danger small" ControlToValidate="txtDataFineValidita" runat="server" ValidationExpression="(0?[1-9]|[12][0-9]|3[01])[/-](0?[1-9]|1[0-2])[/-](1[89][0-9]{2}|[23][0-9]{3})?" />
									</div>
								</div>
								<%--<div class="form-group form-group-sm">
                                    <label for="txtNumeroAutorizzazioneEsenzione" class="col-sm-5 control-label">Numero autorizzazione</label>
                                    <div class="col-sm-7">
                                        <asp:TextBox EnableViewState="false" ID="txtNumeroAutorizzazioneEsenzione" ClientIDMode="Static" runat="server" CssClass="form-control" placeholder="Numero autorizzazione" />
                                    </div>
                                </div>--%>

								<%--<div class="form-group form-group-sm">
                                    <label for="txtTestoEsenzione" class="col-sm-5 control-label">Testo</label>
                                    <div class="col-sm-7">
                                        <asp:TextBox EnableViewState="false" ID="txtTestoEsenzione" ClientIDMode="Static" runat="server" CssClass="form-control" Rows="5" TextMode="MultiLine" placeholder="Testo" />
                                    </div>
                                </div>--%>
								<%-- <div class="form-group form-group-sm">
                                    <label for="txtCodiceDescrizioneEsenzione" class="col-sm-5 control-label">Codice della descrizione</label>
                                    <div class="col-sm-7">
                                        <asp:TextBox EnableViewState="false" ID="txtCodiceDescrizioneEsenzione" ClientIDMode="Static" runat="server" CssClass="form-control" placeholder="Codice della descrizione" />
                                    </div>
                                </div>--%>
								<div class="form-group form-group-sm">
									<label for="txtDescrizioneEsenzione" class="col-sm-5 control-label">Descrizione</label>
									<div class="col-sm-7">
										<asp:TextBox EnableViewState="false" ID="txtDescrizioneEsenzione" ClientIDMode="Static" runat="server" CssClass="form-control" Rows="5" TextMode="MultiLine" placeholder="Descrizione" />
									</div>
								</div>
								<div class="form-group form-group-sm">
									<label for="txtNoteAggiuntive" class="col-sm-5 control-label">Note aggiuntive</label>
									<div class="col-sm-7">
										<asp:TextBox EnableViewState="false" ID="txtNoteAggiuntive" ClientIDMode="Static" runat="server" CssClass="form-control" Rows="5" TextMode="MultiLine" placeholder="Note aggiuntive" />
									</div>
								</div>
								<%-- <div class="form-group form-group-sm">
                                    <label for="txtDecodificaEsenzioneDiagnosi" class="col-sm-5 control-label">Decodifica</label>
                                    <div class="col-sm-7">
                                        <asp:TextBox EnableViewState="false" ID="txtDecodificaEsenzioneDiagnosi" ClientIDMode="Static" runat="server" CssClass="form-control" placeholder="Decodifica" />
                                    </div>
                                </div>--%>
								<%--<div class="form-group form-group-sm">
									<label for="txtAttributoEsenzioneDiagnosi" class="col-sm-5 control-label">Attributo esenzione diagnosi</label>
									<div class="col-sm-7">
										<asp:TextBox EnableViewState="false" ID="txtAttributoEsenzioneDiagnosi" ClientIDMode="Static" runat="server" CssClass="form-control" placeholder="Attributo esenzione diagnosi" />
									</div>
								</div>--%>
							</div>
						</div>
						<div class="modal-footer">
							<div class="btn-group pull-left" role="group">
								<asp:Button ID="btnCaricaEsenzioni" Text="Carica esenzioni" runat="server" CssClass="btn btn-primary" CausesValidation="false" OnClientClick=" $('#modaleEsenzioni').modal('hide');" />
							</div>
							<div class="btn-group pull-right" role="group">
								<button type="button" class="btn btn-default" data-dismiss="modal">Annulla</button>
								<asp:Button ID="btnSalva" Text="Salva" runat="server" CssClass="btn btn-primary" OnClientClick="DisabledFormInput();" CausesValidation="false" />
							</div>
						</div>
					</div>

					<script type="text/javascript">
						$(document).ready(function () {
							// CREO I BOOTSTRAP DATETIMEPICKER
							$('.form-control-dataPicker').datetimepicker({
								format: "DD/MM/YYYY", //Solo DATA, Senza selezione delle ore.
								showTodayButton: true,
								minDate: "01/01/1900"
							});
						});
                    </script>
				</ContentTemplate>
			</asp:UpdatePanel>
		</div>
	</div>

	<!--Modale di caricamento delle esenzioni-->
	<div class="modal fade" id="modaleCaricamentoEsenzioni" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" data-backdrop="static">
		<div class="modal-dialog modal-lg" role="document">
			<asp:UpdatePanel ID="updCaricamentoEsenzioni" runat="server" ViewStateMode="Disabled" EnableViewState="false" UpdateMode="Always">
				<ContentTemplate>
					<div class="modal-content">
						<div class="modal-header">
							<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
							<asp:Label runat="server" ID="Label1" class="modal-title h4" Text="Inserimento esenzione" />
						</div>
						<div class="modal-body">
							<div runat="server" id="div1" class="col-sm-12 alert alert-danger" visible="false" enableviewstate="false">
								<asp:Label ID="Label2" runat="server" CssClass="text-danger" />
							</div>

							<div id="modaleCaricamentoEsenzioniProgressbar" class="progress" style="display: none">
								<div class="progress-bar progress-bar-striped active" role="progressbar" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100" style="width: 100%">
									<span class="sr-only"></span>
								</div>
							</div>

							<div class="form-horizontal" id="formCaricamentoEsenzione">
								<div class="form-group form-group-sm">
									<label for="txtCodice" class="col-sm-1 control-label">Codice</label>
									<div class="col-sm-4">
										<asp:TextBox EnableViewState="False" ID="txtCodice" ClientIDMode="Static" runat="server" CssClass="form-control" placeholder="Codice" />
										<%--<asp:RequiredFieldValidator ErrorMessage="campo obbligatorio" CssClass="text-danger small" ControlToValidate="txtCodice" runat="server" Display="Dynamic" />--%>
									</div>
									<div class="form-group form-group-sm">
										<label for="txtDescrizione" class="col-sm-2 control-label">Descrizione</label>
										<div class="col-sm-4">
											<asp:TextBox EnableViewState="false" ID="txtDescrizione" ClientIDMode="Static" runat="server" CssClass="form-control" placeholder="Codice diagnosi" />
										</div>
									</div>
								</div>
								<%--<div class="form-group form-group-sm">
									<label for="txtDescrizione" class="col-sm-5 control-label">Descrizione</label>
									<div class="col-sm-7">
										<asp:TextBox EnableViewState="false" ID="txtDescrizione" ClientIDMode="Static" runat="server" CssClass="form-control" placeholder="Codice diagnosi" />
									</div>
								</div>--%>
							</div>
						</div>
						<div class="col-sm-12">
							<div class="table-responsive">
								<asp:GridView ID="gvCaricamentoEsenzioni" runat="server" AutoGenerateColumns="False" DataSourceID="odsCaricamentoEsenzioni" EnableViewState="false" AllowPaging="True" CssClass="table table-bordered table-striped table-condensed small" PageSize="15">
									<Columns>
										<asp:BoundField DataField="CodiceEsenzione" HeaderText="Codice Esenzione" SortExpression="CodiceEsenzione"></asp:BoundField>
                                        <asp:BoundField DataField="CodiceDiagnosi" HeaderText="Codice Diagnosi" SortExpression="CodiceDiagnosi"></asp:BoundField>
										<asp:BoundField DataField="TestoEsenzione" HeaderText="Testo Esenzione" SortExpression="TestoEsenzione"></asp:BoundField>
										<asp:BoundField DataField="DecodificaEsenzioneDiagnosi" HeaderText="Decodifica Diagnosi" SortExpression="DecodificaEsenzioneDiagnosi"></asp:BoundField>
										<asp:TemplateField>
											<ItemTemplate>
												<!--Bottone per l'inserimento di una esenzione -->
												<asp:LinkButton CausesValidation="false" CommandName="Inserisci"
													CommandArgument='<%# Eval("CodiceEsenzione") + ";" + Eval("TestoEsenzione") + ";" + Eval("CodiceDiagnosi")%>' Text="" runat="server" ToolTip="Seleziona esenzione" CssClass="btn btn-info btn-xs"
													OnClientClick="javascript: return confirm('Confermi la selezione dell\'esenzione?');">
                                    <span class="glyphicon glyphicon-plus"></span>
												</asp:LinkButton>
											</ItemTemplate>
										</asp:TemplateField>
									</Columns>
								</asp:GridView>
							</div>
						</div>
						<div class="modal-footer">
							<div class="btn-group pull-right" role="group">
								<button type="button" class="btn btn-default" data-dismiss="modal">Annulla</button>
								<asp:Button ID="btnCercaEsenzioni" Text="Cerca" runat="server" CssClass="btn btn-primary" CausesValidation="false" />
							</div>
						</div>
					</div>
					<asp:ObjectDataSource ID="odsCaricamentoEsenzioni" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="EsenzioneOttieniPerCodice" TypeName="SAC.RaccoltaEsenzioni.CustomDataSource">
						<SelectParameters>
							<asp:Parameter Name="Token" Type="Object"></asp:Parameter>
							<asp:ControlParameter ControlID="txtCodice" Type="String" Name="Codice" PropertyName="Text" />
							<asp:ControlParameter ControlID="txtDescrizione" Type="String" Name="Descrizione" PropertyName="Text" />
						</SelectParameters>
					</asp:ObjectDataSource>

				</ContentTemplate>
			</asp:UpdatePanel>
		</div>
	</div>

	<asp:ObjectDataSource ID="odsEsenzioni" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="EsenzioniOttieniPerIdPaziente" TypeName="SAC.RaccoltaEsenzioni.CustomDataSource">
		<SelectParameters>
			<asp:Parameter Name="Token" Type="Object"></asp:Parameter>
			<asp:Parameter DbType="Guid" Name="Id"></asp:Parameter>
		</SelectParameters>
	</asp:ObjectDataSource>

	<%-- Imposto AssemblyVersion per permettere al browser di scaricare la nuova versione dei css dopo un aggionramento. --%>
	<script src="Scripts/CustomCss/esenzioni.js?<%= AssemblyVersion %>"></script>
</asp:Content>
