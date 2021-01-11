



-- =============================================
-- Author:		Simone Bitti
-- Modify date: 2017-03-09
-- Description:	Ottiene gli attributi di un ricovero in base all'id del Ricovero.
-- =============================================
CREATE PROCEDURE [dbo].[BevsAttributiRicoveroOttieni]
(
 @IdRicovero UNIQUEIDENTIFIER
)
AS
BEGIN
  SET NOCOUNT OFF

  SELECT IdRicoveriBase,
	Nome,
	Valore,
	DataPartizione
  FROM  [store].[RicoveriAttributi]
  WHERE [IdRicoveriBase] = @IdRicovero
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsAttributiRicoveroOttieni] TO [ExecuteFrontEnd]
    AS [dbo];

