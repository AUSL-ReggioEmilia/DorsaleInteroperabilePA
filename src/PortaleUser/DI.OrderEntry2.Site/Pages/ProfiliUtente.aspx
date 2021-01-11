<%@ Page Title="Order Entry - Configurazione Profili Utente" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
	CodeBehind="ProfiliUtente.aspx.vb" Inherits="DI.OrderEntry.User.ProfiliUtente" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">

	<style type="text/css">
		@media (min-width: 769px) {
			.modal-dialog {
				/*width:900px !important;*/
				width: 90% !important;
			}
		}

		@media (min-width: 970px) {
			.modal-dialog {
				/*width:900px !important;*/
				width: 900px !important;
			}
			.modal-sm {
				/*width:900px !important;*/
				width: 600px !important;
			}
		}
	</style>

	<div class="row" id="divErrorMessage" runat="server" visible="false" enableviewstate="false">
		<div class="col-sm-12">
			<div class="alert alert-danger">
				<asp:Label ID="lblError" runat="server" CssClass="Error text-danger" EnableViewState="false" />
			</div>
		</div>
	</div>


	<div class="row">
		<div class="col-sm-12">
			<label class="label label-default">Profili personali</label>
			<div class="panel panel-default small">
				<div class="panel-body">
					<div class="form-horizontal">
						<div class="col-sm-5">
							<div class="form-group form-group-sm">
								<div class="col-sm-12">
									<asp:TextBox runat="server" ID="txtProfiliDescrizione" CssClass="form-control" placeholder="Filtra i profili per descrizione" />
								</div>
							</div>
						</div>
						<div class="col-sm-3">
							<div class="form-group form-group-sm">
								<div class="col-sm-12">
									<asp:Button runat="server" ID="btnCercaProfilo" Text="Cerca" ToolTip="Cerca profilo" CssClass="btn btn-sm btn-primary" />
									<asp:Button runat="server" ID="btnNuovoProfilo" Text="Nuovo" ToolTip="Nuovo profilo" CssClass="btn btn-sm btn-default" />
								</div>

							</div>

						</div>
					</div>
				</div>
			</div>
		</div>
	</div>

	<div class="row">
		<div class="col-sm-12">
			<asp:GridView ID="gvProfili" runat="server" AutoGenerateColumns="False" CssClass="table table-bordered table-hover table-condensed" EmptyDataText="Nessun Risultato" DataSourceID="odsProfili">
				<Columns>
					<asp:TemplateField ItemStyle-Width="30px">
						<ItemTemplate>
							<asp:LinkButton ID="btnModificaProfilo" ToolTip="Modifica il profilo" CommandName="ModificaProfilo" ClientIDMode="Static" runat="server" CssClass="btn btn-sm btn-default" CommandArgument='<%# Eval("Id") %>' data-descrizioneprofilo='<%# Eval("Descrizione") %>'>
							<span class="glyphicon glyphicon-th-list"></span>
							</asp:LinkButton>
						</ItemTemplate>
					</asp:TemplateField>
					<asp:TemplateField ItemStyle-Width="30px">
						<ItemTemplate>
							<asp:LinkButton ID="btnModificaPrestazioniProfilo" ToolTip="Modifica le prestazioni del profilo" CommandName="ModificaPrestazioniProfilo" ClientIDMode="Static" runat="server" CssClass="btn btn-sm btn-default" CommandArgument='<%# Eval("Id")%>' data-descrizioneprofilo='<%# Eval("Descrizione") %>'>
							<span class="glyphicon glyphicon-cog"></span>
							</asp:LinkButton>
						</ItemTemplate>
					</asp:TemplateField>
					<asp:BoundField DataField="Codice" HeaderText="Codice" SortExpression="Codice"></asp:BoundField>
					<asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione"></asp:BoundField>
					<asp:TemplateField ItemStyle-Width="2%">
						<ItemTemplate>
							<asp:LinkButton ID="btnRimuoviProfilo" ToolTip="Rimuovi il profilo" CommandName="EliminaProfilo" runat="server" CssClass="btn btn-sm btn-danger" CommandArgument='<%# Eval("Id")%>' OnClientClick="return confirm ('Sicuro di voler eliminare definitivamente questo profilo?')" Text="Elimina">
								<span class="glyphicon glyphicon-remove"></span>
							</asp:LinkButton>
						</ItemTemplate>
					</asp:TemplateField>
				</Columns>
			</asp:GridView>
			<asp:ObjectDataSource runat="server" ID="odsProfili" DeleteMethod="DeleteData" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="CustomDataSource+ProfiliUtente" InsertMethod="UpdateData" UpdateMethod="UpdateData">
				<DeleteParameters>
					<asp:Parameter Name="idProfilo" Type="String"></asp:Parameter>
				</DeleteParameters>
				<InsertParameters>
					<asp:Parameter Name="idProfilo" Type="String"></asp:Parameter>
					<asp:Parameter Name="descrizione" Type="String"></asp:Parameter>
				</InsertParameters>
				<SelectParameters>
					<asp:ControlParameter ControlID="txtProfiliDescrizione" PropertyName="Text" DefaultValue="" Name="codiceDescrizione" Type="String" ConvertEmptyStringToNull="False"></asp:ControlParameter>
				</SelectParameters>
				<UpdateParameters>
					<asp:Parameter Name="idProfilo" Type="String"></asp:Parameter>
					<asp:Parameter Name="descrizione" Type="String"></asp:Parameter>
				</UpdateParameters>
			</asp:ObjectDataSource>
		</div>
	</div>

	<div class="modal fade" runat="server" id="modalModificaPrestazioniProfilo" clientidmode="Static" role="dialog" aria-labelledby="myModalLabel">
		<div class="modal-dialog" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
					<h4 class="modal-title" id="modalModificaPrestazioniProfiloTitle" runat="server"></h4>
				</div>
				<div class="modal-body">
					<asp:UpdatePanel runat="server">
						<ContentTemplate>
							<div class="row">
								<div class="col-sm-5">
									<div class="panel panel-default">
										<div class="panel-heading" id="divHeadingPanel">
											Prestazioni
										</div>
										<div class="panel-body small">
											<div class="row">
												<div class="col-sm-12">
													<asp:GridView ClientIDMode="static" ID="gvPrestazioniPerProfilo" DataKeyNames="Id" EmptyDataText="Nessun risultato" runat="server" AutoGenerateColumns="False" DataSourceID="odsPrestazioniPerProfilo" CssClass="table table-bordered table-condensed">
														<Columns>
															<asp:TemplateField HeaderStyle-Width="30px">
																<ItemTemplate>
																	<asp:CheckBox CssClass="ckChild" runat="Server" />
																</ItemTemplate>
																<HeaderTemplate>
																	<asp:CheckBox ClientIDMode="Static" CssClass="ckSelect" runat="Server" />
																</HeaderTemplate>
															</asp:TemplateField>
															<asp:BoundField DataField="Codice" HeaderText="Codice" SortExpression="Codice"></asp:BoundField>
															<asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione"></asp:BoundField>
															<asp:TemplateField HeaderText="Sistema">
																<ItemTemplate>
																	<%# GetAziendaSistema(Eval("SistemaErogante")) %>
																</ItemTemplate>
															</asp:TemplateField>
														</Columns>
													</asp:GridView>
													<asp:ObjectDataSource ID="odsPrestazioniPerProfilo" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetPrestazioniByProfilo" TypeName="CustomDataSource+Prestazioni" DeleteMethod="DeletePrestazioneDaProfilo" UpdateMethod="InsertPrestazioniInProfilo">
														<DeleteParameters>
															<asp:Parameter Name="idProfilo" Type="String"></asp:Parameter>
															<asp:Parameter Name="idPrestazioni" Type="String"></asp:Parameter>
														</DeleteParameters>
														<SelectParameters>
															<asp:Parameter Name="idProfilo" Type="String"></asp:Parameter>
														</SelectParameters>
														<UpdateParameters>
															<asp:Parameter Name="idProfilo" Type="String"></asp:Parameter>
															<asp:Parameter Name="idPrestazioni" Type="String"></asp:Parameter>
														</UpdateParameters>
													</asp:ObjectDataSource>
												</div>
											</div>

										</div>
									</div>
								</div>
								<div class="col-sm-1 text-center" style="margin-top: 20px;">


									<asp:LinkButton runat="server" ToolTip="Aggiungi le prestazioni selezionate" ID="btnAggiungiPrestazioni" CssClass="leftArrowButton btn btn-default btn-sm btn-block"><span class="glyphicon glyphicon-arrow-left" aria-hidden="true"></span></asp:LinkButton>
									<asp:LinkButton runat="server" ToolTip="Rimuovi le prestazioni selezionate" ID="btnRimuoviPrestazioni" CssClass="rightArrowButton btn btn-default btn-sm btn-block"><span class="glyphicon glyphicon-arrow-right" aria-hidden="true"></span></asp:LinkButton>

								</div>
								<div class="col-sm-6">
									<div class="panel panel-default ">
										<div class="panel-heading">
											Cerca prestazioni
										</div>
										<div class="panel-body small">
											<div class="form">
												<div class="row">
													<div class="col-sm-6">
														<%--Selezione Erogante --%>
														<div class="form-group form-group-sm">
															<asp:Label AssociatedControlID="ddlsistemiEroganti" runat="server" Text="Erogante">Erogante</asp:Label>
															<asp:DropDownList ID="ddlSistemiEroganti" DataTextField="Key" DataValueField="Key" runat="server" DataSourceID="odsSistemiEroganti" AppendDataBoundItems="true" CssClass="form-control" AutoPostBack="false">
															</asp:DropDownList>
                                                            <asp:ObjectDataSource ID="odsSistemiEroganti" runat="server" SelectMethod="GetSistemiEroganti" TypeName="DI.OrderEntry.User.LookupManager"></asp:ObjectDataSource>
														</div>
													</div>
													<div class="col-sm-4">
														<%--Filtro codice/descrizione --%>
														<div class="form-group form-group-sm">
															<asp:Label runat="server" AssociatedControlID="txtDescrizione">Codice/Descrizione</asp:Label>
															<asp:TextBox runat="server" ID="txtDescrizione" CssClass="form-control" placeholder="Codice/Descrizione" />
														</div>
													</div>
													<%--Pulsante cerca --%>
													<div class="col-sm-2">
														<asp:Button runat="server" ID="btnCercaPrestazioni" Text="Cerca" CssClass="searchButton btn btn-sm btn-default" Style="margin-top: 15px;" />
													</div>
												</div>
												<div class="row">
													<div class="col-sm-12">
														<asp:GridView ID="gvPrestazioniErogante" EmptyDataText="Nessun risultato" runat="server" AutoGenerateColumns="False" DataSourceID="odsPrestazioniPerErogante" CssClass="table table-bordered table-condensed" DataKeyNames="Id">
															<Columns>
																<asp:TemplateField HeaderStyle-Width="30px">
																	<ItemTemplate>
																		<asp:CheckBox CssClass="ckChild" Visible='<%# GetCheckboxVisibility(Eval("Codice"), GetAziendaSistema(Eval("SistemaErogante")))%>' runat="Server" />
																	</ItemTemplate>
																	<HeaderTemplate>
																		<asp:CheckBox ClientIDMode="Static" ID="chkboxPrestazioniEroganteMaster" CssClass="ckSelect" runat="Server" />
																	</HeaderTemplate>
																</asp:TemplateField>
																<asp:BoundField DataField="Codice" HeaderText="Codice" SortExpression="Codice"></asp:BoundField>
																<asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione"></asp:BoundField>
																<%--<asp:TemplateField HeaderText="Sistema">
																	<ItemTemplate>
																		<%# GetAziendaSistema(Eval("SistemaErogante")) %>
																	</ItemTemplate>
																</asp:TemplateField>--%>
															</Columns>
														</asp:GridView>
														<asp:ObjectDataSource ID="odsPrestazioniPerErogante" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetListaPrestazioniProfilo" TypeName="CustomDataSource+Prestazioni">
															<SelectParameters>
																<asp:ControlParameter ControlID="txtDescrizione" PropertyName="Text" Name="descrizione" Type="String"></asp:ControlParameter>
																<asp:ControlParameter ControlID="ddlSistemiEroganti" PropertyName="SelectedValue" Name="erogante" Type="String"></asp:ControlParameter>
															</SelectParameters>
														</asp:ObjectDataSource>
													
													</div>
												</div>

											</div>
											
										</div>
									</div>
								</div>
							</div>

							<script type="text/javascript">
								function pageLoad() {
									$(".ckSelect").children(":checkbox").click(function () {
										$(this).closest('div').find('input:checkbox').not(this).prop('checked', this.checked);
									});
									$('#modalModificaPrestazioniProfilo').modal({
										keyboard: false,
										show: false
										})
								};
							</script>
						</ContentTemplate>
					</asp:UpdatePanel>
					
				</div>
				<div class="modal-footer">
					<asp:LinkButton runat="server" CssClass="btn btn-default" Text="Annulla" CommandName="Cancel" ID="UpdateCancelButton" CausesValidation="False" />
				</div>
			</div>
		</div>
	</div>

	<div class="modal fade bs-example-modal-sm" runat="server" id="modalNuovoeModificaProfilo" clientidmode="Static" role="dialog" aria-labelledby="myModalLabel">
		<div class="modal-dialog modal-sm" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
					<h4 class="modal-title" runat="server" id="modalProfiloTitle"></h4>
				</div>
				<div class="modal-body">
					<div class="row">
						<div class="form-horizontal">
							<asp:FormView ID="fvProfilo" runat="server" DataSourceID="odsProfilo" RenderOuterTable="false">
								<EditItemTemplate>
									<div class="form-group form-group-sm">
										<asp:Label AssociatedControlID="CodiceTextBox" CssClass="col-sm-3 control-label" runat="server" Text="Codice:"></asp:Label>
										<div class="col-sm-7">
											<asp:TextBox Text='<%# Eval("Codice") %>' CssClass="form-control" runat="server" Enabled="false" ID="CodiceTextBox" />
										</div>
									</div>
									<br>
									</br>
										<div class="form-group form-group-sm">
											<asp:Label AssociatedControlID="DescrizioneTextBox" CssClass="col-sm-3 control-label" runat="server" Text="Descrizione:"></asp:Label>
											<div class="col-sm-7">
												<asp:TextBox Text='<%# Bind("Descrizione") %>' CssClass="form-control" runat="server" ID="DescrizioneTextBox" />
											</div>
										</div>
								</EditItemTemplate>
								<InsertItemTemplate>
									<div class="form-group form-group-sm">
										<asp:Label AssociatedControlID="DescrizioneTextBox" CssClass="col-sm-3 control-label" runat="server" Text="Descrizione:"></asp:Label>
										<div class="col-sm-9">
											<asp:TextBox Text='<%# Bind("Descrizione") %>' CssClass="form-control" runat="server" ID="DescrizioneTextBox" />
										</div>
									</div>
									<hr />
									<div class="form-group form-group-sm text-right">
										<div class="col-sm-12">
											<asp:LinkButton runat="server" Text="Inserisci" CssClass="btn btn-primary" CommandName="Insert" ID="InsertButton" CausesValidation="True" />
											<asp:LinkButton runat="server" Text="Annulla" CssClass="btn btn-default" CommandName="Cancel" ID="InsertCancelButton" CausesValidation="False" />
										</div>
									</div>
								</InsertItemTemplate>

							</asp:FormView>
							<script type="text/javascript">
								function pageLoad() {
									$('#modalNuovoeModificaProfilo').modal({
										keyboard: false,
										show: false
										})
								};
							</script>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
	<asp:ObjectDataSource ID="odsProfilo" runat="server" DeleteMethod="DeleteData" InsertMethod="UpdateData" OldValuesParameterFormatString="original_{0}" SelectMethod="GetDataById" TypeName="CustomDataSource+ProfiliUtente" UpdateMethod="UpdateData">
		<DeleteParameters>
			<asp:Parameter Name="idProfilo" Type="String"></asp:Parameter>
		</DeleteParameters>
		<InsertParameters>
			<asp:Parameter Name="idProfilo" Type="String"></asp:Parameter>
			<asp:Parameter Name="descrizione" Type="String"></asp:Parameter>
		</InsertParameters>
		<SelectParameters>
			<asp:Parameter Name="idProfilo" Type="String"></asp:Parameter>
		</SelectParameters>
		<UpdateParameters>
			<asp:Parameter Name="idProfilo" Type="String"></asp:Parameter>
			<asp:Parameter Name="descrizione" Type="String"></asp:Parameter>
		</UpdateParameters>
	</asp:ObjectDataSource>

</asp:Content>