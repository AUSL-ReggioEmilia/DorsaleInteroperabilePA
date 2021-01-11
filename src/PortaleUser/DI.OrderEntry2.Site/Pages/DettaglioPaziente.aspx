<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="DettaglioPaziente.aspx.vb" Inherits="DI.OrderEntry.User.DettaglioPaziente" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title></title>
    <link href="~/Styles/master.css" rel="stylesheet" type="text/css" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="~/Scripts/modernizr-2.8.3.js" type="text/javascript"></script>
    <link href="~/Content/bootstrap.min.css" rel="stylesheet" />
    <script src="../Scripts/jquery-1.9.1.min.js"></script>
    <script src="../Scripts/bootstrap.min.js"></script>
    <script src="../Scripts/respond.min.js"></script>
</head>
<body>
    <form id="form1" runat="server">
        <div id="dettaglio">
            <asp:FormView ID="PazienteDettaglioFormView" runat="server" DataSourceID="PazienteDettaglioObjectDataSource" Width="98%">
                <ItemTemplate>
                    <table style="width: 100%;">
                        <tr>
                            <td>
                                <span style="font-weight: bold; font-size: 16px;">
                                    <a id="SacHyperLink" href='<%# DI.OrderEntry.User.DettaglioPaziente.GetSacPazienteUrl( Eval("Id") ) %>'
                                        target="_blank" title="visualizza il dettaglio del paziente">
                                        <img src='../Images/person.gif' alt="visualizza il dettaglio del paziente" />
                                        <%# String.Format("{0} {1} ({2})", Eval("Cognome"), Eval("Nome"), Eval("Sesso")) %>
                                    </a>
                                </span>
                                <br />
                                <asp:Label ID="CodiceFiscaleLabel" runat="server" Font-Bold="true" Text='<%# Eval("CodiceFiscale") %>' Style="padding-left: 22px;" />,
							<%# If (Eval("Sesso") = "M", "nato il ", "nata il ") %>
                                <asp:Label ID="DataNascitaLabel" Font-Bold="true" runat="server" Text='<%# String.Format("{0:d} {1}", Eval("DataNascita"), GetAge(Eval("DataNascita"))) %>' />
                                a
							<asp:Label ID="LuogoNascitaLabel" Font-Bold="true" runat="server" Text='<%# Eval("ComuneNascitaNome") %>' />
                            </td>
                            <td style="width: 80px; text-align: right; padding: 2px;">
                                <asp:Label ID="NumeroEpisodioLabel" runat="server" Text='<%# GetNosologico() %>' Visible='<%# GetNosologico() IsNot Nothing %>'></asp:Label>
                                <div class="separator">
                                </div>
                                <div id="GetEsenzioniContainer" style="float: left; padding: 2px;">
                                </div>
                                <div id="GetRicoveriContainer" style="float: left; padding: 2px;">
                                </div>
                                <div id="GetRefertiContainer" style="float: left; padding: 2px;">
                                </div>
                            </td>
                        </tr>
                    </table>
                </ItemTemplate>
            </asp:FormView>
            <asp:ObjectDataSource ID="PazienteDettaglioObjectDataSource" runat="server" SelectMethod="GetDettaglioPaziente"
                TypeName="DI.OrderEntry.User.DettaglioPaziente">
                <SelectParameters>
                    <asp:QueryStringParameter Name="id" QueryStringField="Id" Type="String" />
                </SelectParameters>
            </asp:ObjectDataSource>

            <div class="modal fade" id="EsenzioniList" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
                <div class="modal-dialog modal-lg"" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                            <h4 class="modal-title">Esenzioni</h4>
                        </div>
                        <div class="modal-body" id="EsenzioniContainer">
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-default" data-dismiss="modal">Chiudi</button>
                        </div>
                    </div>
                </div>
            </div>

            <div class="modal fade" id="RicoveroList" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
                <div class="modal-dialog modal-lg"" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                            <h4 class="modal-title" id="myModalLabel">Ricoveri</h4>
                        </div>
                        <div class="modal-body" id="RicoveroContainer">
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-default" data-dismiss="modal">Chiudi</button>
                            <button type="button" class="btn btn-primary">Save changes</button>
                        </div>
                    </div>
                </div>
            </div>

            <div class="modal fade" id="RefertiList" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
                <div class="modal-dialog modal-lg"" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                            <h4 class="modal-title" id="RefertiListTitle">Referti</h4>
                        </div>
                        <div class="modal-body" id="RefertiContainer">
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-default" data-dismiss="modal">Chiudi</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
