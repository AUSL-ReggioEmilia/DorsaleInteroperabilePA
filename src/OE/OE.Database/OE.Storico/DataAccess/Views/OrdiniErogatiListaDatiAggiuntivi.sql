
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2013-11-21
-- Description:	Accesso alla lista dei dati aggiuntivi ordini erogati
-- =============================================
CREATE VIEW [DataAccess].[OrdiniErogatiListaDatiAggiuntivi]
AS
	SELECT 
		  D.ID
		, D.IDOrdineErogatoTestata

		--DatoAggiuntivo
		, D.Nome
		, D.TipoDato
		, D.TipoContenuto
		, D.ValoreDato
		, D.ValoreDatoVarchar
	FROM 
			dbo.OrdiniErogatiTestateDatiAggiuntivi D WITH(NOLOCK) 
			INNER JOIN dbo.OrdiniErogatiTestate T WITH(NOLOCK) ON D.IDOrdineErogatoTestata = T.ID

