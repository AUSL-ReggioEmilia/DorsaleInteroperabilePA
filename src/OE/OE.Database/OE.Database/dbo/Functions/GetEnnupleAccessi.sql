

-- =============================================
-- Author:		Alessandro Nostini
-- Modify date: 2013-10-08
-- Modify date: 2014-10-01 Sandro - Controlla anche i gruppi di AD sul SAC
-- Description:	Ritorna un elenco delle ennupre accessi dell'utente
-- =============================================
CREATE FUNCTION [dbo].[GetEnnupleAccessi]
(
	  @Utente varchar(64)
	, @idStato tinyint = 1
)
RETURNS @Result TABLE (IDSistemaErogante uniqueidentifier, [R] bit NOT NULL, [I] bit NOT NULL, [S] bit NOT NULL, [Not] bit NOT NULL) 
AS
BEGIN

	INSERT INTO @Result
		SELECT e.[IDSistemaErogante]
			  ,e.[R]
			  ,e.[I]
			  ,e.[S]
			  ,e.[Not]
		FROM [dbo].[EnnupleAccessi] e
		WHERE
			-- Per tutti o per un gruppo specifico
			( e.IDGruppoUtenti IS NULL
				OR e.IDGruppoUtenti IN (SELECT ID FROM [dbo].[GetGruppiOePerUtente](@Utente))
			)
			-- Per stato dell aEnnupla
			AND e.[IDStato] = @idStato
	RETURN 
END

