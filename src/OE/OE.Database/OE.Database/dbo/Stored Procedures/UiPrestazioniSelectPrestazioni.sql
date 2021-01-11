

-- =============================================
-- Author:		--
-- Create date: --
-- Description: Ottiene la lista delle prestazioni
-- Modify Date: SimoneBitti - 2017-06-12: Aggiunto filtro @SistemaAttivo.
-- Modify Date: SimoneBitti - 2018-07-23: Aggiunto filtro @RichiedibileSoloDaProfilo.
-- =============================================

CREATE PROCEDURE [dbo].[UiPrestazioniSelectPrestazioni]

@ID as uniqueidentifier = NULL,
@CodiceDescrizione as varchar(max) = NULL,
@IDSistemaErogante as uniqueidentifier = NULL,
--@Tipo as tinyint =NULL,
@Attivo as bit= NULL,
@SistemaAttivo BIT = NULL,
@RichiedibileSoloDaProfilo AS BIT = NULL

AS
BEGIN
SET NOCOUNT ON

SELECT TOP 501
	 Prestazioni.ID 
	,DataInserimento
	,DataModifica
	,NULL as IDUtente
	,UtenteModifica as UserName
	,Prestazioni.Codice      
	,ISNULL(Prestazioni.Descrizione,Prestazioni.Codice)	AS Descrizione       
	,Tipo
	,Provenienza
	,IDSistemaErogante
	,CASE Tipo
		WHEN 0 THEN Sistemi.CodiceAzienda + '-' + 
			        ISNULL(Sistemi.Codice,Sistemi.Descrizione) + 
				    CASE WHEN Sistemi.Attivo = 0 THEN ' (Disattivo)' ELSE '' END
		WHEN 1 THEN '(Profilo) ' 
		WHEN 2 THEN '(Profilo) ' 
		ELSE Sistemi.CodiceAzienda + '-' + 
			ISNULL(Sistemi.Codice,Sistemi.Descrizione) +
			CASE WHEN Sistemi.Attivo = 0 THEN ' (Disattivo)' ELSE '' END		      
	 END AS SistemaErogante
	,Prestazioni.Attivo
	,Prestazioni.CodiceSinonimo
	,Prestazioni.RichiedibileSoloDaProfilo

	FROM Prestazioni 
	LEFT JOIN Sistemi ON Sistemi.ID = Prestazioni.IDSistemaErogante			

WHERE (@ID IS NULL OR Prestazioni.ID = @ID)
  AND (
		@CodiceDescrizione IS NULL OR 
		Prestazioni.Codice LIKE '%'+@CodiceDescrizione+'%' OR 
		Prestazioni.Descrizione LIKE '%'+@CodiceDescrizione+'%'
	  )
  AND (@IDSistemaErogante IS NULL OR IDSistemaErogante = @IDSistemaErogante)
  AND (@Attivo IS NULL OR Prestazioni.Attivo = @Attivo)
  --AND (@Tipo IS NULL OR Prestazioni.Tipo = @Tipo)
  AND Prestazioni.Tipo = 0
  AND (Sistemi.Attivo = @SistemaAttivo OR @SistemaAttivo IS NULL)
  AND (@RichiedibileSoloDaProfilo IS NULL OR Prestazioni.RichiedibileSoloDaProfilo = @RichiedibileSoloDaProfilo)

ORDER BY Codice


END





GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiPrestazioniSelectPrestazioni] TO [DataAccessUi]
    AS [dbo];

