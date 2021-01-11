<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="LogModifiche.aspx.vb" Inherits=".LogModifiche1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <%--ALERT D'ERRORE --%>
    <div class="row">
        <div class="col-sm-12">
            <div id="alertError" class="alert alert-danger" runat="server" enableviewstate="false" visible="false">
            </div>
        </div>
    </div>

    <%-- PANNELLO FILTRI --%>
    <div class="row">
        <div class="col-sm-12">
            <div class="panel panel-default" id="panelFiltri" runat="server">
                <div class="panel-heading">
                    <h3 class="panel-title">Log Modifiche</h3>
                </div>
                <div class="panel-body">
                    <div class="form-horizontal">
                        <div class="row">
                            <div class="col-sm-4">
                                <div class="form-group form-group-sm">
                                    <asp:Label Text="Data Dal:" runat="server" AssociatedControlID="txtDataDal" CssClass="control-label col-sm-5" />
                                    <div class="col-sm-7">
                                        <asp:TextBox ID="txtDataDal" CssClass="form-control form-control-dataPicker" MaxLength="16" placeholder="Es:22/11/1996 15:00" runat="server" />
                                    </div>
                                </div>
                            </div>
                            <div class="col-sm-4">
                                <div class="form-group form-group-sm">
                                    <asp:Label Text="Data Al:" runat="server" AssociatedControlID="txtDataAl" CssClass="control-label col-sm-5" />
                                    <div class="col-sm-7">
                                        <asp:TextBox ID="txtDataAl" CssClass="form-control form-control-dataPicker" MaxLength="16" placeholder="Es:22/11/1996 15:00" runat="server" />
                                    </div>
                                </div>
                            </div>
                            <div class="col-sm-4">
                                <div class="form-group form-group-sm">
                                    <asp:Label Text="Numero Record:" runat="server" AssociatedControlID="ddlTop" CssClass="control-label col-sm-5" />
                                    <div class="col-sm-7">
                                        <asp:DropDownList ID="ddlTop" CssClass="form-control" runat="server">
                                            <asp:ListItem Value="100" Text="100" />
                                            <asp:ListItem Value="500" Text="500" />
                                            <asp:ListItem Value="1000" Text="1000" />
                                            <asp:ListItem Value="2000" Text="2000" />
                                        </asp:DropDownList>
                                    </div>
                                </div>
                            </div>
                            <div class="col-sm-4">
                                <div class="form-group form-group-sm">
                                    <asp:Label Text="Nome Database:" runat="server" AssociatedControlID="ddlDatabaseNomi" CssClass="control-label col-sm-5" />
                                    <div class="col-sm-7">
                                        <asp:DropDownList ID="ddlDatabaseNomi" runat="server" DataSourceID="odsDatabaseName" DataTextField="DatabaseNome" DataValueField="DatabaseNome" CssClass="form-control" AutoPostBack="true">
                                        </asp:DropDownList>
                                    </div>
                                </div>
                            </div>
                            <div class="col-sm-4">
                                <div class="form-group form-group-sm">
                                    <asp:Label Text="Nome Tabella:" runat="server" AssociatedControlID="ddlTabelleNomi" CssClass="control-label col-sm-5" />
                                    <div class="col-sm-7">
                                        <asp:DropDownList ID="ddlTabelleNomi" runat="server" DataSourceID="odsTabelleNomi" DataTextField="TabellaNome" DataValueField="TabellaNome" CssClass="form-control">
                                        </asp:DropDownList>
                                    </div>
                                </div>
                            </div>
                            <div class="col-sm-2">
                                <asp:Button ID="btnCerca" Text="Cerca" CssClass="btn btn-primary btn-sm" runat="server" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- TABELLA --%>
    <div class="row">
        <div class="col-sm-12">
            <div class="table-responsive">
                <asp:GridView ID="gvListaLogModifiche" runat="server" DataSourceID="odsLogModifiche" AutoGenerateColumns="False" DataKeyNames="ID" GridLines="None"
                    AllowPaging="True" EnableViewState="true"
                    PageSize="100"
                    AllowSorting="false"
                    CssClass="table table-striped table-bordered table-condensed table-custom-padding" EmptyDataText="Nessun record.">
                    <Columns>
                        <asp:TemplateField ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <asp:LinkButton ID="cmdApriDettaglio" CommandArgument='<%# Eval("ID") %>' CommandName="Dettaglio" runat="server" ToolTip="Apri Dettaglio Modifiche">
                                    <span class="glyphicon glyphicon-th-list" aria-hidden="true"></span>
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <asp:LinkButton ID="cmdScaricaDettaglio" CommandArgument='<%# Eval("ID") %>' CommandName="Scarica" runat="server" ToolTip="Scarica Dettaglio Modifiche">
                                    <span class="glyphicon glyphicon-download" aria-hidden="true"></span>
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="DataModifica" HeaderText="Data Modifica" SortExpression="DataModifica" ItemStyle-CssClass="td-custom-align" HeaderStyle-CssClass="custom-align"></asp:BoundField>
                        <asp:BoundField DataField="DatabaseNome" HeaderText="Nome Database" SortExpression="DatabaseNome" ItemStyle-CssClass="td-custom-align" HeaderStyle-CssClass="custom-align"></asp:BoundField>
                        <asp:BoundField DataField="TabellaNome" HeaderText="Nome Tabella" SortExpression="TabellaNome" ItemStyle-CssClass="td-custom-align" HeaderStyle-CssClass="custom-align"></asp:BoundField>
                        <%--<asp:BoundField DataField="DataImportazione" HeaderText="Data Importazione" SortExpression="DataImportazione" ItemStyle-CssClass="td-custom-align" HeaderStyle-CssClass="custom-align"></asp:BoundField>--%>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>

    <asp:ObjectDataSource ID="odsLogModifiche" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="LogModificheTableAdapters.LogModificheCercaTableAdapter">
        <SelectParameters>
            <asp:Parameter Name="DatabaseNome" Type="String"></asp:Parameter>
            <asp:Parameter Name="TabellaNome" Type="String"></asp:Parameter>
            <asp:Parameter Name="DataModificaDal" Type="DateTime"></asp:Parameter>
            <asp:Parameter Name="DataModificaAl" Type="DateTime"></asp:Parameter>
            <asp:Parameter Name="MaxNumRow" Type="Int32"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="odsDatabaseName" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="LogModificheTableAdapters.LogModificheDatabaseNomiOttieniTableAdapter" />
    <asp:ObjectDataSource ID="odsTabelleNomi" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="LogModificheTableAdapters.LogModificheTabelleNomiOttieniTableAdapter">
        <SelectParameters>
            <asp:Parameter Name="DatabaseNome" Type="String"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>

    <script type="text/javascript">
        // CREO I BOOTSTRAP DATEPICKER
        $('.form-control-dataPicker').datetimepicker({
            locale: moment.locale('it'),
            showTodayButton: true,
            useStrict: true,
            minDate: "01/01/1900"
        });
    </script>
</asp:Content>
