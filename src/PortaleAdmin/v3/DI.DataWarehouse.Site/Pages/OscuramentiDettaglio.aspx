<%@ Page Title="Dettaglio Sistema" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="OscuramentiDettaglio.aspx.vb"
    Inherits=".OscuramentiDettaglio" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <style type="text/css">
        .table_dettagli tr {
            height: 60px;
        }

        .table_dettagli td {
            padding: 6px;
        }

        .Evidenzia {
            background-color: #FFEBCF;
        }
    </style>
    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False" />

    <!--Titoli-->
    <div>
        <asp:Label ID="lblTitolo" runat="server" CssClass="Title title-custom-float" Text="Label" />
        <asp:Label ID="lblSubTitle" Visible="false" runat="server" CssClass="Warning" Text="La procedura di oscuramento non è completa. Eseguire la rinotifica degli oggetti interessati." />
    </div>

    <div id="wizard" runat="server" style="width: 100%">
        <ul id="wizardList">
            <li class="wizardElement">
                <div class="selected">
                    <span class="stepNumber">1</span>
                    <span class="stepDescription">Creazione o Modifica Oscuramento</span>
                </div>
            </li>
            <li class="wizardElement">
                <div class="disabled">
                    <span class="stepNumber">2</span>
                    <span class="stepDescription">Rinotifica a SOLE</span>
                </div>
            </li>
        </ul>
    </div>

    <!--Toolbar-->
    <%--    <div class="toolbar-div-left">
        <asp:Button ID="butEliminaTop" runat="server" Text="Elimina" CssClass="Button" CommandName="Delete" OnClientClick="return msgboxYESNO('Si conferma l\'eliminazione dell\'elemento?');"
            ValidationGroup="none" />
    </div>
    <div class="toolbar-div-right">
        <asp:Button ID="butSalvaTop" runat="server" Text="Ok" CssClass="Button" CommandName="Update" OnClick="butSalva_Click" />

        <asp:Button ID="btnAvantiTop" runat="server" Text="Avanti" CssClass="Button" />

        <asp:Button ID="butAnnullaTop" runat="server" CommandName="Cancel" Text="Annulla" CssClass="Button" ValidationGroup="null" />
    </div>--%>

    <!--Corpo-->
    <table id="table_dettagli" class="table_dettagli" runat="server" style="margin-top: 15px;">
        <tr style="height: auto;">
            <td class="Td-Text" valign="top">Titolo
            </td>
            <td class="Td-Value" colspan="4">
                <asp:TextBox ID="txtTitolo" runat="server" Width="100%" MaxLength="50" />
            </td>
        </tr>
        <tr>
            <td class="Td-Text" valign="top">Note
            </td>
            <td class="Td-Value" colspan="4">
                <asp:TextBox ID="txtNote" runat="server" Width="100%" MaxLength="1024" TextMode="MultiLine" Rows="4" />
            </td>
        </tr>
        <tr style="height: auto;">
            <td class="Td-Text" valign="top">Applicabilità
            </td>
            <td class="Td-Value">
                <asp:CheckBox ID="chkApplicaDWH" runat="server" Text="Applica a DWH" />
            </td>
            <td class="Td-Value" colspan="3">
                <asp:CheckBox ID="chkApplicaSole" runat="server" Text="Applica a SOLE" />
            </td>
        </tr>

        <tr style="height: 20px;">
            <td colspan="9" style="height: 30px; vertical-align: bottom;">Oscuramenti Puntuali (non bypassabili):</td>
        </tr>
        <%--TIPO 0 (nascosto)--%>
        <tr runat="server" id="Tr0" style="display: none;">
            <td id="TD0" style="display: none;">
                <asp:RadioButton ID="opt0" runat="server" Text="" AutoPostBack="True" GroupName="TipoOsc" />
            </td>
        </tr>
        <%--TIPO 1--%>
        <tr runat="server" id="riga1">
            <td id="TDopt1" class="Td-Text" align="right">
                <asp:RadioButton ID="opt1" runat="server" Text="" AutoPostBack="True" GroupName="TipoOsc" />
            </td>
            <td class="Td-Value">
                <span>Numero Nosologico (*)</span><br />
                <asp:TextBox ID="txt1NumeroNosologico" runat="server" Width="200px" MaxLength="64" />
            </td>
            <td class="Td-Value" colspan="3">
                <span>Azienda erogante (*)</span><br />
                <asp:DropDownList ID="ddl1AziendaErogante" runat="server" Width="200px" AppendDataBoundItems="true" DataSourceID="odsAziende"
                    DataTextField="Descrizione" DataValueField="Codice">
                    <asp:ListItem Text="" Value="" />
                </asp:DropDownList>
            </td>
        </tr>
        <%--TIPO 3--%>
        <tr runat="server" id="riga3">
            <td id="TDopt3" class="Td-Text" align="right">
                <asp:RadioButton ID="opt3" runat="server" Text="" AutoPostBack="True" GroupName="TipoOsc" />
            </td>
            <td class="Td-Value">
                <span>Numero Referto (*)</span><br />
                <asp:TextBox ID="txt3NumeroReferto" runat="server" Width="200px" MaxLength="16" />
            </td>
            <td class="Td-Value">
                <span>Sistema erogante</span><br />
                <asp:DropDownList ID="txt3SistemaErogante" runat="server" Width="200px" AppendDataBoundItems="True" DataSourceID="odsSistemiEroganti"
                    DataTextField="Descrizione" DataValueField="Codice">
                    <asp:ListItem Text="" Value="" />
                </asp:DropDownList>
            </td>
            <td class="Td-Value" colspan="2">
                <span>Azienda erogante</span><br />
                <asp:DropDownList ID="txt3AziendaErogante" runat="server" Width="200px" AppendDataBoundItems="True" DataSourceID="odsAziende"
                    DataTextField="Descrizione" DataValueField="Codice">
                    <asp:ListItem Text="" Value="" />
                </asp:DropDownList>
            </td>
        </tr>
        <%--TIPO 4--%>
        <tr runat="server" id="riga4">
            <td id="TDopt4" class="Td-Text" align="right">
                <asp:RadioButton ID="opt4" runat="server" Text="" AutoPostBack="True" GroupName="TipoOsc" />
            </td>
            <td class="Td-Value">
                <span>Numero Prenotazione (*)</span><br />
                <asp:TextBox ID="txt4NumeroPrenotazione" runat="server" Width="200px" MaxLength="32" />
            </td>
            <td class="Td-Value">
                <span>Sistema erogante</span><br />
                <asp:DropDownList ID="txt4SistemaErogante" runat="server" Width="200px" AppendDataBoundItems="True" DataSourceID="odsSistemiEroganti"
                    DataTextField="Descrizione" DataValueField="Codice">
                    <asp:ListItem Text="" Value="" />
                </asp:DropDownList>
            </td>
            <td class="Td-Value" colspan="2">
                <span>Azienda erogante</span><br />
                <asp:DropDownList ID="txt4AziendaErogante" runat="server" Width="200px" AppendDataBoundItems="True" DataSourceID="odsAziende"
                    DataTextField="Descrizione" DataValueField="Codice">
                    <asp:ListItem Text="" Value="" />
                </asp:DropDownList>
            </td>
        </tr>
        <%--TIPO 5--%>
        <tr runat="server" id="riga5">
            <td id="TDopt5" class="Td-Text" align="right">
                <asp:RadioButton ID="opt5" runat="server" Text="" AutoPostBack="True" GroupName="TipoOsc" />
            </td>
            <td class="Td-Value">
                <span>Id Order Entry (*)</span><br />
                <asp:TextBox ID="txt5IdOrderEntry" runat="server" Width="200px" MaxLength="64" />
            </td>
            <td class="Td-Value">
                <span>Sistema erogante</span><br />
                <asp:DropDownList ID="txt5SistemaErogante" runat="server" Width="200px" AppendDataBoundItems="True" DataSourceID="odsSistemiEroganti"
                    DataTextField="Descrizione" DataValueField="Codice">
                    <asp:ListItem Text="" Value="" />
                </asp:DropDownList>
            </td>
            <td class="Td-Value" colspan="2">
                <span>Azienda erogante</span><br />
                <asp:DropDownList ID="txt5AziendaErogante" runat="server" Width="200px" AppendDataBoundItems="True" DataSourceID="odsAziende"
                    DataTextField="Descrizione" DataValueField="Codice">
                    <asp:ListItem Text="" Value="" />
                </asp:DropDownList>
            </td>
        </tr>
        <%--TIPO 9--%>
        <tr runat="server" id="riga9">
            <td id="TDopt9" class="Td-Text" align="right">
                <asp:RadioButton ID="opt9" runat="server" Text="" AutoPostBack="True" GroupName="TipoOsc" />
            </td>
            <td class="Td-Value" colspan="5">
                <span>Id Esterno Referto(*)</span><br />
                <asp:TextBox ID="txt9IdEsterno" runat="server" Width="200px" MaxLength="64" />
            </td>
        </tr>
        <tr style="height: 20px;">
            <td colspan="9" style="height: 30px; vertical-align: bottom;">Oscuramenti Massivi (bypassabili):</td>
        </tr>
        <%--TIPO 2--%>
        <tr runat="server" id="riga2">
            <td id="TDopt2" class="Td-Text" align="right">
                <asp:RadioButton ID="opt2" runat="server" Text="" AutoPostBack="True" GroupName="TipoOsc" />
            </td>
            <td class="Td-Value">
                <span>Codice Reparto Richiedente (*)</span><br />
                <asp:TextBox ID="txt2RepartoRichiedenteCodice" runat="server" Width="200px" MaxLength="16" />
            </td>
            <td class="Td-Value">
                <span>Sistema erogante</span><br />
                <asp:DropDownList ID="txt2SistemaErogante" runat="server" Width="200px" AppendDataBoundItems="True" DataSourceID="odsSistemiEroganti"
                    DataTextField="Descrizione" DataValueField="Codice">
                    <asp:ListItem Text="" Value="" />
                </asp:DropDownList>
            </td>
            <td class="Td-Value" colspan="2">
                <span>Azienda erogante</span><br />
                <asp:DropDownList ID="txt2AziendaErogante" runat="server" Width="200px" AppendDataBoundItems="True" DataSourceID="odsAziende"
                    DataTextField="Descrizione" DataValueField="Codice">
                    <asp:ListItem Text="" Value="" />
                </asp:DropDownList>
            </td>
        </tr>
        <%--TIPO 6--%>
        <tr runat="server" id="riga6">
            <td id="TDopt6" class="Td-Text" align="right">
                <asp:RadioButton ID="opt6" runat="server" Text="" AutoPostBack="True" GroupName="TipoOsc" />
            </td>
            <td class="Td-Value">
                <span>Azienda erogante (*)</span><br />
                <asp:DropDownList ID="txt6AziendaErogante" runat="server" Width="200px" AppendDataBoundItems="True" DataSourceID="odsAziende"
                    DataTextField="Descrizione" DataValueField="Codice">
                    <asp:ListItem Text="" Value="" />
                </asp:DropDownList>
                <br />
                <span>Codice Struttura erogante</span><br />
                <asp:TextBox ID="txt6StrutturaEroganteCodice" runat="server" Width="200px" MaxLength="64" />
            </td>
            <td class="Td-Value" style="vertical-align:top">
                <span>Sistema erogante (*)</span><br />
                <asp:DropDownList ID="txt6SistemaErogante" runat="server" Width="200px" AppendDataBoundItems="True" DataSourceID="odsSistemiEroganti"
                    DataTextField="Descrizione" DataValueField="Codice">
                    <asp:ListItem Text="" Value="" />
                </asp:DropDownList>
            </td>
            <td class="Td-Value" style="vertical-align:top">
                <span>Reparto erogante (*)</span><br />
                <asp:TextBox ID="txt6Repartoerogante" runat="server" Width="200px" MaxLength="64" />
            </td>
            <%--<td class="Td-Value">
                <span>Codice Struttura erogante</span><br />
                <asp:TextBox ID="txt6StrutturaEroganteCodice" runat="server" Width="200px" MaxLength="64" />
            </td>--%>
        </tr>
        <%--TIPO 7--%>
        <tr runat="server" id="riga7">
            <td id="TDopt7" class="Td-Text" align="right">
                <asp:RadioButton ID="opt7" runat="server" Text="" AutoPostBack="True" GroupName="TipoOsc" />
            </td>
            <td class="Td-Value Evidenzia">
                <span>Codice Reparto Di Ricovero (*)</span><br />
                <asp:TextBox ID="txt7RepartoRichiedenteCodice" runat="server" Width="200px" MaxLength="16" />
            </td>
            <td class="Td-Value Evidenzia">
                <span>Sistema erogante ricovero</span><br />
                <asp:DropDownList ID="ddl7SistemaErogante" runat="server" Width="200px" AppendDataBoundItems="True" DataSourceID="odsSistemiErogantiRicoveri"
                    DataTextField="Descrizione" DataValueField="Codice">
                    <asp:ListItem Text="" Value="" />
                </asp:DropDownList>

            </td>
            <td class="Td-Value Evidenzia" colspan="2">
                <span>Azienda erogante</span><br />
                <asp:DropDownList ID="ddl7AziendaErogante" runat="server" Width="200px" AppendDataBoundItems="True" DataSourceID="odsAziende"
                    DataTextField="Descrizione" DataValueField="Codice">
                    <asp:ListItem Text="" Value="" />
                </asp:DropDownList>
            </td>
        </tr>
        <%--TIPO 8--%>
        <tr runat="server" id="riga8">
            <td id="TDopt8" class="Td-Text" align="right">
                <asp:RadioButton ID="opt8" runat="server" Text="" AutoPostBack="True" GroupName="TipoOsc" />
            </td>
            <td class="Td-Value" colspan="5">
                <span>Parola per Referti(*)</span><br />
                <asp:TextBox ID="txt8Parola" runat="server" Width="200px" MaxLength="64" />
            </td>
        </tr>
        <%-- TIPO 10 - PAROLA PER EVENTO/RICOVERO--%>
        <tr runat="server" id="riga10">
            <td id="TDopt10" class="Td-Text" align="right">
                <asp:RadioButton ID="opt10" runat="server" Text="" AutoPostBack="True" GroupName="TipoOsc" />
            </td>
            <td class="Td-Value" colspan="5">
                <span>Parola per Eventi/Ricoveri(*)</span><br />
                <asp:TextBox ID="txt10Parola" runat="server" Width="200px" MaxLength="64" />
            </td>
        </tr>

        <%-- 
		
					FOOTER E PULSANTI 
					
        --%>
        <tr style="height: 20px;">
            <td></td>
            <td colspan="9">I campi contrassegnati con (*) sono obbligatori.
            </td>
        </tr>

        <tr id="lblSubTitle2" visible="False" runat="server">
            <td colspan="9">
                <asp:Label ID="lbl" runat="server" CssClass="Warning" Text="La procedura di oscuramento non è completa. Eseguire la rinotifica degli oggetti interessati." />
            </td>
        </tr>

        <tr>
            <td class="LeftFooter">
                <asp:Button ID="butElimina" runat="server" Text="Elimina" CssClass="Button" CommandName="Delete" OnClientClick="return msgboxYESNO('Si conferma l\'eliminazione dell\'elemento?');"
                    ValidationGroup="none" />
            </td>
            <td class="RightFooter" colspan="4">
                <asp:Button ID="butSalva" runat="server" Text="Ok" CssClass="Button" CommandName="Update" OnClick="butSalva_Click" />

                <asp:Button ID="btnAvanti" runat="server" Text="Avanti" CssClass="Button" />

                <asp:Button ID="butAnnulla" runat="server" CommandName="Cancel" Text="Annulla" CssClass="Button" ValidationGroup="null" />
            </td>
        </tr>
    </table>

    <asp:ObjectDataSource ID="odsDettaglio" runat="server" TypeName="OscuramentiDataSetTableAdapters.OscuramentiTableAdapter"
        SelectMethod="GetData" OldValuesParameterFormatString="{0}" DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update">
        <InsertParameters>
            <asp:Parameter Name="Titolo" Type="String" />
            <asp:Parameter Name="Note" Type="String" />
            <asp:Parameter Name="AziendaErogante" Type="String" />
            <asp:Parameter Name="SistemaErogante" Type="String" />
            <asp:Parameter Name="NumeroNosologico" Type="String" />
            <asp:Parameter Name="RepartoRichiedenteCodice" Type="String" />
            <asp:Parameter Name="NumeroPrenotazione" Type="String" />
            <asp:Parameter Name="NumeroReferto" Type="String" />
            <asp:Parameter Name="IdOrderEntry" Type="String" />
            <asp:Parameter Name="RepartoErogante" Type="String" />
            <asp:Parameter Name="StrutturaEroganteCodice" Type="String" />
            <asp:Parameter Name="TipoOscuramento" Type="Byte" />
            <asp:Parameter Name="Parola" Type="String" />
            <asp:Parameter Name="IdEsternoReferto" Type="String" />
            <asp:Parameter Name="Utente" Type="String" />
            <asp:Parameter Name="ApplicaDWH" Type="Boolean"></asp:Parameter>
            <asp:Parameter Name="ApplicaSole" Type="Boolean"></asp:Parameter>
            <asp:Parameter Name="Stato" Type="String"></asp:Parameter>
            <asp:Parameter Name="IdOscuramentoModificato" DbType="Guid" />
            <asp:Parameter Direction="InputOutput" Name="OutputId" Type="Object"></asp:Parameter>
        </InsertParameters>
        <SelectParameters>
            <asp:QueryStringParameter Name="Id" DbType="Guid" QueryStringField="Id" />
        </SelectParameters>
        <UpdateParameters>
            <asp:QueryStringParameter Name="Id" DbType="Guid" QueryStringField="Id" />
            <asp:Parameter Name="Titolo" Type="String" />
            <asp:Parameter Name="Note" Type="String" />
            <asp:Parameter Name="AziendaErogante" Type="String" />
            <asp:Parameter Name="SistemaErogante" Type="String" />
            <asp:Parameter Name="NumeroNosologico" Type="String" />
            <asp:Parameter Name="RepartoRichiedenteCodice" Type="String" />
            <asp:Parameter Name="NumeroPrenotazione" Type="String" />
            <asp:Parameter Name="NumeroReferto" Type="String" />
            <asp:Parameter Name="IdOrderEntry" Type="String" />
            <asp:Parameter Name="RepartoErogante" Type="String" />
            <asp:Parameter Name="StrutturaEroganteCodice" Type="String" />
            <asp:Parameter Name="TipoOscuramento" Type="Byte" />
            <asp:Parameter Name="Parola" Type="String" />
            <asp:Parameter Name="IdEsternoReferto" Type="String" />
            <asp:Parameter Name="Utente" Type="String" />
            <asp:Parameter Name="ApplicaDWH" Type="Boolean" />
            <asp:Parameter Name="ApplicaSole" Type="Boolean"></asp:Parameter>
            <asp:Parameter Name="Stato" Type="String"></asp:Parameter>
        </UpdateParameters>
        <DeleteParameters>
            <asp:QueryStringParameter Name="Id" DbType="Guid" QueryStringField="Id" />
        </DeleteParameters>
    </asp:ObjectDataSource>
    <asp:ObjectDataSource ID="odsAziende" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData"
        TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.AziendeErogantiListaTableAdapter" EnableCaching="False"></asp:ObjectDataSource>
    <asp:ObjectDataSource ID="odsSistemiEroganti" runat="server" SelectMethod="GetDataByAziendaETipo" TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.SistemiErogantiListaTableAdapter"
        EnableCaching="False" OldValuesParameterFormatString="{0}">
        <SelectParameters>
            <asp:Parameter Name="AziendaErogante" Type="String" />
            <asp:Parameter DefaultValue="referti" Name="Tipo" Type="String" />
        </SelectParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="odsSistemiErogantiRicoveri" runat="server" SelectMethod="GetDataByAziendaETipo" TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.SistemiErogantiListaTableAdapter"
        EnableCaching="False" OldValuesParameterFormatString="{0}">
        <SelectParameters>
            <asp:Parameter Name="AziendaErogante" Type="String" />
            <asp:Parameter DefaultValue="ricoveri" Name="Tipo" Type="String" />
        </SelectParameters>
    </asp:ObjectDataSource>


</asp:Content>
