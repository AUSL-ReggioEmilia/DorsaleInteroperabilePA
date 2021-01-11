<%@ Register TagPrefix="uc1" TagName="BarraNavigazione" Src="~/NavigationBar.ascx" %>

<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/AccessoDiretto/AccessoDiretto.master"
    CodeBehind="PazientiConsensoModifica.aspx.vb" Inherits="DwhClinico.Web.PazientiConsensoModifica" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" runat="Server">
    <div style="margin-top: 5px; margin-left: 5px">
        <uc1:BarraNavigazione ID="BarraNavigazione" runat="server"></uc1:BarraNavigazione>
        <div class="PageTitle" id="PageTitle" runat="server">
        </div>
        <asp:Label ID="lblErrorMessage" runat="server" CssClass="errore" EnableViewState="False"></asp:Label>
        <div class="PazienteTable" style="width: 90%">
            <div>
                <table cellspacing="0" cellpadding="4" width="100%" border="0">
                    <tr class="PazienteContent">
                        <td class="PazienteTitle" colspan="4">
                            UTENTE:
                        </td>
                    </tr>
                    <tr class="PazienteContent">
                        <td width="20%">
                            <strong>Nome:</strong>
                        </td>
                        <td colspan="2">
                            <asp:Label ID="lblUtenteNome" runat="server" Text="">
                            </asp:Label>
                        </td>
                    </tr>
                    <tr class="PazienteContent">
                        <td colspan="4">
                            &nbsp;
                        </td>
                    </tr>
                    <tr class="PazienteContent">
                        <td class="PazienteTitle" colspan="4">
                            PAZIENTE:
                        </td>
                    </tr>
                    <tr class="PazienteContent">
                        <td width="20%">
                            <strong>Cognome:</strong>
                        </td>
                        <td>
                            <asp:Label ID="lblCognome" runat="server" Text="">
                            </asp:Label>
                        </td>
                        <td width="20%">
                            <strong>Nome:</strong>
                        </td>
                        <td>
                            <asp:Label ID="lblNome" runat="server" Text="">
                            </asp:Label>
                        </td>
                    </tr>
                    <tr class="PazienteContent">
                        <td>
                            <strong>Data di nascita:</strong>
                        </td>
                        <td>
                            <asp:Label ID="lblDataNascita" runat="server" Text="">
                            </asp:Label>
                        </td>
                        <td>
                            <strong>Luogo di nascita:</strong>
                        </td>
                        <td>
                            <asp:Label ID="lblLuogoNascita" runat="server" Text="">
                            </asp:Label>
                        </td>
                    </tr>
                    <tr class="PazienteContent">
                        <td>
                            <strong>Codice fiscale:</strong>
                        </td>
                        <td colspan="3">
                            <asp:Label ID="lblCodiceFiscale" runat="server" Text="">
                            </asp:Label>
                        </td>
                    </tr>
                    <tr height="20px">
                        <td colspan="4">
                            &nbsp;
                        </td>
                    </tr>
                </table>
                <table cellspacing="0" cellpadding="4" width="100%" border="0">
                    <tr class="PazienteContent">
                        <td valign="top" width="200px">
                            <strong>Consenso:</strong>
                        </td>
                        <td valign="top" colspan="2">
                            <asp:DropDownList ID="cboConsenso" runat="server" AutoPostBack="True">
                                <asp:ListItem Value="-1">Scegli il consenso</asp:ListItem>
                                <asp:ListItem Value="1">Positivo</asp:ListItem>
                                <asp:ListItem Value="0">Negativo</asp:ListItem>
                            </asp:DropDownList>
                        </td>
                    </tr>
                    <tr id="trUtenteAutorizzatoreTitle" runat="server" visible="true">
                        <td colspan="2" style="font-size: 11px; font-weight: bold; color: #000000; padding-top: 10px;">
                            <asp:Label ID="lblUtenteAutorizzatoreTitolo" runat="server" Text="Inserire le generalità del Genitore / Tutore Legale"></asp:Label>
                        </td>
                    </tr>
                    <tr id="trUtenteAutorizzatoreRelazioneColMinore" runat="server" visible="true">
                        <td width="200px">
                            <strong>Relazione col minore:</strong>
                        </td>
                        <td>
                            <asp:DropDownList ID="cmbAutorizzatoreMinoreRelazioneColMinore" runat="server" class="ControlliUtenteAutorizzatoreMinore">
                            </asp:DropDownList>
                        </td>
                    </tr>
                    <tr id="trUtenteAutorizzatoreCognome" runat="server" visible="true">
                        <td width="200px">
                            <strong>Cognome:</strong>
                        </td>
                        <td>
                            <asp:TextBox ID="txtAutorizzatoreMinoreCognome" runat="server" class="ControlliUtenteAutorizzatoreMinore"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="ReqAutorizzatoreMinoreCognome" class="Error" runat="server"
                                ErrorMessage="Campo Obbligatorio" Display="Dynamic" ControlToValidate="txtAutorizzatoreMinoreCognome" />
                        </td>
                    </tr>
                    <tr id="trUtenteAutorizzatoreNome" runat="server" visible="true">
                        <td width="200px">
                            <strong>Nome:</strong>
                        </td>
                        <td>
                            <asp:TextBox ID="txtAutorizzatoreMinoreNome" runat="server" class="ControlliUtenteAutorizzatoreMinore"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="ReqAutorizzatoreMinoreNome" class="Error" runat="server"
                                ErrorMessage="Campo Obbligatorio" Display="Dynamic" ControlToValidate="txtAutorizzatoreMinoreNome" />
                        </td>
                    </tr>
                    <tr id="trUtenteAutorizzatoreDataNascita" runat="server" visible="true">
                        <td width="200px">
                            <strong>Data nascita:</strong>
                        </td>
                        <td>
                            <asp:TextBox ID="txtAutorizzatoreDataNascita" runat="server" class="ControlliUtenteAutorizzatoreMinoreDataNascita"></asp:TextBox>
                            &nbsp;<strong>(gg/mm/aaaa)</strong>
                            <asp:RequiredFieldValidator ID="ReqAutorizzatoreDataNascita" class="Error" runat="server"
                                ErrorMessage="Campo Obbligatorio" Display="Dynamic" ControlToValidate="txtAutorizzatoreDataNascita" />
                            <asp:RangeValidator ID="RangeValAutorizzatoreDataNascita" Type="Date" MinimumValue="1900-01-01"
                                MaximumValue="3000-01-01" ControlToValidate="txtAutorizzatoreDataNascita" CssClass="Error"
                                runat="server" ErrorMessage="Inserire una data valida" Display="Dynamic"></asp:RangeValidator>
                        </td>
                    </tr>
                    <tr id="trUtenteAutorizzatoreLuogoNascita" runat="server" visible="true">
                        <td width="200px">
                            <strong>Luogo di nascita:</strong>
                        </td>
                        <td>
                            <asp:TextBox ID="txtAutorizzatoreLuogoNascita" runat="server" class="ControlliUtenteAutorizzatoreMinore"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="ReqAutorizzatoreLuogoNascita" class="Error" runat="server"
                                ErrorMessage="Campo Obbligatorio" Display="Dynamic" ControlToValidate="txtAutorizzatoreLuogoNascita" />
                        </td>
                    </tr>
                </table>
            </div>
        </div>
        <br />
        <table cellspacing="0" cellpadding="0" width="90%">
            <tr>
                <td width="12%">
                    <asp:Button ID="cmdOK" runat="server" Text="Conferma"></asp:Button>
                </td>
                <td>
                    <input type="button" id="cmdAnnulla" runat="server" value="Annulla" name="cmdAnnulla" />
                </td>
                <td align="right">
                    <input type="button" id="cmdInformativa" runat="server" value="Apri informativa"
                        name="cmdInformativa" />
                </td>
            </tr>
        </table>
    </div>
</asp:Content>
