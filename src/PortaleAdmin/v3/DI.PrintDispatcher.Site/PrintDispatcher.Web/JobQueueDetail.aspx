<%@ Page Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
    CodeBehind="JobQueueDetail.aspx.vb" Inherits="PrintDispatcherAdmin.JobQueueDetail" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">

    <h3 class="page-title">Dettaglio job di stampa</h3>


    <div class="row">
        <div class="col-sm-10 col-md-8 col-lg-7">


            <asp:Panel ID="Panel1" runat="server">
                <asp:FormView ID="UiJobQueueSelectFormView" runat="server" DataKeyNames="Id" DataSourceID="UiJobQueueSelectObjectDataSource" Style="width: 100%;" DefaultMode="Edit">
                    <EditItemTemplate>
                        <div class="div-bianco">
                            <div class="form-horizontal form-horizontal-detail">
                                <div class="form-group">
                                    <asp:Label Text="Nome Documento" runat="server" AssociatedControlID="lblJobName" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <p id="lblJobName" runat="server" class="form-control-static"><%# Eval("JobName") %></p>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <asp:Label Text="Data creazione" runat="server" AssociatedControlID="lblDateCreated" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <p id="lblDateCreated" runat="server" class="form-control-static"><%# Eval("DateCreated") %></p>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <asp:Label Text="Utente creazione" runat="server" AssociatedControlID="lblUserSubmitter" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <p id="lblUserSubmitter" runat="server" class="form-control-static"><%# Eval("UserSubmitter") %></p>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <asp:Label Text="Utente" runat="server" AssociatedControlID="lblUserAccount" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <p id="lblUserAccount" runat="server" class="form-control-static"><%# Eval("UserAccount") %></p>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <asp:Label Text="Nome server" runat="server" AssociatedControlID="lblPrintServerName" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <p id="lblPrintServerName" runat="server" class="form-control-static"><%# Eval("PrintServerName") %></p>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <asp:Label Text="Nome coda" runat="server" AssociatedControlID="lblPrintQueueName" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <p id="lblPrintQueueName" runat="server" class="form-control-static"><%# Eval("PrintQueueName") %></p>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <asp:Label Text="Data inizio stampa" runat="server" AssociatedControlID="lblPrintJobDateStart" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <p id="lblPrintJobDateStart" runat="server" class="form-control-static"><%# Eval("PrintJobDateStart") %></p>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <asp:Label Text="Data completamento stampa" runat="server" AssociatedControlID="lblPrintJobDateCompleted" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <p id="lblPrintJobDateCompleted" runat="server" class="form-control-static"><%# Eval("PrintJobDateCompleted") %></p>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <asp:Label Text="Errore" runat="server" AssociatedControlID="lblPrintJobError" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <p id="lblPrintJobError" runat="server" class="form-control-static"><%# GetError(Eval("PrintJobError")) %></p>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <asp:Label Text="Stato" runat="server" AssociatedControlID="lblPrintJobStatus" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <p id="lblPrintJobStatus" runat="server" class="form-control-static"><%# GetStatus(Eval("PrintJobStatus")) %></p>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <asp:Label Text="Host del servizio" runat="server" AssociatedControlID="lblServerHost" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <p id="lblServerHost" runat="server" class="form-control-static"><%# Eval("HostName") %></p>
                                    </div>
                                </div>
                            </div>
                        </div>


                        <div class="row">
                            <div class="col-xs-6">

                                <asp:Button ID="UpdateRePrintButton" runat="server" CssClass="btn btn-100 btn-primary btn-sm" CausesValidation="false"
                                    CommandName="RePrintCommand" CommandArgument="ParentRedirect"
                                    OnClientClick="return confirm('Ri-inviare la stampa?');" Text="Ri-Stampa" />

                                <div id="divDocViewer" runat="server" visible="false">
                                    <asp:Button ID="ShowDocButton" runat="server" CssClass="btn btn-120 btn-primary btn-sm" CausesValidation="false"
                                        CommandName="ShowDoc" Text="Visualizza Doc." />
                                </div>
                            </div>
                            <div class="col-xs-6">

                                <div class="text-right">
                                    <asp:LinkButton ID="UpdateCancelButton" runat="server" CssClass="btn btn-100 btn-secondary btn-sm" CausesValidation="False"
                                        CommandName="Cancel"> Esci</asp:LinkButton>
                                </div>
                            </div>
                        </div>

                    </EditItemTemplate>
                </asp:FormView>
            </asp:Panel>
        </div>
    </div>

    <asp:ObjectDataSource ID="UiJobQueueSelectObjectDataSource" runat="server" SelectMethod="GetData"
        TypeName="DataAccess.JobQueueDataSetTableAdapters.UiJobQueueSelectTableAdapter"
        OldValuesParameterFormatString="original_{0}" CacheKeyDependency="CKD">
        <SelectParameters>
            <asp:QueryStringParameter DbType="Guid" Name="Id" QueryStringField="id" />
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>
