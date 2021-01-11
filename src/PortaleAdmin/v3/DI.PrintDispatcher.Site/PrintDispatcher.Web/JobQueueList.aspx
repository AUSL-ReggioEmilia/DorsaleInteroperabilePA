<%@ Page Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="JobQueueList.aspx.vb" Inherits="PrintDispatcherAdmin.JobQueueList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">



    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>

            <div class="div-bianco">

                <h3 class="page-title">Elenco dei job di stampa</h3>
                <div class="div-grigio" id="panelFiltri" runat="server">

                    <div class="row">
                        <div class="col-sm-12 col-md-10">
                            <div class="row">
                                <%-- Data Dal --%>
                                <div class="col-sm-4 col-md-4  col-lg-3">
                                    <div class="form-group form-group-sm">
                                        <asp:Label ID="lblDateCreaterdDal" runat="server" Text="Data creazione (dal)" CssClass="control-label col-sm-12 font-weight-bold"></asp:Label>
                                        <div class="col-sm-12">
                                            <asp:TextBox ID="txtFiltroDateCreaterdDal" runat="server" CssClass="form-control form-control-dataPicker input-sm" placeholder="Es:22/11/1996 15:00"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <%-- Data Al --%>
                                <div class="col-sm-4 col-md-4  col-lg-3">
                                    <div class="form-group form-group-sm">
                                        <asp:Label ID="lblDateCreaterdAl" runat="server" Text="Data creazione (al)" CssClass="control-label col-sm-12 font-weight-bold"></asp:Label>
                                        <div class="col-sm-12">
                                            <asp:TextBox ID="txtFiltroDateCreaterdAl" runat="server" CssClass="form-control form-control-dataPicker input-sm" placeholder="Es:31/12/2020 18:00"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <%-- Storici --%>
                                <div class="col-sm-4 col-md-4  col-lg-3">
                                    <div class="form-group form-group-sm">
                                        <asp:Label ID="lblStoricizzati" runat="server" Text="Storicizzati" CssClass="control-label col-sm-12 font-weight-bold"></asp:Label>
                                        <div class="col-sm-12">
                                            <asp:DropDownList ID="ddlFiltroStoricizzati" runat="server" CssClass="form-control input-sm">
                                                <asp:ListItem Value=""></asp:ListItem>
                                                <asp:ListItem Value="true">Si</asp:ListItem>
                                                <asp:ListItem Value="false" Selected="True">No</asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                </div>
                                <%-- Stato --%>
                                <div class="col-sm-4 col-md-4  col-lg-3">
                                    <div class="form-group form-group-sm">
                                        <asp:Label ID="lblStato" runat="server" Text="Stato" CssClass="control-label col-sm-12 font-weight-bold"></asp:Label>
                                        <div class="col-sm-12">
                                            <asp:DropDownList ID="ddlFiltroStato" runat="server" CssClass="form-control input-sm">
                                                <asp:ListItem Value="Tutti" Text=""></asp:ListItem>
                                                <asp:ListItem Value="Non completato">Non completato</asp:ListItem>
                                                <asp:ListItem Value="Completato">Completato</asp:ListItem>
                                                <asp:ListItem Value="Creato">Creato</asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                </div>
                                <%-- Utente richiedente --%>
                                <div class="col-sm-4 col-md-4  col-lg-3">
                                    <div class="form-group form-group-sm" id="tdUserSubmitter">
                                        <asp:Label ID="lblUserSubmitter" runat="server" Text="Utente richiedente" CssClass="control-label col-sm-12 font-weight-bold"></asp:Label>
                                        <div class="col-sm-12">
                                            <asp:TextBox ID="txtFiltroUserSubmitter" runat="server" CssClass="form-control input-sm"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <%-- Utente inviante --%>
                                <div class="col-sm-4 col-md-4  col-lg-3">
                                    <div class="form-group form-group-sm" id="tdUserAccount">
                                        <asp:Label ID="lblUserAccount" runat="server" Text="Utente inviante" CssClass="control-label col-sm-12 font-weight-bold"></asp:Label>
                                        <div class="col-sm-12">
                                            <asp:TextBox ID="txtFiltroUserAccount" runat="server" CssClass="form-control input-sm"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <%-- Nome --%>
                                <div class="col-sm-4 col-md-4  col-lg-3">
                                    <div class="form-group form-group-sm">
                                        <asp:Label ID="lblDocumento" runat="server" Text="Nome" CssClass="control-label col-sm-12 font-weight-bold"></asp:Label>
                                        <div class="col-sm-12">
                                            <asp:TextBox ID="txtFiltroJobName" runat="server" CssClass="form-control input-sm"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <%-- BOTTONI CERCA ANNULLA --%>
                        <div class="col-sm-12 col-md-2 custom-mt-22 text-right">
                            <asp:LinkButton ID="btnCerca" CssClass="btn btn-100 btn-primary btn-sm" runat="server">
                            <i class='fas fa-search fa-lg'></i>&nbsp;Cerca</asp:LinkButton>
                            <asp:LinkButton ID="btnFiltroOff" runat="server" class="btn btn-100 btn-default btn-sm"
                                data-toggle="popover" data-placement="bottom" data-trigger="hover" data-content="Ripristina filtri">
                            <i class="fas fa-undo-alt fa-lg"></i>&nbsp;Annulla</asp:LinkButton>
                        </div>
                    </div>
                </div>

                <%-- Ristampa --%>
                <div class="row">
                    <div class="col-sm-12">
                        <asp:LinkButton ID="btnMassiveRePrint" runat="server" CssClass="button btn-100 btn btn-default btn-sm"
                            OnClientClick="return confirm('Ri-inviare la stampa degli elementi selezionati?');"> Ri-Stampa </asp:LinkButton>
                    </div>
                </div>

                <div id="trRicercaByIdOrderEntry" runat="server" visible="false">
                    <asp:Label ID="lblMsgRicercaByIdOrderEntry" runat="server" Text="" CssClass="MessageRicercaMandataria custom-mb-15"></asp:Label>
                </div>

                <asp:UpdateProgress ID="UpdateProgress1" runat="server">
                    <ProgressTemplate>
                        <i>elaborazione in corso...</i>
                    </ProgressTemplate>
                </asp:UpdateProgress>

                <asp:GridView ID="UiJobQueueListGridView" runat="server" DataKeyNames="Id,PrintJobDateStart,PrintJobDateCompleted,InHistory,PrintJobError,Ts"
                    DataSourceID="UiJobQueueListObjectDataSource"
                    AllowSorting="true" AllowPaging="true" PageSize="100" Width="100%"
                    AutoGenerateColumns="False" GridLines="None"
                    CssClass="table table-striped table-bordered table-condensed" EmptyDataText="Nessun record.">

                    <Columns>
                        <asp:TemplateField Visible="false">
                            <HeaderTemplate>
                                <asp:CheckBox ID="chkSelectRow" runat="server" AutoPostBack="True" OnCheckedChanged="SelectAllItems" />
                            </HeaderTemplate>
                            <ItemTemplate>
                                <asp:CheckBox ID="chkSelectRow" runat="server" Visible='<%# CheckBoxSelectionVisible(Eval("InHistory"), Eval("PrintJobDateCompleted")) %>'
                                    AutoPostBack="True" OnCheckedChanged="DisplayMassiveCommand" />
                            </ItemTemplate>
                            <ItemStyle Width="25px" CssClass="custom-icon-align" />
                        </asp:TemplateField>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <asp:HyperLink ID="HyperLink1" runat="server" Text='<%# GetEditItemImageUrl(Eval("InHistory")) %>' NavigateUrl='<%# GetEditItemNavigateUrl(Eval("Id"))%>'
                                    ToolTip="Naviga al dettaglio"></asp:HyperLink>
                            </ItemTemplate>
                            <ItemStyle Width="25px" CssClass="custom-icon-align" />
                        </asp:TemplateField>
                        <asp:BoundField DataField="JobName" HeaderText="Nome Documento" SortExpression="JobName" />
                        <asp:BoundField DataField="DateCreated" HeaderText="Data creazione" SortExpression="DateCreated"></asp:BoundField>
                        <asp:BoundField DataField="PrintJobStatus" HeaderText="Stato" SortExpression="PrintJobStatus" />
                        <asp:BoundField DataField="UserSubmitter" HeaderText="Utente richiedente" SortExpression="UserSubmitter"></asp:BoundField>
                        <asp:BoundField DataField="UserAccount" HeaderText="Utente inviante" SortExpression="UserAccount"></asp:BoundField>
                        <asp:BoundField DataField="PrintServerName" HeaderText="Server di stampa" SortExpression="PrintServerName"></asp:BoundField>
                        <asp:BoundField DataField="PrintQueueName" HeaderText="Stampante" SortExpression="PrintQueueName"></asp:BoundField>
                        <asp:BoundField DataField="PrintJobDateCompleted" HeaderText="Data di stampa" SortExpression="PrintJobDateCompleted"></asp:BoundField>
                        <asp:BoundField DataField="HostName" HeaderText="Host del servizio" SortExpression="HostName"></asp:BoundField>
                    </Columns>
                </asp:GridView>
            </div>

            <asp:ObjectDataSource ID="UiJobQueueListObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
                SelectMethod="GetData" TypeName="DataAccess.JobQueueDataSetTableAdapters.UiJobQueueListTableAdapter">
                <SelectParameters>
                    <asp:ControlParameter ControlID="txtFiltroUserAccount" Name="UserAccount" PropertyName="Text"
                        Type="String" />
                    <asp:ControlParameter ControlID="txtFiltroUserSubmitter" Name="UserSubmitter" PropertyName="Text"
                        Type="String" />
                    <asp:ControlParameter ControlID="txtFiltroDateCreaterdDal" Name="DateCreatedFrom"
                        PropertyName="Text" Type="DateTime" />
                    <asp:ControlParameter ControlID="txtFiltroDateCreaterdAl" Name="DateCreatedTo" PropertyName="Text"
                        Type="DateTime" />
                    <asp:ControlParameter ControlID="ddlFiltroStato" Name="Stato" PropertyName="SelectedValue"
                        Type="String" />
                </SelectParameters>
            </asp:ObjectDataSource>
        </ContentTemplate>
    </asp:UpdatePanel>

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
