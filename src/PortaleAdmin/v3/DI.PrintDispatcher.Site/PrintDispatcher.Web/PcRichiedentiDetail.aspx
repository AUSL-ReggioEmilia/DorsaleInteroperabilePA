<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="PcRichiedentiDetail.aspx.vb" Inherits="PrintDispatcherAdmin.PcRichiedentiDetail" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">

    <div class="row">
        <div class="col-sm-10 col-md-8 col-lg-6">

            <asp:Panel ID="PanelFormView" runat="server">
                <asp:FormView ID="MainFormView" runat="server" DataKeyNames="Id" DataSourceID="MainDataSource" Style="width: 100%;" DefaultMode="Insert">

                    <InsertItemTemplate>
                        <h3 class="page-title">Nuovo pc richiedente</h3>
                        
                        <div class="div-bianco">
                            <div class="form-horizontal form-horizontal-detail">
                                <div class="form-group">
                                    <asp:Label Text="Nome (*)" runat="server" AssociatedControlID="txtNome" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <asp:TextBox ID="txtNome" runat="server" Text='<%# Bind("Nome") %>' MaxLength="128" CssClass="form-control input-sm" Width="100%" />
                                        <asp:RequiredFieldValidator ID="rfvNome" runat="server" ControlToValidate="txtNome" CssClass="text-danger"
                                            ErrorMessage='Campo obbligatorio' Display="Dynamic"></asp:RequiredFieldValidator>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <%-- Bottoni Inserisci e Annulla --%>
                            <div class="col-sm-12">
                                <div class="text-right">
                                    <asp:Button ID="InsertButton" runat="server" CssClass="btn btn-100 btn-primary btn-sm" CausesValidation="True"
                                        CommandName="Insert" CommandArgument="ParentRedirect" Text="Inserisci" />
                                    <asp:Button ID="InsertCancelButton" runat="server" CssClass="btn btn-100 btn-secondary btn-sm" CausesValidation="False"
                                        CommandName="Cancel" Text="Annulla" />
                                </div>
                            </div>
                        </div>
                    </InsertItemTemplate>

                    <EditItemTemplate>

                        <h3 class="page-title">Dettaglio pc richiedente</h3>
                        <div class="div-bianco">

                            <div class="form-horizontal form-horizontal-detail">
                                <div class="form-group">
                                    <asp:Label Text="Nome (*)" runat="server" AssociatedControlID="txtNome" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <asp:TextBox ID="txtNome" runat="server" Text='<%# Bind("Nome") %>' MaxLength="128" CssClass="form-control input-sm" Width="100%" />
                                        <asp:RequiredFieldValidator ID="rfvNome" runat="server" ControlToValidate="txtNome" CssClass="text-danger"
                                            ErrorMessage='Campo obbligatorio' Display="Dynamic"></asp:RequiredFieldValidator>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-sm-12">
                                <div class="pull-left">
                                    <asp:LinkButton ID="UpdateDeleteButton" runat="server" CssClass="btn btn-100 btn-danger btn-sm" CausesValidation="False"
                                        CommandName="Delete" OnClientClick="return confirm('Procedere con la cancellazione del record?');">
                                        <i class="fas fa-trash-alt fa-lg"></i>&nbsp;Elimina</asp:LinkButton>
                                </div>

                                <div class="pull-right">
                                    <asp:Button ID="UpdateButtonOK" runat="server" CssClass="btn btn-100 btn-primary btn-sm" CausesValidation="True"
                                        CommandName="Update" CommandArgument="ParentRedirect" Text="Conferma" data-toggle="popover" data-placement="bottom" data-trigger="hover" data-content="Salva ed Esci"/>
                                    <asp:Button ID="UpdateCancelButton" runat="server" CssClass="btn btn-100 btn-secondary btn-sm" CausesValidation="False"
                                        CommandName="Cancel" Text="Annulla" />
                                    <asp:LinkButton ID="UpdateButtonApply" runat="server" CssClass="btn btn-100 btn-primary btn-sm" CausesValidation="True"
                                        CommandName="Update" CommandArgument="SelfRedirect" data-toggle="popover" data-placement="bottom" data-trigger="hover" data-content="Salva">
                                        <i class="far fa-save fa-lg"></i>&nbsp;Applica</asp:LinkButton>
                                </div>
                            </div>
                        </div>
                    </EditItemTemplate>
                </asp:FormView>
            </asp:Panel>
        </div>
    </div>

    <div id="divElencoStampanti" runat="server">

        <!-- Sezione lista delle stampanti associate al Pc richiedente -->
        <div class="row">
            <div class="col-sm-12">
                <h3>Elenco stampanti</h3>
            </div>
        </div>

        <asp:UpdateProgress ID="UpdateProgress1" runat="server">
            <ProgressTemplate>
                <i>elaborazione in corso...</i>
            </ProgressTemplate>
        </asp:UpdateProgress>

        <div class="row">
            <div class="col-sm-12">
                <asp:HyperLink ID="lnkNuovo" runat="server" CssClass="btn btn-100 btn-primary btn-sm" data-toggle="popover" data-placement="bottom" data-trigger="hover" data-content="Inserisci una nuova stampante">
                            <i class="fas fa-plus fa-lg"></i>&nbsp;Nuovo
                </asp:HyperLink>
            </div>
        </div>


        <asp:UpdatePanel ID="UpdatePanelGrid" runat="server">
            <ContentTemplate>
                <asp:GridView ID="MainListGridView" runat="server"
                    DataKeyNames="Id" DataSourceID="MainListDataSource" AutoGenerateColumns="False" AllowSorting="false" Width="100%" GridLines="None"
                    CssClass="table table-striped table-bordered table-condensed" EmptyDataText="Nessun record.">
                    <Columns>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <asp:HyperLink ID="HyperLink1" runat="server" NavigateUrl='<%# GetEditItemNavigateUrl(Eval("Id"), Eval("IdPcRichiedenti"))%>' ToolTip="Naviga al dettaglio">
                                    <i class="fas fa-pencil-alt fa-lg"></i>
                                </asp:HyperLink>
                            </ItemTemplate>
                            <ItemStyle Width="25px" />
                        </asp:TemplateField>
                        <asp:BoundField DataField="ServerDiStampa" HeaderText="Server di stampa" SortExpression="ServerDiStampa"></asp:BoundField>
                        <asp:BoundField DataField="Stampante" HeaderText="Stampante" SortExpression="Stampante"></asp:BoundField>
                        <asp:BoundField DataField="TipiStampanteDescrizione" HeaderText="Tipo Stampante"></asp:BoundField>
                        <asp:BoundField DataField="TipoModulo" HeaderText="Tipo Modulo"></asp:BoundField>
                        <asp:BoundField DataField="FormatoModulo" HeaderText="Formato Modulo"></asp:BoundField>
                        <asp:BoundField DataField="ServerVirtuale" HeaderText="Server Virtuale"></asp:BoundField>
                    </Columns>
                </asp:GridView>

                <asp:ObjectDataSource ID="MainListDataSource" runat="server"
                    SelectMethod="GetData" TypeName="DataAccess.PcRichiedentiDatasetTableAdapters.PcRichiedentiStampantiListTableAdapter">
                    <SelectParameters>
                        <asp:Parameter Name="IdPcRichiedenti" Type="String" />
                    </SelectParameters>
                </asp:ObjectDataSource>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>

    <asp:ObjectDataSource ID="MainDataSource" runat="server"
        SelectMethod="GetData" TypeName="DataAccess.PcRichiedentiDataSetTableAdapters.PcRichiedentiSelectTableAdapter"
        DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update">
        <InsertParameters>
            <asp:Parameter Name="UtenteInserimento" Type="String"></asp:Parameter>
            <asp:Parameter Name="Nome" Type="String"></asp:Parameter>
        </InsertParameters>
        <SelectParameters>
            <asp:QueryStringParameter QueryStringField="Id" DbType="Guid" Name="Id"></asp:QueryStringParameter>
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter DbType="Guid" Name="Id"></asp:Parameter>
            <asp:Parameter Name="UtenteModifica" Type="String"></asp:Parameter>
            <asp:Parameter Name="Nome" Type="String"></asp:Parameter>
        </UpdateParameters>
    </asp:ObjectDataSource>
</asp:Content>
