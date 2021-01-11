<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="PcRichiedentiList.aspx.vb" Inherits="PrintDispatcherAdmin.PcRichiedentiList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>

            <div class="div-bianco">

                <h3 class="page-title">Elenco dei Pc Richiedenti</h3>
                <div class="div-grigio" id="panelFiltri" runat="server">


                    <div class="row">
                        <%-- Nome PC --%>
                        <div class="col-sm-4 col-md-4">
                            <div class="form-group form-group-sm">
                                <asp:Label ID="lblNome" runat="server" Text="Nome PC" CssClass="control-label col-sm-12 font-weight-bold"></asp:Label>
                                <div class="col-sm-12">
                                    <asp:TextBox ID="txtNome" runat="server" CssClass="form-control input-sm"></asp:TextBox>
                                </div>
                            </div>
                        </div>

                        <%-- BOTTONI CERCA ANNULLA --%>
                        <div class="col-sm-12 col-md-4 col-lg-4 custom-mt-22 pull-right text-right">
                            <asp:LinkButton ID="btnCerca" CssClass="btn btn-100 btn-primary btn-sm" runat="server">
                            <i class='fas fa-search fa-lg'></i>&nbsp;Cerca</asp:LinkButton>
                            <asp:LinkButton ID="btnFiltroOff" runat="server" class="btn btn-100 btn-default btn-sm"
                                data-toggle="popover" data-placement="bottom" data-trigger="hover" data-content="Ripristina filtri">
                            <i class="fas fa-undo-alt fa-lg"></i>&nbsp;Annulla</asp:LinkButton>
                        </div>
                    </div>
                </div>
            </div>

            <%-- Nuovo PC --%>
            <div class="row">
                <div class="col-sm-12">
                    <asp:HyperLink ID="lnkNuovo" runat="server" NavigateUrl="PcRichiedentiDetail.aspx" CssClass="btn btn-100 btn-primary btn-sm"
                        data-toggle="popover" data-placement="bottom" data-trigger="hover" data-content="Inserisci un nuovo PC">
                                    <i class="fas fa-plus fa-lg"></i>&nbsp;Nuovo
                    </asp:HyperLink>
                </div>
            </div>

            <asp:GridView ID="MainListGridView" runat="server"
                DataKeyNames="Id" DataSourceID="MainListDataSource" AllowSorting="true" AllowPaging="true" PageSize="100" Width="100%"
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
                    <asp:BoundField DataField="Nome" HeaderText="Nome Pc" SortExpression="Nome" />
                    <asp:BoundField DataField="StampantiAssociateDescrizione" HeaderText="Stampanti" HtmlEncode="False" />
                </Columns>
            </asp:GridView>
            </div>

            <asp:ObjectDataSource ID="MainListDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
                SelectMethod="GetData" TypeName="DataAccess.PcRichiedentiDatasetTableAdapters.PcRichiedentiListTableAdapter">
                <SelectParameters>
                    <asp:Parameter Name="Nome" Type="String" />
                </SelectParameters>
            </asp:ObjectDataSource>

        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
