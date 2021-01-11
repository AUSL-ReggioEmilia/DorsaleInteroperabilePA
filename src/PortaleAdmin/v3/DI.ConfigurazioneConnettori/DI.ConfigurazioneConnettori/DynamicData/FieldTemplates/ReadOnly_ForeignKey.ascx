<%@ Control Language="VB" CodeBehind="ReadOnly_ForeignKey.ascx.vb" Inherits="ReadOnlyForeignKeyField" %>

<!--
    
    Campo usato per mostrare le Foreign Key senza i link.
    Usate per esempio nel campo idTipologiaDatoAccessori nella Tabella DatiAccessori del Db OeGestioneOrdiniErogante.
    Senza questo field template, se nei connettori non viene gestita la tabella di join, verrebbe mostrato nella tabella "padre" un link che non naviga a nessuna pagina.

-->
<p class="form-control-static">
	<asp:Label ID="textFk" runat="server"
		Text="<%# GetDisplayString() %>" />
</p>
