<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.master" CodeBehind="ImportAgendePrestazioniLhaCup.aspx.vb" Inherits=".ImportAgendePrestazioniLhaCup" %>
<asp:Content ID="headContent" ContentPlaceHolderID="head" runat="Server">
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

	<div class="row">
				<div class="col-sm-12 col-md-8">
					<div class="panel panel-default">
						<div class="panel-heading">
							<h3 class="panel-title">Importazione dell'Agenda: <% GetAgendaDescrizione() %></h3>
						</div>

                        <div>
                            <asp:Button ID="butImporta" runat="server" Text="Importa" />
                            <asp:Button ID="butAnnulla" runat="server" Text="Annulla" />
                         </div>

						<asp:FormView
							runat="server"
							ID="FormView1"
							DataSourceID="DataSourceDetail"
							DefaultMode="Edit">
							<EditItemTemplate>
                                CodiceAgendaCup:
                                <asp:TextBox Text='<%# Bind("CodiceAgendaCup") %>' runat="server" ID="CodiceAgendaCupTextBox" /><br />
                                DescrizioneAgendaCup:
                                <asp:TextBox Text='<%# Bind("DescrizioneAgendaCup") %>' runat="server" ID="DescrizioneAgendaCupTextBox" /><br />
                                TranscodificaCodiceAgendaCup:
                                <asp:TextBox Text='<%# Bind("TranscodificaCodiceAgendaCup") %>' runat="server" ID="TranscodificaCodiceAgendaCupTextBox" /><br />
                                StrutturaErogante:
                                <asp:TextBox Text='<%# Bind("StrutturaErogante") %>' runat="server" ID="StrutturaEroganteTextBox" /><br />
                                DescrizioneStrutturaErogante:
                                <asp:TextBox Text='<%# Bind("DescrizioneStrutturaErogante") %>' runat="server" ID="DescrizioneStrutturaEroganteTextBox" /><br />
                                CodiceSistemaErogante:
                                <asp:TextBox Text='<%# Bind("CodiceSistemaErogante") %>' runat="server" ID="CodiceSistemaEroganteTextBox" /><br />
                                CodiceAziendaErogante:
                                <asp:TextBox Text='<%# Bind("CodiceAziendaErogante") %>' runat="server" ID="CodiceAziendaEroganteTextBox" /><br />
                                MultiErogante:
                                <asp:CheckBox Checked='<%# Bind("MultiErogante") %>' runat="server" ID="MultiEroganteCheckBox" /><br />
                               
                                <!-- <asp:LinkButton runat="server" Text="Update" CommandName="Importa" ID="UpdateButton" CausesValidation="True" />&nbsp;<asp:LinkButton runat="server" Text="Cancel" CommandName="Cancel" ID="UpdateCancelButton" CausesValidation="False" /> -->

                            </EditItemTemplate>
                            <EmptyDataTemplate>
                                <div class="DDNoItem">Elemento non presente.</div>
                            </EmptyDataTemplate>
                        </asp:FormView>

                        <asp:GridView ID="GridViewListaPrestazioni" DataSourceID="DataSourceListaPrestazioni" runat="server" AutoGenerateColumns="False">
                            <Columns>
                                <asp:BoundField DataField="StrutturaErogante" HeaderText="StrutturaErogante" ReadOnly="True" SortExpression="StrutturaErogante"></asp:BoundField>
                                <asp:BoundField DataField="IdPrestazioneCup" HeaderText="IdPrestazioneCup" ReadOnly="True" SortExpression="IdPrestazioneCup"></asp:BoundField>
                                <asp:BoundField DataField="IdPrestazioneErogante" HeaderText="IdPrestazioneErogante" ReadOnly="True" SortExpression="IdPrestazioneErogante"></asp:BoundField>
                                <asp:BoundField DataField="Nome" HeaderText="Nome" ReadOnly="True" SortExpression="Nome"></asp:BoundField>
                                <asp:BoundField DataField="Codice" HeaderText="Codice" ReadOnly="True" SortExpression="Codice"></asp:BoundField>
                                <asp:BoundField DataField="Posizione" HeaderText="Posizione" ReadOnly="True" SortExpression="Posizione"></asp:BoundField>
                                <asp:BoundField DataField="Descrizione" HeaderText="Descrizione" ReadOnly="True" SortExpression="Descrizione"></asp:BoundField>
                                <asp:BoundField DataField="TipoDato" HeaderText="TipoDato" ReadOnly="True" SortExpression="TipoDato"></asp:BoundField>
                                <asp:BoundField DataField="TipoContenuto" HeaderText="TipoContenuto" ReadOnly="True" SortExpression="TipoContenuto"></asp:BoundField>
                                <asp:BoundField DataField="SpecialitaEsameCup" HeaderText="SpecialitaEsameCup" ReadOnly="True" SortExpression="SpecialitaEsameCup"></asp:BoundField>
                                <asp:BoundField DataField="CodiceSistemaErogante" HeaderText="CodiceSistemaErogante" ReadOnly="True" SortExpression="CodiceSistemaErogante"></asp:BoundField>
                                <asp:BoundField DataField="CodiceAziendaErogante" HeaderText="CodiceAziendaErogante" ReadOnly="True" SortExpression="CodiceAziendaErogante"></asp:BoundField>
                            </Columns>
                        </asp:GridView>

                        <div>
                            <asp:Button ID="butImporta2" runat="server" Text="Importa" />
                            <asp:Button ID="butAnnulla2" runat="server" Text="Annulla" />
                         </div>

                    </div>
                </div>
        <!-- Object datasource dettaglio -->
        <asp:ObjectDataSource ID="DataSourceDetail" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="ImportazioneLhaCupDataSetTableAdapters.LHAAgendeTableAdapter">
            <SelectParameters>
                <asp:QueryStringParameter QueryStringField="IdAgenda" Name="Codice" Type="String"></asp:QueryStringParameter>
            </SelectParameters>
        </asp:ObjectDataSource>
        <!-- Object datasource lista delle prestazioni associate all'agenda-->
        <asp:ObjectDataSource ID="DataSourceListaPrestazioni" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="ImportazioneLhaCupDataSetTableAdapters.LHAAgendePrestazioniTableAdapter">
            <SelectParameters>
                <asp:QueryStringParameter QueryStringField="IdAgenda" Name="CodiceAgenda" Type="String"></asp:QueryStringParameter>
            </SelectParameters>
        </asp:ObjectDataSource>


		
	</div>


</asp:Content>
