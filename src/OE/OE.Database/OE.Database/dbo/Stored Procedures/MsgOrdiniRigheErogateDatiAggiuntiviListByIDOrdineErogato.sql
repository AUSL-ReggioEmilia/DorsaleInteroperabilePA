
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2016-08-23
-- Modify date: 
-- Description:	Ritorna i tutti i dati aggiuntivi di tutte le righe della ErogatoTestata
-- =============================================
CREATE PROCEDURE [dbo].[MsgOrdiniRigheErogateDatiAggiuntiviListByIDOrdineErogato]
  @IdOrdineErogato uniqueidentifier
 ,@IdDatoAggiuntivo varchar(64) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		oreda.ID, oreda.IDRigaErogata, oreda.IDDatoAggiuntivo
		, oreda.Nome, oreda.TipoDato, oreda.TipoContenuto
		, oreda.ValoreDato, oreda.ValoreDatoVarchar, oreda.ValoreDatoXml
		, oreda.ParametroSpecifico, oreda.Persistente

	FROM [dbo].[OrdiniRigheErogateDatiAggiuntivi] oreda
		INNER JOIN [dbo].[OrdiniRigheErogate] ore
			ON oreda.IDRigaErogata = ore.ID

	WHERE ore.IDOrdineErogatoTestata = @IDOrdineErogato
		AND (oreda.IDDatoAggiuntivo = @IDDatoAggiuntivo OR @IDDatoAggiuntivo IS NULL)
	
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[MsgOrdiniRigheErogateDatiAggiuntiviListByIDOrdineErogato] TO [DataAccessMsg]
    AS [dbo];

