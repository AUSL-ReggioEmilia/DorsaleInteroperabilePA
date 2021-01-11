<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="SistemiErogantiList.aspx.vb" Inherits="PrintDispatcherAdmin.SistemiErogantiList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>

            <div class="div-bianco">

                <h3 class="page-title">Elenco sistemi eroganti</h3>

                <div class="div-grigio" id="panelFiltri" runat="server">

                    <div class="row">
                        <%-- Codice Sistema --%>
                        <div class="col-sm-4 col-md-3">
                            <div class="form-group form-group-sm">
                                <asp:Label ID="lblCodice" runat="server" Text="Codice Sistema" CssClass="control-label col-sm-12 font-weight-bold"></asp:Label>
                                <div class="col-sm-12">
                                    <asp:TextBox ID="txtCodice" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                        </div>
                        <%-- Codice Azienda --%>
                        <div class="col-sm-4 col-md-3">
                            <div class="form-group form-group-sm">
                                <asp:Label ID="lblCodiceAzienda" runat="server" Text="Codice Azienda" CssClass="control-label col-sm-12 font-weight-bold"></asp:Label>
                                <div class="col-sm-12">
                                    <asp:TextBox ID="txtCodiceAzienda" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                        </div>
                        <%-- Attivo --%>
                        <div class="col-sm-4 col-md-3">
                            <div class="form-group form-group-sm">
                                <asp:Label ID="lblStato" runat="server" Text="Attivo" CssClass="control-label col-sm-12 font-weight-bold"></asp:Label>
                                <div class="col-sm-12">
                                    <asp:DropDownList ID="ddlStato" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="2" Text="Tutti" Selected="True" />
                                        <asp:ListItem Value="1" Text="Si" />
                                        <asp:ListItem Value="0" Text="No" />
                                    </asp:DropDownList>
                                </div>
                            </div>
                        </div>

                        <%-- Bottoni Cerca-Annulla --%>
                        <div class="col-sm-12 col-md-3 custom-mt-22 text-right">
                            <asp:LinkButton ID="btnCerca" CssClass="btn btn-100 btn-primary btn-sm" runat="server">
                            <i class='fas fa-search fa-lg'></i>&nbsp;Cerca</asp:LinkButton>
                            <asp:LinkButton ID="btnFiltroOff" runat="server" class="btn btn-100 btn-default btn-sm"
                                data-toggle="popover" data-placement="bottom" data-trigger="hover" data-content="Ripristina filtri">
                            <i class="fas fa-undo-alt fa-lg"></i>&nbsp;Annulla</asp:LinkButton>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row">
                <%-- BTN Nuovo sistema erogante --%>
                <div class="col-sm-12">
                    <asp:HyperLink ID="lnkNuovo" runat="server" NavigateUrl="SistemiErogantiDetail.aspx" CssClass="btn btn-100 btn-primary btn-sm"
                        data-toggle="popover" data-placement="bottom" data-trigger="hover" data-content="Inserisci un nuovo Sitema Erogante">
                            <i class="fas fa-plus fa-lg"></i>&nbsp;Nuovo</asp:HyperLink>
                </div>
            </div>

            <asp:UpdateProgress ID="UpdateProgress1" runat="server">
                <ProgressTemplate>
                    <i>elaborazione in corso...</i>
                </ProgressTemplate>
            </asp:UpdateProgress>

            <asp:GridView ID="MainListGridView" runat="server" DataKeyNames="Id" DataSourceID="MainListDataSource"
                AllowSorting="true" AllowPaging="true" PageSize="100" Width="100%"
                AutoGenerateColumns="False" GridLines="None"
                CssClass="table table-striped table-bordered table-condensed" EmptyDataText="Nessun record.">
                <Columns>
                    <asp:TemplateField>
                        <ItemTemplate>
                            <asp:HyperLink ID="HyperLink1" runat="server" NavigateUrl='<%# GetEditItemNavigateUrl(Eval("Id"))%>' ToolTip="Naviga al dettaglio" CssClass="center-block">
                                    <i class="fas fa-pencil-alt fa-lg"></i>
                            </asp:HyperLink>
                        </ItemTemplate>
                        <ItemStyle Width="25px" />
                    </asp:TemplateField>
                    <asp:BoundField DataField="Codice" HeaderText="Codice" SortExpression="Codice"></asp:BoundField>
                    <asp:BoundField DataField="CodiceAzienda" HeaderText="Codice Azienda" SortExpression="CodiceAzienda"></asp:BoundField>
                    <asp:CheckBoxField DataField="Attivo" HeaderText="Attivo" SortExpression="Attivo" ItemStyle-CssClass="td-custom-align " HeaderStyle-CssClass="custom-align"></asp:CheckBoxField>
                    <asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione"></asp:BoundField>
                </Columns>
            </asp:GridView>
            </div>


            <asp:ObjectDataSource ID="MainListDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
                SelectMethod="GetData" TypeName="DataAccess.SistemiErogantiDatasetTableAdapters.SistemiErogantiListTableAdapter">
                <SelectParameters>
                    <asp:Parameter Name="Codice" Type="String" />
                    <asp:Parameter Name="CodiceAzienda" Type="String" />
                    <asp:Parameter Name="Attivo" Type="Byte" />
                </SelectParameters>
            </asp:ObjectDataSource>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
