<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/SitePopup.Master" CodeBehind="DettaglioPrestazioniDatoAccessorio.aspx.vb" Inherits=".DettaglioPrestazioniDatoAccessorio" %>

<asp:Content ID="Content1" ContentPlaceHolderID="OrderEntryContentPlaceHolder" runat="server">
    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False" />

    <div style="width: 100%">
        <div style="width: 45%; float: left;">
            <fieldset style="height: 400px;">
                <legend>Prestazioni che comprendono il Dato Accessorio</legend>
                <div style="height: 400px; overflow-y: auto; margin-top: 10px;">
                    <asp:GridView ID="gvPrestazioniDatoAccessorio" Style="width: 100%; border: 1px silver solid;" border="1"
                        class="Grid" GridLines="none" runat="server" DataSourceID="odsPrestazioniDatoAccessorio" AutoGenerateColumns="False" DataKeyNames="IDPrestazione" >
                        <Columns>

                            <asp:TemplateField>
                                <HeaderTemplate>
                                    <asp:CheckBox ID="chkPrestazioni" AutoPostBack="true" OnCheckedChanged="chekAllPrestazioniDatoAccessorio" runat="server" />
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:CheckBox ID="chkPrestazioniDatoAccessorio" AutoPostBack="false" runat="server" />
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField>
                                <ItemTemplate>
                                    <asp:ImageButton ID="ImageButton1" class="ImageButton" BorderWidth="0px" ImageUrl="~/Images/edititem.gif" runat="server" ToolTip="modifica dati accessori" OnClientClick='<%# "ShowPopUpSistemi(""" & Me.Request.QueryString("id").ToString() & """, """ & Eval("IDPrestazione").ToString & """, """ & Eval("ID").ToString & """, """ & Eval("Descrizione").ToString() & """, """ & Eval("Codice").ToString() & """); return false;"%>' />
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%--<asp:BoundField DataField="ID" HeaderText="ID" SortExpression="ID"></asp:BoundField>--%>
                            <%--<asp:BoundField DataField="IDPrestazione" HeaderText="IDPrestazione" SortExpression="IDPrestazione"></asp:BoundField>--%>
                            <asp:BoundField DataField="Codice" HeaderText="Codice" SortExpression="Codice"></asp:BoundField>
                            <%--<asp:BoundField DataField="CodiceDatoAccessorio" HeaderText="CodiceDatoAccessorio" SortExpression="CodiceDatoAccessorio"></asp:BoundField>--%>
                            <%--<asp:BoundField DataField="IDSistemaErogante" HeaderText="IDSistemaErogante" SortExpression="IDSistemaErogante"></asp:BoundField>--%>
                            <asp:BoundField DataField="Descrizione" HeaderText="Descrizione" ReadOnly="True" SortExpression="Descrizione"></asp:BoundField>
                            <asp:BoundField DataField="SistemaErogante" HeaderText="SistemaErogante" ReadOnly="True" SortExpression="SistemaErogante"></asp:BoundField>

                            <asp:CheckBoxField DataField="Attivo" HeaderText="Attivo" ReadOnly="True" SortExpression="Attivo"></asp:CheckBoxField>
                        </Columns>
                    </asp:GridView>
                </div>
            </fieldset>
        </div>

        <div style="width: 5%; margin-top: 30px; float: left; text-align: center; height: 25px;">
            <asp:ImageButton ID="addButton"  class="ImageButton" ImageUrl="~/Images/back.gif" Text="Aggiungi" runat="server" />
            <asp:ImageButton ID="removeButton"  class="ImageButton" ImageUrl="~/Images/next.gif" Text="Aggiungi" runat="server" />
        </div>

        <div style="width: 45%; float: left">
            <fieldset style="height: 400px;">
                <legend>Prestazioni</legend>
                Codice o Descrizione:
                <asp:TextBox ID="codiceDescrizioneTxb" ToolTip="Codice o Descrizione" runat="server" />
                <asp:Button runat="server" ID="cercaBtn" Text="Cerca" />
                <div style="height: 400px; overflow-y: auto;">
                    <asp:GridView Style="width: 100%; border: 1px silver solid;" border="1"
                        class="Grid" ID="gvPrestazioni" runat="server" DataSourceID="odsPrestazioni" AutoGenerateColumns="False" DataKeyNames="ID">
                        <Columns>
                            <asp:TemplateField>
                                <HeaderTemplate>
                                    <asp:CheckBox ID="chkPrestazioni" AutoPostBack="true" OnCheckedChanged="chekAllPrestazioni" runat="server" />
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:CheckBox ID="chkPrestazioniLista" AutoPostBack="false" runat="server" />
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%--<asp:BoundField DataField="ID" HeaderText="ID" ReadOnly="True" SortExpression="ID"></asp:BoundField>--%>
                            <%--<asp:BoundField DataField="DataInserimento" HeaderText="DataInserimento" SortExpression="DataInserimento"></asp:BoundField>--%>
                            <%--<asp:BoundField DataField="DataModifica" HeaderText="DataModifica" SortExpression="DataModifica"></asp:BoundField>--%>
                            <%--<asp:BoundField DataField="IDUtente" HeaderText="IDUtente" ReadOnly="True" SortExpression="IDUtente"></asp:BoundField>--%>
                            <%--<asp:BoundField DataField="UserName" HeaderText="UserName" SortExpression="UserName"></asp:BoundField>--%>
                            <asp:BoundField DataField="Codice" HeaderText="Codice" SortExpression="Codice"></asp:BoundField>
                            <asp:BoundField DataField="Descrizione" HeaderText="Descrizione" ReadOnly="True" SortExpression="Descrizione"></asp:BoundField>
                            <%--<asp:BoundField DataField="Tipo" HeaderText="Tipo" SortExpression="Tipo"></asp:BoundField>--%>
                            <%--<asp:BoundField DataField="Provenienza" HeaderText="Provenienza" SortExpression="Provenienza"></asp:BoundField>--%>
                            <%--<asp:BoundField DataField="IDSistemaErogante" HeaderText="IDSistemaErogante" SortExpression="IDSistemaErogante"></asp:BoundField>--%>
                            <asp:BoundField DataField="SistemaErogante" HeaderText="SistemaErogante" ReadOnly="True" SortExpression="SistemaErogante"></asp:BoundField>
                            <asp:CheckBoxField DataField="Attivo" HeaderText="Attivo" SortExpression="Attivo"></asp:CheckBoxField>
                            <%--<asp:BoundField DataField="CodiceSinonimo" HeaderText="CodiceSinonimo" SortExpression="CodiceSinonimo"></asp:BoundField>--%>
                        </Columns>
                    </asp:GridView>
                </div>
            </fieldset>
        </div>
    </div>

    <div style="width: 100%;">
        <button style="float: right; margin-top: 50px;" onclick="window.parent.commonModalDialogClose(0);" class="asp_button">
            Chiudi</button>
    </div>


    <asp:ObjectDataSource ID="odsPrestazioniDatoAccessorio" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="DI.OrderEntry.Admin.Data.DatiAccessoriTableAdapters.UiDatiAccessoriPrestazioniTableAdapter">
        <SelectParameters>
            <asp:QueryStringParameter QueryStringField="id" Name="CodiceDatoAccessorio" Type="String"></asp:QueryStringParameter>
        </SelectParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="odsPrestazioni" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="DI.OrderEntry.Admin.Data.PrestazioniTableAdapters.UiPrestazioniSelectTableAdapter">
        <SelectParameters>
            <asp:Parameter DbType="Guid" Name="ID"></asp:Parameter>
            <asp:ControlParameter ControlID="codiceDescrizioneTxb" PropertyName="Text" Name="CodiceDescrizione" Type="String"></asp:ControlParameter>
            <asp:Parameter DbType="Guid" Name="IDSistemaErogante"></asp:Parameter>
            <asp:Parameter Name="Attivo" Type="Boolean"></asp:Parameter>
            <asp:Parameter Name="SistemaAttivo" Type="Boolean"></asp:Parameter>
            <asp:Parameter Name="RichiedibileSoloDaProfilo" Type="Boolean"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>

    <script type="text/javascript">
        function ShowPopUpSistemi(idDatoAccessorio, IdPrestazione, Id, descrizionePrestazione,codicePrestazione) {

            if (idDatoAccessorio == undefined || idDatoAccessorio == '') {
                commonModalDialogOpen('DettaglioAssociazionePrestazioniDatoAccessorio.aspx', '', 300, 300);
            }
            else {
                commonModalDialogOpen('DettaglioAssociazionePrestazioniDatoAccessorio.aspx?IdDatoAccessorio=' + idDatoAccessorio + '&idPrestazione=' + IdPrestazione + '&id=' + Id + '&descrizione=' + descrizionePrestazione, 'Modifica Dati Accessori Prestazione   [' + codicePrestazione + '] - ' + descrizionePrestazione, 300, 300);
            }
            return false;
        }
    </script>

</asp:Content>
