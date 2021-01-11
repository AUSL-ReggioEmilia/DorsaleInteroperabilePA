<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="SistemiErogantiDetail.aspx.vb" Inherits="PrintDispatcherAdmin.SistemiErogantiDetail" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">

    <div class="row">
        <div class="col-sm-10 col-md-8 col-lg-6">

            <asp:Panel ID="PanelFormView" runat="server">
                <asp:FormView ID="MainFormView" runat="server" DataKeyNames="Id" DataSourceID="MainDataSource" Style="width: 100%;" DefaultMode="Insert">

                    <InsertItemTemplate>
                        <h3 class="page-title">Nuovo sistema erogante</h3>
                        <div class="div-bianco">
                            <div class="form-horizontal form-horizontal-mb-5">
                                <div class="form-group">
                                    <asp:Label Text="Codice (*)" runat="server" AssociatedControlID="txtCodice" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <asp:TextBox ID="txtCodice" runat="server" Text='<%# Bind("Codice") %>' MaxLength="16" CssClass="form-control input-sm" Width="100%" />
                                        <asp:RequiredFieldValidator ID="rfvCodice" runat="server" ControlToValidate="txtCodice" CssClass="text-danger"
                                            ErrorMessage='Campo obbligatorio' Display="Dynamic"></asp:RequiredFieldValidator>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <asp:Label Text="Codice Azienda (*)" runat="server" AssociatedControlID="txtCodiceAzienda" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <asp:TextBox ID="txtCodiceAzienda" runat="server" Text='<%# Bind("CodiceAzienda") %>' MaxLength="16" CssClass="form-control input-sm" Width="100%" />
                                        <asp:RequiredFieldValidator ID="rfvCodiceAzienda" runat="server" ControlToValidate="txtCodiceAzienda" CssClass="text-danger"
                                            ErrorMessage='Campo obbligatorio' Display="Dynamic"></asp:RequiredFieldValidator>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <asp:Label Text="Attivo" runat="server" AssociatedControlID="chkAttivo" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <asp:CheckBox ID="chkAttivo" runat="server" Checked='<%# Bind("Attivo") %>' CssClass="input-sm" Width="100%" />
                                    </div>
                                </div>
                                <div class="form-group">
                                    <asp:Label Text="Descrizione (*)" runat="server" AssociatedControlID="txtDescrizione" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <asp:TextBox ID="txtDescrizione" runat="server" Text='<%# Bind("Descrizione") %>' MaxLength="16" CssClass="form-control input-sm" Width="100%" />
                                        <asp:RequiredFieldValidator ID="rfvDescrizione" runat="server" ControlToValidate="txtCodiceAzienda" CssClass="text-danger"
                                            ErrorMessage='Campo obbligatorio' Display="Dynamic"></asp:RequiredFieldValidator>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="text-right">
                            <asp:Button ID="InsertButton" runat="server" CssClass="btn btn-100 btn-primary btn-sm" CausesValidation="True"
                                CommandName="Insert" CommandArgument="ParentRedirect" Text="Inserisci" />
                            <asp:Button ID="InsertCancelButton" runat="server" CssClass="btn btn-100 btn-secondary btn-sm" CausesValidation="False"
                                CommandName="Cancel" Text="Annulla" />
                        </div>
                    </InsertItemTemplate>

                    <EditItemTemplate>

                        <h3 class="page-title">Dettaglio sistema erogante</h3>

                        <div class="div-bianco">
                            <div class="form-horizontal form-horizontal-mb-5">
                                <div class="form-group">
                                    <asp:Label Text="Codice (*)" runat="server" AssociatedControlID="txtCodice" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <asp:TextBox ID="txtCodice" runat="server" Text='<%# Bind("Codice") %>' MaxLength="16" CssClass="form-control input-sm" Width="100%" />
                                        <asp:RequiredFieldValidator ID="rfvCodice" runat="server" ControlToValidate="txtCodice" CssClass="text-danger"
                                            ErrorMessage='Campo obbligatorio' Display="Dynamic"></asp:RequiredFieldValidator>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <asp:Label Text="Codice Azienda (*)" runat="server" AssociatedControlID="txtCodiceAzienda" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <asp:TextBox ID="txtCodiceAzienda" runat="server" Text='<%# Bind("CodiceAzienda") %>' MaxLength="16" CssClass="form-control input-sm" Width="100%" />
                                        <asp:RequiredFieldValidator ID="rfvCodiceAzienda" runat="server" ControlToValidate="txtCodiceAzienda" CssClass="text-danger"
                                            ErrorMessage='Campo obbligatorio' Display="Dynamic"></asp:RequiredFieldValidator>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <asp:Label Text="Attivo" runat="server" AssociatedControlID="chkAttivo" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <asp:CheckBox ID="chkAttivo" runat="server" Checked='<%# Bind("Attivo") %>' CssClass="input-sm" Width="100%" />
                                    </div>
                                </div>
                                <div class="form-group">
                                    <asp:Label Text="Descrizione (*)" runat="server" AssociatedControlID="txtDescrizione" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <asp:TextBox ID="txtDescrizione" runat="server" Text='<%# Bind("Descrizione") %>' MaxLength="16" CssClass="form-control input-sm" Width="100%" />
                                        <asp:RequiredFieldValidator ID="rfvDescrizione" runat="server" ControlToValidate="txtCodiceAzienda" CssClass="text-danger"
                                            ErrorMessage='Campo obbligatorio' Display="Dynamic"></asp:RequiredFieldValidator>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <%-- Bottoni Elimina    Conferma Annulla Applica --%>
                            <div class="col-sm-12">
                                <div class="pull-left">
                                    <asp:LinkButton ID="UpdateDeleteButton" runat="server" CausesValidation="False" CssClass="btn btn-100 btn-danger btn-sm"
                                        CommandName="Delete" OnClientClick="return confirm('Procedere con la cancellazione del record?');">
                                    <i class="fas fa-trash-alt fa-lg"></i>&nbsp;Elimina</asp:LinkButton>
                                </div>
                                <div class="pull-right">
                                    <asp:Button ID="UpdateButtonOK" runat="server" CausesValidation="True" CssClass="btn btn-100 btn-primary btn-sm"
                                        CommandName="Update" CommandArgument="ParentRedirect" Text="Conferma" data-toggle="popover" data-placement="bottom" data-trigger="hover" data-content="Salva ed Esci" />
                                    <asp:Button ID="UpdateCancelButton" runat="server" CssClass="btn btn-100 btn-secondary btn-sm" CausesValidation="False"
                                        CommandName="Cancel" Text="Annulla" />
                                    <asp:LinkButton ID="UpdateButtonApply" CommandArgument="SelfRedirect" runat="server" CssClass="btn btn-100 btn-primary btn-sm"
                                        CausesValidation="True" CommandName="Update" data-toggle="popover" data-placement="bottom" data-trigger="hover" data-content="Salva">
                                    <i class="far fa-save fa-lg"></i>&nbsp;Applica</asp:LinkButton>
                                </div>
                            </div>
                        </div>
                    </EditItemTemplate>
                </asp:FormView>
            </asp:Panel>
        </div>
    </div>

    <!-- Sezione della lista dei moduli associato al sistema erogante -->
    <div id="divElencoModuli" runat="server">

        <div class="row">
            <div class="col-sm-12">
                <h3>Elenco moduli</h3>
            </div>
        </div>

        <div class="row">
            <div class="col-sm-12">
                <asp:HyperLink ID="lnkNuovo" runat="server" CssClass="btn btn-100 btn-primary btn-sm" data-toggle="popover" data-placement="bottom" data-trigger="hover" data-content="Inserisci un nuovo modulo">
                <i class="fas fa-plus fa-lg"></i>&nbsp;Nuovo</asp:HyperLink>
            </div>
        </div>

        <asp:UpdatePanel ID="UpdatePanelGrid" runat="server">

            <ContentTemplate>
                <asp:UpdateProgress ID="UpdateProgress1" runat="server">
                    <ProgressTemplate>
                        <i>elaborazione in corso...</i>
                    </ProgressTemplate>
                </asp:UpdateProgress>

                <asp:GridView ID="MainListGridView" runat="server" AllowPaging="true" PageSize="100" Width="100%" GridLines="None"
                    DataKeyNames="Id" DataSourceID="MainListDataSource" AutoGenerateColumns="False" AllowSorting="false"
                    CssClass="table table-striped table-bordered table-condensed"
                    EmptyDataText="Nessun dato da visualizzare!">
                    <Columns>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <asp:HyperLink ID="HyperLink1" runat="server" NavigateUrl='<%# GetEditItemNavigateUrl(Eval("Id"), Eval("IdSistemiEroganti"))%>' ToolTip="Naviga al dettaglio" CssClass="center-block">
                                     <i class="fas fa-pencil-alt fa-lg"></i>
                                </asp:HyperLink>
                            </ItemTemplate>
                            <ItemStyle Width="25px" />
                        </asp:TemplateField>
                        <asp:BoundField DataField="TipoModulo" HeaderText="Tipo"></asp:BoundField>
                        <asp:BoundField DataField="FormatoModulo" HeaderText="Formato"></asp:BoundField>
                        <asp:BoundField DataField="NomeDocumento" HeaderText="Nome Documento"></asp:BoundField>
                        <asp:BoundField DataField="OrdineDocumento" HeaderText="Ordine Documento"></asp:BoundField>
                    </Columns>
                </asp:GridView>

                <asp:ObjectDataSource ID="MainListDataSource" runat="server"
                    SelectMethod="GetData" TypeName="DataAccess.SistemiErogantiDatasetTableAdapters.SistemiErogantiModuliListTableAdapter">
                    <SelectParameters>
                        <asp:Parameter Name="IdSistemiEroganti" Type="String" />
                    </SelectParameters>
                </asp:ObjectDataSource>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>
    <asp:ObjectDataSource ID="MainDataSource" runat="server" SelectMethod="GetData" TypeName="DataAccess.SistemiErogantiDatasetTableAdapters.SistemiErogantiSelectTableAdapter"
        DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update">
        <UpdateParameters>
            <asp:Parameter DbType="Guid" Name="Id" />
            <asp:Parameter Name="Codice" Type="String" />
            <asp:Parameter Name="CodiceAzienda" Type="String" />
            <asp:Parameter Name="Descrizione" Type="String" />
            <asp:Parameter Name="Attivo" Type="Boolean" />
            <asp:Parameter Name="UtenteModifica" Type="String" />
        </UpdateParameters>
        <SelectParameters>
            <asp:QueryStringParameter DbType="Guid" Name="Id" QueryStringField="id" />
        </SelectParameters>
        <InsertParameters>
            <asp:Parameter Name="Codice" Type="String" />
            <asp:Parameter Name="CodiceAzienda" Type="String" />
            <asp:Parameter Name="Descrizione" Type="String" />
            <asp:Parameter Name="Attivo" Type="Boolean" />
            <asp:Parameter Name="UtenteInserimento" Type="String" />
        </InsertParameters>
    </asp:ObjectDataSource>
</asp:Content>
