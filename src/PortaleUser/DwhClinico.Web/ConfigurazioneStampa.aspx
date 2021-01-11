<%@ Page Language="VB" MasterPageFile="~/Portale/Default.master" AutoEventWireup="false" Inherits="DwhClinico.Web.ConfigurazioneStampa" Title="" CodeBehind="ConfigurazioneStampa.aspx.vb" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" runat="Server">
    <div class="row">
        <div class="col-sm-12">
            <div id="divPageTitle" class="lead" runat="server">
                Configurazione di stampa
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <div class="alert alert-danger" id="alertErrorMessage" runat="server" enableviewstate="false" visible="false">
                <asp:Label ID="lblErrorMessage" runat="server" EnableViewState="False"></asp:Label>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <div class="jumbotron message-custom-padding">
                <asp:Label ID="lblHowToMsg" runat="server"></asp:Label>
            </div>
        </div>
    </div>

    <div class="row" id="divConfigMsg" runat="server">
        <div class="col-sm-12 ">
            <div class="jumbotron message-custom-padding">
                <div class="col-sm-1">
                    <span style="font-size:30px;" ID="imgPrinterStatus" runat="server" class="glyphicons glyphicons-print"></span>
                </div>
                <asp:Label ID="lblConfigMsg" runat="server" CssClass="text-warning"></asp:Label>
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-xs-8 col-xs-offset-2 col-sm-8 col-sm-offset-2 col-md-6 col-md-offset-3 col-lg-4 col-lg-offset-4" >
            <div runat="server" id="tblConfigNetPrinter">
                <div class="form-horizontal">
                    <div class="col-sm-12">
                        <asp:RadioButton ID="rbConfigNetPrinter"
                            runat="server" Text="Stampanti di rete"
                            GroupName="ConfigType" AutoPostBack="True" />
                    </div>
                    <div class="row">
                        <div class="form-group form-group-sm">
                            <div class="col-sm-6 col-sm-offset-1" data-toggle="tooltip" data-placement="right" title="Selezionare il server">
                                <asp:DropDownList ID="cmbNetPrinterServer" runat="server" AutoPostBack="True" CssClass="form-control">
                                </asp:DropDownList>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="form-group form-group-sm">
                            <div class="col-sm-6 col-sm-offset-1" data-toggle="tooltip" data-placement="right" title="Selezionare la stampante">
                                <asp:DropDownList ID="cmbNetPrinterName" runat="server" CssClass="form-control">
                                </asp:DropDownList>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-12">
                        <div class="alert alert-danger" id="alertMessagePredefConfig" runat="server" visible="false" enableviewstate="false">
                            <asp:Label ID="lblMessagePredefConfig" runat="server" EnableViewState="False" CssClass="text-danger"></asp:Label>
                        </div>
                    </div>
                </div>
            </div>

            <div runat="server" id="tblConfigLocalPrinter">
                <div class="form-horizontal">
                    <div class="col-sm-12">
                        <asp:RadioButton ID="rbConfigLocalPrinter" runat="server"
                            Text="Stampante locale" GroupName="ConfigType" AutoPostBack="True" />
                    </div>
                    <div class="row">
                        <div class="form-group form-group-sm">
                            <div class="col-sm-6 col-sm-offset-1" data-toggle="tooltip" data-placement="right" title=" Inserire il nome del client [Es.: \\Client] e premere 'Cerca'">
                                <asp:TextBox ID="txtLocalPrinterServer" runat="server" CssClass="form-control"></asp:TextBox>
                            </div>
                            <div class="col-sm-1">
                                <asp:Button ID="cmdLocalFindPrinter" runat="server" Text="Cerca" CssClass="btn btn-default btn-sm" />
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="form-group form-group-sm">
                            <div class="col-sm-6 col-sm-offset-1">
                                <asp:DropDownList ID="cmbLocalPrinterName" runat="server" CssClass="form-control">
                                </asp:DropDownList>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-12">
                        <div class="alert alert-danger" id="alertMessageLocalPrinterConfig" runat="server" visible="false" enableviewstate="false">
                            <asp:Label ID="lblMessageLocalPrinterConfig" runat="server" EnableViewState="False" CssClass="Errore text-danger"></asp:Label>
                        </div>
                    </div>
                </div>
            </div>

            <div runat="server" visible="false">
                <div class="form-horizontal">
                    <div class="col-sm-12">
                        <asp:RadioButton ID="rbConfigPersonal" runat="server"
                            Text="Altra stampante" GroupName="ConfigType" AutoPostBack="True" />
                    </div>
                    <div class="row">
                        <div class="form-group">
                            <div class="col-sm-4 col-sm-offset-1">
                                <asp:TextBox ID="txtPersonalPrinterServer" runat="server" CssClass="form-control input-sm"></asp:TextBox>
                            </div>
                            <div class="col-sm-1">
                                <asp:Button ID="cmdPersonalFindPrinter" runat="server" Text="Cerca" CssClass="btn btn-sm btn-default" />
                            </div>
                            <div class="col-sm-5">
                                Inserire il nome del client [Es.: \\Client] e premere "Cerca"
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="form-group">
                            <div class="col-sm-4 col-sm-offset-1">
                                <asp:DropDownList ID="cmbPersonalPrinterName" runat="server">
                                </asp:DropDownList>
                            </div>
                            <div class="col-sm-7">
                                Selezionare la stampante
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-sm-12">
                            <asp:Label ID="lblMessagePersonalConfig" runat="server" EnableViewState="False" CssClass="text-danger"></asp:Label>
                        </div>
                    </div>
                </div>
            </div>
            <hr />
            <div class="row">
                <div class="col-sm-7">
                    <asp:Button ID="btnGeneraPDF" runat="server" Text="Genera Pdf di test" CssClass="btn btn-sm btn-default" />
                    <asp:LinkButton ID="btnStampaPaginaDiTest" CssClass="btn btn-sm btn-default" Text="text" runat="server">
                    <span class="glyphicon glyphicon-print" aria-hidden="true"></span>
                    Stampa pagina di test
                    </asp:LinkButton>
                </div>
                <div class=" col-sm-5">
                    <div class="text-right">
                        <asp:Button ID="btnStampa" runat="server" Text="Stampa" CssClass="btn btn-sm btn-default" />
                        <asp:Button ID="btnSalvaConfig" runat="server" Text="Salva" CssClass="btn btn-sm btn-default" />
                        <asp:Button ID="btnEsci" runat="server" Text="Esci" CssClass="btn btn-sm btn-primary" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
