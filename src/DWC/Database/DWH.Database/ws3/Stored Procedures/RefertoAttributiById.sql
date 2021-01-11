


-- =============================================
-- Author:		ETTORE
-- Create date: 2016-03-22
-- Description:	Restituisce TUTTI gli attributi associati al referto @IdReferti
--				Questa SP dev essere utilizzata solo per ricavare il dettaglio del referto
--				Il controllo di accesso deve essere fatto sul record del referto per questo motivo non c'è il parametro @IdToken
-- Modify date: 2019-03-12 - ETTORE: Nel caso in cui l'attributo sia di tipo "Data" lo converto in stringa nel formato serializzabile
-- Modify date: 2020-05-18 - ETTORE: Filtro gli attributi "Persistenti" (iniziano on $@)
--									 Restituisco solo '$@NumeroVersione' con il nome 'Dwh@NumeroVersione'
--									 Aggiunto l'ordinamento per Nome
-- =============================================
CREATE PROCEDURE [ws3].[RefertoAttributiById]
(
	@IdReferti  uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT ON

	SELECT	
		IdRefertiBase 
		, CASE 
			WHEN Nome = '$@NumeroVersione' THEN 'Dwh@NumeroVersione'
			ELSE Nome END AS Nome
		, CASE WHEN SQL_VARIANT_PROPERTY(Valore, 'BaseType') IN ('datetime', 'smalldatetime', 'datetime2', 'date') THEN
			CONVERT(varchar(40) , Valore, 126) --aaaa-mm-ggThh:mi:ss.mmm
		  ELSE
			Valore
		  END AS Valore
	FROM	
		store.RefertiAttributi
	WHERE	
		IdRefertiBase = @IdReferti
		AND (
			NOT Nome like '$@%'
			OR Nome = '$@NumeroVersione'
			)
	ORDER BY Nome
END