
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2013-11-21
-- Description:	Accesso alla lista dei dati aggiuntivi degli ordini
-- =============================================
CREATE VIEW [DataAccess].[OrdiniListaDatiAggiuntivi]
AS
	SELECT 
		  D.ID
		, D.IDOrdineTestata

		--DatoAggiuntivo
		, D.Nome
		, D.TipoDato
		, D.TipoContenuto
		, D.ValoreDato
		, D.ValoreDatoVarchar
	FROM 
			dbo.OrdiniTestateDatiAggiuntivi D WITH(NOLOCK) 
			INNER JOIN dbo.OrdiniTestate T WITH(NOLOCK) ON D.IDOrdineTestata = T.ID

