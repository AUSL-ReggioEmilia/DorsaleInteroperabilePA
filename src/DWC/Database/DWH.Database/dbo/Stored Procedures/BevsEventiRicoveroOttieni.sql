



-- =============================================
-- Author:		Simone Bitti
-- Modify date: 2017-03-09
-- Description:	Ottiene un evento in base al numero nosologico e allla azienda erogante.
-- =============================================
CREATE PROCEDURE [dbo].[BevsEventiRicoveroOttieni]
(
 @NumeroNosologico VARCHAR(64),
 @AziendaErogante VARCHAR(16)
)
AS
BEGIN
  SET NOCOUNT ON

  SELECT id,
	IdPaziente,
	DataInserimento,
	DataModifica,
	AziendaErogante,
	SistemaErogante,
	RepartoErogante,
	DataEvento,
	StatoCodice,
	TipoEventoCodice,
	TipoEventoDescr,
	TipoEpisodio,
	TipoEpisodioDescr,
	NumeroNosologico
  FROM  [store].[Eventi]
  WHERE [NumeroNosologico] = @NumeroNosologico
	AND [AziendaErogante] = @AziendaErogante
  ORDER BY DataEvento ASC
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsEventiRicoveroOttieni] TO [ExecuteFrontEnd]
    AS [dbo];

