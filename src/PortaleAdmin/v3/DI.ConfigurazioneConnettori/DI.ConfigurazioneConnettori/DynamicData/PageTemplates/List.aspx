<%@ Page Language="VB" MasterPageFile="~/Site.master" CodeBehind="List.aspx.vb" Inherits="List" EnableEventValidation="false" %>

<%@ MasterType VirtualPath="~/Site.Master" %>

<%@ Register Src="~/DynamicData/Content/GridViewPager.ascx" TagName="GridViewPager" TagPrefix="asp" %>

<asp:Content ID="headContent" ContentPlaceHolderID="head" runat="Server">
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

    <asp:DynamicDataManager ID="DynamicDataManager1" runat="server" AutoLoadForeignKeys="true">
        <DataControls>
            <asp:DataControlReference ControlID="GridView1" />
        </DataControls>
    </asp:DynamicDataManager>

    <%--	<asp:UpdatePanel ID="UpdatePanel1" runat="server">
		<ContentTemplate>--%>
    <asp:ValidationSummary ID="ValidationSummary1" runat="server"
        EnableClientScript="true"
        HeaderText="Sono presenti errori di validazione dei filtri:"
        CssClass="alert alert-danger" />

    <asp:DynamicValidator runat="server" ID="GridViewValidator"
        ControlToValidate="GridView1"
        Display="None"
        CssClass="alert alert-danger" />

    <div class="div-bianco">
        <div class="row">
            <div class="col-sm-12">

                <h3 class="page-title"><%= DDHelper.GetTableFullName(table) %></h3>

                <div id="filterRow" class="div-grigio" runat="server">
                    <div id="filters" runat="server">
                        <div class="form-horizontal">
                            <asp:QueryableFilterRepeater runat="server" ID="FilterRepeater">
                                <ItemTemplate>
                                    <div class="col-md-4 col-sm-6">
                                        <div class="form-group form-group-sm">
                                            <div class="col-md-5">
                                                <asp:Label
                                                    runat="server"
                                                    Text='<%# Eval("DisplayName") %>'
                                                    CssClass="control-label"
                                                    OnPreRender="Label_PreRender" />

                                            </div>
                                            <div class="col-md-7">
                                                <asp:DynamicFilter
                                                    runat="server"
                                                    ID="DynamicFilter"
                                                    OnFilterChanged="DynamicFilter_FilterChanged" />
                                            </div>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:QueryableFilterRepeater>
                        </div>
                    </div>
                </div>


                <%--TOOLBAR ALTO--%>
                <div class="row">
                    <div class="col-sm-12">
                        <asp:DynamicHyperLink ID="btnAggiungiTop" runat="server" CssClass="btn btn-100 btn-primary" Action="Insert"><i class="fas fa-plus"></i>&nbsp;Aggiungi</asp:DynamicHyperLink>
                        <asp:Button ID="btnEsportaExcelTop" runat="server" CssClass="btn btn-120 btn-default" Text="Esporta in Excel" OnClientClick="MouseWait(this);" UseSubmitBehavior="false" />
                        <asp:DynamicHyperLink ID="butImportaExcelTop" runat="server" Action="Import" CssClass="btn btn-130 btn-default">Importa da Excel...</asp:DynamicHyperLink>
                    </div>
                </div>

                <div class="table-responsive">
                    <asp:GridView
                        ID="GridView1"
                        runat="server"
                        DataSourceID="GridDataSource"
                        EnablePersistedSelection="true"
                        AllowPaging="True"
                        PageSize="100"
                        AllowSorting="True"
                        GridLines="None"
                        CssClass="table table-striped table-bordered table-condensed table-custom-padding"
                        EnableViewState="false">
                        <Columns>
                            <asp:TemplateField HeaderStyle-Width="60px" ItemStyle-CssClass="text-nowrap">
                                <ItemTemplate>
                                    <asp:DynamicHyperLink runat="server" ToolTip="Apri" CssClass="btn btn-default btn-sm"><i class="fas fa-eye text-primary"></i></asp:DynamicHyperLink>
                                    <asp:DynamicHyperLink runat="server" Action="Edit" ToolTip="Modifica" CssClass="btn btn-default btn-sm"><i class="fas fa-pencil-alt fa-lg  text-primary"></i></asp:DynamicHyperLink>
                                    <asp:LinkButton ID="btnCopyRecord" runat="server" CssClass="btn btn-default btn-sm"
                                        CommandName="Copia" CommandArgument='<%# Container.DataItemIndex %>' ToolTip="Crea una copia…"><span class="fas fa-copy fa-lg text-primary"></span></asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%--Link Custom per Import Agende--%>
                            <%-- Non spostare la colonna: Viene usato l'index della cella (lato codice) per fare riferimento al pulsante! --%>
                            <asp:TemplateField HeaderStyle-Width="30px">
                                <ItemTemplate>
                                    <asp:LinkButton ID="BtnOeConCupWizardAgende" runat="server" CssClass="btn btn-default btn-sm"
                                        CommandName="OeConCupWizardAgende" CommandArgument='<%# Container.DataItemIndex %>' ToolTip="Crea nuova Agenda e Prestazioni associate"><span class="glyphicon glyphicon-queen"></span></asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderStyle-Width="30px">
                                <ItemTemplate>
                                    <asp:LinkButton runat="server" CommandName="Delete" ToolTip="Elimina" CssClass="btn btn-danger btn-sm"
                                        OnClientClick="return confirm('Si conferma l\'eliminazione dell\'elemento?');"><i class="fas fa-trash-alt"></i></asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <PagerStyle CssClass="pagination-gridview" />
                        <EmptyDataTemplate>
                            Nessun elemento da visualizzare.
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>

                <%--TOOLBAR BASSO--%>
                <div class="row" style="margin-top:5px;">
                    <div class="col-sm-12">
                        <asp:DynamicHyperLink ID="btnAggiungiDown" runat="server" CssClass="btn btn-100 btn-primary" Action="Insert"><i class="fas fa-plus"></i>&nbsp;Aggiungi</asp:DynamicHyperLink>
                        <asp:Button ID="btnEsportaExcelDown" runat="server" CssClass="btn btn-120 btn-default" Text="Esporta in Excel" UseSubmitBehavior="false" />
                        <asp:DynamicHyperLink ID="butImportaExcelDown" runat="server" Action="Import" CssClass="btn btn-130 btn-default">Importa da Excel...</asp:DynamicHyperLink>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <asp:LinqDataSource ID="GridDataSource" runat="server" EnableDelete="true" />
    <asp:QueryExtender TargetControlID="GridDataSource" ID="GridQueryExtender" runat="server">
        <asp:DynamicFilterExpression ControlID="FilterRepeater" />
    </asp:QueryExtender>

    <%--		</ContentTemplate>
	</asp:UpdatePanel>--%>

    <script type="text/javascript">

        function MouseWait(sender) {
            try {
                sender.style.cursor = 'wait';
                document.body.style.cursor = 'wait';
                //DOPO 3 SECONDI RIMETTE A POSTO IL CURSORE
                setTimeout(function () {
                    sender.style.cursor = 'auto';
                    document.body.style.cursor = 'auto';
                }, 3000);
            } catch (e) {
            }
        }
    </script>


</asp:Content>

