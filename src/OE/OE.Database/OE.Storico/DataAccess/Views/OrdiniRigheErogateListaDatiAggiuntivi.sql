
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2013-11-21
-- Description:	Accesso alla lista dei dati aggiuntivi delle righe dei degli ordini erogati
-- =============================================
CREATE VIEW [DataAccess].[OrdiniRigheErogateListaDatiAggiuntivi]
AS
	SELECT 
		  D.ID
		, D.IDRigaErogata
		, R.IDOrdineErogatoTestata
		, R.IDPrestazione

		--DatoAggiuntivo
		, D.Nome
		, D.TipoDato
		, D.TipoContenuto
		, D.ValoreDato
		, D.ValoreDatoVarchar
	FROM 
			dbo.OrdiniRigheErogateDatiAggiuntivi D WITH(NOLOCK) 
			INNER JOIN dbo.OrdiniRigheErogate R WITH(NOLOCK) ON D.IDRigaErogata = R.ID

