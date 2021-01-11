<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="SistemiErogantiDettaglio.aspx.vb" Inherits=".SistemiErogantiDettaglio" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"></asp:Label>
    <asp:Label ID="labelTitolo" runat="server" CssClass="Title" />
    <!-- NON SI VA IN INSERIMENTO: I DATI VENGONO DAL SAC, SINCRONIZZATI CON UN JOB -->
    <asp:FormView runat="server" ID="FormViewDettaglio" DataSourceID="SistemiErogantiOds" DataKeyNames="Id">
        <EditItemTemplate>
            <table class="table_dettagli" width="500px">
                <tr>
                    <td class="Td-Text" width="150px">Id
                    </td>
                    <td class="Td-Value">
                        <asp:Label Text='<%# Eval("Id") %>' runat="server" ID="IdLabel1" />
                    </td>
                </tr>
                <tr>
                    <td class="Td-Text" width="150px">AziendaErogante
                    </td>
                    <td class="Td-Value">
                        <!-- Non editabile: viene dal SAC -->
                        <asp:Label Text='<%# Eval("AziendaErogante") %>' runat="server" ID="AziendaEroganteLabel" /><br />
                    </td>
                </tr>
                <tr>
                    <td class="Td-Text" width="150px">SistemaErogante
                    </td>
                    <td class="Td-Value">
                        <!-- Non editabile: viene dal SAC -->
                        <asp:Label Text='<%# Eval("SistemaErogante") %>' runat="server" ID="SistemaEroganteLabel" /><br />
                    </td>
                </tr>
                <tr>
                    <td class="Td-Text" width="150px">Descrizione
                    </td>
                    <td class="Td-Value">
                        <!-- Non editabile: viene dal SAC -->
                        <asp:Label Text='<%# Eval("Descrizione") %>' runat="server" ID="DescrizioneLabel" /><br />
                    </td>
                </tr>
                <tr>
                    <td class="Td-Text" width="150px">RuoloVisualizzazione
                    </td>
                    <td class="Td-Value">
                        <asp:TextBox Text='<%# Bind("RuoloVisualizzazione") %>' runat="server" ID="RuoloVisualizzazioneTextBox" />
                    </td>
                </tr>
                <tr>
                    <td class="Td-Text" width="150px">EmailControlloQualitaPassivo
                    </td>
                    <td class="Td-Value">
                        <asp:TextBox Text='<%# Bind("EmailControlloQualitaPassivo") %>' runat="server" ID="EmailControlloQualitaPassivoTextBox" />
                    </td>
                </tr>
                <tr>
                    <td class="Td-Text" width="150px">TipoReferti
                    </td>
                    <td class="Td-Value">
                        <asp:CheckBox Checked='<%# Bind("TipoReferti") %>' runat="server" ID="TipoRefertiCheckBox" />
                    </td>
                </tr>
                <tr>
                    <td class="Td-Text" width="150px">TipoRicoveri
                    </td>
                    <td class="Td-Value">
                        <asp:CheckBox Checked='<%# Bind("TipoRicoveri") %>' runat="server" ID="TipoRicoveriCheckBox" />
                    </td>
                </tr>
                <tr>
                    <td class="Td-Text" width="150px">TipoNoteAnamnestiche
                    </td>
                    <td class="Td-Value">
                        <asp:CheckBox Checked='<%# Bind("TipoNoteAnamnestiche") %>' runat="server" ID="TipoNoteAnamnesticheCheckBox" />
                    </td>
                </tr>
                <tr>
                    <td class="Td-Text" width="150px">LoginToSac
                    </td>
                    <td class="Td-Value">
                        <asp:TextBox Text='<%# Bind("LoginToSac") %>' runat="server" ID="LoginToSacTextBox" />
                    </td>
                </tr>
                <tr>
                    <td class="Td-Text" width="150px">RuoloManager
                    </td>
                    <td class="Td-Value">
                        <asp:TextBox Text='<%# Bind("RuoloManager") %>' runat="server" ID="RuoloManagerTextBox" /><br />
                    </td>
                </tr>
                 <tr>
                     <td class="Td-Text" width="150px">GeneraAnteprimaReferto
                    </td>
                    <td class="Td-Value">
                        <asp:CheckBox ID="chkGeneraAnteprimaReferto" runat="server" Checked='<%# Bind("GeneraAnteprimaReferto") %>' /><br />
                    </td>
                </tr>
                <tr>
                    <td class="LeftFooter">
                        <!--<asp:Button ID="butElimina" runat="server" Text="Elimina" CssClass="Button" CommandName="Delete" OnClientClick="return msgboxYESNO('Si conferma l\'eliminazione dell\'elemento?');"
                            ValidationGroup="none" />-->
                    </td>
                    <td class="RightFooter">
                        <asp:Button ID="butSalva" runat="server" Text="Conferma" CssClass="Button" CommandName="Update" />
                        <asp:Button ID="butAnnulla" runat="server" CommandName="Cancel" Text="Annulla" CssClass="Button" ValidationGroup="none" />
                    </td>
                </tr>
            </table>
        </EditItemTemplate>
    </asp:FormView>

    <asp:ObjectDataSource ID="SistemiErogantiOds" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetDataBy" TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.BevsSistemiErogantiTableAdapter"  DeleteMethod="Delete" UpdateMethod="Update">
        <SelectParameters>
            <asp:QueryStringParameter QueryStringField="Id" DbType="Guid" Name="Id"></asp:QueryStringParameter>
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter DbType="Guid" Name="Id"></asp:Parameter>
            <asp:Parameter Name="RuoloVisualizzazione" Type="String"></asp:Parameter>
            <asp:Parameter Name="EmailControlloQualitaPassivo" Type="String"></asp:Parameter>
            <asp:Parameter Name="TipoReferti" Type="Boolean"></asp:Parameter>
            <asp:Parameter Name="TipoRicoveri" Type="Boolean"></asp:Parameter>
            <asp:Parameter Name="TipoNoteAnamnestiche" Type="Boolean"></asp:Parameter>
            <asp:Parameter Name="LoginToSac" Type="String"></asp:Parameter>
            <asp:Parameter Name="RuoloManager" Type="String"></asp:Parameter>
            <asp:Parameter Name="GeneraAnteprimaReferto" Type="Boolean"></asp:Parameter>
        </UpdateParameters>
    </asp:ObjectDataSource>
</asp:Content>
